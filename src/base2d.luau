--!strict

local stdlib = require(script.Parent.Parent.stdlib)
local ExImage = require(script.Parent.ExImage)

--[=[
	Base abstract class

	@class Base2d
]=]
local base2d = {}

export type Base2dStruct = {
	Image: ExImage.ExImage,
}

export type Base2d = typeof(setmetatable(
	{} :: Base2dStruct,
	{ __index = base2d }
))

--[=[
	@return { Instance }

	@method Preload
	@within Base2d
]=]
function base2d.Preload(self: Base2dStruct | Base2d): { Instance }
	return { self.Image.ImageInstance }
end

--[=[
	Clone

	@method Clone
	@within Base2d
]=]
function base2d.Clone<T>(self: T): T
	return stdlib.utility.clone(self)
end

--[=[
	@param image ExImage
	@return Base2d

	@within Base2d
]=]
function base2d.new(image: ExImage.ExImage): Base2d
	local self: Base2dStruct = {
		Image = image,
	}

	setmetatable(self, { __index = base2d })

	return self
end

return base2d
