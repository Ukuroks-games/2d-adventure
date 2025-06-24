local AssetService = game:GetService("AssetService")

--[[
	Extentended Image
]]
local ExImage = {}

export type Image = ImageButton | ImageLabel

export type ExImage = {
	--[[
		Real image resolution
	]]
	RealSize: Vector2,

	ImageInstance: Image,
} & Image

function ExImage.new(id: string, isButton: boolean?): ExImage
	id = "rbxassetid://" .. id

	local ImageInstance = Instance.new("Image" .. (function()
		if isButton == true then
			return "Button"
		else
			return "Label"
		end
	end)())
	ImageInstance.Image = id

	local _self = {
		RealSize = AssetService:CreateEditableImageAsync(id).Size,
		ImageInstance = ImageInstance,
	}

	setmetatable(_self, {
		__index = function(self: typeof(_self), key)
			local _, e = pcall(function()
				return self.ImageInstance[key]
			end)

			return e or rawget(self, key)
		end,
		__newindex = function(self: typeof(_self), key, value)
			if typeof(value) == typeof(_self) then
				self.ImageInstance[key] = value.ImageInstance
			else
				self.ImageInstance[key] = value
			end
		end,
	})

	return _self
end

return ExImage
