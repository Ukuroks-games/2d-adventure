local ReplicatedStorage = game:GetService("ReplicatedStorage")

local giflib = require(ReplicatedStorage.Packages.giflib)

local gifInfo = {}

export type Func = (parent: Frame?) -> giflib.Gif

function gifInfo.new(
	frames,
	loopAnimation: boolean?,
	showFirstFrameBeforeStart: boolean?,
	mode: number
): Func
	return function(parent: Frame?)
		return giflib.gif.new(
			frames,
			parent,
			loopAnimation,
			showFirstFrameBeforeStart,
			mode
		)
	end
end

return gifInfo
