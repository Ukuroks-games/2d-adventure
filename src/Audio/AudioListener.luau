--!nocheck

local Audio = require(script.Parent)
local Audio2dObject = require(script.Parent.Audio2dObject)
local physicObject = require(script.Parent.Parent.physicObject)

--[=[
	inherit from [Audio2dObject](Audio2dObject)

	Wrapper for [AudioListener](https://create.roblox.com/docs/reference/engine/classes/AudioListener)

	@class AudioListener2d
	@tag Audio

	@since v0.6.0
]=]
local AudioListener = setmetatable({}, { __index = Audio2dObject })

export type AudioListener2dStruct = {
	Output: Wire,
	Listener: AudioListener,
} & Audio2dObject.Audio2dObjectStruct

--[=[
	@interface AudioListener2d
	@within AudioListener2d

	@field Output Wire
	@field Listener AudioListener
]=]
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
	output: Wire,
	listener: AudioListener?
): AudioListener2d
	local self = Audio2dObject.new({
		Parent = p,
		Output = output,
		Listener = listener or Instance.new("AudioListener"),
	})	:: AudioListener2dStruct

	setmetatable(self, { __index = AudioListener })
	

	self.Listener.Parent = self.Part
	self.Listener.AudioInteractionGroup = AudioListener.Audio.DefaultGroup
	self.Output.SourceInstance = self.Listener

	return self
end

return AudioListener
