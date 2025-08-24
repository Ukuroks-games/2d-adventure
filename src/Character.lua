--!nonstrict

local stdlib = require(script.Parent.Parent.stdlib)
local AnimatedObject = require(script.Parent.AnimatedObject)
local BaseCharacter = require(script.Parent.BaseCharacter)
local Calc = require(script.Parent.Calc)
local ExImage = require(script.Parent.ExImage)
local physicObject = require(script.Parent.physicObject)

--[[
	Character
]]
local Character2d = setmetatable({}, {
	__index = function(self, key: string)
		return AnimatedObject[key] or BaseCharacter[key]
	end,
})

export type Character2dStruct = {
	MoveStopConnection: RBXScriptConnection?,
} & AnimatedObject.AnimatedObjectStruct & BaseCharacter.BaseCharacter2dStruct

--[[
	Character with animations
]]
export type Character2d =
	Character2dStruct
	& typeof(Character2d)
	& AnimatedObject.AnimatedObject
	& BaseCharacter.BaseCharacter2d

--[[

]]
function Character2d.CalcSize(self: Character2d): Vector3
	return Calc.CalcSize(self.Size, self.background)
end

function Character2d.SetZIndex(self: Character2d, ZIndex: number)
	BaseCharacter.SetZIndex(self, ZIndex)

	for _, group in pairs(self.Animations) do
		for _, animation in pairs(group) do
			for _, frame in pairs(animation.Frames) do
				frame.Image.ZIndex = ZIndex
			end
		end
	end
end

function Character2d.WalkMoveRaw(
	self: Character2d,
	X: number,
	Y: number,
	RelativeObject: ExImage.ExImage,
	cooldownTime: number?
): Tween
	if self.MoveStopConnection then
		self.MoveStopConnection:Disconnect()
		self.MoveStopConnection = nil
	end

	local touchedSide = self:GetTouchedSide()

	local function CheckCanMoveToSide(side: physicObject.TouchSide): boolean
		if #side > 0 then
			return stdlib.algorithm.any_of(
				side,
				function(
					value
				): boolean -- Все один из коснувшихся являются anchored
					return value.Anchored
						and (
							value.PhysicMode
							>= physicObject.PhysicMode.CanCollide
						)
				end
			)
		else
			return false
		end
	end

	if
		((X > 0) and CheckCanMoveToSide(touchedSide.Right))
		or ((X < 0) and CheckCanMoveToSide(touchedSide.Left))
	then
		X = 0
	end

	if
		((Y > 0) and CheckCanMoveToSide(touchedSide.Up))
		or ((Y < 0) and CheckCanMoveToSide(touchedSide.Down))
	then
		Y = 0
	end

	local r = math.abs(X / Y)

	local animationName = "Walk"

	local function SetY()
		if Y > 0 then
			animationName ..= "Up"
		elseif Y < 0 then
			animationName ..= "Down"
		end
	end

	if r > 0.75 then -- X bigger
		if X < 0 then
			animationName ..= "Left"
		elseif X > 0 then
			animationName ..= "Right"
		end

		if r <= 1 then
			SetY()
		end
	else -- Y bigger
		SetY()
	end

	if animationName == "Walk" then
		animationName = "IDLE"
	end

	self:SetAnimation(animationName)

	local t =
		BaseCharacter.WalkMoveRaw(self, X, Y, RelativeObject, cooldownTime)

	self.MoveStopConnection = t.Completed:Connect(
		function(state: Enum.PlaybackState)
			if state == Enum.PlaybackState.Completed then
				self:SetAnimation("Stay" .. self.CurrentAnimation:sub(5))
			end
		end
	)

	return t
end

function Character2d.new(
	Animations: AnimatedObject.ConstructorAnimations,
	WalkSpeed: BaseCharacter.CharacterSpeed,
	Size: Vector3
): Character2d
	local self = BaseCharacter.new(WalkSpeed, Size)

	stdlib.utility.merge(self, AnimatedObject.new(Animations, self.Image))

	setmetatable(self, { __index = Character2d })

	return self
end

return Character2d
