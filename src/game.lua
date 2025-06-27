local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Object2d = require(script.Parent.Object2d)
local InputLib = require(ReplicatedStorage.Packages.InputLib)
local cooldown = require(ReplicatedStorage.Packages.cooldown)
local stdlib = require(ReplicatedStorage.Packages.stdlib)
local mutex = stdlib.mutex

local defaultControls = require(script.Parent.defaultControls)
local map = require(script.Parent.map)
local physicObject = require(script.Parent.physicObject)
local player = require(script.Parent.player)

--[[
	Класс игры
]]
local Game = {}

export type Game = {
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
	
	]]
	Destroy: (self: Game) -> nil,

	--[[
		Player IDLE
	]]
	IDLE: (self: Game) -> nil,

	--[[
		Player move to up
	]]
	Up: (self: Game) -> nil,

	--[[
		Player move to down
	]]
	Down: (self: Game) -> nil,

	--[[
		Player move to Left
	]]
	Left: (self: Game) -> nil,

	--[[
		Player move to Right
	]]
	Right: (self: Game) -> nil,

	--[[
		List of objects that will be destroyed on Destroy call
	]]
	DestroyableObjects: {},

	Connections: { RBXScriptConnection },

	--[[
	
	]]
	DestroyingEvent: BindableEvent,

	--[[
	
	]]
	CollideStepedEvent: BindableEvent,

	MoveTween: Tween,

	CollideMutex: mutex.Mutex,
} & typeof(Game)

--[[

]]
function Game.Destroy(self: Game)
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

local function showAnimation(self: Game, animationName: string)
	if
		self.Player.CurrentAnimation.AnimationRunning
		and self.Player.CurrentAnimation.AnimationRunning
			~= self.Player.Animations[animationName]
	then
		if self.MoveTween then
			self.MoveTween:Cancel()
			self.MoveTween:Destroy()
			self.MoveTween = nil
		end

		self.Player.CurrentAnimation:StopAnimation()
		self.Player.CurrentAnimation:Hide()
	end

	self.Player.Animations[animationName]:StartAnimation()

	self.Player.CurrentAnimation = self.Player.Animations[animationName]
end

function Game.IDLE(self: Game)
	showAnimation(self, "IDLE")
end

function Game.Up(self: Game)
	self.CollideMutex:wait()
	showAnimation(self, "WalkUp")

	if self.Player:GetTouchedSide().Up ~= true then
		self.MoveTween = TweenService:Create(
			self.Map.Image.ImageInstance,
			TweenInfo.new(self.CooldownTime),
			{
				["Position"] = UDim2.new(
					self.Map.Image.Position.X,
					UDim.new(
						self.Map.Image.Position.Y.Scale + self.Player.WalkSpeed,
						self.Map.Image.Position.Y.Offset
					)
				),
			}
		)

		self.MoveTween:Play()
	end
end

function Game.Down(self: Game)
	self.CollideMutex:wait()
	showAnimation(self, "WalkDown")

	if self.Player:GetTouchedSide().Down ~= true then
		self.MoveTween = TweenService:Create(
			self.Map.Image.ImageInstance,
			TweenInfo.new(self.CooldownTime),
			{
				["Position"] = UDim2.new(
					self.Map.Image.Position.X,
					UDim.new(
						self.Map.Image.Position.Y.Scale - self.Player.WalkSpeed,
						self.Map.Image.Position.Y.Offset
					)
				),
			}
		)
		self.MoveTween:Play()
	end
end

function Game.Left(self: Game)
	self.CollideMutex:wait()
	showAnimation(self, "WalkLeft")

	if self.Player:GetTouchedSide().Left ~= true then
		self.MoveTween = TweenService:Create(
			self.Map.Image.ImageInstance,
			TweenInfo.new(self.CooldownTime),
			{
				["Position"] = UDim2.new(
					UDim.new(
						self.Map.Image.Position.X.Scale + self.Player.WalkSpeed,
						self.Map.Image.Position.X.Offset
					),
					self.Map.Image.Position.Y
				),
			}
		)

		self.MoveTween:Play()
	end
end

function Game.Right(self: Game)
	self.CollideMutex:wait()
	showAnimation(self, "WalkRight")

	if self.Player:GetTouchedSide().Right ~= true then
		self.MoveTween = TweenService:Create(
			self.Map.Image.ImageInstance,
			TweenInfo.new(self.CooldownTime),
			{
				["Position"] = UDim2.new(
					UDim.new(
						self.Map.Image.Position.X.Scale - self.Player.WalkSpeed,
						self.Map.Image.Position.X.Offset
					),
					self.Map.Image.Position.Y
				),
			}
		)

		self.MoveTween:Play()
	end
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

	local self = {
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

	setmetatable(self, { __index = Game })

	self.Map.Image.Parent = self.Frame
	self.Player.Image.Parent = self.Frame

	table.insert(self.Map.Objects, self.Player) -- add player to objects for enable collision for player

	self.Map:SetPlayerPosition(self.Player, self.Map.StartPosition)

	--[[
		обёртка для self.Map:CalcPositions
	]]
	local function CalcPositions()
		self.Map:CalcPositions()
	end

	CalcPositions() -- превоночальный расет

	--[[
		расчет после изменения фрейма игры
	]]
	self.Frame:GetPropertyChangedSignal("Size"):Connect(CalcPositions)

	self.Player.Animations.IDLE:SetFrame(1) -- set first IDLE frame as default

	local Up = cooldown.new(self.CooldownTime, self.Up)

	local Down = cooldown.new(self.CooldownTime, self.Down)

	local Left = cooldown.new(self.CooldownTime, self.Left)

	local Right = cooldown.new(self.CooldownTime, self.Right)

	table.insert(self.DestroyableObjects, Up)
	table.insert(self.DestroyableObjects, Down)
	table.insert(self.DestroyableObjects, Left)
	table.insert(self.DestroyableObjects, Right)

	table.insert(
		self.DestroyableObjects,
		InputLib.WhileKeyPressed(function()
			self.CollideMutex:lock()
			Up:Call(self)
		end, {
			defaultControls.Keyboard.Up,
			defaultControls.Gamepad.Up,
		})
	)

	table.insert(
		self.DestroyableObjects,
		InputLib.WhileKeyPressed(function()
			self.CollideMutex:lock()
			Down(self)
		end, {
			defaultControls.Keyboard.Down,
			defaultControls.Gamepad.Down,
		})
	)

	table.insert(
		self.DestroyableObjects,
		InputLib.WhileKeyPressed(function()
			self.CollideMutex:lock()
			Left(self)
		end, {
			defaultControls.Keyboard.Left,
			defaultControls.Gamepad.Left,
		})
	)

	table.insert(
		self.DestroyableObjects,
		InputLib.WhileKeyPressed(function()
			self.CollideMutex:lock()
			Right(self)
		end, {
			defaultControls.Keyboard.Right,
			defaultControls.Gamepad.Right,
		})
	)

	stdlib.events.AnyEvent({
		Up.CallEvent.Event,
		Down.CallEvent.Event,
		Right.CallEvent.Event,
		Left.CallEvent.Event,
	}, self.Player.MoveEvent)

	local IdleRun = cooldown.new(4, self.IDLE)
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
		IdleRun:Destroy()
	end)

	return self
end

return Game
