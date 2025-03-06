local ReplicatedStorage = game:GetService("ReplicatedStorage")

local giflib = require(ReplicatedStorage.Packages._Index["egor00f_giflib@0.1.6"].giflib.src.giflib)
local giflibFrame = require(ReplicatedStorage.Packages._Index["egor00f_giflib@0.1.6"].giflib.src.gifFrame)

--[[
	Player class
]]
local player = {}

export type Animations = {
	WalkUp:	giflib.Gif,
	WalkDown:	giflib.Gif,
	WalkRight:	giflib.Gif,
	WalkLeft:	giflib.Gif,
	IDLE:	giflib.Gif,
		
	-- Other animations
}

export type Player2d = {
	Animations: Animations,
	WalkSpeed: number,
	CurrentAnimation: giflib.Gif,
	Frame: Frame
}



function player.new(Animations: { {giflibFrame.GifFrame} }, WalkSpeed: number, Size: { X: number, Y: number }): Player2d
	
	local PlayerFrame = Instance.new("Frame")
	PlayerFrame.BackgroundTransparency = 1
	PlayerFrame.Size = UDim2.fromScale(Size.X, Size.Y)
	PlayerFrame.Position = UDim2.new(0.5, - PlayerFrame.AbsoluteSize.X / 2, 0.5, - PlayerFrame.AbsoluteSize.Y / 2)	-- move to center PlayerFrame
	

	local CreatedAnimations = {}

	for i, v in pairs(Animations) do
		CreatedAnimations[i] = giflib.new(PlayerFrame, v, true)
	end

	local self: Player2d = {
		Frame = PlayerFrame,
		Animations = CreatedAnimations,
		WalkSpeed = WalkSpeed,
		CurrentAnimation = CreatedAnimations.IDLE or nil
	}

	return self
end

return player
