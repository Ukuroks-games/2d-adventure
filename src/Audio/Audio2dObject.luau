local config = require("../config")
local physicObject = require(script.Parent.Parent.physicObject)

--[=[
	@class Audio2dObject

	Abstract class for another classes
]=]
local Audio2dObject = {}

export type Audio2dObjectStruct = {
	Part: Part,
	Parent: physicObject.PhysicObject,
}

export type Audio2dObject = typeof(setmetatable(
	{} :: Audio2dObjectStruct,
	{ __index = Audio2dObject }
))

--[=[
	@method UpdatePosition
	@within Audio2dObject
]=]
function Audio2dObject.UpdatePosition(self: Audio2dObject)
	local pos = self.Parent:GetCoordinates()
	self.Part.Position = Vector3.new(pos.X, pos.Y, 0) + config.AudioPosition
end

--[=[
	Constructor

	@param override
]=]
function Audio2dObject.new<I, T>(override: {
	Parent: physicObject.PhysicObject,
	[I]: T,
}): Audio2dObject & { [I]: T }
	local self = setmetatable(
		{
			Part = Instance.new("Part"),
		} :: Audio2dObjectStruct,
		{ __index = Audio2dObject }
	)

	self.Part.Parent = workspace
	self.Part.CanCollide = false
	self.Part.CanTouch = false
	self.Part.Anchored = true

	for i, v in pairs(override) do
		self[i] = v
	end

	local function UpdatePos()
		self:UpdatePosition()
	end

	UpdatePos()

	return self
end

return Audio2dObject
