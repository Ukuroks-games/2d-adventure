local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnimationController = require(
	ReplicatedStorage.Packages["2d-adventure"].Animations.AnimationController
)
local Animation = require(script.Parent.Animations.Animation)

--[=[
	character animation controller

	@class AnimatedObject

	@external Gif https://ukuroks-games.github.io/giflib/api/gif
]=]
local animatedObject = setmetatable({}, { __index = AnimationController })

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

--[[
	Animations controller
]]
export type AnimatedObject =
	AnimationController.AnimationController
	& typeof(animatedObject)

local function setup(self: AnimationController): AnimatedObject
	AnimationController.UpdateParent(self)

	setmetatable(self, { __index = AnimationController })

	return self :: AnimatedObject
end

function animatedObject.Clone(self: AnimatedObjectStruct): AnimatedObject
	local copy = self:Clone()

	local function CheckGroup(name)
		if not copy.Animations[name] then
			copy.Animations[name] = {}
		end
	end

	CheckGroup("Walk")
	CheckGroup("Stay")
	CheckGroup("IDLE")

	return setup(copy :: AnimatedObjectStruct)
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

	return setup(self)
end

return animatedObject
