-- services

local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")

-- libs

local Calc = require(script.Parent.Calc)
local stdlib = require(script.Parent.Parent.stdlib)
local algorithm = stdlib.algorithm

--

local ExImage = require(script.Parent.ExImage)
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

	Objects: { [number]: physicObject.PhysicObject },

	cam: camera2d.Camera2d,

	ObjectMovement: RBXScriptSignal,

	ObjectMovementEvent: BindableEvent,

	StartPosition: Vector2?,

	PlayerSize: Vector3?,

	Connections: { RBXScriptConnection },
}

export type Map = typeof(setmetatable({} :: MapStruct, { __index = map }))

--[[
	Calc position for move Player to position on the map

	Зечем? Игрок находится в центре а координаты от левого верхнего угла изображения
]]
function map.CalcPlayerPositionAbsolute(
	self: Map,
	player: player2d.Player2d,
	pos: Vector2
): Vector2
	return Vector2.new(
		player.Image.ImageInstance.AbsolutePosition.X - pos.X,
		player.Image.ImageInstance.AbsolutePosition.Y - pos.Y
	)
end

--[[

]]
function map.CalcPlayerPosition(
	self: Map,
	player: player2d.Player2d,
	pos: Vector2
): Vector2
	return map.CalcPlayerPositionAbsolute(
		self,
		player,
		Calc.CalcPosition(pos, self.Image)
	)
end

--[[

]]
function map.GetSetPlayerPosTween(
	self: Map,
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

function map.AddObject(self: Map, obj: physicObject.PhysicObject)
	obj:SetParent(self.Image)

	table.insert(self.Objects, obj)
end

function map.CalcPositions(self: Map)
	for _, v in pairs(self.Objects) do
		v:CalcSizeAndPos()
	end
end

function map.CalcCollide(self: Map)
	--[[
		Список объектов которые имеют коллизию
	]]
	local Objects = algorithm.copy_if(self.Objects, function(value): boolean
		return value.CanCollide
	end)

	for _, v in pairs(Objects) do
		v:StartPhysicCalc()
	end

	for _, v in pairs(Objects) do
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
	self: Map,
	player: player2d.Player2d,
	pos: Vector2
)
	local p = map.CalcPlayerPosition(self, player, pos)
	self.Image.ImageInstance.Position = UDim2.fromOffset(p.X, p.Y)
end

--[[
	Init map
]]
function map.Init(self: Map, Player: player2d.Player2d, GameFrame: Frame)
	local b = 0
	local c = 0

	local function CalcPositions()
		self:CalcPositions()
		self:CalcZIndexs()

		local speed = Calc.CalcSize(
			Vector3.new(Player.WalkSpeed.X, Player.WalkSpeed.Y, 0),
			self.Image
		)

		Player.WalkSpeed.Calculated = Vector2.new(speed.X, speed.Y)

		if
			self.Image.ImageInstance.ScaleType == Enum.ScaleType.Fit
			and self.Image.ImageInstance.Parent
		then

			print(self.Image.ImageInstance.Position)
			print(self.Image.ImageInstance.Size)

			local A = (
				self.Image.ImageInstance.AbsoluteSize.X
				/ self.Image.ImageInstance.AbsoluteSize.Y
			)
			local B = (self.Image.RealSize.X / self.Image.RealSize.Y)
			if A > B then
				local a = (
					Calc.LeftSpace(Calc.width(self.Image), self.Image)
					/ self.Image.ImageInstance.Parent.AbsoluteSize.X
				) / 4
				self.Image.ImageInstance.Position = UDim2.fromScale(
					self.Image.ImageInstance.Position.X.Scale - (a - b),
					self.Image.ImageInstance.Position.Y.Scale
				)
				b = a
			elseif A < B then
				local d = (
					Calc.UpSpace(Calc.height(self.Image), self.Image)
					/ self.Image.ImageInstance.Parent.AbsoluteSize.Y
				) / 4

				self.Image.ImageInstance.Position = UDim2.fromScale(
					self.Image.ImageInstance.Position.X.Scale,
					self.Image.ImageInstance.Position.Y.Scale - (d - c) 
				)
				c = d
			end

		end
	end

	self.Image.ImageInstance.Parent = GameFrame

	self.Image.ImageInstance.Visible = true

	self:SetPlayer(Player)

	Player:SetPosition(Vector2.new())

	for _, v in pairs(self.Objects) do
		v:SetBackground(self.Image)
	end

	CalcPositions() -- первоначальный расчет

	self:SetPlayerPosition(Player, self.StartPosition or Vector2.new(0, 0))

	--[[
		расчет после изменения фрейма игры
	]]
	table.insert(
		self.Connections,
		GameFrame:GetPropertyChangedSignal("AbsoluteSize")
			:Connect(CalcPositions)
	)
end

--[[
	Done map.

	It needed for change map. After `Init` map must call `Done` method
]]
function map.Done(self: Map, Player: player2d.Player2d)
	self.Image.ImageInstance.Visible = false

	self:DeletePlayer(Player)

	for _, v in pairs(self.Connections) do
		if v then
			v:Disconnect()
		end
	end
end

--[[
	Calc ZIndex for all objects on map
]]
function map.CalcZIndexs(self: Map)
	table.sort(
		self.Objects,
		function(
			a: physicObject.PhysicObject,
			b: physicObject.PhysicObject
		): boolean
			return a.physicImage.AbsolutePosition.Y
				< b.physicImage.AbsolutePosition.Y
		end
	)

	for i, v in pairs(self.Objects) do
		v:SetZIndex(i + 1)
	end
end

function map.DeletePlayer(self: Map, Player: player2d.Player2d)
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

function map.Loading(self: Map, Progress: NumberValue)
	local i = 0
	for _, v in pairs(self.Objects) do
		v:Preload()

		i += 1
		Progress.Value = i / (#self.Objects + 1)
	end

	ContentProvider:PreloadAsync({ self.Image.ImageInstance.Image })

	Progress.Value = 1
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

	setmetatable(self, { __index = map })

	if Objects then
		for _, v in pairs(Objects) do
			self:AddObject(v)
		end
	end

	self.Image.ImageInstance.Size = UDim2.fromScale(Size.X, Size.Y)
	self.Image.ImageInstance.ScaleType = Enum.ScaleType.Fit

	return self
end

return map
