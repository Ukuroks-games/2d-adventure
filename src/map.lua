local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ExImage = require(script.Parent.ExImage)
local stdlib = require(ReplicatedStorage.Packages.stdlib)
local algorithm = stdlib.algorithm

local Object2d = require(script.Parent.Object2d)
local camera2d = require(script.Parent.camera2d)
local physicObject = require(script.Parent.physicObject)
local player2d = require(script.Parent.player)

--[[
	Map class
]]
local map = {}

export type MapStruct = {
	-- fields

	Image: ExImage.ExImage,

	Objects: { physicObject.PhysicObject },

	PlayerIndex: number?,

	cam: camera2d.Camera2d,

	ObjectMovement: RBXScriptSignal,

	ObjectMovementEvent: BindableEvent,

	StartPosition: Vector2?,

	PlayerSize: Vector3?,

	Connections: { RBXScriptConnection },
}

export type Map = MapStruct & typeof(map)

--[[
	Calc position for move Player to position on the map

	Зечем? Игрок находится в центре а координаты от левого верхнего угла изображения
]]
function map.CalcPlayerPositionAbsolute(
	self: MapStruct,
	player: player2d.Player2d,
	pos: Vector2
): Vector2
	return Vector2.new(
		player.Image.AbsolutePosition.X - pos.X,
		player.Image.AbsolutePosition.Y - pos.Y
	)
end

--[[

]]
function map.CalcPlayerPosition(
	self: MapStruct,
	player: player2d.Player2d,
	pos: Vector2
): Vector2
	return map.CalcPlayerPositionAbsolute(
		self,
		player,
		Object2d.CalcPosition(pos, self.Image)
	)
end

--[[

]]
function map.GetSetPlayerPosTween(
	self: MapStruct,
	player: player2d.Player2d,
	pos: Vector2
): Tween
	local p = map.CalcPlayerPosition(self, player, pos)

	return TweenService:Create(
		self.Image.ImageInstance,
		TweenInfo.new(self.cam.CameraMoveSpeed / pos.Magnitude),
		{
			["Position"] = UDim2.fromOffset(p.X, p.X),
		}
	)
end

function map.AddObject(self: MapStruct, obj: physicObject.PhysicObject)
	obj:SetParent(self.Image)

	table.insert(self.Objects, obj)
end

function map.CalcPositions(self: MapStruct)
	for _, v in pairs(self.Objects) do
		v:CalcSizeAndPos(self.Image)
	end
end

function map.CalcCollide(self: MapStruct)
	--[[
		Список объектов которые имеют колизию
	]]
	local Objects = algorithm.copy_if(self.Objects, function(value): boolean
		return value.CanCollide
	end)

	for _, v in pairs(Objects) do
		v.TouchedSideMutex:lock()

		v.TouchedSide.Up = false -- reset TouchedSide
		v.TouchedSide.Down = false
		v.TouchedSide.Left = false
		v.TouchedSide.Right = false

		local i = algorithm.find_if(Objects, function(value): boolean
			return physicObject.CheckCollision(v, value)
		end)

		if i then
			-- here checking side

			v.TouchedEvent:Fire(Objects[i]) -- connection defined in physicObject constructor must unlock mutex
		else
			v.TouchedSideMutex:unlock()
		end
	end
end

function map.Destroy(self: Map)
	self.ObjectMovementEvent:Destroy()
	self:Done()

	table.clear(self)
end

--[[

]]
function map.SetPlayerPosition(
	self: MapStruct,
	player: player2d.Player2d,
	pos: Vector2
)
	local p = map.CalcPlayerPosition(self, player, pos)
	self.Image.Position = UDim2.fromOffset(p.X, p.Y)
end

function map.Init(self: Map, Player: player2d.Player2d, GameFrame: Frame)
	local function CalcPositions()
		self:CalcPositions()
	end

	self.Image.Parent = GameFrame

	self.Image.Visible = true

	Player.Size = self.PlayerSize or Player.Size

	table.insert(self.Objects, Player) -- add player to objects for enable collision for player
	self.PlayerIndex = #self.Objects

	CalcPositions() -- превоночальный расчет

	self:SetPlayerPosition(Player, self.StartPosition or Vector2.new(0, 0))

	--[[
		расчет после изменения фрейма игры
	]]
	table.insert(
		self.Connections,
		GameFrame:GetPropertyChangedSignal("Size"):Connect(CalcPositions)
	)
end

function map.Done(self: Map)
	self.Image.Visible = false

	if self.PlayerIndex then
		self.Objects[self.PlayerIndex] = nil
		self.PlayerIndex = nil
	end

	for _, v in pairs(self.Connections) do
		if v then
			v:Disconnect()
		end
	end
end

--[[
	Map constructor

	`Size` - Size of map. If you want that map scale to screen use Vector2.new(1, 1)
]]
function map.new(
	Size: Vector2,
	cam: camera2d.Camera2d,
	BackgroundImage: string,
	Objects: { [any]: Object2d.Object2d }?,
	startPosition: Vector2?,
	playerSize: Vector3?
): Map
	local ObjectMovementEvent = Instance.new("BindableEvent")

	local self: MapStruct = {
		Image = ExImage.new(BackgroundImage),
		Objects = {},
		cam = cam,
		ObjectMovement = ObjectMovementEvent.Event,
		ObjectMovementEvent = ObjectMovementEvent,
		StartPosition = startPosition,
		PlayerSize = playerSize,
		Connections = {},
		PlayerIndex = nil,
	}

	if Objects then
		for _, v in pairs(Objects) do
			map.AddObject(self, v)
		end
	end

	self.Image.Size = UDim2.fromScale(Size.X, Size.Y)
	self.Image.ScaleType = Enum.ScaleType.Fit

	setmetatable(self, { __index = map })

	return self
end

return map
