local TweenService = game:GetService("TweenService")
local AnimatedObject = require(script.Parent.AnimatedObject)
local BaseCharacter = require(script.Parent.BaseCharacter)
local Character = require(script.Parent.Character)
local ExImage = require(script.Parent.ExImage)

--[[
	Player class
]]
local player2d = setmetatable({}, { __index = Character })

--[[
	Класс игрока.

	По сути является классом Character2d с несколькими переопределёнными 
]]
export type Player2dStruct = {} & Character.Character2d

export type Player2d = Player2dStruct & typeof(player2d)



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

function player2d.GetMoveTween(
	self: Player2d,
	X: number,
	Y: number,
	RelativeObject: GuiObject? | ExImage.ExImage,
	cooldownTime: number?
): Tween?
	local tween

	if self.WalkSpeed.Calculated and RelativeObject and cooldownTime then
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
	else
		warn("self.Player.WalkSpeed hasn't been calculate yet")
	end

	return tween
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
