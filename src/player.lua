local ReplicatedStorage = game:GetService("ReplicatedStorage")

local giflib = require(ReplicatedStorage.Packages.giflib)
local stdlib = require(ReplicatedStorage.Packages.stdlib)

local utility = stdlib.utility

local physicObject = require(script.Parent.physicObject)

--[[
	Player class
]]
local player = {}

export type Animations = {
	WalkUp: giflib.Gif,
	WalkDown: giflib.Gif,
	WalkRight: giflib.Gif,
	WalkLeft: giflib.Gif,
	IDLE: giflib.Gif,

	-- Other animations
}

--[[
	Класс игрока
]]
export type Player2d = {
	--[[
		Анимации игрока
	]]
	Animations: Animations,

	--[[
		Скорость ходьбы
	]]
	WalkSpeed: number,

	--[[
		Текущяя анимация
	]]
	CurrentAnimation: giflib.Gif,
} & physicObject.PhysicObject

function player.new(
	Animations: { [string]: {} },
	WalkSpeed: number,
	Size: { X: number, Y: number }
): Player2d
	local PlayerFrame = Instance.new("Frame")
	PlayerFrame.BackgroundTransparency = 1
	PlayerFrame.Size = UDim2.fromScale(Size.X, Size.Y)
	PlayerFrame.Position = UDim2.new(
		0.5,
		-PlayerFrame.AbsoluteSize.X / 2,
		0.5,
		-PlayerFrame.AbsoluteSize.Y / 2
	) -- move to center PlayerFrame

	local CreatedAnimations = {}

	for i, v in pairs(Animations) do
		local gif = giflib.gif.new(PlayerFrame, v, true)

		gif:Hide()
		gif:SetBackgroundTransparency(1)

		CreatedAnimations[i] = gif
	end

	local self: Player2d = utility.merge({
		Animations = CreatedAnimations,
		WalkSpeed = WalkSpeed,
		CurrentAnimation = CreatedAnimations.IDLE or nil,
	}, physicObject.new(PlayerFrame))

	self.Touched:Connect(function(collided: physicObject.PhysicObject)
		print("player touched", collided)
	end)

	return self
end

return player
