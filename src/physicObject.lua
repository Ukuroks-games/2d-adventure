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

export type PhysicObject = {

	--[[
		fire where PhysicObject touched another PhysicObject


		example:
		```lua
		obj.Touched:Connect(function(obj: PhysicObject )

		end)
		```
	]]
	Touched: RBXScriptSignal,

	TouchedEvent: BindableEvent,

	TouchedSide: TouchedSide,

	TouchedSideMutex: mutex.Mutex,

	Image: Frame,

	CanCollide: boolean,

	CalcSizeAndPos: (self: PhysicObject, background: ExImage.ExImage) -> nil,

	GetTouchedSide: (self: PhysicObject) -> TouchedSide,
}

function physicObject.Destroy(self: PhysicObject)
	self.TouchedEvent:Destroy()
	self.Image:Destroy()
end

function physicObject.CheckCollision(
	self: PhysicObject,
	other: PhysicObject
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

function physicObject.GetTouchedSide(self: PhysicObject): TouchedSide
	self.TouchedSideMutex:wait()
	return self.TouchedSide
end

function physicObject.CalcSizeAndPos()
	-- empty because its an interface
end

function physicObject.new(
	image: Frame,
	canCollide: boolean?,
	checkingTouchedSize: boolean?
): PhysicObject
	local TouchedEvent = Instance.new("BindableEvent")

	local this = {
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

			if p1x < p2x then
				this.TouchedSide.Right = this.TouchedSide.Right or true
				this.TouchedSide.Left = this.TouchedSide.Left or false
			else
				this.TouchedSide.Right = this.TouchedSide.Right or false
				this.TouchedSide.Left = this.TouchedSide.Left or true
			end

			if p1y > p2y then
				this.TouchedSide.Up = this.TouchedSide.Up or true
				this.TouchedSide.Down = this.TouchedSide.Down or false
			else
				this.TouchedSide.Up = this.TouchedSide.Up or false
				this.TouchedSide.Down = this.TouchedSide.Down or true
			end

			this.TouchedSideMutex:unlock()
		end)
	end

	return this
end

return physicObject
