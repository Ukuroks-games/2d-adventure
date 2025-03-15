local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local cooldown = require(ReplicatedStorage.Packages.cooldown)
local switch = require(ReplicatedStorage.Packages.switch)
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
	Map: map.Map
}

function Game.new(GameFrame: Frame, Player: player.Player2d, Map: map.Map): Game
	local self: Game = {
		Frame = GameFrame,
		Player = Player,
		Map = Map
	}

	self.Map.Image.Parent = self.Frame
	self.Player.Frame.Parent = self.Frame

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

	local function Up()
		showAnimation("WalkUp")
		self.Map.Image.Position = UDim2.new(self.Map.Image.Position.X, UDim.new(self.Map.Image.Position.Y.Scale, self.Map.Image.Position.Y.Offset + self.Player.WalkSpeed))
	end

	local function Down()
		showAnimation("WalkDown")
		self.Map.Image.Position = UDim2.new(self.Map.Image.Position.X, UDim.new(self.Map.Image.Position.Y.Scale, self.Map.Image.Position.Y.Offset - self.Player.WalkSpeed))
	end

	local function Left()
		showAnimation("WalkLeft")
		self.Map.Image.Position = UDim2.new(UDim.new(self.Map.Image.Position.X.Scale, self.Map.Image.Position.X.Offset + self.Player.WalkSpeed), self.Map.Image.Position.Y)
	end

	local function Right()
		showAnimation("WalkRight")
		self.Map.Image.Position = UDim2.new(UDim.new(self.Map.Image.Position.X.Scale, self.Map.Image.Position.X.Offset - self.Player.WalkSpeed), self.Map.Image.Position.Y)
	end

	local WalkCooldown = cooldown.new(
		0.08,
		function(Input: InputObject)
			if Input.UserInputType == Enum.UserInputType.Keyboard or Input.UserInputType == Enum.UserInputType.Gamepad1 then
				switch(Input.KeyCode)
				{
					[defaultControls.Keyboard.Down] = Down,
					[defaultControls.Keyboard.Up] = Up,
					[defaultControls.Keyboard.Left] = Left,
					[defaultControls.Keyboard.Right] = Right,
					[defaultControls.Gamepad.Down] = Down,
					[defaultControls.Gamepad.Up] = Up,
					[defaultControls.Gamepad.Left] = Left,
					[defaultControls.Gamepad.Right] = Right
				}
			end
		end
	)
	
	local function Hanlder(...)
		WalkCooldown:Call(...)
	end

	UserInputService.InputBegan:Connect(Hanlder)
	UserInputService.InputChanged:Connect(Hanlder)

	task.spawn(function()
		while true do
			WalkCooldown.CallEvent.Event:Wait()
			task.wait(4)
			IDLE()
		end
	end)

	return self
end

return Game
