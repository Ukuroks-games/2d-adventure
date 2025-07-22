local Character = require(script.Parent.Character)

local physicObject = require(script.Parent.physicObject)
--[[
	Player class
]]
local player2d = {}


--[[
	Класс игрока
]]
export type Player2dStruct = {
	
} & Character.Character2d

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
	Animations: Character.ConstructorAnimations,
	WalkSpeed: Character.CharacterSpeed,
	Size: Vector3
): Player2d
	local self = Character.new(Animations, WalkSpeed, Size)

	setmetatable(self, {
		__index = function(_self, key)
			return Character[key] or player2d[key] or physicObject[key]
		end,
	})

	return self
end

return player2d
