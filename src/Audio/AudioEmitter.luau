local physicObject = require(script.Parent.Parent.physicObject)

local AudioObject = {}

export type AudioObject2dStruct = {
	Parent: physicObject.PhysicObject,
	Input: Wire,
	Emitter: AudioEmitter,
	Part: Part,
}

export type AudioObject2d = typeof(setmetatable(
	{} :: AudioObject2dStruct,
	{ __index = AudioObject }
))

function AudioObject.UpdatePosition(self: AudioObject2d)
	local pos = self.Parent:GetCoordinates()
	self.Part.Position = Vector3.new(pos.X, pos.Y, 0)
end

function AudioObject.new(
	parent: physicObject.PhysicObject,
	input: Wire
): AudioObject2d
	local self: AudioObject2dStruct = {
		Parent = parent,
		Input = input,
		Emitter = Instance.new("AudioEmitter"),
		Part = Instance.new("Part"),
	}
	self.Part.CanCollide = false
	self.Part.CanTouch = false

	self.Emitter.Parent = self.Part

	self.Input.TargetInstance = self.Emitter

	setmetatable(self, { __index = AudioObject })

	self:UpdatePosition()

	return self
end

return AudioObject
