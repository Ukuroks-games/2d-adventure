local AssetService = game:GetService("AssetService")

local stdlib = require(script.Parent.Parent.stdlib)
local AnimatedObject = require(script.Parent.AnimatedObject)
local BaseCharacter = require(script.Parent.BaseCharacter)
local ExImage = require(script.Parent.ExImage)
local Object2d = require(script.Parent.Object2d)
local physicObject = require(script.Parent.physicObject)

local Character2d = setmetatable({}, {
	__index = function(self: Character2d, key: string)
		return AnimatedObject[key] or BaseCharacter[key]
	end,
})

--[[
	Character with animations
]]
export type Character2d =
	{}
	& AnimatedObject.AnimatedObject
	& BaseCharacter.BaseCharacter2d
	& typeof(Character2d)

--[[

]]
function Character2d.CalcSize(
	self: Character2d,
	mapImage: ExImage.ExImage
): Vector3
	local Resolution: Vector3

	if self.Size.X == -1 or self.Size.Y == -1 then
		local a = AssetService:CreateEditableImageAsync(
			self.Animations[self.CurrentAnimation].Frames[1].Image.Image
		).Size
		Resolution = Vector3.new(a.X, a.Y, self.Size.Z)
	end

	return Object2d.CalcSize(Resolution or self.Size, mapImage)
end

function Character2d.SetZIndex(self: Character2d, ZIndex: number)
	BaseCharacter.SetZIndex(self, ZIndex)

	for _, animation in pairs(self.Animations) do
		for _, frame in pairs(animation.Frames) do
			frame.Image.ZIndex = ZIndex
		end
	end
end

function Character2d.WalkMove(
	self: Character2d,
	X: number,
	Y: number,
	RelativeObject: GuiObject? | ExImage.ExImage,
	cooldownTime: number?
): Tween
	local touchedSide = self:GetTouchedSide()

	local function CheckCanMoveToSide(
		side: physicObject.TouchSide
	): boolean
		if #side > 0 then
			return stdlib.algorithm.any_of(
				side,
				function(
					value
				): boolean -- Все один из коснувшихся являются anchored
					return value.Anchored
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

	return BaseCharacter.WalkMove(self, X, Y, RelativeObject, cooldownTime)
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
