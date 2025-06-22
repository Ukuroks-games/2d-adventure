local ExImage = require(script.Parent.ExImage)
local physicObject = {}

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

	TouchedSide: number,

	Image: Frame,

	CanCollide: boolean,

	CalcSizeAndPos: (self: PhysicObject, background: ExImage.ExImage) -> nil,
}

physicObject.TouchedSide = {
	NotTouched = 0,
	Up = 2,
	Down = 1,
	Left = 3,
	Right = 4,
}

function physicObject.Destroy(self: PhysicObject)
	self.TouchedEvent:Destroy()
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
		TouchedSide = physicObject.TouchedSide.NotTouched,

		CalcSizeAndPos = function()
			-- empty because its an interface
		end,
	}

	setmetatable(this, {
		__index = function(self: typeof(this), key)
			local _, e = pcall(function()
				return self.Image[key]
			end)
			return e or rawget(self, key)
		end,
		__newindex = function(self: typeof(this), key, value)
			self.Image[key] = value
		end,
	})

	if checkingTouchedSize then
		this.Touched:Connect(function(obj: PhysicObject)
			local p1x = this.Image.AbsolutePosition.X
				+ (this.Image.AbsoluteSize.X / 2)
			local p1y = this.Image.AbsolutePosition.Y
				+ (this.Image.AbsoluteSize.Y / 2)

			--[[
				idk why, but it fall on trying get `AbsolutePosition.X`

				ExImage constructor must set __index, but it doesnt working here
			]]
			if typeof(obj.Image) ~= "Frame" then
				setmetatable(
					obj._physicObject.Image,
					{ __index = obj._physicObject.Image.ImageInstance }
				)
				obj.Image = obj._physicObject.Image
			end

			local p2x = obj.Image.AbsolutePosition.X
				+ (obj.Image.AbsoluteSize.X / 2)
			local p2y = obj.Image.AbsolutePosition.Y
				+ (obj.Image.AbsoluteSize.Y / 2)

			local x = p1x - p2x
			local y = p1y - p2y

			-- угол
			local a = y / x

			if a > 1 then
				if y > 0 then
					this.TouchedSide = physicObject.TouchedSide.Up
				elseif y < 0 then
					this.TouchedSide = physicObject.TouchedSide.Down
				else -- хз совпало
					this.TouchedSide = physicObject.TouchedSide.NotTouched
				end
			elseif a <= 1 then
				if x > 0 then
					this.TouchedSide = physicObject.TouchedSide.Right
				elseif x < 0 then
					this.TouchedSide = physicObject.TouchedSide.Left
				else -- хз совпало
					this.TouchedSide = physicObject.TouchedSide.NotTouched
				end
			else
				warn("wtf a: " .. a)
			end
		end)
	end

	return this
end

return physicObject
