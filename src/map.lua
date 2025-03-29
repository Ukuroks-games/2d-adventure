local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local stdlib = require(ReplicatedStorage.Packages.stdlib)
local algorithm = stdlib.algorithm

local Object2d = require(script.Parent.Object2d)
local camera2d = require(script.Parent.camera2d)

--[[
	Map class
]]
local map = {}

export type Map = {
	Image: ImageLabel,

	Objects: {
		Object2d.Object2d
	},

	cam: camera2d.Camera2d,

	SetPlayerPos: (self: Map, pos: Vector2) -> nil,

	CalcCollide: (self: Map) -> nil
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

function map.CalcCollide(self: Map)
	
	local Objects = algorithm.copy_if(
		self.Objects,
		function(value: Object2d.Object2d): boolean 
			return value.CanCollide
		end
	)

	for _, v in pairs(Objects) do
		local i = algorithm.find_if(
			Objects, 
			function(value: Object2d.Object2d): boolean 
				return	( (value.AnchorPosition.X >= v.AnchorPosition.X and value.AnchorPosition.X <= (v.AnchorPosition.X + v.Size.X)) and	-- check if value in v
				      	  (value.AnchorPosition.Y >= v.AnchorPosition.Y and value.AnchorPosition.Y <= (v.AnchorPosition.Y + v.Size.Y)) ) 	-- обратная проверка не нужна т.к. и так проходим по всем
			end
		)
		local collided = (function()
			if i then
				return Objects[i]
			else
				return nil
			end
		end)()

		if collided	then
			
			-- here checking side

			v.TouchedEvent:Fire(collided)
			collided.TouchedEvent:Fire(v)
		end
	end

end

--[[
	Map constructor

	`Size` - Size of map. If you want that map scale to screen use Vector2.new(1, 1)
]]
function map.new(Size: Vector2, cam: camera2d.Camera2d, BackgroundImage: string, Objects: { Object2d.Object2d }?): Map
	local self: Map = {
		Image = Instance.new("ImageLabel"),
		Objects = Objects or {},
		cam = cam,
		SetPlayerPos = map.SetPlayerPos,
		CalcCollide = map.CalcCollide
	}

	self.Image.Image = "rbxassetid://" .. BackgroundImage

	self.Image.Size = UDim2.fromScale(Size.X, Size.Y)

	for _, v in pairs(self.Objects) do
		v.Parent = self.Image
	end

	return self
end

return map
