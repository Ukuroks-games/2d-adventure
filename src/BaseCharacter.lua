-- services

local TweenService = game:GetService("TweenService")

--

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
} & physicObject.PhysicObjectStruct

--[[

]]
export type BaseCharacter2d = typeof(setmetatable(
	{} :: BaseCharacter2dStruct,
	{ __index = BaseCharacter2d }
))

--[[
	Destroy player
]]
function BaseCharacter2d.Destroy(self: BaseCharacter2d)
	self.MoveEvent:Destroy()
	physicObject.Destroy(self)
end

--[[

]]
function BaseCharacter2d.GetMoveTween(
	self: BaseCharacter2d,
	X: number,
	Y: number,
	RelativeObject: ExImage.ExImage,
	cooldownTime: number?
): Tween?
	local tween

	if self.WalkSpeed.Calculated then
		local instance = RelativeObject.ImageInstance

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

--[[

]]
function BaseCharacter2d.NormalizeXY(X: number, Y: number): (number, number)
	-- Привидение значений X и Y к [-1; 1]
	if not (X == 0 and Y == 0) then
		local a = math.atan(Y / X)

		local function sign(n: number): number
			local r = math.sign(n)

			if r == 0 then
				r = 1
			end

			return r
		end

		return math.cos(a) * X, math.sin(a) * sign(X) * math.abs(Y)
	else
		return 0, 0
	end
end

--[[

]]
function BaseCharacter2d.WalkMoveRaw(
	self: BaseCharacter2d,
	X: number,
	Y: number,
	RelativeObject: ExImage.ExImage?,
	cooldownTime: number?
): Tween?
	if not RelativeObject then
		RelativeObject = self.Image
	end

	local t = self:GetMoveTween(X, Y, RelativeObject, cooldownTime)

	if t then
		self.MoveEvent:Fire()
	end

	return t
end

--[[

]]
function BaseCharacter2d.WalkMove(
	self: BaseCharacter2d,
	X: number,
	Y: number,
	RelativeObject: ExImage.ExImage?,
	cooldownTime: number?
)
	X, Y = self.NormalizeXY(X, Y)

	return self:WalkMoveRaw(X, Y, RelativeObject, cooldownTime)
end

--[[
	BaseCharacter2d constructor
]]
function BaseCharacter2d.new(
	WalkSpeed: CharacterSpeed,
	Size: Vector3
): BaseCharacter2d
	local PlayerFrame = ExImage.new("")
	PlayerFrame.ImageInstance.BackgroundTransparency = 1

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
