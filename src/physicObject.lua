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

	Right: boolean,

	Left: boolean,

	Up: boolean,

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

	Image: Frame,

	CanCollide: boolean,

	Anchored: boolean,
}

export type PhysicObject = PhysicObjectStruct & typeof(physicObject)

function physicObject.Destroy(self: PhysicObjectStruct)
	self.TouchedEvent:Destroy()
	self.Image:Destroy()
end

function physicObject.CheckCollision(
	self: PhysicObjectStruct,
	other: PhysicObjectStruct
): boolean
	local function Check(a, b)
		return (
			( -- тут тупо смотрим находится ли верхняя точка self где-то в other
				(
					a.Image.AbsolutePosition.X
					<= (b.Image.AbsolutePosition.X + b.Image.AbsoluteSize.X)
				)
				and (
					(a.Image.AbsolutePosition.X + a.Image.AbsoluteSize.X)
					>= b.Image.AbsolutePosition.X
				)
			)
			and (
				(
					a.Image.AbsolutePosition.Y
					<= (b.Image.AbsolutePosition.Y + b.Image.AbsoluteSize.Y)
				)
				and (
					(a.Image.AbsolutePosition.Y + a.Image.AbsoluteSize.Y)
					>= b.Image.AbsolutePosition.Y
				)
			)
		)
	end

	return other ~= self
		and (
			Check(self, other)
			or Check(other, self) -- если наооборот верхня левая точка other находится в self
		)
end

function physicObject.GetTouchedSide(self: PhysicObjectStruct): TouchedSide
	self.TouchedSideMutex:wait()
	return self.TouchedSide
end

function physicObject.CalcSizeAndPos()
	-- empty because its an interface
end

function physicObject.GetPosition(self: PhysicObjectStruct): Vector2
	return self.Image.AbsolutePosition
end

function physicObject.GetSize(self: PhysicObjectStruct): Vector2
	return self.Image.AbsoluteSize
end

function physicObject.new(
	image: Frame,
	canCollide: boolean?,
	checkingTouchedSize: boolean?,
	anchored: boolean?
): PhysicObject
	local TouchedEvent = Instance.new("BindableEvent")

	local this: PhysicObjectStruct = {
		Touched = TouchedEvent.Event,
		TouchedEvent = TouchedEvent,
		Image = image or error("image is nil"),
		CanCollide = canCollide or true,
		TouchedSideMutex = mutex.new(false),
		TouchedSide = {
			Right = false,
			Left = false,
			Up = false,
			Down = false,
		},
		Anchored = anchored or true,
	}

	setmetatable(this, { __index = physicObject })

	if checkingTouchedSize then
		this.Touched:Connect(function(obj: PhysicObject)
			if type(obj.Image) == "table" then
				setmetatable(obj.Image, { __index = obj.Image.ImageInstance })
			end

			local p1x = this.Image.AbsolutePosition.X
				+ (this.Image.AbsoluteSize.X / 2)
			local p1y = this.Image.AbsolutePosition.Y
				+ (this.Image.AbsoluteSize.Y / 2)

			local p2x = obj.Image.AbsolutePosition.X
				+ (obj.Image.AbsoluteSize.X / 2)
			local p2y = obj.Image.AbsolutePosition.Y
				+ (obj.Image.AbsoluteSize.Y / 2)

			local w = (function()
				if
					this.Image.AbsolutePosition.X > obj.Image.AbsolutePosition.X
				then
					return obj.Image.AbsolutePosition.X
						+ obj.Image.AbsoluteSize.X
						- this.Image.AbsolutePosition.X
				else
					return this.Image.AbsolutePosition.X
						+ this.Image.AbsoluteSize.X
						- obj.Image.AbsolutePosition.X
				end
			end)()

			local h = (function()
				if
					this.Image.AbsolutePosition.Y > obj.Image.AbsolutePosition.Y
				then
					return obj.Image.AbsolutePosition.Y
						+ obj.Image.AbsoluteSize.Y
						- this.Image.AbsolutePosition.Y
				else
					return this.Image.AbsolutePosition.Y
						+ this.Image.AbsoluteSize.Y
						- obj.Image.AbsolutePosition.Y
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
		end)
	else
		this.Touched:Connect(function()
			this.TouchedSideMutex:unlock()
		end)
	end

	this.Touched:Connect(function(obj: PhysicObject)
		if not this.Anchored then
			this.TouchedSideMutex:wait()

			if type(obj.Image) == "table" then
				setmetatable(obj.Image, { __index = obj.Image.ImageInstance })
			end

			if this.TouchedSide.Up then
				this.Image.Position = UDim2.new(
					this.Image.Position.X,
					UDim.new(
						this.Image.Position.Y.Scale,
						this.Image.Position.Y.Offset
							+ (
								obj.Image.AbsolutePosition.Y
								+ obj.Image.AbsoluteSize.Y
								- this.Image.AbsolutePosition.Y
							)
					)
				)
			end

			if this.TouchedSide.Down then
				this.Image.Position = UDim2.new(
					this.Image.Position.X,
					UDim.new(
						this.Image.Position.Y.Scale,
						this.Image.Position.Y.Offset
							- (
								this.Image.AbsolutePosition.Y
								+ this.Image.AbsoluteSize.Y
								- obj.Image.AbsolutePosition.Y
							)
					)
				)
			end

			if this.TouchedSide.Left then
				this.Image.Position = UDim2.new(
					UDim.new(
						this.Image.Position.X.Scale,
						this.Image.Position.X.Offset
							+ (
								obj.Image.AbsolutePosition.X
								+ obj.Image.AbsoluteSize.X
								- this.Image.AbsolutePosition.X
							)
					),
					this.Image.Position.Y
				)
			end

			if this.TouchedSide.Right then
				this.Image.Position = UDim2.new(
					UDim.new(
						this.Image.Position.X.Scale,
						this.Image.Position.X.Offset
							- (
								this.Image.AbsolutePosition.X
								+ this.Image.AbsoluteSize.X
								- obj.Image.AbsolutePosition.X
							)
					),
					this.Image.Position.Y
				)
			end
		end
	end)

	return this
end

return physicObject
