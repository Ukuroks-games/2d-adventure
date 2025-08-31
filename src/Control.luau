--!strict

local Players = game:GetService("Players")

local PlayerModule =
	require(Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))

local player = require(script.Parent.player)
local InputLib = require(script.Parent.Parent.InputLib)
local ControlType = require(script.Parent.ControlType)
local stdlib = require(script.Parent.Parent.stdlib)
local map = require(script.Parent.map)

--[=[
	@class Control
]=]
local Control = {}

export type ControlStruct = {
	ControlThread: thread?,
	Player: player.Player2d,

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

	ControllerSettings: ControlType.Control,

	--[[
	
	]]
	CooldownTime: number,

	--[[
		Map
	]]
	Map: map.Map,

	Moving: boolean,

	MoveTween: Tween?,

	CollideMutex: stdlib.Mutex,

	--[[
		Sent on physic step end
	]]
	CollideStepped: RBXScriptSignal<>,

	--[[
	
	]]
	Destroying: RBXScriptSignal<>,

	--[[
	
	]]
	CollideSteppedEvent: BindableEvent<>,
}

export type Control = typeof(setmetatable(
	{} :: ControlStruct,
	{ __index = Control }
))

--[=[
		
]=]
function Control.IDLE(self: Control, name: string?)
	if self.MoveTween then
		self.MoveTween:Destroy()
		self.MoveTween = nil -- set to nil for this IF can working
	end

	task.wait()

	--[[
		#self.Player.Animations.IDLE == 0 (idk why)
	]]
	local n = stdlib.algorithm.GetIndexs(self.Player.Animations.IDLE)

	self.Player:SetAnimation("IDLE" .. (name or n[math.random(#n)]))
end

function Control.Up(self: Control)
	Control.Move(self, 0, 1)
end

function Control.Down(self: Control)
	Control.Move(self, 0, -1)
end

function Control.Left(self: Control)
	Control.Move(self, -1, 0)
end

function Control.Right(self: Control)
	Control.Move(self, 1, 0)
end

function Control.LeftUp(self: Control)
	Control.Move(self, -1, 1)
end

function Control.LeftDown(self: Control)
	Control.Move(self, -1, -1)
end

function Control.RightUp(self: Control)
	Control.Move(self, 1, 1)
end

function Control.RightDown(self: Control)
	Control.Move(self, 1, -1)
end

--[[
	Move player
]]
function Control.Move(self: Control, X: number, Y: number)
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
	Start game
]]
function Control.Start(self: Control)
	self.ControlThread = task.spawn(function()
		self:IDLE()

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
			local function Move(_self: Control, XPos: number?, YPos: number?)
				self.CollideSteppedEvent:Fire()
				if
					self.DestroyableObjects.Up.State.Value
					and self.DestroyableObjects.Right.State.Value
				then --	Right Up
					Control.RightUp(_self)
				elseif
					self.DestroyableObjects.Down.State.Value
					and self.DestroyableObjects.Right.State.Value
				then -- Right Down
					Control.RightDown(_self)
				elseif
					self.DestroyableObjects.Down.State.Value
					and self.DestroyableObjects.Left.State.Value
				then --	Left Down
					Control.LeftDown(_self)
				elseif
					self.DestroyableObjects.Up.State.Value
					and self.DestroyableObjects.Left.State.Value
				then --	Left Up
					Control.LeftUp(_self)
				elseif self.DestroyableObjects.Up.State.Value then --	Up
					Control.Up(_self)
				elseif self.DestroyableObjects.Down.State.Value then --	Down
					Control.Down(_self)
				elseif self.DestroyableObjects.Left.State.Value then --	Left
					Control.Left(_self)
				elseif self.DestroyableObjects.Right.State.Value then --	Right
					Control.Right(_self)
				elseif YPos and XPos then
					Control.Move(_self, XPos, YPos)
				else
					warn(
						"No key pressed and positions of X and Y are not indicated"
					)
				end
			end

			stdlib.events
				.AnyEvent({
					self.DestroyableObjects.Up.Called,
					self.DestroyableObjects.Down.Called,
					self.DestroyableObjects.Right.Called,
					self.DestroyableObjects.Left.Called,
				}).Event
				:Connect(function(_: any)
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

function Control.Pause(self: Control)
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

function Control.Resume(self: Control)
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

return Control
