local ReplicatedStorage = game:GetService("ReplicatedStorage")

local stdlib = require(ReplicatedStorage.Packages.stdlib)

local utility = stdlib.utility

local ExImage = require(script.Parent.ExImage)
local physicObject = require(script.Parent.physicObject)

local Object2d = {}

Object2d.TouchSide = {
	NoTouched = 0,
	Up = 1,
	Down = 2,
	Right = 3,
	Left = 4,
}

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

	TouchedSide: number,

	Image: ExImage.ExImage,

	_physicObject: physicObject.PhysicObject,

	CalcSizeAndPos: (self: Object2d, background: ExImage.ExImage) -> nil,
} & physicObject.PhysicObject

--[[
	Расчитывает координаты объекта
]]
function Object2d.GetPosition(self: Object2d, background: ExImage.ExImage)
	if background.ScaleType == Enum.ScaleType.Fit then
		--отношение текущих размеров
		local currentSizes = background.AbsoluteSize.X
			/ background.AbsoluteSize.Y

		if currentSizes < 1 then -- тоесть если есть поля сверху и снизу
			-- высота самого изображения
			local h = (background.RealSize.Y * background.AbsoluteSize.X)
				/ background.RealSize.X

			return Vector2.new(
				self.AnchorPosition.X
					* (background.AbsoluteSize.X / background.RealSize.X),
				self.AnchorPosition.Y * (h / background.RealSize.Y)
					+ ((background.AbsoluteSize.Y - h) / 2)
			)
		elseif currentSizes > 1 then -- поля справа и слева
			-- ширина самого изображения
			local w = (background.RealSize.X * background.AbsoluteSize.Y)
				/ background.RealSize.Y

			return Vector2.new(
				self.AnchorPosition.X * (w / background.RealSize.X)
					+ ((background.AbsoluteSize.X - w) / 2),
				self.AnchorPosition.Y
					* (background.AbsoluteSize.Y / background.RealSize.Y)
			)
		end
	end

	return Vector2.new(
		self.AnchorPosition.X
			* (background.AbsoluteSize.X / background.RealSize.X),
		self.AnchorPosition.Y
			* (background.AbsoluteSize.Y / background.RealSize.Y)
	)
end

--[[
	Расчитывает размыеры объекта
]]
function Object2d.GetSize(self: Object2d, background: ExImage.ExImage)
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
				self.Size.X
					* (background.AbsoluteSize.X / background.RealSize.X),
				self.Size.Y * (h / background.RealSize.Y)
			)
		elseif currentSizes > 1 then -- поля справа и слева
			local w = (background.RealSize.X * background.AbsoluteSize.Y)
				/ background.RealSize.Y

			return Vector2.new(
				self.Size.X * (w / background.RealSize.X),
				self.Size.Y
					* (background.AbsoluteSize.Y / background.RealSize.Y)
			)
		end
	end

	return Vector2.new(
		self.Size.X * (background.AbsoluteSize.X / background.RealSize.X),
		self.Size.Y * (background.AbsoluteSize.Y / background.RealSize.Y)
	)
end

function Object2d.CalcSizeAndPos(self: Object2d, background: ExImage.ExImage)
	local p = Object2d.GetPosition(self, background)
	local s = Object2d.GetSize(self, background)

	self._physicObject.Image.Size = UDim2.fromOffset(s.X, s.Y)
	self._physicObject.Image.Position = UDim2.fromOffset(p.X, p.Y)
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
	local self = {
		AnchorPosition = AnchorPosition,
		Size = Size,
		TouchedSide = Object2d.TouchSide.NoTouched, -- by default not touched
		CalcSizeAndPos = Object2d.CalcSizeAndPos,
		_physicObject = physicObject.new(Image),
	}

	setmetatable(self, {
		__index = function(_self: typeof(self), key)
			return self._physicObject[key]
		end,
	})

	self.Image.BackgroundTransparency = 1

	return self
end

return Object2d
