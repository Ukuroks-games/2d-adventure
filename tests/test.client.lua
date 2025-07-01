local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Game = require(ReplicatedStorage.shared.game)
local giflib = require(ReplicatedStorage.Packages.giflib)
local ExImage = require(ReplicatedStorage.shared.ExImage)
local camera2d = require(ReplicatedStorage.shared.camera2d)
local map = require(ReplicatedStorage.shared.map)
local player = require(ReplicatedStorage.shared.player)
local Object2d = require(ReplicatedStorage.shared.Object2d)
local gifInfo = require(ReplicatedStorage.shared.gifInfo)

local GameFrame = Players.LocalPlayer
	:WaitForChild("PlayerGui")
	:WaitForChild("ScreenGui").Frame
GameFrame.Size = UDim2.fromScale(1, 1)

local cam = camera2d.new(1)

local _game = Game.new(
	GameFrame,
	player.new({
		["IDLE"] = gifInfo.new({ -- IDLE animation frames
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
		}, true, true, giflib.gif.Mode.Replace),
		["WalkUp"] = gifInfo.new({
			giflib.Frame.new("131056695027889", 0.5), -- 1
		}, true, false, giflib.gif.Mode.Replace),
		["WalkDown"] = gifInfo.new({
			giflib.Frame.new("108839932127938", 0.5), -- 1
		}, true, false, giflib.gif.Mode.Replace),
		["WalkLeft"] = gifInfo.new({
			giflib.Frame.new("131056695027889", 0.5), -- 1
		}, true, false, giflib.gif.Mode.Replace),
		["WalkRight"] = gifInfo.new({
			giflib.Frame.new("82185418640948", 0.5), -- 1
		}, true, false, giflib.gif.Mode.Replace),
	}, 1 / 100, Vector3.new(-1, -1, 4)),
	map.new(Vector2.new(1, 1), cam, "76803732961234", {
		Object2d.new( -- door
			Vector2.new(157, 196),
			Vector3.new(28, 69, 8),
			ExImage.new("84486373084684")
		),
	}, Vector2.new(80, 300))
)
