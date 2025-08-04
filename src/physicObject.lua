local stdlib = require(script.Parent.Parent.stdlib)
local ExImage = require(script.Parent.ExImage)
local config = require(script.Parent.config)

local mutex = stdlib.mutex

--[[
	Physic object

	interface for another classes, that can have physic
]]
local physicObject = {}

export type TouchSide = { PhysicObject }

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
		```lua
		obj.Touched:Connect(function(obj: PhysicObject)

		end)
		```
	]]
	Touched: RBXScriptSignal,

	TouchedEvent: BindableEvent,

	TouchedSide: TouchedSides,

	TouchedSideMutex: stdlib.Mutex,

	physicImage: Frame,

	Image: ExImage.ExImage,

	Size: Vector3,

	CanCollide: boolean,

	Anchored: boolean,

	TouchMsg: {
		[PhysicObject]: boolean,
	},

	TouchMsgMutex: stdlib.Mutex,

	ID: number
}

physicObject.Id = -999999999999990

export type PhysicObject = typeof(setmetatable(
	{} :: PhysicObjectStruct,
	{ __index = physicObject }
))

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
	local function Check(a: Frame, b: Frame)
		return (
			( -- тут тупо смотрим находится ли верхняя точка self где-то в other
				(
					a.AbsolutePosition.X
					<= (b.AbsolutePosition.X + b.AbsoluteSize.X)
				)
				and (
					(a.AbsolutePosition.X + a.AbsoluteSize.X)
					>= b.AbsolutePosition.X
				)
			)
			and (
				(
					a.AbsolutePosition.Y
					<= (b.AbsolutePosition.Y + b.AbsoluteSize.Y)
				)
				and (
					(a.AbsolutePosition.Y + a.AbsoluteSize.Y)
					>= b.AbsolutePosition.Y
				)
			)
		)
	end

	return other ~= self
		and (
			Check(self.physicImage, other.physicImage)
			or Check(other.physicImage, self.physicImage) -- если наоборот верхня левая точка other находится в self
		)
end

--[[

]]
function physicObject.GetTouchedSide(self: PhysicObjectStruct): TouchedSides
	self.TouchedSideMutex:wait()
	return self.TouchedSide
end

--[[

]]
function physicObject.CalcSizeAndPos(
	self: PhysicObject,
	background: ExImage.ExImage
)
	self:SetSize(self:GetSize(background))
	self:SetPosition(self:GetPosition(background))
end

--[[

]]
function physicObject.GetPosition(
	self: PhysicObject,
	background: ExImage.ExImage
): Vector2
	return self:CalcPosition(background)
end

--[[

]]
function physicObject.CalcSize(
	self: PhysicObject,
	background: ExImage.ExImage
): Vector3
	return Vector3.new(
		self.Image.ImageInstance.AbsoluteSize.X,
		self.Image.ImageInstance.AbsolutePosition.Y,
		self.physicImage.AbsoluteSize.Y
	)
end

--[[

]]
function physicObject.CalcPosition(
	self: PhysicObject,
	background: ExImage.ExImage
): Vector2
	return self.Image.ImageInstance.AbsolutePosition
end

--[[

]]
function physicObject.GetSize(
	self: PhysicObject,
	background: ExImage.ExImage
): Vector3
	return self:CalcSize(background)
end

--[[

]]
function physicObject.SetParent(
	self: PhysicObject,
	parent: ExImage.ExImage | Frame
)
	if typeof(parent) == "table" then
		self.physicImage.Parent = parent.ImageInstance
	else
		self.physicImage.Parent = parent
	end
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
		pos + self.Image.ImageInstance.AbsoluteSize.Y - self.physicImage.AbsoluteSize.Y
	)
end

function physicObject.SetPositionRaw(self: PhysicObject, pos: Vector2)
	self.physicImage.Position = UDim2.new(self.physicImage.Position.X.Scale, pos.X, self.physicImage.Position.Y.Scale, pos.Y)
end

--[[

]]
function physicObject.SetSize(self: PhysicObject, size: Vector3)
	self.Image.ImageInstance.Size = UDim2.new(0, size.X, 0, size.Y)

	self.Image.ImageInstance.Position = UDim2.new(0, 0, 0, size.Z - size.Y)

	self.physicImage.Size = UDim2.fromOffset(size.X, size.Z)
end

--[[
	Set ZIndex for physic object
]]
function physicObject.SetZIndex(self: PhysicObject, ZIndex: number)
	self.physicImage.ZIndex = ZIndex
	self.Image.ImageInstance.ZIndex = ZIndex
end

function physicObject.StartPhysicCalc(self: PhysicObject)
	self.TouchedSideMutex:lock()
	table.clear(self.TouchMsg)
	for _, v in pairs(self.TouchedSide) do
		table.clear(v)
	end
end

function physicObject.GetTouchMsg(
	self: PhysicObject,
	obj: PhysicObject
): boolean?
	print("ab1")
	mutex.wait(obj.TouchMsgMutex)
	print("ab2")
	return self.TouchMsg[obj]
end

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
	Physic object constructor
]]
function physicObject.new(
	Image: ExImage.ExImage,
	canCollide: boolean?,
	checkingTouchedSize: boolean?,
	anchored: boolean?
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
		ID = physicObject.Id
	}

	physicObject.Id += 1

	print("create", this)

	this.Image.ImageInstance.Parent = this.physicImage

	this.physicImage.BackgroundTransparency = (function()
		if config.ShowHitboxes then
			return config.HitboxesTransparent
		else
			return 1
		end
	end)()

	setmetatable(this, { __index = physicObject })

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
				local X, Y = s.physicImage.Position.X.Offset, s.physicImage.Position.Y.Offset

				if stdlib.algorithm.find_if(s.TouchedSide.Up, function(value): boolean 
					return value.ID == b.ID
				end) then
					Y += (b.physicImage.AbsolutePosition.Y + b.physicImage.AbsoluteSize.Y - s.physicImage.AbsolutePosition.Y) / m
				end

				if stdlib.algorithm.find_if(s.TouchedSide.Down, function(value): boolean 
					return value.ID == b.ID
				end) then
					Y -= (s.physicImage.AbsolutePosition.Y + s.physicImage.AbsoluteSize.Y - b.physicImage.AbsolutePosition.Y) / m
				end

				if stdlib.algorithm.find_if(s.TouchedSide.Left, function(value): boolean 
					return value.ID == b.ID
				end) then
					X += (b.physicImage.AbsolutePosition.X + b.physicImage.AbsoluteSize.X - s.physicImage.AbsolutePosition.X) / m
				end

				if stdlib.algorithm.find_if(s.TouchedSide.Right, function(value): boolean 
					return value.ID == b.ID
				end) then
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
