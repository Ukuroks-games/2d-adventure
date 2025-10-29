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

export type ExImageStruct = {
	--[[
		Real image resolution
	]]
	RealSize: Vector2,

	ImageInstance: Image,
}

export type ExImage = typeof(setmetatable(
	{} :: ExImageStruct,
	{ __index = ExImage }
))

--[=[
	Destroy `ExImage`
]=]
function ExImage.Destroy(self: ExImage)
	self.ImageInstance:Destroy()
end

--[=[
	Clone `ExImage`
]=]
function ExImage.Clone(self: ExImage): ExImage
	local c = table.clone(self)
	c.ImageInstance = self.ImageInstance:Clone()
	return c
end

local function GetResolution(id: string, overrideSize: Vector2?): Vector2?
	if overrideSize then
		return overrideSize
	else
		
		local s, e = pcall(function(...)
			return AssetService:CreateEditableImageAsync(id).Size
		end)

		if s then
			return e
		else
			warn(e)
		end
	end

	return nil
end

--[=[
	Set id and recalc size
]=]
function ExImage.SetImage(self: ExImage, id: string, overrideSize: Vector2?)
	id = "rbxassetid://" .. id
	
	self.ImageInstance.Image = id

	self.RealSize = GetResolution(id, overrideSize) or Vector2.new()
end

--[=[
	ExImage constructor
]=]
function ExImage.new(
	id: string,
	isButton: boolean?,
	overrideSize: Vector2?
): ExImage
	local ImageInstance = Instance.new("Image" .. (function()
		if isButton == true then
			return "Button"
		else
			return "Label"
		end
	end)())

	local _self: ExImageStruct = {
		RealSize = Vector2.new(),
		ImageInstance = ImageInstance,
	}

	setmetatable(_self, { __index = ExImage })

	_self:SetImage(id, overrideSize)

	return _self
end

return ExImage
