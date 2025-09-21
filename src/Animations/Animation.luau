--!strict

local giflib = require(script.Parent.Parent.Parent.giflib)
local gifInfo = require(script.Parent.Parent.gifInfo)

--[=[
	@class Animation
	@since v0.6.0

	Union for gif and audio
]=]
local Animation = {}

export type AnimationStruct = {
	gif: giflib.Gif,
	audio: AudioPlayer,
}

export type Animation = typeof(setmetatable(
	{} :: AnimationStruct,
	{ __index = Animation }
))


--[=[
	@method Stop
	@within Animation
	@since v0.6.0
]=]
function Animation.Stop(self: Animation)
	self.gif:StopAnimation()
	self.gif:Hide()
	self.audio:Stop()
end

--[=[
	@method Start
	@within Animation
	@since v0.6.0
]=]
function Animation.Start(self: Animation)
	self.gif:StartAnimation(true)
	self.audio:Play()
end

--[=[
	Constructor

	@param gif Func
	@param sound AudioPlayer
	@return Animation -- Created animation
	@since v0.6.0
]=]
function Animation.new(gif: gifInfo.Func, sound: AudioPlayer): Animation
	local self: AnimationStruct = {
		gif = gif(),
		audio = sound,
	}

	setmetatable(self, { __index = Animation })

	return self
end

return Animation
