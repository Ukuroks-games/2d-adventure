local ExImage = require(script.Parent.ExImage)
local physicObject = require(script.Parent.physicObject)

local Object2d = setmetatable({}, { __index = physicObject })

--[[
	Just static object without animations
]]
export type Object2d = {

	--[[
		К каким пикселям на реальном изображении прикрутить объект

		то в каких координатах находился левый верхний угол изначально
	]]
	AnchorPosition: Vector2,

	Image: ExImage.ExImage,
} & physicObject.PhysicObject & typeof(Object2d)

--[[

]]
function Object2d.CalcPosition(
	AnchorPosition: Vector2,
	background: ExImage.ExImage
): Vector2
	if background.ImageInstance.ScaleType == Enum.ScaleType.Fit then
		--отношение текущих размеров
		local currentSizes = background.ImageInstance.AbsoluteSize.X
			/ background.ImageInstance.AbsoluteSize.Y

		if currentSizes < 1 then -- то есть если есть поля сверху и снизу
			-- высота самого изображения
			local h = (
				background.RealSize.Y * background.ImageInstance.AbsoluteSize.X
			) / background.RealSize.X

			return Vector2.new(
				AnchorPosition.X
					* (
						background.ImageInstance.AbsoluteSize.X
						/ background.RealSize.X
					),
				AnchorPosition.Y * (h / background.RealSize.Y)
					+ ((background.ImageInstance.AbsoluteSize.Y - h) / 2)
			)
		elseif currentSizes > 1 then -- поля справа и слева
			-- ширина самого изображения
			local w = (
				background.RealSize.X * background.ImageInstance.AbsoluteSize.Y
			) / background.RealSize.Y

			return Vector2.new(
				AnchorPosition.X * (w / background.RealSize.X)
					+ ((background.ImageInstance.AbsoluteSize.X - w) / 2),
				AnchorPosition.Y
					* (
						background.ImageInstance.AbsoluteSize.Y
						/ background.RealSize.Y
					)
			)
		end
	end

	return Vector2.new(
		AnchorPosition.X
			* (background.ImageInstance.AbsoluteSize.X / background.RealSize.X),
		AnchorPosition.Y
			* (background.ImageInstance.AbsoluteSize.Y / background.RealSize.Y)
	)
end

--[[

]]
function Object2d.CalcSize(Size: Vector3, background: ExImage.ExImage): Vector3
	if background.ImageInstance.ScaleType == Enum.ScaleType.Fit then
		-- отношение изначальных размеров

		--отношение текущих размеров
		local currentSizes = background.ImageInstance.AbsoluteSize.X
			/ background.ImageInstance.AbsoluteSize.Y

		if currentSizes < 1 then -- то есть если есть поля сверху и снизу
			-- высота самого изображения
			local h = (
				background.RealSize.Y * background.ImageInstance.AbsoluteSize.X
			) / background.RealSize.X

			return Vector3.new(
				Size.X
					* (
						background.ImageInstance.AbsoluteSize.X
						/ background.RealSize.X
					),
				Size.Y * (h / background.RealSize.Y),
				Size.Z * (h / background.RealSize.Y)
			)
		elseif currentSizes > 1 then -- поля справа и слева
			local w = (
				background.RealSize.X * background.ImageInstance.AbsoluteSize.Y
			) / background.RealSize.Y

			return Vector3.new(
				Size.X * (w / background.RealSize.X),
				Size.Y
					* (
						background.ImageInstance.AbsoluteSize.Y
						/ background.RealSize.Y
					),
				Size.Z
					* (
						background.ImageInstance.AbsoluteSize.Y
						/ background.RealSize.Y
					)
			)
		end
	end

	return Vector3.new(
		Size.X
			* (background.ImageInstance.AbsoluteSize.X / background.RealSize.X),
		Size.Y
			* (background.ImageInstance.AbsoluteSize.Y / background.RealSize.Y),
		Size.Z
			* (background.ImageInstance.AbsoluteSize.Y / background.RealSize.Y)
	)
end

--[[
	Рассчитывает координаты объекта
]]
function Object2d.GetPosition(
	self: Object2d,
	background: ExImage.ExImage
): Vector2
	return Object2d.CalcPosition(self.AnchorPosition, background)
end

--[[
	Рассчитывает размеры объекта
]]
function Object2d.GetSize(self: Object2d, background: ExImage.ExImage): Vector3
	return Object2d.CalcSize(self.Size, background)
end

--[[
	Рассчитывает размеры и коо объекта
]]
function Object2d.CalcSizeAndPos(self: Object2d, background: ExImage.ExImage)
	self:SetSize(self:GetSize(background))
	self:SetPosition(self:GetPosition(background))
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
	local self = physicObject.new(Image, canCollide, CheckTouchedSide, anchored)

	self.AnchorPosition = AnchorPosition
	self.Size = Size

	self.Image.ImageInstance.BackgroundTransparency = 1

	setmetatable(self, {
		__index = Object2d,
	})

	return self
end

return Object2d
