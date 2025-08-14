--!strict

local AnimatedObject = require(script.Parent.AnimatedObject)
local BaseCharacter = require(script.Parent.BaseCharacter)
local Character = require(script.Parent.Character)

--[[
	Player class
]]
local player2d = setmetatable({}, { __index = Character })

--[[
	Класс игрока.

	По сути является классом Character2d с несколькими переопределёнными 
]]
export type Player2dStruct = Character.Character2dStruct

export type Player2d = Player2dStruct & typeof(player2d) & Character.Character2d

function player2d.SetPositionX(self: Player2dStruct, _: number)
	self.physicImage.Position = UDim2.new(
		0.5,
		-self.physicImage.AbsoluteSize.X / 2,
		0.5,
		-self.physicImage.AbsoluteSize.Y / 2
	) -- move to center PlayerFrame
end

function player2d.SetPositionY(self: Player2dStruct, _: number)
	self.physicImage.Position = UDim2.new(
		0.5,
		-self.physicImage.AbsoluteSize.X / 2,
		0.5,
		-self.physicImage.AbsoluteSize.Y / 2
	) -- move to center PlayerFrame
end

function player2d.SetPositionRaw(self: Player2d, _: Vector2)
	self.physicImage.Position = UDim2.new(
		0.5,
		-self.physicImage.AbsoluteSize.X / 2,
		0.5,
		-self.physicImage.AbsoluteSize.Y / 2
	) -- move to center PlayerFrame
end

--[[
	Player2d constructor
]]
function player2d.new(
	Animations: AnimatedObject.ConstructorAnimations,
	WalkSpeed: BaseCharacter.CharacterSpeed,
	Size: Vector3
): Player2d
	local self = Character.new(Animations, WalkSpeed, Size)

	setmetatable(self, {
		__index = player2d,
	})

	return self
end

return player2d
