local Animation = require(script.Parent.Animation)
local ExImage = require(script.Parent.Parent.ExImage)

local base2d = require(script.Parent.Parent.base2d)

--[=[
	general character controller

	@class AnimationController

	@external Gif https://ukuroks-games.github.io/giflib/api/gif
]=]
local AnimationController = {}

type AnimationsGroupDefault = { [string]: Animation.Animation }

--[=[
	@type Animations { [string]: Animation }
	@within AnimatedObject
]=]
export type Animations = {
	[string]: AnimationsGroupDefault
}

export type AnimationControllerStruct = {
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
export type AnimationController =
	base2d.Base2d
	& AnimationControllerStruct
	& typeof(AnimationController)

--[=[

	@return { Instance } -- List of Instances for [`ContentProvider:PreloadAsync`](https://create.roblox.com/docs/reference/engine/classes/ContentProvider#PreloadAsync)

	@method Preload 

	@within AnimationController
]=]
function AnimationController.Preload(self: AnimationController): { Instance }
	local t = base2d.Preload(self)

	for _, group: AnimationsGroupDefault in pairs(self.Animations) do
		for _, animation in pairs(group) do
			for _, frame in pairs(animation.gif.Frames) do
				table.insert(t, frame.Image)
			end
		end
	end

	return t
end

--[=[
	GetAnimation

	@param animationName string
	@return Animation? -- found gif or nil

	@method GetAnimation

	@within AnimationController
]=]
function AnimationController.GetAnimation(
	self: AnimationController,
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

	@within AnimationController
]=]
function AnimationController.SetAnimation(
	self: AnimationController,
	animationName: string
)
	local animation = self:GetAnimation(animationName)
	if animation and self.CurrentAnimation ~= animationName then
		self:StopAnimation()

		self.CurrentAnimation = animationName

		animation.gif:RestartAnimation(true)
		animation.audio:Play()
	end
end

--[=[
	Raw start current or specified animation.

	Usually you don't need to call this function.

	@param self AnimatedObject
	@param animationName string

	@method StartAnimation

	@within AnimationController
]=]
function AnimationController.StartAnimation(
	self: AnimationController,
	animationName: string?
)
	local animation = self:GetAnimation(animationName or self.CurrentAnimation)

	if animation then
		animation:Start()
	end
end

--[=[
	Stop (and hide) current or specified animation

	@param animationName string?
	@return Animation? -- Stopped animation

	@method StopAnimation
	@within AnimationController
]=]
function AnimationController.StopAnimation(
	self: AnimationController,
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

	@method StopAnimation

	@within AnimationController
]=]
function AnimationController.StopAnimations(self: AnimationController)
	for _, v: AnimationsGroupDefault in pairs(self.Animations) do
		for _, animation in pairs(v) do
			animation:Stop()
		end
	end
end

--[=[
	Set ZIndex

	@param ZIndex number

	@method SetZIndex
	@within AnimationController
]=]
function AnimationController.SetZIndex(self: AnimationController, ZIndex: number)
	for _, group: AnimationsGroupDefault in pairs(self.Animations) do
		for _, animation in pairs(group) do
			animation.gif:SetZIndex(ZIndex)
		end
	end
end

function AnimationController.UpdateParent(self: AnimationController | AnimationControllerStruct)
	for _, g: AnimationsGroupDefault in pairs(self.Animations) do
		for _, a in pairs(g) do
			a.gif:SetParent(self.Image.ImageInstance)
		end
	end
end

local function setup(self: AnimationControllerStruct): AnimationController
	AnimationController.UpdateParent(self)
	
	setmetatable(self, { __index = AnimationController })

	return self :: AnimationController
end

function AnimationController.Clone(self: AnimationController): AnimationController
	local copy = {
		Animations = (function()
			local t = {}
			for i, group in pairs(self.Animations) do
				t[i] = (function()
					local g = {}
					for i, v in pairs(group) do
						g[i] = v:Clone()
					end
				end)()
			end
			return t
		end)(),
		Image = self.Image,
		CurrentAnimation = self.CurrentAnimation
	}

	return setup(copy :: AnimationControllerStruct)
end

--[=[
	`AnimationController` constructor

	@function new

	@param Animations ConstructorAnimations
	@param Parent ExImage
	@return AnimatedObjects

	@within AnimationController
]=]
function AnimationController.new(
	Animations: Animations,
	Parent: ExImage.ExImage
): AnimationController
	local self: AnimationControllerStruct = {
		Animations = Animations,
		Image = Parent,
		CurrentAnimation = "IDLE",
	}

	return setup(self)
end

return AnimationController
