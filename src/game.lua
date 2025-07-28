local UserInputService = game:GetService("UserInputService")

local InputLib = require(script.Parent.Parent.InputLib)
local cooldown = require(script.Parent.Parent.cooldown)
local stdlib = require(script.Parent.Parent.stdlib)
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

	Moving: boolean,

	MoveStopConnection: RBXScriptConnection?,

	ControlThread: thread,
}

export type Game = typeof(setmetatable({} :: GameStruct, { __index = Game }))

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
	self.Player:Destroy()
	self.DestroyingEvent:Destroy()
end

local function showAnimation(self: Game, animationName: string)
	if self.MoveTween then
		self.MoveTween:Destroy()
		self.MoveTween = nil -- set to nil for this IF can working
	else
		print("bbb")
	end

	self.Player:SetAnimation(animationName)
end

function Game.IDLE(self: Game)
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

function Game.LeftUp(self: GameStruct)
	Game.Move(self, -0.5, 0.5)
end

function Game.LeftDown(self: GameStruct)
	Game.Move(self, -0.5, -0.5)
end

function Game.RightUp(self: GameStruct)
	Game.Move(self, 0.5, 0.5)
end

function Game.RightDown(self: GameStruct)
	Game.Move(self, 0.5, -0.5)
end

function Game.Move(self: GameStruct, X: number, Y: number)
	if not self.Moving then
		self.Moving = true

		if self.MoveStopConnection then
			self.MoveStopConnection:Disconnect()
		end

		if self.MoveTween then
			self.MoveTween:Destroy()
			self.MoveTween = nil -- set to nil for this IF can working
		end

		self.CollideMutex:wait()

		self.MoveTween =
			self.Player:WalkMove(X, Y, self.Map.Image, self.CooldownTime)

		if self.MoveTween then
			self.MoveTween:Play()
			self.Moving = false
		end

		self.MoveStopConnection = self.MoveTween.Completed:Connect(
			function(a0: Enum.PlaybackState)
				self.Player:StopAnimation()
			end
		)
	end
end

--[[
	Set current map
]]
function Game.SetMap(self: Game, newMap: map.Map)
	self.Map:Done(self.Player)
	self.Map = newMap
	newMap:Init(self.Player, self.Frame)
end

--[[
	Set player
]]
function Game.SetPlayer(self: Game, newPlayer: player.Player2d)
	self.Map:SetPlayer(newPlayer, self.Player)
	self.Player = newPlayer
end

--[[
	Loading game
]]
function Game.Loading(self: Game)
	local DoneEvent = Instance.new("BindableEvent")
	local Progress = Instance.new("NumberValue")

	task.spawn(function()
		self.Map:Loading(Progress)
		DoneEvent:Fire()
	end)

	local a = setmetatable({
		Wait = function()
			print(Progress.Value)
			if Progress.Value < 1 then
				DoneEvent.Event:Wait()
			end
		end,
	}, { __index = DoneEvent.Event })

	DoneEvent.Destroying:Connect(function(_: any)
		table.clear(a)
	end)

	return {
		Done = a,
		Progress = Progress,
		DoneEvent = DoneEvent,
	}
end

--[[
	Start game
]]
function Game.Start(self: Game)
	self.ControlThread = task.spawn(function()
		-- Keyboard controls

		local Up = InputLib.WhileKeyPressed(task.wait, {
			defaultControls.Keyboard.Up,
			defaultControls.Gamepad.Up,
			Enum.KeyCode.Up,
		})

		local Down = InputLib.WhileKeyPressed(task.wait, {
			defaultControls.Keyboard.Down,
			defaultControls.Gamepad.Down,
			Enum.KeyCode.Down,
		})

		local Right = InputLib.WhileKeyPressed(task.wait, {
			defaultControls.Keyboard.Right,
			defaultControls.Gamepad.Right,
			Enum.KeyCode.Right,
		})

		local Left = InputLib.WhileKeyPressed(task.wait, {
			defaultControls.Keyboard.Left,
			defaultControls.Gamepad.Left,
			Enum.KeyCode.Left,
		})

		local Move = cooldown.new(
			self.CooldownTime,
			function(_self, XPos: number?, YPos: number?)
				if Up.State.Value and Right.State.Value then --	Right Up
					Game.RightUp(_self)
				elseif Down.State.Value and Right.State.Value then -- Right Down
					Game.RightDown(_self)
				elseif Down.State.Value and Left.State.Value then --	Left Down
					Game.LeftDown(_self)
				elseif Up.State.Value and Left.State.Value then --	Left Up
					Game.LeftUp(_self)
				elseif Up.State.Value then --	Up
					Game.Up(_self)
				elseif Down.State.Value then --	Down
					Game.Down(_self)
				elseif Left.State.Value then --	Left
					Game.Left(_self)
				elseif Right.State.Value then --	Right
					Game.Right(_self)
				elseif YPos and XPos then
					Game.Move(_self, XPos, YPos)
				else
					warn(
						"No key pressed and positions of X and Y are not indicated"
					)
				end
			end
		)

		table.insert(self.DestroyableObjects, Up)
		table.insert(self.DestroyableObjects, Down)
		table.insert(self.DestroyableObjects, Left)
		table.insert(self.DestroyableObjects, Right)

		local KeyboardMoveEvent = stdlib.events.AnyEvent({
			Up.Called,
			Down.Called,
			Right.Called,
			Left.Called,
		})

		KeyboardMoveEvent.Event:Connect(function(...: any)
			Move(self)
		end)

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
			while GamepadThumbStick1.Changed:Wait() do -- не через Changed потому, что Есть CollideMutex и его нужно ждать
				Move(
					self,
					GamepadThumbStick1.Value.X,
					GamepadThumbStick1.Value.Y
				)
			end
		end)

		-- other

		stdlib.events.AnyEvent({
			KeyboardMoveEvent.Event,
			GamepadThumbStick1.Changed,
		}, self.Player.MoveEvent)

		local IdleRun = cooldown.new(4, function(...)
			self:IDLE()
		end)

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

		self.CollideSteped:Connect(function()
			self.CollideMutex:lock()
			self.Map:CalcCollide()
			self.CollideMutex:unlock()
		end)

		self.CollideStepedEvent.Event:Connect(function()
			self.Map:CalcZIndexs()
		end)

		self.Destroying:Connect(function()
			task.cancel(IDLE_show_thread)
			task.cancel(GamepadControlThread)
			IdleRun:Destroy()
			GamepadThumbStick1:Destroy()
		end)
	end)
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
		CooldownTime = cooldownTime or 0.1,
		DestroyableObjects = {},
		Connections = {},
		MoveTween = nil,
		CollideMutex = mutex.new(true),
		Moving = false,
		ControlThread = nil,
	}

	self.Player:SetParent(self.Frame)

	self.Map:Init(self.Player, self.Frame)

	setmetatable(self, { __index = Game })

	showAnimation(self, "IDLE")

	return self
end

return Game
