--!strict

local ExImage = require(script.Parent.ExImage)

local base2d = {}

export type Base2dStruct = {
	Image: ExImage.ExImage,
}

export type Base2d = typeof(setmetatable(
	{} :: Base2dStruct,
	{ __index = base2d }
))

function base2d.Preload(self: Base2dStruct | Base2d): { Instance }
	return { self.Image.ImageInstance }
end

function base2d.new(image: ExImage.ExImage): Base2d
	local self: Base2dStruct = {
		Image = image,
	}

	setmetatable(self, { __index = base2d })

	return self
end

return base2d
