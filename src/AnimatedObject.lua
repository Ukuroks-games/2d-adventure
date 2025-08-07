local ExImage = require(script.Parent.ExImage)
local gifInfo = require(script.Parent.gifInfo)
local giflib = require(script.Parent.Parent.giflib)
local base2d = require(script.Parent.base2d)

local animatedObject = setmetatable({}, { __index = base2d })

type AnimationsGroupDefault<T> = { [string]: T }

--[[
	Animations list

	Group names only 4 symbols
]]
type AnimationsList<T> = {
	Walk: {
		Up: T,
		Down: T,
		Right: T,
		Left: T,
		LeftUp: T,
		LeftDown: T,
		RightUp: T,
		RightDown: T,
	},

	Stay: {
		Up: T,
		Down: T,
		Right: T,
		Left: T,
		LeftUp: T,
		LeftDown: T,
		RightUp: T,
		RightDown: T,
	},

	IDLE: AnimationsGroupDefault<T>,
}

export type Animations = AnimationsList<giflib.Gif>

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
export type AnimatedObject = AnimatedObjectStruct & typeof(animatedObject)

function animatedObject.Preload(self: AnimatedObject)
	local t = base2d.Preload(self)

	for _, group in pairs(self.Animations) do
		for _, gif in pairs(group) do
			for _, frame in pairs(gif.Frames) do
				table.insert(t, frame.Image.Image)
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

--[[
	GetAnimation
]]
function animatedObject.GetAnimation(
	self: AnimatedObject,
	animationName: string
): giflib.Gif?
	local g = self.Animations[animationName:sub(1, 4)]

	if g then
		return g[animationName:sub(5)]
	else
		warn("Animation " .. tostring(animationName) .. "not exist")
		return nil
	end
end

--[[
	Set current animation.

	Automatically stop current animation and start specified animation
]]
function animatedObject.SetAnimation(
	self: AnimatedObject,
	animationName: string
)
	local Animation = self:GetAnimation(animationName)

	if Animation and self.CurrentAnimation ~= animationName then
		self:StopAnimation()

		self.CurrentAnimation = animationName

		Animation:RestartAnimation(true)
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
	local animation = self:GetAnimation(animationName or self.CurrentAnimation)

	if animation then
		animation:StartAnimation()
	end
end

--[[
	Stop (and hide) current or specified animation
]]
function animatedObject.StopAnimation(
	self: AnimatedObject,
	animationName: string?
)
	local animation = self:GetAnimation(animationName or self.CurrentAnimation)

	if animation then
		animation:StopAnimation()
		animation:Hide()
	end

	return animation
end

--[[
	Stop all animations
]]
function animatedObject.StopAnimations(self: AnimatedObject)
	for _, v in pairs(self.Animations) do
		for _, animation in pairs(v) do
			animation:StopAnimation()
			animation:Hide()
		end
	end
end

--[[
	AnimatedObject constructor
]]
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

	return self
end

return animatedObject
