--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local stdlib = require(ReplicatedStorage.Packages.stdlib)
local AnimationController = require(
	ReplicatedStorage.Packages["2d-adventure"].Animations.AnimationController
)
local Calc = require(script.Parent.Calc)
local ExImage = require(script.Parent.ExImage)
local Object2d = require(script.Parent.Object2d)

--[=[
	Just static object with animations.

	inherited from PhysicObject.

	@class Object2d
]=]
local AnimatedObject2d = setmetatable({}, {
	__index = function(self, key)
		return Object2d[key] or AnimationController[key]
	end,
})

export type AnimatedObject2dStruct = {

	--[[
		К каким пикселям на реальном изображении прикрутить объект

		то в каких координатах находился левый верхний угол изначально
	]]
	AnchorPosition: Vector2,
} & Object2d.Object2dStruct

export type AnimatedObject2d =
	AnimatedObject2dStruct
	& typeof(AnimatedObject2d)
	& Object2d.Object2d

function AnimatedObject2d.Clone(self: AnimatedObject2d): AnimatedObject2d
	local copy = AnimationController.Clone(self)

	stdlib.utility.merge(copy, Object2d.clone(self))

	setmetatable(copy, {
		__index = AnimatedObject2d,
	})

	return copy
end
	
--[=[
	Constructor
]=]
function AnimatedObject2d.new(
	Animations: AnimationController.Animations
	AnchorPosition: Vector2,
	Size: Vector3,
	Image: ExImage.ExImage,
	isButton: boolean?,
	canCollide: boolean?,
	CheckTouchedSide: boolean?,
	anchored: boolean?
): AnimatedObject2d
	local self = Object2d.new(AnchorPosition, Size, Image, isButton, canCollide, CheckTouchedSide, anchored)

	stdlib.utility.merge(self, AnimationController.new(Animations, Image))

	setmetatable(self, {
		__index = AnimatedObject2d,
	})

	return self
end

return AnimatedObject2d
