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
	Set current animation
]]
function animatedObject.SetAnimation(
	self: AnimatedObject,
	animationName: string
)
	if
		self.Animations[self.CurrentAnimation]
		and self.CurrentAnimation ~= animationName
	then
		self.Animations[self.CurrentAnimation]:StopAnimation()
		self.Animations[self.CurrentAnimation]:Hide()

		self.CurrentAnimation = animationName

		self.Animations[self.CurrentAnimation]:RestartAnimation(true)
	end
end

function animatedObject.StartAnimation(
	self: AnimatedObject,
	animationName: string?
)
	self.Animations[animationName or self.CurrentAnimation]:StartAnimation()
end

function animatedObject.StopAnimation(
	self: AnimatedObject,
	animationName: string?
)
	self.Animations[animationName or self.CurrentAnimation]:StopAnimation()
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
