local ReplicatedStorage = game:GetService("ReplicatedStorage")

local giflib = require(ReplicatedStorage.Packages.giflib)

local gifInfo = {}

export type Func = (parent: Frame?) -> giflib.Gif

function gifInfo.new(
	frames,
	loopAnimation: boolean?,
	showFirstFrameBeforeStart: boolean?,
	mode: number?,
	resampleMode: Enum.ResamplerMode?
): Func
	return function(parent: Frame?)
		local gif = giflib.gif.new(
			frames,
			parent,
			loopAnimation,
			showFirstFrameBeforeStart,
			mode
		)

		if resampleMode then
			gif:SetResampleMode(resampleMode)
		end

		return gif
	end
end

return gifInfo
