local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local giflibFrame = require(ReplicatedStorage.Packages._Index["egor00f_giflib@0.1.6"].giflib.src.gifFrame)
local switch = require(ReplicatedStorage.Packages.switch)
local defaultControls = require(script.Parent.defaultControls)
local map = require(script.Parent.map)
local player = require(script.Parent.player)

--[[
	Класс игры
]]
local Game = {}

export type Game = {
	Player: player.Player2d,
	Map: map.Map
}

function Game.new(PlayerAnimations: { { giflibFrame.GifFrame } }, playerWalkSpeed: number, Size: { X: number, Y: number }): Game
	local self: Game = {
		Player = player.new(PlayerAnimations, playerWalkSpeed, Size),
		Map = map.new()
	}

	-- set all images to center

	local function SetImage(v: ImageLabel)
		v.Parent = self.Map.Image
		v.Position = UDim2.new(0.5, -v.ImageRectSize.X / 2, 0.5, -v.ImageRectSize.Y / 2)
	end

	for i, v in pairs(self.Player.Animations) do
		for j, k in pairs(v.Frames) do
			SetImage(k)
		end
	end

	local function showAnimation(animationName: string)
		if self.Player.CurrentAnimation.AnimationRunning then
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
		self.Map.Image.Position.Y.Offset += self.Player.WalkSpeed
	end

	local function Down()
		showAnimation("WalkDown")
		self.Map.Image.Position.Y.Offset -= self.Player.WalkSpeed
	end

	local function Left()
		showAnimation("WalkLeft")
		self.Map.Image.Position.X.Offset += self.Player.WalkSpeed
	end

	local function Right()
		showAnimation("WalkRight")
		self.Map.Image.Position.Y.Offset -= self.Player.WalkSpeed
	end

	local function Handler(Input: InputObject, Processed: boolean)
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
			wait(0.1)
		end
	end

	UserInputService.InputBegan:Connect(Handler)
	UserInputService.InputChanged:Connect(Handler)

	UserInputService.InputEnded:Connect(function(Input: InputObject, Processed: boolean) 
		if Input.UserInputType == Enum.UserInputType.Keyboard or Input.UserInputType == Enum.UserInputType.Gamepad1 then
			IDLE()
		end
	end)

	return self
end

return Game
