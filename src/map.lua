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

function map.Destroy(self: Map, Player: player2d.Player2d)
	self.ObjectMovementEvent:Destroy()
	self:Done(Player)

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
		self:CalcZIndexs()
	end

	self.Image.Parent = GameFrame

	self.Image.Visible = true

	self:SetPlayer(Player)

	Player:SetPosition(Vector2.new())

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

function map.Done(self: Map, Player: player2d.Player2d)
	self.Image.Visible = false

	self:DeletePlayer(Player)

	for _, v in pairs(self.Connections) do
		if v then
			v:Disconnect()
		end
	end
end

function map.CalcZIndexs(self: MapStruct)
	table.sort(
		self.Objects,
		function(
			a: physicObject.PhysicObject,
			b: physicObject.PhysicObject
		): boolean
			return a.Image.AbsolutePosition.Y < b.Image.AbsolutePosition.Y
		end
	)

	for i, v in pairs(self.Objects) do
		v:SetZIndex(i + 1)
	end
end

function map.DeletePlayer(self: MapStruct, Player: player2d.Player2d)
	local p = table.find(self.Objects, Player)
	if p then
		self.Objects[p] = nil
	end
end

function map.SetPlayer(
	self: Map,
	newPlayer: player2d.Player2d,
	oldPlayer: player2d.Player2d?
)
	if oldPlayer then
		self:DeletePlayer(oldPlayer)
	end

	newPlayer.Size = self.PlayerSize or newPlayer.Size

	table.insert(self.Objects, newPlayer) -- add player to objects for enable collision for player
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
