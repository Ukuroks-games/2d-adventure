--!strict

local Audio = require(script.Parent)
local config = require(script.Parent.Parent.config)
local physicObject = require(script.Parent.Parent.physicObject)

--[=[
	@class Audio2dObject

	Abstract class for another classes
	@tag Audio
	@since v0.6.0
]=]
local Audio2dObject = {}

export type Audio2dObjectStruct = {
	Part: Part,
	Parent: physicObject.PhysicObject,
}

--[=[
	@interface Audio2dObject
	@within Audio2dObject

	@field Part Part
	@field Parent PhysicObject
]=]
export type Audio2dObject = typeof(setmetatable(
	{} :: Audio2dObjectStruct,
	{ __index = Audio2dObject }
))

--[=[

	@param self Audio2dObject

	@method UpdatePosition
	@within Audio2dObject
]=]
function Audio2dObject.UpdatePosition(self: Audio2dObject)
	local pos = self.Parent:GetCenterCoordinates()
	
	self.Part.Position = Vector3.new(
		(pos.X) / self.Parent.background.RealSize.X * config.AudioDistanceFactor,
		pos.Y / self.Parent.background.RealSize.Y * config.AudioDistanceFactor,
		0
	) + config.AudioPosition
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

	self.Part.Parent = Audio.Folder
	self.Part.CanCollide = false
	self.Part.CanTouch = false
	self.Part.Anchored = true
	self.Part.Transparency = 1

	for i, v in pairs(override) do
		self[i] = v
	end

	local function UpdatePos()
		self:UpdatePosition()
	end

	UpdatePos()

	return self :: Audio2dObject & { [I]: T }
end

return Audio2dObject
