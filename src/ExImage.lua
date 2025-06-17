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
}

function ExImage.new(id: string, isButton: boolean?)
	local function b()
		if isButton == true then
			return "Button"
		else
			return "Label"
		end
	end

	id = "rbxassetid://" .. id

	local ImageInstance = Instance.new("Image" .. b())
	ImageInstance.Image = id

	local self = {
		RealSize = AssetService:CreateEditableImageAsync(id).Size,
		ImageInstance = ImageInstance,
	}

	setmetatable(self, {
		__index = function(self, key)
			return self.ImageInstance[key]
		end,
	})

	return self
end

return ExImage
