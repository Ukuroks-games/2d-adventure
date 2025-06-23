local ExImage = require(script.Parent.ExImage)

--[[
	Physic object

	interface for another classes, that can have physic
]]
local physicObject = {}

export type TouchedSide = {
	--[[
		Right - true, left - false
	]]
	X: boolean,

	--[[
		Up - true, down - false
	]]
	Y: boolean,
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

	Image: Frame,

	CanCollide: boolean,

	CalcSizeAndPos: (self: PhysicObject, background: ExImage.ExImage) -> nil,

	Points: { Vector2int16 },
}

function physicObject.Destroy(self: PhysicObject)
	self.TouchedEvent:Destroy()
	self.Image:Destroy()
end

function physicObject.CheckCollision(
	self: PhysicObject,
	other: PhysicObject
): boolean
	return other ~= self
		and (
			(
				other.Image.AbsolutePosition.X
					>= self.Image.AbsolutePosition.X
				and other.Image.AbsolutePosition.X
					<= (self.Image.AbsolutePosition.X + self.Image.AbsoluteSize.X)
			) -- check if other in v
			and (
				other.Image.AbsolutePosition.Y
					>= self.Image.AbsolutePosition.Y
				and other.Image.AbsolutePosition.Y
					<= (self.Image.AbsolutePosition.Y + self.Image.AbsoluteSize.Y)
			)
		) -- обратная проверка не нужна т.к. и так проходим по всем]]
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
		TouchedSide = {
			X = nil,
			Y = nil,
		},

		CalcSizeAndPos = function()
			-- empty because its an interface
		end,
	}

	if checkingTouchedSize then
		this.Touched:Connect(function(obj: PhysicObject)
			print(this, obj)

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

			this.TouchedSide.X = p1x < p2x
			this.TouchedSide.Y = p1y > p2y
		end)
	end

	return this
end

return physicObject
