
--[[
	Map class
]]
local map = {}

export type Map = {
	Image: ImageLabel,
	Size: { 
		X: number,
		Y: number
	},
	Objects: {

	}
}

function map.new(): Map
	local self: Map = {
		Image = Instance.new("ImageLabel"),
		Size = {
			X = 0,
			Y = 0
		},
		Objects = {}
	}

	return self
end

return map
