local ExImage = require(script.Parent.ExImage)

local gifInfo = require(script.Parent.gifInfo)
local giflib = require(script.Parent.Parent.giflib)
local base2d = require(script.Parent.base2d)
--[=[
	character animation controller

	@class AnimatedObject

	@external Gif https://ukuroks-games.github.io/giflib/api/gif
]=]
local animatedObject = {}

export type Animation<T> = {
	gif: T,
	audio: AudioPlayer,
}

type AnimationsGroupDefault<T> = { [string]: Animation<T> }

--[[
	Animations list

	Group names only 4 symbols
]]
type AnimationsList<T> = {
	Walk: {
		Up: Animation<T>,
		Down: Animation<T>,
		Right: Animation<T>,
		Left: Animation<T>,
		LeftUp: Animation<T>,
		LeftDown: Animation<T>,
		RightUp: Animation<T>,
		RightDown: Animation<T>,
	},

	Stay: {
		Up: Animation<T>,
		Down: Animation<T>,
		Right: Animation<T>,
		Left: Animation<T>,
		LeftUp: Animation<T>,
		LeftDown: Animation<T>,
		RightUp: Animation<T>,
		RightDown: Animation<T>,
	},

	IDLE: AnimationsGroupDefault<T>,
}

--[=[
	@type Animations { Walk: {Up: Gif, Down: Gif, Right: Gif, Left: Gif, LeftUp: Gif, LeftDown: Gif, RightUp: Gif, RightDown: Gif}, Stay: {Up: Gif, Down: Gif, Right: Gif, Left: Gif, LeftUp: Gif, LeftDown: Gif, RightUp: Gif, RightDown: Gif}, IDLE: {[any]: Gif}}
	@within AnimatedObject
]=]
export type Animations = AnimationsList<giflib.Gif>

--[=[
	@type ConstructorAnimations { Walk: {Up: Func, Down: Func, Right: Func, Left: Func, LeftUp: Func, LeftDown: Func, RightUp: Func, RightDown: Func}, Stay: {Up: Func, Down: Func, Right: Func, Left: Func, LeftUp: Func, LeftDown: Func, RightUp: Func, RightDown: Func}, IDLE: {[any]: Func}}
	@within AnimatedObject
]=]
export type ConstructorAnimations = AnimationsList<gifInfo.Func>

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

	for _, group: AnimationsGroupDefault<giflib.Gif> in pairs(self.Animations) do
		for _, gif in pairs(group) do
			for _, frame in pairs(gif.Frames) do
				table.insert(t, frame.Image)
			end
		end
	end

	return t
end

--[[

]]
local function CreateAnimationsFromConstructor(
	Animations: ConstructorAnimations,
	PlayerFrame: ExImage.ExImage
): Animations
	local CreatedAnimations = {}

	for GroupName, Group in pairs(Animations) do
		CreatedAnimations[GroupName] = {}

		for i, v in pairs(Group) do
			local gif = v(PlayerFrame.ImageInstance)

			gif:Hide()
			gif:SetBackgroundTransparency(1)

			CreatedAnimations[GroupName][i] = gif
		end
	end

	return CreatedAnimations
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
): Animation<giflib.Gif>?
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
		animation.gif:StartAnimation()
	end
end

--[[
	Stop (and hide) current or specified animation
]]
function animatedObject.StopAnimation(
	self: AnimatedObject,
	animationName: string?
): Animation<giflib.Gif>
	local animation = self:GetAnimation(animationName or self.CurrentAnimation)

	if animation then
		animation.gif:StopAnimation()
		animation.gif:Hide()
		animation.audio:Stop()
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
	for _, v in pairs(self.Animations) do
		for _, animation in pairs(v) do
			animation:StopAnimation()
			animation:Hide()
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
	Animations: ConstructorAnimations,
	Parent: ExImage.ExImage
): AnimatedObject
	local self: AnimatedObjectStruct = {
		Animations = CreateAnimationsFromConstructor(Animations, Parent),
		Image = Parent,
		CurrentAnimation = "IDLE",
	}

	setmetatable(self, { __index = animatedObject })

	return self :: AnimatedObject
end

return animatedObject
