local AssetService = game:GetService("AssetService")

local gifInfo = require(script.Parent.gifInfo)
local giflib = require(script.Parent.Parent.giflib)

local physicObject = require(script.Parent.physicObject)
local Object2d = require(script.Parent.Object2d)
local ExImage = require(script.Parent.ExImage)

--[[
	Player class
]]
local player2d = {}

--[[
	Animations list
]]
export type Animations = {
	WalkUp: giflib.Gif,
	WalkDown: giflib.Gif,
	WalkRight: giflib.Gif,
	WalkLeft: giflib.Gif,
	IDLE: giflib.Gif,

	-- Other animations
	[any]: giflib.Gif,
}

export type ConstructorAnimations = {
	WalkUp: gifInfo.Func,
	WalkDown: gifInfo.Func,
	WalkRight: gifInfo.Func,
	WalkLeft: gifInfo.Func,
	IDLE: gifInfo.Func,

	-- Other animations
	[any]: gifInfo.Func,
}

export type PlayerSpeed = {
	X: number,
	Y: number,
	Calculated: PlayerSpeed?
}

--[[
	Класс игрока
]]
export type Player2dStruct = {
	--[[
		Анимации игрока
	]]
	Animations: Animations,

	--[[
		Скорость ходьбы
	]]
	WalkSpeed: PlayerSpeed,

	Move: RBXScriptSignal,

	MoveEvent: BindableEvent,

	--[[
		Текущяя анимация
	]]
	CurrentAnimation: giflib.Gif,

	Image: Frame,
} & physicObject.PhysicObject

export type Player2d = Player2dStruct & typeof(player2d)

--[[
	Destroy player
]]
function player2d.Destroy(self: Player2dStruct)
	for _, v in pairs(self.Animations) do
		v:Destroy()
	end

	self.MoveEvent:Destroy()
end

--[[

]]
function player2d.CalcSize(
	self: Player2dStruct,
	mapImage: ExImage.ExImage
): Vector3
	local Resolution: Vector3

	if self.Size.X == -1 or self.Size.Y == -1 then
		local a = AssetService:CreateEditableImageAsync(
			self.CurrentAnimation.Frames[1].Image.Image
		).Size
		Resolution = Vector3.new(a.X, a.Y, self.Size.Z)
	end

	return Object2d.CalcSize(Resolution or self.Size, mapImage)
end

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
	Set ZIndex for player
]]
function player2d.SetZIndex(self: Player2dStruct, ZIndex: number)
	physicObject.SetZIndex(self, ZIndex)

	for _, animation in pairs(self.Animations) do
		for _, frame in pairs(animation.Frames) do
			frame.Image.ZIndex = ZIndex
		end
	end
end

--[[
	Player2d constructor
]]
function player2d.new(
	Animations: ConstructorAnimations,
	WalkSpeed: PlayerSpeed,
	Size: Vector3
): Player2d
	local PlayerFrame = Instance.new("Frame")
	local CreatedAnimations = {}
	local self = physicObject.new(PlayerFrame, true, true, false)

	for i, v in pairs(Animations) do
		local gif = v(PlayerFrame)

		gif:Hide()
		gif:SetBackgroundTransparency(1)

		CreatedAnimations[i] = gif
	end

	PlayerFrame.BackgroundTransparency = 1

	self.Image = PlayerFrame
	self.Animations = CreatedAnimations
	self.WalkSpeed = WalkSpeed
	self.CurrentAnimation = CreatedAnimations.IDLE or nil
	self.MoveEvent = Instance.new("BindableEvent")
	self.Move = self.MoveEvent.Event
	self.Anchored = false
	self.Size = Size

	setmetatable(self, {
		__index = function(_self, key)
			return player2d[key] or physicObject[key]
		end,
	})

	return self
end

return player2d
