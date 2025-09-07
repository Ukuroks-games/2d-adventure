local Audio2dObject = require(script.Parent.Audio2dObject)
local physicObject = require(script.Parent.Parent.physicObject)

--[=[
	inherit from [AudioListener2d](AudioListener2d)

	@class AudioListener2d

]=]
local AudioListener = setmetatable({}, { __index = Audio2dObject })

export type AudioListener2dStruct = {
	Output: Wire,
	Listener: AudioListener,
} & Audio2dObject.Audio2dObjectStruct

export type AudioListener2d =
	AudioListener2dStruct
	& typeof(AudioListener)
	& Audio2dObject.Audio2dObject

--[=[
	Constructor

	@param p PhysicObject
	@param output Wire

	@within AudioListener2d
]=]
function AudioListener.new(
	p: physicObject.PhysicObject,
	output: Wire
): AudioListener2d
	local self = Audio2dObject.new({
		Parent = p,
		Output = output,
		Listener = Instance.new("AudioListener"),
	})

	setmetatable(self, { __index = AudioListener })

	self.Listener.Parent = self.Part
	self.Output.SourceInstance = self.Listener

	return self
end

return AudioListener
