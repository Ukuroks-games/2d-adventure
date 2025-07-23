local AnimatedObject = require(script.Parent.AnimatedObject)
local BaseCharacter = require(script.Parent.BaseCharacter)
local Character = require(script.Parent.Character)

--[[
	Player class
]]
local player2d = setmetatable({}, { __index = Character })

--[[
	Класс игрока
]]
export type Player2dStruct = {} & Character.Character2d

export type Player2d = Player2dStruct & typeof(player2d)

--[[
	Set player position.

	It ignore any changes. player always on centre
]]
function player2d.SetPosition(self: Player2dStruct, pos: Vector2)
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
