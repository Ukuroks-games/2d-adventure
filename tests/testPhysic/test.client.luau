--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local giflib = require(ReplicatedStorage.Packages.giflib)
local adventure2d = require(ReplicatedStorage.Packages["2d-adventure"])
local gifInfo = adventure2d.GifInfo

adventure2d.config.ShowHitboxes = true

Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

local GameFrame = Players.LocalPlayer.PlayerGui.ScreenGui.Frame
GameFrame.Size = UDim2.fromScale(1, 1)

local NoPhysic = adventure2d.Object2d.new(
	Vector2.new(100, 100),
	Vector3.new(80, 30, 30),
	adventure2d.ExImage.new("")
)
NoPhysic.PhysicMode = adventure2d.PhysicObject.PhysicMode.NoPhysic

local canTouch = adventure2d.Object2d.new(
	Vector2.new(200, 100),
	Vector3.new(80, 30, 30),
	adventure2d.ExImage.new("")
)
canTouch.PhysicMode = adventure2d.PhysicObject.PhysicMode.CanTouch

local CanCheckSide = adventure2d.Object2d.new(
	Vector2.new(100, 200),
	Vector3.new(100, 30, 30),
	adventure2d.ExImage.new(""),
	nil,
	nil,
	true
)
CanCheckSide.PhysicMode = adventure2d.PhysicObject.PhysicMode.CanCheckSide

local CanCollide = adventure2d.Object2d.new(
	Vector2.new(200, 200),
	Vector3.new(100, 30, 30),
	adventure2d.ExImage.new("")
)
local CanCollide2 = adventure2d.Object2d.new(
	Vector2.new(220, 220),
	Vector3.new(100, 30, 30),
	adventure2d.ExImage.new("")
)

local _game = adventure2d.Game.new(
	GameFrame,
	adventure2d.Player2d.new({
		["IDLE"] = {
			[""] = gifInfo.new(
				{ -- IDLE animation frames
					giflib.Frame.new("123651728909570", 0.5), -- 1
					giflib.Frame.new("73880862501758", 0.08), -- 2
					giflib.Frame.new("76251571010833", 0.08), -- 3
					giflib.Frame.new("115109214996806", 0.08), -- 4
					giflib.Frame.new("75706149017684", 0.08), -- 5
					giflib.Frame.new("93666646688648", 0.08), -- 6
					giflib.Frame.new("108839932127938", 0.08), -- 7
					giflib.Frame.new("81644303475497", 0.08), -- 8
					giflib.Frame.new("131056695027889", 0.08), -- 9
					giflib.Frame.new("82185418640948", 0.08), -- 10
					giflib.Frame.new("131056695027889", 0.08), -- 11
					giflib.Frame.new("82185418640948", 0.08), -- 12
				},
				true,
				true,
				giflib.gif.Mode.Replace,
				Enum.ResamplerMode.Pixelated
			),
		},
		["Walk"] = {
			["Up"] = gifInfo.new(
				{
					giflib.Frame.new("137969061702953", 0.2), -- 1
					giflib.Frame.new("83379893118196", 0.2), -- 2
				},
				true,
				false,
				giflib.gif.Mode.Replace,
				Enum.ResamplerMode.Pixelated
			),
			["Down"] = gifInfo.new(
				{
					giflib.Frame.new("80528378729899", 0.2), -- 1
					giflib.Frame.new("76126762386526", 0.2), -- 2
				},
				true,
				false,
				giflib.gif.Mode.Replace,
				Enum.ResamplerMode.Pixelated
			),
			["Left"] = gifInfo.new(
				{
					giflib.Frame.new("130325387410477", 0.2), -- 1
					giflib.Frame.new("134555323130510", 0.2), -- 2
					giflib.Frame.new("129026456910746", 0.23), -- 3
				},
				true,
				false,
				giflib.gif.Mode.Replace,
				Enum.ResamplerMode.Pixelated
			),
			["Right"] = gifInfo.new(
				{
					giflib.Frame.new("75448470198348", 0.2), -- 1
					giflib.Frame.new("86103040112243", 0.2), -- 2
					giflib.Frame.new("121217812639445", 0.2), -- 3
					giflib.Frame.new("115170788363461", 0.23), -- 4
				},
				true,
				false,
				giflib.gif.Mode.Replace,
				Enum.ResamplerMode.Pixelated
			),
			["LeftDown"] = gifInfo.new(
				{
					giflib.Frame.new("136521176957799", 0.2), -- 1
					giflib.Frame.new("87327527117896", 0.2), -- 2
					giflib.Frame.new("103358812367962", 0.2), --  3
					giflib.Frame.new("136354488624873", 0.2), -- 4
				},
				true,
				false,
				giflib.gif.Mode.Replace,
				Enum.ResamplerMode.Pixelated
			),
			["LeftUp"] = gifInfo.new(
				{
					giflib.Frame.new("115357019166297", 0.2), -- 1
					giflib.Frame.new("131955103378417", 0.2), -- 2
					giflib.Frame.new("93896191427341", 0.2), -- 3
					giflib.Frame.new("103596248518223", 0.2), -- 4
				},
				true,
				false,
				giflib.gif.Mode.Replace,
				Enum.ResamplerMode.Pixelated
			),
			["RightDown"] = gifInfo.new(
				{
					giflib.Frame.new("140606003074301", 0.2), -- 1
					giflib.Frame.new("79160010562415", 0.2), -- 2
					giflib.Frame.new("92726860268238", 0.2), -- 3
					giflib.Frame.new("133771113402094", 0.2), --4
				},
				true,
				false,
				giflib.gif.Mode.Replace,
				Enum.ResamplerMode.Pixelated
			),
			["RightUp"] = gifInfo.new(
				{
					giflib.Frame.new("88352851617875", 0.2), -- 1
					giflib.Frame.new("103617057842315", 0.2), -- 2
					giflib.Frame.new("116455657084740", 0.2), -- 3
					giflib.Frame.new("130845587189191", 0.2), -- 3
				},
				true,
				false,
				giflib.gif.Mode.Replace,
				Enum.ResamplerMode.Pixelated
			),
		},
		["Stay"] = {
			["Up"] = gifInfo.new(
				{
					giflib.Frame.new("137969061702953", 0.2), -- 1
				},
				true,
				false,
				giflib.gif.Mode.Replace,
				Enum.ResamplerMode.Pixelated
			),
			["Down"] = gifInfo.new(
				{
					giflib.Frame.new("80528378729899", 0.2), -- 1
				},
				true,
				false,
				giflib.gif.Mode.Replace,
				Enum.ResamplerMode.Pixelated
			),
			["Left"] = gifInfo.new(
				{
					giflib.Frame.new("107191532188364", 0.2), -- 1
				},
				true,
				false,
				giflib.gif.Mode.Replace,
				Enum.ResamplerMode.Pixelated
			),
			["Right"] = gifInfo.new(
				{
					giflib.Frame.new("75448470198348", 0.2), -- 1
				},
				true,
				false,
				giflib.gif.Mode.Replace,
				Enum.ResamplerMode.Pixelated
			),
			["LeftDown"] = gifInfo.new(
				{
					giflib.Frame.new("87327527117896", 0.2),
				},
				true,
				false,
				giflib.gif.Mode.Replace,
				Enum.ResamplerMode.Pixelated
			),
			["RightDown"] = gifInfo.new(
				{
					giflib.Frame.new("133771113402094", 0.2),
				},
				true,
				false,
				giflib.gif.Mode.Replace,
				Enum.ResamplerMode.Pixelated
			),
			["LeftUp"] = gifInfo.new(
				{
					giflib.Frame.new("103596248518223", 0.2),
				},
				true,
				false,
				giflib.gif.Mode.Replace,
				Enum.ResamplerMode.Pixelated
			),
			["RightUp"] = gifInfo.new(
				{
					giflib.Frame.new("130845587189191", 0.2),
				},
				true,
				false,
				giflib.gif.Mode.Replace,
				Enum.ResamplerMode.Pixelated
			),
		},
	}, { X = 10, Y = 9 }, Vector3.new(-1, -1, 4)),
	adventure2d.Map.new(
		Vector2.new(1, 1),
		adventure2d.Camera2d.new(1),
		"114575775575709",
		{
			NoPhysic,
			canTouch,
			CanCheckSide,
			CanCollide,
			CanCollide2,
		},
		Vector2.new(80, 300),
		Vector3.new(22, 48, 8)
	)
)

_game:Loading().Done:Wait()

_game:Start()

canTouch.Touched:Connect(function()
	print("touched")
end)

CanCheckSide.Touched:Connect(function(obj)
	print(" Touched with: ", obj, "touched in: ", CanCheckSide:GetTouchedSide())
end)
