local ReplicatedStorage = game:GetService("ReplicatedStorage")

local giflib = require(ReplicatedStorage.Packages.giflib)
local gifInfo = require(ReplicatedStorage.Packages["2d-adventure"].gifInfo)
local Animation = {}

export type AnimationStruct = {
	gif: giflib.Gif,
	audio: AudioPlayer,
}

export type Animation = typeof(setmetatable(
	{} :: AnimationStruct,
	{ __index = Animation }
))

function Animation.Stop(self: Animation)
	self.gif:StopAnimation()
	self.gif:Hide()
	self.audio:Stop()
end

function Animation.Start(self: Animation)
	self.gif:StartAnimation(true)
	self.audio:Play()
end

function Animation.new(gif: gifInfo.Func, sound: AudioPlayer): Animation
	local self: AnimationStruct = {
		gif = gif(),
		audio = sound,
	}

	setmetatable(self, { __index = Animation })

	return self
end

return Animation
