local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetService = game:GetService("AssetService")

local gifInfo = require(script.Parent.gifInfo)
local giflib = require(ReplicatedStorage.Packages.giflib)

local physicObject = require(script.Parent.physicObject)
local Object2d = require(script.Parent.Object2d)
local ExImage = require(script.Parent.ExImage)

--[[
	Player class
]]
local player2d = {}

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
	WalkSpeed: number,

	Move: RBXScriptSignal,

	MoveEvent: BindableEvent,

	--[[
		Текущяя анимация
	]]
	CurrentAnimation: giflib.Gif,

	Size: Vector2,
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

function player2d.CalcSize(
	self: Player2dStruct,
	mapImage: ExImage.ExImage,
	overrideSize: Vector2?
)
	local Resolution: Vector2

	if self.Size.X == -1 or self.Size.Y == -1 then
		Resolution = overrideSize
			or AssetService:CreateEditableImageAsync(
				self.CurrentAnimation.Frames[1].Image.Image
			).Size
	end

	if self.Size.X == -1 and self.Size.Y == -1 then
		local s = Object2d.CalcSize(Resolution, mapImage)
		self.Image.Size = UDim2.fromOffset(s.X, s.Y)
	elseif self.Size.X == -1 then
		self.Image.Size = UDim2.new(
			0,
			Object2d.CalcSize(Resolution, mapImage).X,
			self.Size.Y,
			0
		)
	elseif self.Size.Y == -1 then
		self.Image.Size = UDim2.new(
			self.Size.X,
			0,
			0,
			Object2d.CalcSize(Resolution, mapImage).X
		)
	else
		self.Image.Size = UDim2.fromScale(self.Size.X, self.Size.Y)
	end

	self.Image.Position = UDim2.new(
		0.5,
		-self.Image.AbsoluteSize.X / 2,
		0.5,
		-self.Image.AbsoluteSize.Y / 2
	) -- move to center PlayerFrame
end

--[[
	Player2d constructor
]]
function player2d.new(
	Animations: ConstructorAnimations,
	WalkSpeed: number,
	Size: { X: number, Y: number }
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


	self.Animations = CreatedAnimations
	self.WalkSpeed = WalkSpeed
	self.CurrentAnimation = CreatedAnimations.IDLE or nil
	self.MoveEvent = Instance.new("BindableEvent")
	self.Move = self.MoveEvent.Even
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
