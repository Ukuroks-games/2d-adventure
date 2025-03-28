local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local InputLib = require(ReplicatedStorage.Packages.InputLib)
local cooldown = require(ReplicatedStorage.Packages.cooldown)
local stdlib = require(ReplicatedStorage.Packages.stdlib)
local defaultControls = require(script.Parent.defaultControls)
local map = require(script.Parent.map)
local player = require(script.Parent.player)


--[[
	Класс игры
]]
local Game = {}

export type Game = {
	Frame: Frame,
	Player: player.Player2d,
	Map: map.Map,

	Destroying: RBXScriptSignal,
	DestroyingEvent: BindableEvent,

	Destroy: (self: Game) -> nil
}

--[[

]]
function Game.Destroy(self: Game)
	self.DestroyingEvent:Fire()

	self.Frame:Destroy()
	self.DestroyingEvent:Destroy()
end

--[[

]]
function Game.new(GameFrame: Frame, Player: player.Player2d, Map: map.Map): Game

	local DestroyingEvent = Instance.new("BindableEvent")

	local self: Game = {
		Frame = GameFrame,
		Player = Player,
		Map = Map,
		Destroying = DestroyingEvent.Event,
		DestroyingEvent = DestroyingEvent,
		Destroy = Game.Destroy
	}

	self.Map.Image.Parent = self.Frame
	self.Player.Frame.Parent = self.Frame

	self.Player.Animations.IDLE:SetFrame(1)	-- set first IDLE frame as default

	local function showAnimation(animationName: string)
		if	self.Player.CurrentAnimation.AnimationRunning and
			self.Player.CurrentAnimation.AnimationRunning ~= self.Player.Animations[animationName] 
		then
			self.Player.CurrentAnimation:StopAnimation()
		end

		self.Player.Animations[animationName]:StartAnimation()

		self.Player.CurrentAnimation = self.Player.Animations[animationName]
	end

	local function IDLE()
		showAnimation("IDLE")
	end

	local cooldownTime = 0.02

	local Up = cooldown.new(
		cooldownTime,
		function ()
			showAnimation("WalkUp")

			TweenService:Create(
				self.Map.Image, 
				TweenInfo.new(cooldownTime),
				{
					["Position"] = UDim2.new(
						self.Map.Image.Position.X, 
						UDim.new(
							self.Map.Image.Position.Y.Scale,
							self.Map.Image.Position.Y.Offset + self.Player.WalkSpeed
						)
					)
				}
			):Play()
		end
	)

	local Down = cooldown.new(
		cooldownTime,
		function()
			showAnimation("WalkDown")

			TweenService:Create(
				self.Map.Image, 
				TweenInfo.new(cooldownTime),
				{
					["Position"] = UDim2.new(
						self.Map.Image.Position.X,
						UDim.new(
							self.Map.Image.Position.Y.Scale,
							self.Map.Image.Position.Y.Offset - self.Player.WalkSpeed
						)
					)
				}
			):Play()

		end
	)

	local Left = cooldown.new(
		cooldownTime,
		function ()
			showAnimation("WalkLeft")

			TweenService:Create(
				self.Map.Image, 
				TweenInfo.new(cooldownTime),
				{
					["Position"] = UDim2.new(
						UDim.new(
							self.Map.Image.Position.X.Scale,
							self.Map.Image.Position.X.Offset + self.Player.WalkSpeed
						), 
						self.Map.Image.Position.Y
					)
				}
			):Play()
		
		end
	)

	local Right = cooldown.new(
		cooldownTime,
		function()
			showAnimation("WalkRight")

			TweenService:Create(
				self.Map.Image, 
				TweenInfo.new(cooldownTime),
				{
					["Position"] = UDim2.new(
						UDim.new(
							self.Map.Image.Position.X.Scale,
							self.Map.Image.Position.X.Offset - self.Player.WalkSpeed
						), 
						self.Map.Image.Position.Y
					)
				}
			):Play()
		end
	)

	InputLib.WhileKeyPressed(
		function()
			Up:Call()
		end,
		{
			defaultControls.Keyboard.Up,
			defaultControls.Gamepad.Up,
		}
	)

	InputLib.WhileKeyPressed(
		function()
			Down:Call()
		end,
		{
			defaultControls.Keyboard.Down,
			defaultControls.Gamepad.Down,
		}
	)

	InputLib.WhileKeyPressed(
		function()
			Left:Call()
		end,
		{
			defaultControls.Keyboard.Left,
			defaultControls.Gamepad.Left,
		}
	)

	InputLib.WhileKeyPressed(
		function()
			Right:Call()
		end,
		{
			defaultControls.Keyboard.Right,
			defaultControls.Gamepad.Right,
		}
	)

	task.spawn(function()
		local event = stdlib.events.AnyEvent(
			{
				Up.CallEvent.Event,
				Down.CallEvent.Event,
				Right.CallEvent.Event,
				Left.CallEvent.Event
			}
		)

		local IdleRun = cooldown.new(4, IDLE)

		local t = task.spawn(function()
			while true do
				event.Event:Wait()
				wait(4)
				IdleRun:Call()
			end
		end)

		self.Destroying:Connect(function(...: any) 
			task.cancel(t)
			IdleRun:Destroy()
			event:Destroy()
		end)
	end)

	return self
end

return Game
