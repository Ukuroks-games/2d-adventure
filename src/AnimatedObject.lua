local Animation = require(script.Parent.Animations.Animation)
local ExImage = require(script.Parent.ExImage)

local base2d = require(script.Parent.base2d)

--[=[
	character animation controller

	@class AnimatedObject

	@external Gif https://ukuroks-games.github.io/giflib/api/gif
]=]
local animatedObject = {}




type AnimationsGroupDefault = { [string]: Animation.Animation }

--[=[
	@type Animations { Walk: {Up: Gif, Down: Gif, Right: Gif, Left: Gif, LeftUp: Gif, LeftDown: Gif, RightUp: Gif, RightDown: Gif}, Stay: {Up: Gif, Down: Gif, Right: Gif, Left: Gif, LeftUp: Gif, LeftDown: Gif, RightUp: Gif, RightDown: Gif}, IDLE: {[any]: Gif}}
	@within AnimatedObject
]=]
export type Animations = {
	Walk: {
		Up: Animation.Animation,
		Down: Animation.Animation,
		Right: Animation.Animation,
		Left: Animation.Animation,
		LeftUp: Animation.Animation,
		LeftDown: Animation.Animation,
		RightUp: Animation.Animation,
		RightDown: Animation.Animation,
	},

	Stay: {
		Up: Animation.Animation,
		Down: Animation.Animation,
		Right: Animation.Animation,
		Left: Animation.Animation,
		LeftUp: Animation.Animation,
		LeftDown: Animation.Animation,
		RightUp: Animation.Animation,
		RightDown: Animation.Animation,
	},

	IDLE: AnimationsGroupDefault,
}

export type AnimatedObjectStruct = {
	--[[
		Анимации
	]]
	Animations: Animations,

	--[[
		Текущая анимация
	]]
	CurrentAnimation: string,
} & base2d.Base2dStruct

--[[
	Animations controller
]]
export type AnimatedObject =
	base2d.Base2d
	& AnimatedObjectStruct
	& typeof(animatedObject)

--[=[
	@param self AnimatedObject

	@method Preload 

	@within AnimatedObject
]=]
function animatedObject.Preload(self: AnimatedObject): { Instance }
	local t = base2d.Preload(self)

	for _, group: AnimationsGroupDefault in pairs(self.Animations) do
		for _, gif in pairs(group) do
			for _, frame in pairs(gif.Frames) do
				table.insert(t, frame.Image)
			end
		end
	end

	return t
end

--[=[
	GetAnimation

	@param self AnimatedObject
	@param animationName string
	@return found gif or nil

	@method GetAnimation

	@within AnimatedObject
]=]
function animatedObject.GetAnimation(
	self: AnimatedObject,
	animationName: string
): Animation.Animation?
	local g = self.Animations[animationName:sub(1, 4)] :: Animations

	if g then
		return g[animationName:sub(5)]
	else
		warn("Animation " .. tostring(animationName) .. "not exist")
		return nil
	end
end

--[=[
	Set current animation.

	Automatically stop current animation and start specified animation

	@param self AnimatedObject
	@param animationName string

	@method SetAnimation

	@within AnimatedObject
]=]
function animatedObject.SetAnimation(
	self: AnimatedObject,
	animationName: string
)
	local Animation = self:GetAnimation(animationName)
	if Animation and self.CurrentAnimation ~= animationName then
		self:StopAnimation()

		self.CurrentAnimation = animationName

		Animation.gif:RestartAnimation(true)
		Animation.audio:Play()
	end
end

--[=[
	Raw start current or specified animation.

	Usually you don't need to call this function.

	@param self AnimatedObject
	@param animationName string

	@method StartAnimation

	@within AnimatedObject
]=]
function animatedObject.StartAnimation(
	self: AnimatedObject,
	animationName: string?
)
	local animation = self:GetAnimation(animationName or self.CurrentAnimation)

	if animation then
		animation:Start()
	end
end

--[[
	Stop (and hide) current or specified animation
]]
function animatedObject.StopAnimation(
	self: AnimatedObject,
	animationName: string?
): Animation.Animation?
	local animation = self:GetAnimation(animationName or self.CurrentAnimation)

	if animation then
		animation:Stop()
	end

	return animation
end

--[=[
	Stop all animations

	@param self AnimatedObject

	@method StopAnimation

	@within AnimatedObject
]=]
function animatedObject.StopAnimations(self: AnimatedObject)
	for _, v: AnimationsGroupDefault in pairs(self.Animations) do
		for _, animation in pairs(v) do
			animation:Stop()
		end
	end
end

--[=[
	`AnimatedObject` constructor

	@function new

	@param Animations ConstructorAnimations
	@param Parent ExImage
	@return AnimatedObjects

	@within AnimatedObject
]=]
function animatedObject.new(
	Animations: Animations,
	Parent: ExImage.ExImage
): AnimatedObject
	local self: AnimatedObjectStruct = {
		Animations = Animations,
		Image = Parent,
		CurrentAnimation = "IDLE",
	}

	setmetatable(self, { __index = animatedObject })

	return self :: AnimatedObject
end

return animatedObject
