local Calc = require(script.Parent.Calc)
local stdlib = require(script.Parent.Parent.stdlib)

local ExImage = require(script.Parent.ExImage)
local base2d = require(script.Parent.base2d)
local config = require(script.Parent.config)
local physic = require(script.Parent.physic)

local mutex = stdlib.mutex

--[[
	Physic object

	interface for another classes, that can have physic
]]
local physicObject = setmetatable({}, { __index = base2d })

export type TouchSide = { PhysicObject }

--[[
	Struct contain list of another `PhysicObject`s  that touched this `PhysicObject`
]]
export type TouchedSides = {

	--[[
		Touched right side
	]]
	Right: TouchSide,

	--[[
		Touched left side
	]]
	Left: TouchSide,

	--[[
		Touched up side
	]]
	Up: TouchSide,

	--[[
		Touched bottom side
	]]
	Down: TouchSide,
}

export type PhysicObjectStruct = {

	--[[
		fire where PhysicObject touched another PhysicObject


		example:
		```luau
		obj.Touched:Connect(function(obj: PhysicObject)

		end)
		```
	]]
	Touched: RBXScriptSignal,

	TouchedEvent: BindableEvent,

	TouchedSide: TouchedSides,

	TouchedSideMutex: stdlib.Mutex,

	physicImage: Frame,

	ImageOffset: Vector2,

	ImageSize: Vector2,

	Size: Vector3,

	CanCollide: boolean,

	Anchored: boolean,

	TouchMsg: {
		[PhysicObject]: boolean,
	},

	TouchMsgMutex: stdlib.Mutex,

	ID: number,

	background: ExImage.ExImage?,

	TransparencyOnFocusedBack: number,

	InFocus: boolean,
} & base2d.Base2dStruct

--[[
	Счётчик id. при создании нового `physicObject` увеличивается на 1. Вообще надо бы заменить на нормальный контроллер id, но пока пофиг думаю 10^30 (наверное столько) хватит
]]
physicObject.Id = -999999999999990

export type PhysicObject =
	PhysicObjectStruct
	& typeof(physicObject)
	& base2d.Base2d

--[[

]]
function physicObject.Destroy(self: PhysicObjectStruct)
	self.TouchedEvent:Destroy()
	self.physicImage:Destroy()
end

--[[

]]
function physicObject.CheckCollision(
	self: PhysicObjectStruct,
	other: PhysicObjectStruct
): boolean
	return other ~= self
		and physic.CheckCollision(self.physicImage, other.physicImage)
end

--[[

]]
function physicObject.GetTouchedSide(self: PhysicObjectStruct): TouchedSides
	self.TouchedSideMutex:wait()
	return self.TouchedSide
end

--[[

]]
function physicObject.CalcSizeAndPos(self: PhysicObject)
	self:SetSize(self:GetSize())
	self:SetPosition(self:GetPosition())
	self:SetImageOffset(self.ImageOffset)
	self:SetImageSize(self.ImageSize)
end

--[[

]]
function physicObject.GetPosition(self: PhysicObject): Vector2
	return self:CalcPosition()
end

--[[

]]
function physicObject.CalcSize(self: PhysicObject): Vector3
	return Vector3.new(
		self.Image.ImageInstance.AbsoluteSize.X,
		self.Image.ImageInstance.AbsolutePosition.Y,
		self.physicImage.AbsoluteSize.Y
	)
end

--[[

]]
function physicObject.CalcPosition(self: PhysicObject): Vector2
	return self.Image.ImageInstance.AbsolutePosition
end

--[[

]]
function physicObject.GetSize(self: PhysicObject): Vector3
	return self:CalcSize()
end

--[[

]]
function physicObject.SetParent(
	self: PhysicObject,
	parent: Frame | ExImage.ExImage
)
	if typeof(parent) == "table" then
		self.physicImage.Parent = parent.ImageInstance
		self:SetBackground(parent)
	else
		self.physicImage.Parent = parent
	end
end

function physicObject.SetBackground(
	self: PhysicObject,
	background: ExImage.ExImage
)
	self.background = background
end

--[[

]]
function physicObject.SetPosition(self: PhysicObject, pos: Vector2)
	self:SetPositionX(pos.X)
	self:SetPositionY(pos.Y)
end

--[[
	Set physicObject position.
]]
function physicObject.SetPositionX(self: PhysicObject, pos: number)
	self.physicImage.Position =
		UDim2.fromOffset(pos, self.physicImage.Position.Y.Offset)
end

--[[
	Set physicObject position.
]]
function physicObject.SetPositionY(self: PhysicObject, pos: number)
	self.physicImage.Position = UDim2.fromOffset(
		self.physicImage.Position.X.Offset,
		pos
			+ self.Image.ImageInstance.AbsoluteSize.Y
			- self.physicImage.AbsoluteSize.Y
	)
end

--[[

]]
function physicObject.SetImageOffset(self: PhysicObject, pos: Vector2)
	self.ImageOffset = pos

	if self.background then
		local p = Calc.CalcSize(
			Vector3.new(self.ImageOffset.X, self.ImageOffset.Y),
			self.background
		)

		self.Image.ImageInstance.Position += UDim2.fromOffset(p.X, p.Y)
	end
end

--[[

]]
function physicObject.SetImageSize(self: PhysicObject, size: Vector2)
	self.ImageSize = size

	if self.background then
		local s = Calc.CalcSize(
			Vector3.new(self.ImageSize.X, self.ImageSize.Y),
			self.background
		)

		if self.ImageSize.X == -1 and self.ImageSize.Y ~= -1 then
			self.Image.ImageInstance.Size =
				UDim2.new(self.Image.ImageInstance.Size.X, UDim.new(0, s.X))
		elseif self.ImageSize.Y == -1 and self.ImageSize.X ~= -1 then
			self.Image.ImageInstance.Size =
				UDim2.new(UDim.new(0, s.X), self.Image.ImageInstance.Size.Y)
		elseif self.ImageSize.X ~= -1 and self.ImageSize.Y ~= -1 then
			self.Image.ImageInstance.Size = UDim2.fromOffset(s.X, s.Y)
		end
	end
end

--[[
	Изменить координаты напрямую
]]
function physicObject.SetPositionRaw(self: PhysicObject, pos: Vector2)
	self.physicImage.Position = UDim2.new(
		self.physicImage.Position.X.Scale,
		pos.X,
		self.physicImage.Position.Y.Scale,
		pos.Y
	)
end

--[[

]]
function physicObject.SetSize(self: PhysicObject, size: Vector3)
	self.Image.ImageInstance.Size = UDim2.new(0, size.X, 0, size.Y)

	self.Image.ImageInstance.Position = UDim2.new(0, 0, 0, size.Z - size.Y)
	self:SetImageOffset(self.ImageOffset)

	self.physicImage.Size = UDim2.fromOffset(size.X, size.Z)
	self:SetImageSize(self.ImageSize)
end

--[[
	Set ZIndex for physic object
]]
function physicObject.SetZIndex(self: PhysicObject, ZIndex: number)
	self.physicImage.ZIndex = ZIndex
	self.Image.ImageInstance.ZIndex = ZIndex
end

--[[

]]
function physicObject.StartPhysicCalc(self: PhysicObject)
	self.TouchedSideMutex:lock()
	table.clear(self.TouchMsg)
	for _, v in pairs(self.TouchedSide) do
		table.clear(v)
	end
end

--[[

]]
function physicObject.GetTouchMsg(
	self: PhysicObject,
	obj: PhysicObject
): boolean?
	mutex.wait(obj.TouchMsgMutex)
	return self.TouchMsg[obj]
end

--[[

]]
function physicObject.SetTouchMsg(
	self: PhysicObject,
	obj: PhysicObject,
	val: boolean?
)
	self.TouchMsgMutex:wait()
	self.TouchMsgMutex:lock()
	self.TouchMsg[obj] = val or true
	self.TouchMsgMutex:unlock()
end

--[[
	Get `PhysicObject` coordinates
]]
function physicObject.GetCoordinates(self: PhysicObject): Vector2
	if self.background then
		return Calc.ReturnPosition(
			Vector2.new(
				self.physicImage.AbsolutePosition.X
					- self.background.ImageInstance.AbsolutePosition.X,
				self.physicImage.AbsolutePosition.Y
					- self.background.ImageInstance.AbsolutePosition.Y
			),
			self.background
		)
	else -- без фона не получится посчитать
		error("self.background = nil") -- ошибка чтоб ненадобыло возвращать что-либо
	end
end

--[[
	Simple calculation of distance using the Pythagorean theorem.

	Returns the distance to `obj`
]]
function physicObject.GetDistanceTo(self: PhysicObject, obj: PhysicObject)
	local p1 = self:GetCoordinates()
	local p2 = obj:GetCoordinates()

	return math.sqrt(math.pow(p1.X - p2.X, 2) + math.pow(p1.Y - p2.X, 2))
end

--[[
	Physic object constructor

	`imageSize` by default -1, -1 (ignore)
]]
function physicObject.new(
	Image: ExImage.ExImage,
	canCollide: boolean?,
	checkingTouchedSize: boolean?,
	anchored: boolean?,
	background: ExImage.ExImage?,
	imageOffset: Vector2?,
	imageSize: Vector2?
): PhysicObject
	local TouchedEvent = Instance.new("BindableEvent")

	local this: PhysicObjectStruct = {
		Touched = TouchedEvent.Event,
		TouchedEvent = TouchedEvent,
		physicImage = Instance.new("Frame"),
		CanCollide = canCollide or true,
		TouchedSideMutex = mutex.new(false),
		TouchedSide = {
			Right = {},
			Left = {},
			Up = {},
			Down = {},
		},
		Anchored = (function()
			if anchored ~= nil then
				return anchored
			else
				return true
			end
		end)(),
		Size = Vector3.new(),
		Image = Image,
		TouchMsg = {},
		TouchMsgMutex = mutex.new(),
		ID = physicObject.Id,
		background = background,
		ImageOffset = imageOffset or Vector2.new(),
		ImageSize = imageSize or Vector2.new(-1, -1),
	}

	physicObject.Id += 1

	this.Image.ImageInstance.Parent = this.physicImage

	this.physicImage.BackgroundTransparency = (function()
		if config.ShowHitboxes then
			return config.HitboxesTransparent
		else
			return 1
		end
	end)()

	this.Touched:Connect(function(obj: PhysicObject)
		--[[
			Кароч в чем смысол алгоритма:

			находим центральные точки двух прямоугольников и смотрим как они расположены относительно друг друга

			А для конечного определения по какой оси было касание (вверх-низ, право-лево, обе) смотрим отношение 
			сторон области пересечения. 

			Касание по двум осям возможно если область пересечения - квадрат.
		]]
		if not this.Anchored or checkingTouchedSize then
			local p1x = this.physicImage.AbsolutePosition.X
				+ (this.physicImage.AbsoluteSize.X / 2)
			local p1y = this.physicImage.AbsolutePosition.Y
				+ (this.physicImage.AbsoluteSize.Y / 2)

			local p2x = obj.physicImage.AbsolutePosition.X
				+ (obj.physicImage.AbsoluteSize.X / 2)
			local p2y = obj.physicImage.AbsolutePosition.Y
				+ (obj.physicImage.AbsoluteSize.Y / 2)

			local w = (function()
				if
					this.physicImage.AbsolutePosition.X
					> obj.physicImage.AbsolutePosition.X
				then
					return obj.physicImage.AbsolutePosition.X
						+ obj.physicImage.AbsoluteSize.X
						- this.physicImage.AbsolutePosition.X
				else
					return this.physicImage.AbsolutePosition.X
						+ this.physicImage.AbsoluteSize.X
						- obj.physicImage.AbsolutePosition.X
				end
			end)()

			local h = (function()
				if
					this.physicImage.AbsolutePosition.Y
					> obj.physicImage.AbsolutePosition.Y
				then
					return obj.physicImage.AbsolutePosition.Y
						+ obj.physicImage.AbsoluteSize.Y
						- this.physicImage.AbsolutePosition.Y
				else
					return this.physicImage.AbsolutePosition.Y
						+ this.physicImage.AbsoluteSize.Y
						- obj.physicImage.AbsolutePosition.Y
				end
			end)()

			if h >= w then
				if p1x < p2x then
					table.insert(this.TouchedSide.Right, obj)
				else
					table.insert(this.TouchedSide.Left, obj)
				end
			end

			if h <= w then
				if p1y > p2y then
					table.insert(this.TouchedSide.Up, obj)
				else
					table.insert(this.TouchedSide.Down, obj)
				end
			end

			this.TouchedSideMutex:unlock()
		end
	end)

	this.Touched:Connect(function(obj: PhysicObject)
		if not this.Anchored then
			this.TouchedSideMutex:wait()

			local function calc(s: PhysicObject, b: PhysicObject, m: number)
				local X, Y =
					s.physicImage.Position.X.Offset,
					s.physicImage.Position.Y.Offset

				local function cmp(value: PhysicObject): boolean
					return value.ID == b.ID
				end

				if stdlib.algorithm.find_if(s.TouchedSide.Up, cmp) then
					Y += (b.physicImage.AbsolutePosition.Y + b.physicImage.AbsoluteSize.Y - s.physicImage.AbsolutePosition.Y) / m
				end

				if stdlib.algorithm.find_if(s.TouchedSide.Down, cmp) then
					Y -= (s.physicImage.AbsolutePosition.Y + s.physicImage.AbsoluteSize.Y - b.physicImage.AbsolutePosition.Y) / m
				end

				if stdlib.algorithm.find_if(s.TouchedSide.Left, cmp) then
					X += (b.physicImage.AbsolutePosition.X + b.physicImage.AbsoluteSize.X - s.physicImage.AbsolutePosition.X) / m
				end

				if stdlib.algorithm.find_if(s.TouchedSide.Right, cmp) then
					X -= (s.physicImage.AbsolutePosition.X + s.physicImage.AbsoluteSize.X - b.physicImage.AbsolutePosition.X) / m
				end

				s:SetPositionRaw(Vector2.new(X, Y))
			end

			if not obj.Anchored and physicObject.GetTouchMsg(obj, this) then
				calc(this, obj, 2)
				this:SetTouchMsg(obj)
			else
				calc(this, obj, 1)
			end
		end
	end)

	return this
end

return physicObject
