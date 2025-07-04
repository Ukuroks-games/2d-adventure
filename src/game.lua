local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local InputLib = require(ReplicatedStorage.Packages.InputLib)
local cooldown = require(ReplicatedStorage.Packages.cooldown)
local stdlib = require(ReplicatedStorage.Packages.stdlib)
local mutex = stdlib.mutex

local defaultControls = require(script.Parent.defaultControls)
local map = require(script.Parent.map)
local player = require(script.Parent.player)

--[[
	Класс игры
]]
local Game = {}

export type GameStruct = {
	--[[
		Game background
	]]
	Frame: Frame,

	--[[
		Player
	]]
	Player: player.Player2d,

	--[[
		Map
	]]
	Map: map.Map,

	--[[
		Sent on physic step end
	]]
	CollideSteped: RBXScriptSignal,

	--[[
	
	]]
	Destroying: RBXScriptSignal,

	--[[
	
	]]
	CooldownTime: number,

	--[[
		List of objects that will be destroyed on Destroy call
	]]
	DestroyableObjects: {},

	--[[
	
	]]
	Connections: { RBXScriptConnection },

	--[[
	
	]]
	DestroyingEvent: BindableEvent,

	--[[
	
	]]
	CollideStepedEvent: BindableEvent,

	MoveTween: Tween,

	CollideMutex: mutex.Mutex,
}

export type Game = GameStruct & typeof(Game)

--[[

]]
function Game.Destroy(self: GameStruct)
	self.DestroyingEvent:Fire()

	for _, v in pairs(self.DestroyableObjects) do
		if v then
			v:Destroy()
		end
	end

	for _, v in pairs(self.Connections) do
		if v then
			v:Disconnect()
		end
	end

	self.Frame:Destroy()
	self.CollideStepedEvent:Destroy()
	player.Destroy(self.Player)
	self.DestroyingEvent:Destroy()
end

local function showAnimation(self: GameStruct, animationName: string)
	if
		self.Player.CurrentAnimation.AnimationRunning
		and self.Player.CurrentAnimation.AnimationRunning
			~= self.Player.Animations[animationName]
	then
		if self.MoveTween then
			self.MoveTween:Cancel()
			self.MoveTween:Destroy()
			self.MoveTween = nil -- set to nil for this IF can working
		end

		self.Player.CurrentAnimation:StopAnimation()
		self.Player.CurrentAnimation:Hide()
	end

	self.Player.Animations[animationName]:StartAnimation()

	self.Player.CurrentAnimation = self.Player.Animations[animationName]
end

function Game.IDLE(self: GameStruct)
	showAnimation(self, "IDLE")
end

function Game.Up(self: GameStruct)
	Game.Move(self, 0, 1)
end

function Game.Down(self: GameStruct)
	Game.Move(self, 0, -1)
end

function Game.Left(self: GameStruct)
	Game.Move(self, -1, 0)
end

function Game.Right(self: GameStruct)
	Game.Move(self, 1, 0)
end

function Game.Move(self: GameStruct, X: number, Y: number)
	self.CollideMutex:wait()
	local touchedSide = self.Player:GetTouchedSide()

	X = -X

	if
		((X < 0) and (touchedSide.Right == true))
		or ((X > 0) and (touchedSide.Left == true))
	then
		X = 0
	end

	if
		((Y > 0) and (touchedSide.Up == true))
		or ((Y < 0) and (touchedSide.Down == true))
	then
		Y = 0
	end

	if math.abs(X / Y) > 1 then -- X bigger
		if X > 0 then
			showAnimation(self, "WalkLeft")
		else
			showAnimation(self, "WalkRight")
		end
	else -- Y bigger
		if Y > 0 then
			showAnimation(self, "WalkUp")
		else
			showAnimation(self, "WalkDown")
		end
	end

	self.MoveTween = TweenService:Create(
		self.Map.Image.ImageInstance,
		TweenInfo.new(self.CooldownTime),
		{
			["Position"] = UDim2.new(
				UDim.new(
					self.Map.Image.Position.X.Scale
						+ (X * self.Player.WalkSpeed),
					self.Map.Image.Position.X.Offset
				),
				UDim.new(
					self.Map.Image.Position.Y.Scale
						+ (Y * self.Player.WalkSpeed),
					self.Map.Image.Position.Y.Offset
				)
			),
		}
	)

	self.MoveTween:Play()
end

function Game.SetMap(self: Game, newMap: map.Map)
	self.Map:Done(self.Player)
	self.Map = newMap
	newMap:Init(self.Player, self.Frame)
end

function Game.SetPlayer(self: Game, newPlayer: player.Player2d)
	self.Map:SetPlayer(newPlayer, self.Player)
	self.Player = newPlayer
end

--[[
	Game constructor
]]
function Game.new(
	GameFrame: Frame,
	Player: player.Player2d,
	Map: map.Map,
	cooldownTime: number?
): Game
	local DestroyingEvent = Instance.new("BindableEvent")
	local CollideStepedEvent = Instance.new("BindableEvent")

	local self: GameStruct = {
		Frame = GameFrame,
		Player = Player,
		Map = Map,
		Destroying = DestroyingEvent.Event,
		DestroyingEvent = DestroyingEvent,
		CollideSteped = CollideStepedEvent.Event,
		CollideStepedEvent = CollideStepedEvent,
		CooldownTime = cooldownTime or 0.012,
		DestroyableObjects = {},
		Connections = {},
		MoveTween = nil,
		CollideMutex = mutex.new(true),
	}

	self.Player:SetParent(self.Frame)

	self.Map:Init(self.Player, self.Frame)

	self.Player.Animations.IDLE:StartAnimation()

	-- Keyboard controls

	local Up = cooldown.new(self.CooldownTime, Game.Up)

	local Down = cooldown.new(self.CooldownTime, Game.Down)

	local Left = cooldown.new(self.CooldownTime, Game.Left)

	local Right = cooldown.new(self.CooldownTime, Game.Right)

	local Move = cooldown.new(self.CooldownTime, Game.Move)

	table.insert(self.DestroyableObjects, Up)
	table.insert(self.DestroyableObjects, Down)
	table.insert(self.DestroyableObjects, Left)
	table.insert(self.DestroyableObjects, Right)

	table.insert(
		self.DestroyableObjects,
		InputLib.WhileKeyPressed(function()
			Up(self)
		end, {
			defaultControls.Keyboard.Up,
			defaultControls.Gamepad.Up,
			Enum.KeyCode.Up,
		})
	)

	table.insert(
		self.DestroyableObjects,
		InputLib.WhileKeyPressed(function()
			Down(self)
		end, {
			defaultControls.Keyboard.Down,
			defaultControls.Gamepad.Down,
			Enum.KeyCode.Down,
		})
	)

	table.insert(
		self.DestroyableObjects,
		InputLib.WhileKeyPressed(function()
			Left(self)
		end, {
			defaultControls.Keyboard.Left,
			defaultControls.Gamepad.Left,
			Enum.KeyCode.Left,
		})
	)

	table.insert(
		self.DestroyableObjects,
		InputLib.WhileKeyPressed(function()
			Right(self)
		end, {
			defaultControls.Keyboard.Right,
			defaultControls.Gamepad.Right,
			Enum.KeyCode.Right,
		})
	)

	-- gamepad input

	local GamepadThumbStick1 = Instance.new("Vector3Value")

	table.insert(
		self.Connections,
		UserInputService.InputChanged:Connect(
			function(input: InputObject, a1: boolean)
				if input.KeyCode == Enum.KeyCode.Thumbstick1 then
					GamepadThumbStick1.Value = input.Position
				end
			end
		)
	)

	local GamepadControlThread = task.spawn(function()
		while GamepadThumbStick1.Changed:Wait() do -- не через changed потому, что Есть CollideMutex и его нужно ждать
			Move(self, GamepadThumbStick1.Value.X, GamepadThumbStick1.Value.Y)
		end
	end)

	-- other

	stdlib.events.AnyEvent({
		Up.CallEvent.Event,
		Down.CallEvent.Event,
		Right.CallEvent.Event,
		Left.CallEvent.Event,
		GamepadThumbStick1.Changed,
	}, self.Player.MoveEvent)

	local IdleRun = cooldown.new(4, Game.IDLE)
	stdlib.events.AnyEvent({
		self.Map.ObjectMovement,
		self.Player.Move,
	}, self.CollideStepedEvent)

	--[[
		
	]]
	local IDLE_show_thread = task.spawn(function()
		--[[
			Кароч как оно рабтает:

			Когда игрок надижает клавищу начинаем отсчет времени.

			Если во время ожидания была нажата ещё клавиша, то сбрасываем ожидание и ждем следующего.

			> При длительном зажатии получается что что цикл посторяется, что может созданить проблемы с производительностью
		]]

		local t

		self.Player.Move:Connect(function()
			if t then
				task.cancel(t)
			end
		end)

		self.Player.Move:Connect(function()
			t = task.spawn(function()
				wait(4)

				IdleRun(self)
			end)
		end)
	end)

	CollideStepedEvent.Event:Connect(function()
		self.Map:CalcCollide()
		self.CollideMutex:unlock()
	end)

	self.Destroying:Connect(function()
		task.cancel(IDLE_show_thread)
		task.cancel(GamepadControlThread)
		IdleRun:Destroy()
		GamepadThumbStick1:Destroy()
	end)

	setmetatable(self, { __index = Game })

	return self
end

return Game
