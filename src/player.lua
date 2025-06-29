local ReplicatedStorage = game:GetService("ReplicatedStorage")

local gifInfo = require(script.Parent.gifInfo)
local giflib = require(ReplicatedStorage.Packages.giflib)

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
	[any]: giflib.Gif,
}

export type ConstructorAnimations = {
	WalkUp: gifInfo.Func,
	WalkDown: gifInfo.Func,
	WalkRight: gifInfo.Func,
	WalkLeft: gifInfo.Func,
	IDLE: gifInfo.Func,

	-- Other animations
	[any]: gifInfo.Func,
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

	Move: RBXScriptSignal,

	MoveEvent: BindableEvent,

	--[[
		Текущяя анимация
	]]
	CurrentAnimation: giflib.Gif,
} & physicObject.PhysicObject & typeof(player)

--[[
	Destroy player
]]
function player.Destroy(self: Player2d)
	for _, v in pairs(self.Animations) do
		v:Destroy()
	end

	self.MoveEvent:Destroy()
end

--[[
	Player2d constructor
]]
function player.new(
	Animations: ConstructorAnimations,
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
		local gif = v(PlayerFrame)

		gif:Hide()
		gif:SetBackgroundTransparency(1)

		CreatedAnimations[i] = gif
	end

	local self = physicObject.new(PlayerFrame, true, true, false)

	self.Animations = CreatedAnimations
	self.WalkSpeed = WalkSpeed
	self.CurrentAnimation = CreatedAnimations.IDLE or nil
	self.MoveEvent = Instance.new("BindableEvent")
	self.Move = self.MoveEvent.Event
	self.Anchored = false

	setmetatable(self, {
		__index = function(_self, key)
			return player[key] or physicObject[key]
		end,
	})

	return self
end

return player
