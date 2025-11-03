-- services

local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")

--

local Calc = require(script.Parent.Calc)
local ExImage = require(script.Parent.ExImage)
local Object2d = require(script.Parent.Object2d)
local camera2d = require(script.Parent.camera2d)
local physic = require(script.Parent.physic)
local physicObject = require(script.Parent.physicObject)
local player2d = require(script.Parent.player)
local PhysicController = require(script.Parent.PhysicController)

--[=[
	Map class

	@class Map
]=]
local map = setmetatable({}, { __index = PhysicController })

export type MapStruct = {
	-- fields

	Image: ExImage.ExImage,

	cam: camera2d.Camera2d,

	ObjectMovement: RBXScriptSignal,

	ObjectMovementEvent: BindableEvent,

	StartPosition: Vector2?,

	PlayerSize: Vector3?,

	Connections: { RBXScriptConnection },
} & PhysicController.PhysicControllerStruct

export type Map = MapStruct & typeof(map) & PhysicController.PhysicController

--[[
	Calc position for move Player to position on the map

	Зачем? Игрок находится в центре а координаты от левого верхнего угла изображения
]]
function map.CalcPlayerPositionAbsolute(
	self: Map,
	player: player2d.Player2d,
	pos: Vector2
): Vector2
	return Vector2.new(
		(player.Image.ImageInstance.AbsolutePosition.X - player.background.ImageInstance.AbsolutePosition.X) - pos.X,
		(player.Image.ImageInstance.AbsolutePosition.Y - player.background.ImageInstance.AbsolutePosition.Y) - pos.Y
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
	local function CalcPositions()
		self:CalcPositions()
		self:CalcZIndexs()

		local speed = Calc.CalcSize(
			Vector3.new(Player.WalkSpeed.X, Player.WalkSpeed.Y, 0),
			self.Image
		)

		Player.WalkSpeed.Calculated = Vector2.new(speed.X, speed.Y)
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

	Player:CalcSizeAndPos()

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
			local A = a.physicImage.AbsolutePosition.Y
			local B = b.physicImage.AbsolutePosition.Y
			return A < B
		end
	)

	for i, v in pairs(self.Objects) do
		v:SetZIndex(i + 1)

		if v.InFocus then
			for j = i + 1, #self.Objects do
				local f: physicObject.PhysicObject? = (
					self.Objects :: { physicObject.PhysicObject }
				)[j]

				if f then --  if v in the end
					if
						not f.InFocus
						and physic.CheckCollision(
							v.Image.ImageInstance,
							f.Image.ImageInstance
						)
					then
						f.Image.ImageInstance.ImageTransparency =
							f.TransparencyOnFocusedBack
					else
						f.Image.ImageInstance.ImageTransparency = 0
					end
				end
			end
		end
	end
end

function map.DeletePlayer(self: Map, Player: player2d.Player2d)
	local Objects = self.Objects

	local p = table.find(Objects, Player)

	if p then
		table.remove(Objects, p)
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

--[=[
	@param Progress NumberValue

	@method Loading
	@within Map
]=]
function map.Loading(self: Map, Progress: NumberValue)
	local i = 0
	local PreloadList = { self.Image.ImageInstance }
	for _, v in pairs(self.Objects) do
		for _, j in pairs(v:Preload()) do
			table.insert(PreloadList, j)
		end

		i += 1
		Progress.Value = i / (#self.Objects + 1)
	end

	ContentProvider:PreloadAsync(PreloadList)

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
		StartPosition = startPosition or Vector2.new(),
		PlayerSize = playerSize,
		Connections = {},
		PlayerIndex = nil,
	}

	setmetatable(self, { __index = map })

	if Objects then
		for _, v in pairs(Objects) do
			map.AddObject(self, v)
		end
	end

	self.Image.ImageInstance.Size = UDim2.fromScale(Size.X, Size.Y)
	self.Image.ImageInstance.ScaleType = Enum.ScaleType.Fit

	return self :: Map
end

return map
