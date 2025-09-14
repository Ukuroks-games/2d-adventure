local ReplicatedStorage = game:GetService("ReplicatedStorage")

local gifInfo = require(ReplicatedStorage.Packages["2d-adventure"].gifInfo)
local Animation = {}


export type AnimationStruct = {}

export type Animation = typeof(setmetatable({} :: AnimationStruct, {__index = Animation}))

function Animation.new(gif: gifInfo.Func, sound: AudioPlayer): Animation
	local self: AnimationStruct = {

	}

	setmetatable(self, {__index = Animation})


	return self
end

return Animation
