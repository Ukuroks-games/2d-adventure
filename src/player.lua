local ReplicatedStorage = game:GetService("ReplicatedStorage")

local giflib = require(ReplicatedStorage.Packages.giflib)
local giflibFrame = giflib.Frame

--[[
	Player class
]]
local player = {}

export type Animations = {
	WalkUp: giflib.Gif,
	WalkDown: giflib.Gif,
	WalkRight: giflibFrame.Gif,
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

	--[[
		Фреём в которы вписиваются анимации
	]]
	Frame: Frame,
}

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

	local self: Player2d = {
		Frame = PlayerFrame,
		Animations = CreatedAnimations,
		WalkSpeed = WalkSpeed,
		CurrentAnimation = CreatedAnimations.IDLE or nil,
	}

	return self
end

return player
