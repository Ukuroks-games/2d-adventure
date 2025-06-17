local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ExImage = require(script.Parent.ExImage)
local stdlib = require(ReplicatedStorage.Packages.stdlib)
local algorithm = stdlib.algorithm

local Object2d = require(script.Parent.Object2d)
local camera2d = require(script.Parent.camera2d)

--[[
	Map class
]]
local map = {}

export type Map = {
	-- fields

	Image: ExImage.ExImage,

	Objects: { Object2d.Object2d },

	cam: camera2d.Camera2d,

	ObjectMovement: RBXScriptSignal,

	ObjectMovementEvent: BindableEvent,

	-- function

	SetPlayerPos: (self: Map, pos: Vector2) -> nil,

	CalcCollide: (self: Map) -> nil,

	Destroy: (self: Map) -> nil,

	CalcPositions: (self: Map) -> nil,

	AddObject: (self: Map, obj: Object2d.Object2d) -> nil,
}

function map.SetPlayerPos(self: Map, pos: Vector2)
	TweenService:Create(self.Image, TweenInfo.new(self.cam.CameraMoveSpeed / pos.Magnitude), {
		["Position"] = UDim2.fromScale(pos.X, pos.X),
	}):Play()
end

function map.AddObject(self: Map, obj: Object2d.Object2d)
	obj.Image.Parent = self.Image

	table.insert(self.Objects, obj)
end

function map.CalcPositions(self: Map)
	for _, v in pairs(self.Objects) do
		v.Image.Parent = self.Image
		v:CalcSizeAndPos(self.Image)
	end
end

function map.CalcCollide(self: Map)
	local Objects = algorithm.copy_if(self.Objects, function(value: Object2d.Object2d): boolean
		return value.CanCollide
	end)

	for _, v in pairs(Objects) do
		local i = algorithm.find_if(Objects, function(value: Object2d.Object2d): boolean
			return (
				(
					value.AnchorPosition.X >= v.AnchorPosition.X
					and value.AnchorPosition.X <= (v.AnchorPosition.X + v.Size.X)
				) -- check if value in v
				and (
					value.AnchorPosition.Y >= v.AnchorPosition.Y
					and value.AnchorPosition.Y <= (v.AnchorPosition.Y + v.Size.Y)
				)
			) -- обратная проверка не нужна т.к. и так проходим по всем
		end)
		local collided = (function()
			if i then
				return Objects[i]
			else
				return nil
			end
		end)()

		if collided then
			-- here checking side

			v.TouchedEvent:Fire(collided)
			collided.TouchedEvent:Fire(v)
		end
	end
end

function map.Destroy(self: Map)
	self.ObjectMovementEvent:Destroy()

	table.clear(self)
end

--[[
	Map constructor

	`Size` - Size of map. If you want that map scale to screen use Vector2.new(1, 1)
]]
function map.new(Size: Vector2, cam: camera2d.Camera2d, BackgroundImage: string, Objects: { Object2d.Object2d }?): Map
	local ObjectMovementEvent = Instance.new("BindableEvent")

	local self: Map = {
		Image = ExImage.new(BackgroundImage),
		Objects = Objects or {},
		cam = cam,
		ObjectMovement = ObjectMovementEvent.Event,
		ObjectMovementEvent = ObjectMovementEvent,
		SetPlayerPos = map.SetPlayerPos,
		CalcCollide = map.CalcCollide,
		AddObject = map.AddObject,
		CalcPositions = map.CalcPositions,
		Destroy = map.Destroy,
	}

	self.Image.Size = UDim2.fromScale(Size.X, Size.Y)
	self.Image.ScaleType = Enum.ScaleType.Fit

	return self
end

return map
