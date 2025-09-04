local physicObject = require(script.Parent.Parent.physicObject)

local AudioListener = {}

export type AudioListener2dStruct = {
	Parent: physicObject.PhysicObject,
	Output: Wire,
	Listener: AudioListener,
	Part: Part,
}

export type AudioListener2d = typeof(setmetatable(
	{} :: AudioListener2dStruct,
	{ __index = AudioListener }
))

function AudioListener.new(
	p: physicObject.PhysicObject,
	output: Wire
): AudioListener2d
	local self: AudioListener2dStruct = {
		Parent = p,
		Output = output,
		Listener = Instance.new("AudioListener"),
		Part = Instance.new("Part"),
	}

	self.Listener.Parent = self.Part
	self.Output.SourceInstance = self.Listener

	setmetatable(self, { __index = AudioListener })

	return self
end

return AudioListener
