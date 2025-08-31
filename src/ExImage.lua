--!nonstrict

local AssetService = game:GetService("AssetService")

--[=[
	Extended Image.

	> Attributes?	NO!
	>
	> THIS SHIT?	YES!

	@class ExImage
]=]
local ExImage = {}

export type Image = ImageLabel

export type ExImage = {
	--[[
		Real image resolution
	]]
	RealSize: Vector2,

	ImageInstance: Image,
}

--[=[
	ExImage constructor
]=]
function ExImage.new(
	id: string,
	isButton: boolean?,
	overrideSize: Vector2?
): ExImage
	id = "rbxassetid://" .. id

	local ImageInstance = Instance.new("Image" .. (function()
		if isButton == true then
			return "Button"
		else
			return "Label"
		end
	end)())
	ImageInstance.Image = id

	local s, e = pcall(function(...)
		return AssetService:CreateEditableImageAsync(id).Size
	end)

	local size

	if s then
		size = overrideSize or e
	else
		size = overrideSize
	end

	local _self = {
		RealSize = size,
		ImageInstance = ImageInstance,
	}

	return _self
end

return ExImage
