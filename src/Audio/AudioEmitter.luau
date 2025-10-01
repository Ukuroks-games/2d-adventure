local Audio2dObject = require(script.Parent.Audio2dObject)
local physicObject = require(script.Parent.Parent.physicObject)

--[=[
	inherit from [Audio2dObject](Audio2dObject)

	@class AudioEmitter2d
	@tag Audio
	@since v0.6.0
]=]
local AudioEmitter = setmetatable({}, { __index = Audio2dObject })

export type AudioEmitter2dStruct = {
	Input: Wire,
	Emitter: AudioEmitter,
} & Audio2dObject.Audio2dObjectStruct

--[=[
	@interface AudioEmitter2d
	@within AudioEmitter2d

	@field Input Wire
	@field Emitter AudioEmitter
]=]
export type AudioEmitter2d =
	AudioEmitter2dStruct
	& typeof(AudioEmitter)
	& Audio2dObject.Audio2dObject

--[=[
	Constructor

	@param parent PhysicObject
	@param input Wire
	@return AudioEmitter2d

	@within AudioEmitter2d
]=]
function AudioEmitter.new(
	parent: physicObject.PhysicObject,
	input: Wire,
	emitter: AudioEmitter?
): AudioEmitter2d
	local self = Audio2dObject.new({
		Parent = parent,
		Input = input,
		Emitter = emitter or Instance.new("AudioEmitter"),
	}) :: AudioEmitter2dStruct

	setmetatable(self, { __index = AudioEmitter })

	self.Emitter.Parent = self.Part

	self.Input.TargetInstance = self.Emitter

	return self
end

return AudioEmitter
