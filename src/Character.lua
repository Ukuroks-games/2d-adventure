local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local gifInfo = require(script.Parent.gifInfo)
local giflib = require(script.Parent.Parent.giflib)

local physicObject = require(script.Parent.physicObject)
local Object2d = require(script.Parent.Object2d)
local ExImage = require(script.Parent.ExImage)

--[[
	Player class
]]
local Character2d = {}

--[[
	Animations list
]]
export type Animations = {
	WalkUp: giflib.Gif,
	WalkDown: giflib.Gif,
	WalkRight: giflib.Gif,
	WalkLeft: giflib.Gif,
	IDLE: giflib.Gif,
	WalkLeftUp: giflib.Gif,
	WalkLeftDown: giflib.Gif,
	WalkRightUp: giflib.Gif,
	WalkRightDown: giflib.Gif,

	-- Other animations
	[any]: giflib.Gif,
}

export type ConstructorAnimations = {
	WalkUp: gifInfo.Func,
	WalkDown: gifInfo.Func,
	WalkRight: gifInfo.Func,
	WalkLeft: gifInfo.Func,
	WalkLeftUp: gifInfo.Func,
	WalkLeftDown: gifInfo.Func,
	WalkRightUp: gifInfo.Func,
	WalkRightDown: gifInfo.Func,
	IDLE: gifInfo.Func,

	-- Other animations
	[any]: gifInfo.Func,
}

export type CharacterSpeed = {
	X: number,
	Y: number,
	Calculated: CharacterSpeed,
}

--[[
	Класс игрока
]]
export type Character2dStruct = {
	--[[
		Анимации игрока
	]]
	Animations: Animations,

	--[[
		Скорость ходьбы
	]]
	WalkSpeed: CharacterSpeed,

	Move: RBXScriptSignal,

	MoveEvent: BindableEvent,

	--[[
		Текущяя анимация
	]]
	CurrentAnimation: string,

	Image: Frame,
} & physicObject.PhysicObject

export type Character2d = Character2dStruct & typeof(Character2d)

--[[
	Destroy player
]]
function Character2d.Destroy(self: Character2dStruct)
	for _, v in pairs(self.Animations) do
		v:Destroy()
	end

	self.MoveEvent:Destroy()
end

--[[

]]
function Character2d.CalcSize(
	self: Character2dStruct,
	mapImage: ExImage.ExImage
): Vector3
	local Resolution: Vector3

	if self.Size.X == -1 or self.Size.Y == -1 then
		local a = AssetService:CreateEditableImageAsync(
			self.Animations[self.CurrentAnimation].Frames[1].Image.Image
		).Size
		Resolution = Vector3.new(a.X, a.Y, self.Size.Z)
	end

	return Object2d.CalcSize(Resolution or self.Size, mapImage)
end

--[[
	Set ZIndex for player
]]
function Character2d.SetZIndex(self: Character2dStruct, ZIndex: number)
	physicObject.SetZIndex(self, ZIndex)

	for _, animation in pairs(self.Animations) do
		for _, frame in pairs(animation.Frames) do
			frame.Image.ZIndex = ZIndex
		end
	end
end

--[[
	Set current animation
]]
function Character2d.SetAnimation(self: Character2dStruct, animationName: string)
	if
		self.Animations[self.CurrentAnimation]
		and self.CurrentAnimation ~= animationName
	then
		self.Animations[self.CurrentAnimation]:StopAnimation()
		self.Animations[self.CurrentAnimation]:Hide()

		self.CurrentAnimation = animationName

		self.Animations[self.CurrentAnimation]:RestartAnimation()
	end
end

--[[
	Stop all animations
]]
function Character2d.StopAnimations(self: Character2dStruct)
	for _, v in pairs(self.Animations) do
		v:StopAnimation()
		v:Hide()
	end
end

local function CreateAnimationsFromConstructor(
	Animations: ConstructorAnimations,
	PlayerFrame: Frame
): Animations
	local CreatedAnimations = {}

	for i, v in pairs(Animations) do
		local gif = v(PlayerFrame)

		gif:Hide()
		gif:SetBackgroundTransparency(1)

		CreatedAnimations[i] = gif
	end

	return CreatedAnimations
end

--[[
	Character2d constructor
]]
function Character2d.new(
	Animations: ConstructorAnimations,
	WalkSpeed: CharacterSpeed,
	Size: Vector3
): Character2d
	local PlayerFrame = Instance.new("Frame")
	local CreatedAnimations =
		CreateAnimationsFromConstructor(Animations, PlayerFrame)

	local self = physicObject.new(PlayerFrame, true, true, false)

	PlayerFrame.BackgroundTransparency = 1

	self.Image = PlayerFrame
	self.Animations = CreatedAnimations
	self.WalkSpeed = WalkSpeed
	self.CurrentAnimation = "IDLE"
	self.MoveEvent = Instance.new("BindableEvent")
	self.Move = self.MoveEvent.Event
	self.Anchored = false
	self.Size = Size

	setmetatable(self, {
		__index = function(_self, key)
			return Character2d[key] or physicObject[key]
		end,
	})

	return self
end

return Character2d
