--!strict

local Players = game:GetService("Players")

local PlayerModule =
	require(Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))

local InputLib = require(script.Parent.Parent.InputLib)
local cooldown = require(script.Parent.Parent.cooldown)
local stdlib = require(script.Parent.Parent.stdlib)
local mutex = stdlib.mutex

local ControlType = require(script.Parent.ControlType)
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
	CollideStepped: RBXScriptSignal<>,

	--[[
	
	]]
	Destroying: RBXScriptSignal<>,

	--[[
	
	]]
	CooldownTime: number,

	--[[
		List of objects that will be destroyed on Destroy call
	]]
	DestroyableObjects: {
		Up: InputLib.WhileKeyPressedController?,
		Down: InputLib.WhileKeyPressedController?,
		Right: InputLib.WhileKeyPressedController?,
		Left: InputLib.WhileKeyPressedController?,
		Gamepad: InputLib.WhileKeyPressedController?,

		[any]: any,
	},

	--[[
	
	]]
	Connections: { RBXScriptConnection },

	--[[
	
	]]
	DestroyingEvent: BindableEvent,

	--[[
	
	]]
	CollideSteppedEvent: BindableEvent<>,

	MoveTween: Tween?,

	CollideMutex: stdlib.Mutex,

	Moving: boolean,

	ControlThread: thread?,

	ControllerSettings: ControlType.Control,
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
	self.CollideSteppedEvent:Destroy()
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
	showAnimation(
		self,
		"IDLE"
			.. stdlib.algorithm.GetIndexs(self.Player.Animations.IDLE)[math.random(
				#self.Player.Animations.IDLE
			)]
	)
end

function Game.Up(self: Game)
	Game.Move(self, 0, 1)
end

function Game.Down(self: Game)
	Game.Move(self, 0, -1)
end

function Game.Left(self: Game)
	Game.Move(self, -1, 0)
end

function Game.Right(self: Game)
	Game.Move(self, 1, 0)
end

function Game.LeftUp(self: Game)
	Game.Move(self, -1, 1)
end

function Game.LeftDown(self: Game)
	Game.Move(self, -1, -1)
end

function Game.RightUp(self: Game)
	Game.Move(self, 1, 1)
end

function Game.RightDown(self: Game)
	Game.Move(self, 1, -1)
end

--[[
	Move player
]]
function Game.Move(self: Game, X: number, Y: number)
	if not self.Moving then
		self.Moving = true

		if self.MoveTween then
			self.MoveTween:Destroy()
			self.MoveTween = nil -- set to nil for this IF can working
		end

		self.CollideMutex:wait()

		self.MoveTween =
			self.Player:WalkMove(X, Y, self.Map.Image, self.CooldownTime)

		if self.MoveTween then
			self.MoveTween:Play()
		end

		self.Moving = false
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
		Wait = function(_)
			print(Progress.Value)
			if Progress.Value < 1 then
				DoneEvent.Event:Wait()
			end
		end,
	}, { __index = DoneEvent.Event })

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
		self.Player:SetAnimation("IDLE")

		-- Keyboard controls

		local function w(_: InputObject, _: boolean): boolean
			task.wait()
			return true
		end

		self.DestroyableObjects.Up = InputLib.WhileKeyPressed(w, {
			self.ControllerSettings.Keyboard.Up,
			self.ControllerSettings.Gamepad.Up,
			Enum.KeyCode.Up,
		})

		self.DestroyableObjects.Down = InputLib.WhileKeyPressed(w, {
			self.ControllerSettings.Keyboard.Down,
			self.ControllerSettings.Gamepad.Down,
			Enum.KeyCode.Down,
		})

		self.DestroyableObjects.Right = InputLib.WhileKeyPressed(w, {
			self.ControllerSettings.Keyboard.Right,
			self.ControllerSettings.Gamepad.Right,
			Enum.KeyCode.Right,
		})

		self.DestroyableObjects.Left = InputLib.WhileKeyPressed(w, {
			self.ControllerSettings.Keyboard.Left,
			self.ControllerSettings.Gamepad.Left,
			Enum.KeyCode.Left,
		})

		-- gamepad input

		local GamepadThumbStick1 = Instance.new("Vector3Value")

		self.DestroyableObjects.Gamepad = InputLib.WhileKeyPressed(
			function(InputObject: InputObject, a1: boolean)
				if
					Players.LocalPlayer.Character.Humanoid.MoveDirection
					~= Vector3.new()
				then
					GamepadThumbStick1.Value = PlayerModule:GetControls()
						:GetMoveVector()
					return true
				end

				return false
			end,
			{
				Enum.KeyCode.Thumbstick1,
				Enum.KeyCode.Unknown,
			}
		)

		if
			self.DestroyableObjects.Up
			and self.DestroyableObjects.Down
			and self.DestroyableObjects.Right
			and self.DestroyableObjects.Left
			and self.DestroyableObjects.Gamepad
		then
			local function Move(_self: Game, XPos: number?, YPos: number?)
				self.CollideSteppedEvent:Fire()
				if
					self.DestroyableObjects.Up.State.Value
					and self.DestroyableObjects.Right.State.Value
				then --	Right Up
					Game.RightUp(_self)
				elseif
					self.DestroyableObjects.Down.State.Value
					and self.DestroyableObjects.Right.State.Value
				then -- Right Down
					Game.RightDown(_self)
				elseif
					self.DestroyableObjects.Down.State.Value
					and self.DestroyableObjects.Left.State.Value
				then --	Left Down
					Game.LeftDown(_self)
				elseif
					self.DestroyableObjects.Up.State.Value
					and self.DestroyableObjects.Left.State.Value
				then --	Left Up
					Game.LeftUp(_self)
				elseif self.DestroyableObjects.Up.State.Value then --	Up
					Game.Up(_self)
				elseif self.DestroyableObjects.Down.State.Value then --	Down
					Game.Down(_self)
				elseif self.DestroyableObjects.Left.State.Value then --	Left
					Game.Left(_self)
				elseif self.DestroyableObjects.Right.State.Value then --	Right
					Game.Right(_self)
				elseif YPos and XPos then
					Game.Move(_self, XPos, YPos)
				else
					warn(
						"No key pressed and positions of X and Y are not indicated"
					)
				end
			end

			stdlib.events.AnyEvent({
				self.DestroyableObjects.Up.Called,
				self.DestroyableObjects.Down.Called,
				self.DestroyableObjects.Right.Called,
				self.DestroyableObjects.Left.Called,
			}).Event:Connect(function(_: any)
				Move(self)
			end)

			self.DestroyableObjects.Gamepad.Called:Connect(function(_: any)
				Move(
					self,
					GamepadThumbStick1.Value.X,
					-GamepadThumbStick1.Value.Z
				)
			end)

			-- other

			stdlib.events.AnyEvent({
				self.Map.ObjectMovement,
				self.Player.Move,
			}, self.CollideSteppedEvent)

			--[[

			]]
			local IDLE_show_thread = task.spawn(function()
				--[[
					Короче как оно работает:

					Когда игрок нажимает клавишу начинаем отсчет времени.

					Если во время ожидания была нажата ещё клавиша, то сбрасываем ожидание и ждем следующего.

					> При длительном зажатии получается что что цикл повторяется, что может создать проблемы с производительностью
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

						self:IDLE()
					end)
				end)
			end)

			self.CollideStepped:Connect(function()
				self.CollideMutex:lock()
				self.Map:CalcCollide()
				self.CollideMutex:unlock()
			end)

			self.CollideStepped:Connect(function()
				self.Map:CalcZIndexs()
			end)

			self.Destroying:Connect(function()
				task.cancel(IDLE_show_thread)
				GamepadThumbStick1:Destroy()
			end)
		end
	end)
end

function Game.Pause(self: Game)
	if self.DestroyableObjects.Up then
		self.DestroyableObjects.Up.Pause()
	end
	if self.DestroyableObjects.Down then
		self.DestroyableObjects.Down.Pause()
	end
	if self.DestroyableObjects.Left then
		self.DestroyableObjects.Left.Pause()
	end
	if self.DestroyableObjects.Right then
		self.DestroyableObjects.Right.Pause()
	end
	if self.DestroyableObjects.Gamepad then
		self.DestroyableObjects.Gamepad.Pause()
	end
end

function Game.Resume(self: Game)
	if self.DestroyableObjects.Up then
		self.DestroyableObjects.Up.Resume()
	end
	if self.DestroyableObjects.Down then
		self.DestroyableObjects.Down.Resume()
	end
	if self.DestroyableObjects.Left then
		self.DestroyableObjects.Left.Resume()
	end
	if self.DestroyableObjects.Right then
		self.DestroyableObjects.Right.Resume()
	end
	if self.DestroyableObjects.Gamepad then
		self.DestroyableObjects.Gamepad.Resume()
	end
end

--[[
	Game constructor
]]
function Game.new(
	GameFrame: Frame,
	Player: player.Player2d,
	Map: map.Map,
	cooldownTime: number?,
	controllerSettings: ControlType.Control?
): Game
	local DestroyingEvent = Instance.new("BindableEvent")
	local CollideSteppedEvent = Instance.new("BindableEvent")

	local self: GameStruct = {
		Frame = GameFrame,
		Player = Player,
		Map = Map,
		Destroying = DestroyingEvent.Event,
		DestroyingEvent = DestroyingEvent,
		CollideStepped = CollideSteppedEvent.Event,
		CollideSteppedEvent = CollideSteppedEvent,
		CooldownTime = cooldownTime or 0.1,
		DestroyableObjects = {},
		Connections = {},
		MoveTween = nil,
		CollideMutex = mutex.new(true),
		Moving = false,
		ControlThread = nil,
		ControllerSettings = controllerSettings or defaultControls,
	}

	self.Player:SetParent(self.Frame)

	self.Map:Init(self.Player, self.Frame)

	setmetatable(self, { __index = Game })

	showAnimation(self, "IDLE")

	return self
end

return Game
