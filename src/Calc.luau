local ExImage = require(script.Parent.ExImage)

local calc = {}

--[[

]]
function calc.CalcPosition(
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
function calc.CalcSize(Size: Vector3, background: ExImage.ExImage): Vector3
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

return calc
