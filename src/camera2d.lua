--!strict

--[=[
	@class Camera2d
]=]
local Camera2d = {}

export type Camera2d = {
	--[[
		Скорость следования за игроком
	]]
	CameraMoveSpeed: number,
}

function Camera2d.new(CameraMoveSpeed: number): Camera2d
	return {
		CameraMoveSpeed = CameraMoveSpeed,
	}
end

return Camera2d
