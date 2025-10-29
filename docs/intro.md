# Getting started with 2d-adventure



Example:
```lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local player = require(StarterPlayer.StarterPlayerScripts.shared.player)
local dialoglib = require(ReplicatedStorage.DevPackages.dialoglib)
local InputLib = require(ReplicatedStorage.Packages.InputLib)
local adventure2d = require(ReplicatedStorage.Packages["2d-adventure"])

local GameFrame = Players.LocalPlayer
	:WaitForChild("PlayerGui")
	:WaitForChild("ScreenGui")
	:WaitForChild("Frame") :: Frame

local cam = camera2d.new(1)

local changeMap = adventure2d.Object2d.new(
	Vector2.new(336, 94),
	Vector3.new(28, 69, 10),
	adventure2d.ExImage.new("84486373084684")
)

local shee = adventure.Object2d.new(
	Vector2.new(300, 140),
	Vector3.new(24, 50, 8),
	adventure2d.ExImage.new("75550147574274")
)

local map1 = adventure2d.Map.new(Vector2.new(1, 1), cam, "114575775575709", {
	Object2d.new( -- door
		Vector2.new(157, 196),
		Vector3.new(28, 69, 10),
		adventure2d.ExImage.new("84486373084684")
	),
	changeMap,
	Object2d.new( -- plant
		Vector2.new(572, 133),
		Vector3.new(20, 33, 12),
		adventure2d.ExImage.new("76560541017161"),
		false,
		true,
		true,
		true
	),
	shee,
}, Vector2.new(80, 300), Vector3.new(22, 48, 8))

local player = adventure2d.Player2d.new({
	["IDLE"] = {
		["a"] = adventure2d.Animation.new(
			adventure2d.GifInfo.new(
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
			audio.Stay
		),
	},
	["Walk"] = {
		["Up"] = adventure2d.Animation.new(
			adventure2d.GifInfo.new(
				{
					giflib.Frame.new("137969061702953", 0.2), -- 1
					giflib.Frame.new("83379893118196", 0.2), -- 2
				},
				true,
				false,
				giflib.gif.Mode.Replace,
				Enum.ResamplerMode.Pixelated
			),
			audio.Walk
		),
		["Down"] = adventure2d.Animation.new(
			adventure2d.GifInfo.new(
				{
					giflib.Frame.new("80528378729899", 0.2), -- 1
					giflib.Frame.new("76126762386526", 0.2), -- 2
				},
				true,
				false,
				giflib.gif.Mode.Replace,
				Enum.ResamplerMode.Pixelated
			),
			audio.Walk
		),
		["Left"] = adventure2d.Animation.new(
			adventure2d.GifInfo.new(
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
			audio.Walk
		),
		["Right"] = adventure2d.Animation.new(
			adventure2d.GifInfo.new(
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
			audio.Walk
		),
		["LeftDown"] = adventure2d.Animation.new(
			adventure2d.GifInfo.new(
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
			audio.Walk
		),
		["LeftUp"] = adventure2d.Animation.new(
			adventure2d.GifInfo.new(
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
			audio.Walk
		),
		["RightDown"] = adventure2d.Animation.new(
			adventure2d.GifInfo.new(
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
			audio.Walk
		),
		["RightUp"] = adventure2d.Animation.new(
			adventure2d.GifInfo.new(
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
			audio.Walk
		),
	},
	["Stay"] = {
		["Up"] = adventure2d.Animation.new(
			adventure2d.GifInfo.new(
				{
					giflib.Frame.new("137969061702953", 0.2), -- 1
				},
				true,
				false,
				giflib.gif.Mode.Replace,
				Enum.ResamplerMode.Pixelated
			),
			audio.Stay
		),
		["Down"] = adventure2d.Animation.new(
			adventure2d.GifInfo.new(
				{
					giflib.Frame.new("80528378729899", 0.2), -- 1
				},
				true,
				false,
				giflib.gif.Mode.Replace,
				Enum.ResamplerMode.Pixelated
			),
			audio.Stay
		),
		["Left"] = adventure2d.Animation.new(
			adventure2d.GifInfo.new(
				{
					giflib.Frame.new("107191532188364", 0.2), -- 1
				},
				true,
				false,
				giflib.gif.Mode.Replace,
				Enum.ResamplerMode.Pixelated
			),
			audio.Stay
		),
		["Right"] = adventure2d.Animation.new(
			adventure2d.GifInfo.new(
				{
					giflib.Frame.new("75448470198348", 0.2), -- 1
				},
				true,
				false,
				giflib.gif.Mode.Replace,
				Enum.ResamplerMode.Pixelated
			),
			audio.Stay
		),
		["LeftDown"] = adventure2d.Animation.new(
			adventure2d.GifInfo.new(
				{
					giflib.Frame.new("87327527117896", 0.2),
				},
				true,
				false,
				giflib.gif.Mode.Replace,
				Enum.ResamplerMode.Pixelated
			),
			audio.Stay
		),
		["RightDown"] = adventure2d.Animation.new(
			adventure2d.GifInfo.new(
				{
					giflib.Frame.new("133771113402094", 0.2),
				},
				true,
				false,
				giflib.gif.Mode.Replace,
				Enum.ResamplerMode.Pixelated
			),
			audio.Stay
		),
		["LeftUp"] = adventure2d.Animation.new(
			adventure2d.GifInfo.new(
				{
					giflib.Frame.new("103596248518223", 0.2),
				},
				true,
				false,
				giflib.gif.Mode.Replace,
				Enum.ResamplerMode.Pixelated
			),
			audio.Stay
		),
		["RightUp"] = adventure2d.Animation.new(
			adventure2d.GifInfo.new(
				{
					giflib.Frame.new("130845587189191", 0.2),
				},
				true,
				false,
				giflib.gif.Mode.Replace,
				Enum.ResamplerMode.Pixelated
			),
			audio.Stay
		),
	},
}, { X = 10, Y = 9 }, Vector3.new(25, 50, 4))

local _game = adventure2d.Game.new(GameFrame, player, map1)

_game:Loading().Done:Wait()

_game:Start()

```



