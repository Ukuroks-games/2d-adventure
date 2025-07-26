local AssetService = game:GetService("AssetService")

--[[
	Extentended Image
]]
local ExImage = {}

export type Image = ImageButton | ImageLabel

local function Index(self, key)
	local _, e = pcall(function()
		return self.ImageInstance[key]
	end)

	return e
end

local function NewIndex(self, key, value)
	if typeof(value) == typeof(self) then	-- if something like ExImage.Parent = ExImage
		self.ImageInstance[key] = value.ImageInstance
	else
		self.ImageInstance[key] = value
	end
end

export type ExImage = typeof(setmetatable({} :: {
	--[[
		Real image resolution
	]]
	RealSize: Vector2,

	ImageInstance: Image,
}, {__index = Index, __newindex = NewIndex}))

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
		__index = Index,
		__newindex = NewIndex,
	})

	return _self
end

return ExImage
