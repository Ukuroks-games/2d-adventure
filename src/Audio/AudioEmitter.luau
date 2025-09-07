local Audio2dObject = require(script.Parent.Audio2dObject)
local physicObject = require(script.Parent.Parent.physicObject)

--[=[
	@class AudioEmitter2d
]=]
local AudioEmitter = setmetatable({}, { __index = Audio2dObject })

export type AudioEmitter2dStruct = {
	Input: Wire,
	Emitter: AudioEmitter,
} & Audio2dObject.Audio2dObjectStruct

export type AudioEmitter2d =
	AudioEmitter2dStruct
	& typeof(AudioEmitter)
	& Audio2dObject.Audio2dObject

--[=[
	Constructor

	@param parent PhysicObject
	@param input Wire

	@within AudioEmitter2d
]=]
function AudioEmitter.new(
	parent: physicObject.PhysicObject,
	input: Wire
): AudioEmitter2d
	local self = Audio2dObject.new({
		Parent = parent,
		Input = input,
		Emitter = Instance.new("AudioEmitter"),
	})

	setmetatable(self :: AudioEmitter2dStruct, { __index = AudioEmitter })

	self.Part.CanCollide = false
	self.Part.CanTouch = false

	self.Emitter.Parent = self.Part

	self.Input.TargetInstance = self.Emitter

	return self
end

return AudioEmitter
