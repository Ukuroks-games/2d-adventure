local ReplicatedStorage = game:GetService("ReplicatedStorage")

local stdlib = require(ReplicatedStorage.Packages.stdlib)
local ExImage = require(script.Parent.ExImage)

local mutex = stdlib.mutex

--[[
	Physic object

	interface for another classes, that can have physic
]]
local physicObject = {}

export type TouchedSide = {

	--[[
		Touched right side
	]]
	Right: boolean,

	--[[
		Touched left side
	]]
	Left: boolean,

	--[[
		Touched up side
	]]
	Up: boolean,

	--[[
		Touched bottom side
	]]
	Down: boolean,
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

	TouchedSide: TouchedSide,

	TouchedSideMutex: mutex.Mutex,

	physicImage: Frame,

	Image: Frame | ExImage.ExImage,

	Size: Vector3,

	CanCollide: boolean,

	Anchored: boolean,
}

export type PhysicObject = PhysicObjectStruct & typeof(physicObject)

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
			or Check(other.physicImage, self.physicImage) -- если наооборот верхня левая точка other находится в self
		)
end

--[[

]]
function physicObject.GetTouchedSide(self: PhysicObjectStruct): TouchedSide
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
	background: ExImage.ExImage | Frame
): Vector2
	return self:CalcPosition(background)
end

--[[

]]
function physicObject.CalcSize(
	self: PhysicObjectStruct,
	background: ExImage.ExImage | Frame
): Vector3
	return Vector3.new(
		self.Image.AbsoluteSize.X,
		self.Image.AbsoluteSize.Y,
		self.physicImage.AbsoluteSize.Y
	)
end

--[[

]]
function physicObject.CalcPosition(
	self: PhysicObjectStruct,
	background: ExImage.ExImage | Frame
): Vector2
	return self.Image.AbsolutePosition
end

--[[

]]
function physicObject.GetSize(
	self: PhysicObject,
	background: ExImage.ExImage | Frame
): Vector3
	return self:CalcSize(background)
end

--[[

]]
function physicObject.SetParent(
	self: PhysicObjectStruct,
	parent: GuiObject | ExImage.ExImage
)
	if typeof(parent) == "table" then
		self.physicImage.Parent = parent.ImageInstance
	else
		self.physicImage.Parent = parent
	end
end

--[[

]]
function physicObject.SetPosition(self: PhysicObjectStruct, pos: Vector2)
	self.physicImage.Position = UDim2.fromOffset(
		pos.X,
		pos.Y + self.Image.AbsoluteSize.Y - self.physicImage.AbsoluteSize.Y
	)
end

--[[

]]
function physicObject.SetSize(self: PhysicObjectStruct, size: Vector3)
	self.Image.Size = UDim2.new(0, size.X, 0, size.Y)

	self.Image.Position = UDim2.new(0, 0, 0, size.Z - size.Y)

	self.physicImage.Size = UDim2.fromOffset(size.X, size.Z)
end

--[[
	Physic object constructor
]]
function physicObject.new(
	Image: GuiObject | ExImage.ExImage,
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
			Right = false,
			Left = false,
			Up = false,
			Down = false,
		},
		Anchored = anchored or true,
		Size = Vector3.new(),
		Image = Image,
	}

	Image.Parent = this.physicImage
	this.physicImage.BackgroundTransparency = 1

	setmetatable(this, { __index = physicObject })

	this.Touched:Connect(function(obj: PhysicObject)
		--[[
			Кароч в чем смысол алгоритма:

			находим центральные точки твух прямоугольников и смотрим как они расположены относительно друг друга

			А для конечного пределения по какой оси было касание (вверх-низ, право-лево, обе) смотрим отношение 
			сторон области пересечения. 

			Касание по двум осям возможно если область пересения - квадрат.
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
					this.TouchedSide.Right = this.TouchedSide.Right or true
					this.TouchedSide.Left = this.TouchedSide.Left or false
				else
					this.TouchedSide.Right = this.TouchedSide.Right or false
					this.TouchedSide.Left = this.TouchedSide.Left or true
				end
			end

			if h <= w then
				if p1y > p2y then
					this.TouchedSide.Up = this.TouchedSide.Up or true
					this.TouchedSide.Down = this.TouchedSide.Down or false
				else
					this.TouchedSide.Up = this.TouchedSide.Up or false
					this.TouchedSide.Down = this.TouchedSide.Down or true
				end
			end

			this.TouchedSideMutex:unlock()
		end
	end)

	this.Touched:Connect(function(obj: PhysicObject)
		if not this.Anchored then
			this.TouchedSideMutex:wait()

			if this.TouchedSide.Up then
				this.physicImage.Position = UDim2.new(
					this.physicImage.Position.X,
					UDim.new(
						this.physicImage.Position.Y.Scale,
						this.physicImage.Position.Y.Offset
							+ (
								obj.physicImage.AbsolutePosition.Y
								+ obj.physicImage.AbsoluteSize.Y
								- this.physicImage.AbsolutePosition.Y
							)
					)
				)
			end

			if this.TouchedSide.Down then
				this.physicImage.Position = UDim2.new(
					this.physicImage.Position.X,
					UDim.new(
						this.physicImage.Position.Y.Scale,
						this.physicImage.Position.Y.Offset
							- (
								this.physicImage.AbsolutePosition.Y
								+ this.physicImage.AbsoluteSize.Y
								- obj.physicImage.AbsolutePosition.Y
							)
					)
				)
			end

			if this.TouchedSide.Left then
				this.physicImage.Position = UDim2.new(
					UDim.new(
						this.physicImage.Position.X.Scale,
						this.physicImage.Position.X.Offset
							+ (
								obj.physicImage.AbsolutePosition.X
								+ obj.physicImage.AbsoluteSize.X
								- this.physicImage.AbsolutePosition.X
							)
					),
					this.physicImage.Position.Y
				)
			end

			if this.TouchedSide.Right then
				this.physicImage.Position = UDim2.new(
					UDim.new(
						this.physicImage.Position.X.Scale,
						this.physicImage.Position.X.Offset
							- (
								this.physicImage.AbsolutePosition.X
								+ this.physicImage.AbsoluteSize.X
								- obj.physicImage.AbsolutePosition.X
							)
					),
					this.physicImage.Position.Y
				)
			end
		end
	end)

	return this
end

return physicObject
