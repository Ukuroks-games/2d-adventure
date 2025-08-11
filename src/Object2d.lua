--!strict

local Calc = require(script.Parent.Calc)
local ExImage = require(script.Parent.ExImage)
local physicObject = require(script.Parent.physicObject)

local Object2d = setmetatable({}, { __index = physicObject })

--[[
	Just static object without animations
]]
export type Object2dStruct = {

	--[[
		К каким пикселям на реальном изображении прикрутить объект

		то в каких координатах находился левый верхний угол изначально
	]]
	AnchorPosition: Vector2,

	Image: ExImage.ExImage,
} & physicObject.PhysicObjectStruct

export type Object2d = typeof(setmetatable(
	{} :: Object2dStruct,
	{ __index = Object2d }
))

function Object2d.CalcSize(self: Object2d, background: ExImage.ExImage): Vector3
	return Calc.CalcSize(self.Size, background)
end

function Object2d.CalcPosition(self: Object2d, background: ExImage.ExImage): Vector2
	return Calc.CalcPosition(self.AnchorPosition, background)
end

--[[
	Constructor
]]
function Object2d.new(
	AnchorPosition: Vector2,
	Size: Vector3,
	Image: ExImage.ExImage,
	isButton: boolean?,
	canCollide: boolean?,
	CheckTouchedSide: boolean?,
	anchored: boolean?
): Object2d
	local self: Object2d = physicObject.new(
		Image,
		canCollide,
		CheckTouchedSide,
		anchored
	) :: Object2d

	self.AnchorPosition = AnchorPosition
	self.Size = Size

	self.Image.ImageInstance.BackgroundTransparency = 1

	setmetatable(self, {
		__index = Object2d,
	})

	return self
end

return Object2d
