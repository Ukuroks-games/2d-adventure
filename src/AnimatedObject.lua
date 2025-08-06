local ExImage = require(script.Parent.ExImage)
local gifInfo = require(script.Parent.gifInfo)
local giflib = require(script.Parent.Parent.giflib)

local animatedObject = {}

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

	StayUp: giflib.GifFrame,
	StayDown: giflib.GifFrame,
	StayRight: giflib.GifFrame,
	StayLeft: giflib.GifFrame,
	StayLeftUp: giflib.GifFrame,
	StayLeftDown: giflib.GifFrame,
	StayRightUp: giflib.GifFrame,
	StayRightDown: giflib.GifFrame,

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

	StayUp: gifInfo.Func,
	StayDown: gifInfo.Func,
	StayRight: gifInfo.Func,
	StayLeft: gifInfo.Func,
	StayLeftUp: gifInfo.Func,
	StayLeftDown: gifInfo.Func,
	StayRightUp: gifInfo.Func,
	StayRightDown: gifInfo.Func,

	-- Other animations
	[any]: gifInfo.Func,
}

--[[
	Animations controller
]]
export type AnimatedObject = typeof(setmetatable(
	{} :: {
		--[[
			Анимации
		]]
		Animations: Animations,

		--[[
			Текущяя анимация
		]]
		CurrentAnimation: string,

		Image: ExImage.ExImage,
	},
	{ __index = animatedObject }
))

local function CreateAnimationsFromConstructor(
	Animations: ConstructorAnimations,
	PlayerFrame: ExImage.ExImage
): Animations
	local CreatedAnimations = {}

	for i, v in pairs(Animations) do
		local gif = v(PlayerFrame.ImageInstance)

		gif:Hide()
		gif:SetBackgroundTransparency(1)

		CreatedAnimations[i] = gif
	end

	return CreatedAnimations
end

--[[
	Set current animation.

	Automatically stop current animation and start specified animation
]]
function animatedObject.SetAnimation(
	self: AnimatedObject,
	animationName: string
)
	if
		self.Animations[self.CurrentAnimation]
		and self.Animations[animationName]
		and self.CurrentAnimation ~= animationName
	then
		self:StopAnimation()

		self.CurrentAnimation = animationName

		self.Animations[self.CurrentAnimation]:RestartAnimation(true)
	end
end

--[[
	Raw start current or specified animation.

	Usually you don't need to call this function.
]]
function animatedObject.StartAnimation(
	self: AnimatedObject,
	animationName: string?
)
	self.Animations[animationName or self.CurrentAnimation]:StartAnimation()
end

--[[
	Stop (and hide) current or specified animation
]]
function animatedObject.StopAnimation(
	self: AnimatedObject,
	animationName: string?
)
	local name = animationName or self.CurrentAnimation
	self.Animations[name]:StopAnimation()
	self.Animations[name]:Hide()
end

--[[
	Stop all animations
]]
function animatedObject.StopAnimations(self: AnimatedObject)
	for _, v in pairs(self.Animations) do
		v:StopAnimation()
		v:Hide()
	end
end

--[[
	AnimatedObject constructor
]]
function animatedObject.new(
	Animations: ConstructorAnimations,
	Parent: ExImage.ExImage
): AnimatedObject
	local self = {
		Animations = CreateAnimationsFromConstructor(Animations, Parent),
		Image = Parent,
		CurrentAnimation = "IDLE",
	}

	setmetatable(self, { __index = animatedObject })

	return self
end

return animatedObject
