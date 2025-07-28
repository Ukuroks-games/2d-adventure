local TweenService = game:GetService("TweenService")
local ExImage = require(script.Parent.ExImage)
local physicObject = require(script.Parent.physicObject)

--[[
	Player class
]]
local BaseCharacter2d = setmetatable({}, {
	__index = physicObject,
})

export type CharacterSpeed = {
	X: number,
	Y: number,
	Calculated: Vector2?,
}

--[[
	Базовый класс персонажа
]]
export type BaseCharacter2dStruct = {

	--[[
		Скорость ходьбы
	]]
	WalkSpeed: CharacterSpeed,

	Move: RBXScriptSignal,

	MoveEvent: BindableEvent,

	Image: Frame,
} & physicObject.PhysicObject

export type BaseCharacter2d = BaseCharacter2dStruct & typeof(BaseCharacter2d)

--[[
	Destroy player
]]
function BaseCharacter2d.Destroy(self: BaseCharacter2d)
	self.MoveEvent:Destroy()
	physicObject.Destroy(self)
end

function BaseCharacter2d.GetMoveTween(self: BaseCharacter2d, X: number, Y: number, RelativeObject: GuiObject? | ExImage.ExImage, cooldownTime: number?): Tween?
	local tween

	if not RelativeObject then
		RelativeObject = self.Image
	end

	if self.WalkSpeed.Calculated then
		local instance = (function()
			if typeof(RelativeObject) == "table" then
				return RelativeObject.ImageInstance
			else
				return RelativeObject
			end
		end)()

		tween = TweenService:Create(instance, TweenInfo.new(cooldownTime), {
			["Position"] = UDim2.new(
				UDim.new(
					instance.Position.X.Scale,
					instance.Position.X.Offset
						- (X * self.WalkSpeed.Calculated.X)
				),
				UDim.new(
					instance.Position.Y.Scale,
					instance.Position.Y.Offset
						+ (Y * self.WalkSpeed.Calculated.Y)
				)
			),
		})
	end

	return tween
end

function BaseCharacter2d.WalkMove(
	self: BaseCharacter2d,
	X: number,
	Y: number,
	RelativeObject: GuiObject? | ExImage.ExImage,
	cooldownTime: number?
): Tween?
	local t = self:GetMoveTween(X, Y, RelativeObject, cooldownTime)

	if t then
		self.MoveEvent:Fire()
	end

	return t
end

--[[
	BaseCharacter2d constructor
]]
function BaseCharacter2d.new(
	WalkSpeed: CharacterSpeed,
	Size: Vector3
): BaseCharacter2d
	local PlayerFrame = Instance.new("Frame")
	PlayerFrame.BackgroundTransparency = 1

	local self = physicObject.new(PlayerFrame, true, true, false)

	self.WalkSpeed = WalkSpeed
	self.MoveEvent = Instance.new("BindableEvent")
	self.Move = self.MoveEvent.Event
	self.Size = Size

	setmetatable(self, {
		__index = BaseCharacter2d,
	})

	return self
end

return BaseCharacter2d
