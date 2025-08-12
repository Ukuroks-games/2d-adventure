--!strict
local RemoteCursorService = game:GetService("RemoteCursorService")

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

function Object2d.CalcSize(self: Object2d): Vector3
	if self.background then
		return Calc.CalcSize(self.Size, self.background)
	else
		error("self.background = nil")
	end
end

function Object2d.CalcPosition(self: Object2d): Vector2
	if self.background then
		return Calc.CalcPosition(self.AnchorPosition, self.background)
	else
		error("self.background = nil")
	end
end

function Object2d.SetPosition(self: Object2d, pos: Vector2)
	if self.background then
		self.AnchorPosition = Calc.ReturnPosition(pos, self.background)
	end
	physicObject.SetPosition(self, pos)
end

function Object2d.SetPositionRaw(self: Object2d, pos: Vector2)
	physicObject.SetPositionRaw(self, pos)
	if self.background then
		self.AnchorPosition = Calc.ReturnPosition(
			Vector2.new(
				self.physicImage.Position.X.Offset,
				self.physicImage.Position.Y.Offset
					- self.Image.ImageInstance.AbsoluteSize.Y
					+ self.physicImage.AbsoluteSize.Y
			),
			self.background
		)
	end
end

function Object2d.SetSize(self: Object2d, size: Vector3)
	if self.background then
		self.Size = Calc.ReturnSize(size, self.background)
	end
	physicObject.SetSize(self, size)
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
