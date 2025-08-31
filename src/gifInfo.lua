--!strict

local giflib = require(script.Parent.Parent.giflib)

--[=[
	@class gifInfo
]=]
local gifInfo = {}

--[=[
	@type Func (parent: Frame?)->giflib.Gif
	@within gifInfo
]=]
export type Func = (parent: Frame?) -> giflib.Gif

--[=[
	@function new
	@within gifInfo
]=]
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
