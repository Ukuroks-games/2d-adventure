local stdlib = require(script.Parent.Parent.stdlib)

local AnimatedObject = require(script.Parent.AnimatedObject)
local BaseCharacter = require(script.Parent.BaseCharacter)
local Calc = require(script.Parent.Calc)
local ExImage = require(script.Parent.ExImage)
local physicObject = require(script.Parent.physicObject)

--[=[
	inherited from [BaseCharacter2d](BaseCharacter2d) and [AnimatedObject](AnimatedObject)

	@class Character2d
]=]
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
	AnimatedObject.SetZIndex(self, ZIndex)
	BaseCharacter.SetZIndex(self, ZIndex)
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
					local v = physicObject.Registry[value]

					return v.Anchored
						and (v.PhysicMode >= physicObject.PhysicMode.CanCollide)
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
	Animations: AnimatedObject.Animations,
	WalkSpeed: BaseCharacter.CharacterSpeed,
	Size: Vector3
): Character2d
	local self = BaseCharacter.new(WalkSpeed, Size)

	stdlib.utility.merge(self, AnimatedObject.new(Animations, self.Image))

	setmetatable(self, { __index = Character2d })

	return self
end

return Character2d
