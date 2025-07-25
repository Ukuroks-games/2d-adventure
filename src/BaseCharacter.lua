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
	self.Anchored = false
	self.Size = Size

	setmetatable(self, {
		__index = BaseCharacter2d,
	})

	return self
end

return BaseCharacter2d
