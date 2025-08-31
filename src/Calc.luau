--!strict

local ExImage = require(script.Parent.ExImage)

--[=[
	collection of functions

	@class calc
]=]
local calc = {}

local function RelativeSizes(background: ExImage.ExImage): number
	return background.ImageInstance.AbsoluteSize.X
		/ background.ImageInstance.AbsoluteSize.Y
end

local function height(background: ExImage.ExImage): number
	return (background.RealSize.Y * background.ImageInstance.AbsoluteSize.X)
		/ background.RealSize.X
end

local function width(background: ExImage.ExImage): number
	return (background.RealSize.X * background.ImageInstance.AbsoluteSize.Y)
		/ background.RealSize.Y
end

local function UpSpace(h: number, background: ExImage.ExImage): number
	return ((background.ImageInstance.AbsoluteSize.Y - h) / 2)
end

local function LeftSpace(w: number, background: ExImage.ExImage): number
	return ((background.ImageInstance.AbsoluteSize.X - w) / 2)
end

--[=[
	Рассчитать координаты объекта на экране по размеру изображения.

	@param AnchorPosition Vector2 -- координаты объекта на изображении
	@param background ExImage
]=]
function calc.CalcPosition(
	AnchorPosition: Vector2,
	background: ExImage.ExImage
): Vector2
	if background.ImageInstance.ScaleType == Enum.ScaleType.Fit then
		--отношение текущих размеров
		local currentSizes = RelativeSizes(background)
		local ResSizes = background.RealSize.X / background.RealSize.Y

		if currentSizes < ResSizes then -- то есть если есть поля сверху и снизу
			-- высота самого изображения
			local h = height(background)

			return Vector2.new(
				AnchorPosition.X
					* (
						background.ImageInstance.AbsoluteSize.X
						/ background.RealSize.X
					),
				AnchorPosition.Y * (h / background.RealSize.Y)
					+ UpSpace(h, background)
			)
		elseif currentSizes > ResSizes then -- поля справа и слева
			-- ширина самого изображения
			local w = width(background)

			return Vector2.new(
				AnchorPosition.X * (w / background.RealSize.X)
					+ LeftSpace(w, background),
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

--[=[
	@param Size Vector3
	@param background ExImage
]=]
function calc.CalcSize(Size: Vector3, background: ExImage.ExImage): Vector3
	if background.ImageInstance.ScaleType == Enum.ScaleType.Fit then
		-- отношение изначальных размеров

		--отношение текущих размеров
		local currentSizes = RelativeSizes(background)
		local ResSizes = background.RealSize.X / background.RealSize.Y

		if currentSizes < ResSizes then -- то есть если есть поля сверху и снизу
			-- высота самого изображения
			local h = height(background)

			return Vector3.new(
				Size.X
					* (
						background.ImageInstance.AbsoluteSize.X
						/ background.RealSize.X
					),
				Size.Y * (h / background.RealSize.Y),
				Size.Z * (h / background.RealSize.Y)
			)
		elseif currentSizes > ResSizes then -- поля справа и слева
			local w = width(background)

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

--[=[
	Обратная CalcPosition функция

	@param AbsolutePosition Vector2 -- координаты
	@param background ExImage
]=]
function calc.ReturnPosition(
	AbsolutePosition: Vector2,
	background: ExImage.ExImage
): Vector2
	if background.ImageInstance.ScaleType == Enum.ScaleType.Fit then
		local currentSizes = RelativeSizes(background)
		local ResSizes = background.RealSize.X / background.RealSize.Y

		if currentSizes < ResSizes then
			local h = height(background)

			return Vector2.new(
				AbsolutePosition.X
					/ background.ImageInstance.AbsoluteSize.X
					* background.RealSize.X,
				(AbsolutePosition.Y - UpSpace(h, background))
					/ h
					* background.RealSize.Y
			)
		elseif currentSizes > ResSizes then
			local w = width(background)

			return Vector2.new(
				(AbsolutePosition.X - LeftSpace(w, background))
					/ w
					* background.RealSize.X,
				AbsolutePosition.Y
					/ background.ImageInstance.AbsoluteSize.Y
					* background.RealSize.Y
			)
		end
	end

	return Vector2.new(
		AbsolutePosition.X
			/ background.ImageInstance.AbsoluteSize.X
			* background.RealSize.X,
		AbsolutePosition.Y
			/ background.ImageInstance.AbsoluteSize.Y
			* background.RealSize.Y
	)
end

--[=[
	@param AbsoluteSize Vector3
	@param background ExImage
]=]
function calc.ReturnSize(
	AbsoluteSize: Vector3,
	background: ExImage.ExImage
): Vector3
	if background.ImageInstance.ScaleType == Enum.ScaleType.Fit then
		-- отношение изначальных размеров

		--отношение текущих размеров
		local currentSizes = RelativeSizes(background)
		local ResSizes = background.RealSize.X / background.RealSize.Y

		if currentSizes < ResSizes then -- то есть если есть поля сверху и снизу
			-- высота самого изображения
			local h = height(background)

			return Vector3.new(
				AbsoluteSize.X
					/ background.ImageInstance.AbsoluteSize.X
					* background.RealSize.X,
				AbsoluteSize.Y / h * background.RealSize.Y,
				AbsoluteSize.Z / h * background.RealSize.Y
			)
		elseif currentSizes > ResSizes then -- поля справа и слева
			local w = width(background)

			return Vector3.new(
				AbsoluteSize.X / w * background.RealSize.X,
				AbsoluteSize.Y
					/ background.ImageInstance.AbsoluteSize.Y
					* background.RealSize.Y,
				AbsoluteSize.Z
					/ background.ImageInstance.AbsoluteSize.Y
					* background.RealSize.Y
			)
		end
	end

	return Vector3.new(
		AbsoluteSize.X
			/ background.ImageInstance.AbsoluteSize.X
			* background.RealSize.X,
		AbsoluteSize.Y
			/ background.ImageInstance.AbsoluteSize.Y
			* background.RealSize.Y,
		AbsoluteSize.Z
			/ background.ImageInstance.AbsoluteSize.Y
			* background.RealSize.Y
	)
end

return calc
