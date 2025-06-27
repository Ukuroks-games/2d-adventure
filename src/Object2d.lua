local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ExImage = require(script.Parent.ExImage)
local physicObject = require(script.Parent.physicObject)

local Object2d = {}

export type Object2d = {

	--[[
		К каким пикселям на реальном изображении прикрутить объект

		то в каких координатах находился левый верхний угол изначально
	]]
	AnchorPosition: Vector2,

	--[[
		то какого изначально объект размера
	]]
	Size: Vector2,

	Image: ExImage.ExImage,
} & physicObject.PhysicObject & typeof(Object2d)

function Object2d.CalcPosition(
	AnchorPosition: Vector2,
	background: ExImage.ExImage
): Vector2
	if background.ScaleType == Enum.ScaleType.Fit then
		--отношение текущих размеров
		local currentSizes = background.AbsoluteSize.X
			/ background.AbsoluteSize.Y

		if currentSizes < 1 then -- тоесть если есть поля сверху и снизу
			-- высота самого изображения
			local h = (background.RealSize.Y * background.AbsoluteSize.X)
				/ background.RealSize.X

			return Vector2.new(
				AnchorPosition.X
					* (background.AbsoluteSize.X / background.RealSize.X),
				AnchorPosition.Y * (h / background.RealSize.Y)
					+ ((background.AbsoluteSize.Y - h) / 2)
			)
		elseif currentSizes > 1 then -- поля справа и слева
			-- ширина самого изображения
			local w = (background.RealSize.X * background.AbsoluteSize.Y)
				/ background.RealSize.Y

			return Vector2.new(
				AnchorPosition.X * (w / background.RealSize.X)
					+ ((background.AbsoluteSize.X - w) / 2),
				AnchorPosition.Y
					* (background.AbsoluteSize.Y / background.RealSize.Y)
			)
		end
	end

	return Vector2.new(
		AnchorPosition.X * (background.AbsoluteSize.X / background.RealSize.X),
		AnchorPosition.Y * (background.AbsoluteSize.Y / background.RealSize.Y)
	)
end

function Object2d.CalcSize(Size: Vector2, background: ExImage.ExImage): Vector2
	if background.ScaleType == Enum.ScaleType.Fit then
		-- отношение изначальных размеров

		--отношение текущих размеров
		local currentSizes = background.AbsoluteSize.X
			/ background.AbsoluteSize.Y

		if currentSizes < 1 then -- тоесть если есть поля сверху и снизу
			-- высота самого изображения
			local h = (background.RealSize.Y * background.AbsoluteSize.X)
				/ background.RealSize.X

			return Vector2.new(
				Size.X * (background.AbsoluteSize.X / background.RealSize.X),
				Size.Y * (h / background.RealSize.Y)
			)
		elseif currentSizes > 1 then -- поля справа и слева
			local w = (background.RealSize.X * background.AbsoluteSize.Y)
				/ background.RealSize.Y

			return Vector2.new(
				Size.X * (w / background.RealSize.X),
				Size.Y * (background.AbsoluteSize.Y / background.RealSize.Y)
			)
		end
	end

	return Vector2.new(
		Size.X * (background.AbsoluteSize.X / background.RealSize.X),
		Size.Y * (background.AbsoluteSize.Y / background.RealSize.Y)
	)
end

--[[
	Расчитывает координаты объекта
]]
function Object2d.GetPosition(
	self: Object2d,
	background: ExImage.ExImage
): Vector2
	return Object2d.CalcPosition(self.AnchorPosition, background)
end

--[[
	Расчитывает размыеры объекта
]]
function Object2d.GetSize(self: Object2d, background: ExImage.ExImage): Vector2
	return Object2d.CalcSize(self.Size, background)
end

function Object2d.CalcSizeAndPos(self: Object2d, background: ExImage.ExImage)
	local p = Object2d.GetPosition(self, background)
	local s = Object2d.GetSize(self, background)

	self.Image.Size = UDim2.fromOffset(s.X, s.Y)
	self.Image.Position = UDim2.fromOffset(p.X, p.Y)
end

--[[
	Constructor
]]
function Object2d.new(
	AnchorPosition: Vector2,
	Size: Vector2,
	Image: ExImage.ExImage,
	isButton: boolean?
): Object2d
	local self = physicObject.new(Image)

	self.AnchorPosition = AnchorPosition
	self.Size = Size

	self.Image.BackgroundTransparency = 1

	setmetatable(self, { __index = Object2d })

	return self
end

return Object2d
