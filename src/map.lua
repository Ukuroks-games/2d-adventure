local TweenService = game:GetService("TweenService")

local camera2d = require(script.Parent.camera2d)

--[[
	Map class
]]
local map = {}

export type Map = {
	Image: ImageLabel,

	Objects: {
		Instance
	},

	cam: camera2d.Camera2d,

	SetPlayerPos: (self: Map, pos: Vector2) -> nil
}

function map.SetPlayerPos(self: Map, pos: Vector2)
	
	TweenService:Create(
		self.Image,
		TweenInfo.new(self.cam.CameraMoveSpeed / pos.Magnitude),
		{
			["Position"] = UDim2.fromScale(pos.X, pos.X)
		}
	):Play()

end

--[[
	Map constructor

	`Size` - Size of map. If you want that map scale to screen use Vector2.new(1, 1)
]]
function map.new(Size: Vector2, cam: camera2d.Camera2d, BackgroundImage: string, Objects: { Instance }?): Map
	local self: Map = {
		Image = Instance.new("ImageLabel"),
		Objects = Objects or {},
		cam = cam,
		SetPlayerPos = map.SetPlayerPos
	}

	self.Image.Image = "rbxassetid://" .. BackgroundImage

	self.Image.Size = UDim2.fromScale(Size.X, Size.Y)

	for _, v in pairs(self.Objects) do
		v.Parent = self.Image
	end

	return self
end

return map
