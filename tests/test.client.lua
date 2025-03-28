local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Game = require(ReplicatedStorage.shared.game)
local giflib = require(ReplicatedStorage.Packages.giflib)
local camera2d = require(ReplicatedStorage.shared.camera2d)
local map = require(ReplicatedStorage.shared.map)
local player = require(ReplicatedStorage.shared.player)


local GameGui = Instance.new("ScreenGui", Players.LocalPlayer.PlayerGui)
local GameFrame = Instance.new("Frame", GameGui)
GameFrame.Size = UDim2.fromScale(1, 1)


local cam = camera2d.new(1)
local Map = map.new(Vector2.new(1, 1), cam, "76803732961234")



local _game = Game.new(
	GameFrame,
	player.new(
		{
			["IDLE"] = {
				giflib.Frame.new("123651728909570", 0.5),	-- 1
				giflib.Frame.new("73880862501758", 0.08),	-- 2
				giflib.Frame.new("76251571010833", 0.08),	-- 3
				giflib.Frame.new("115109214996806", 0.08),	-- 4
				giflib.Frame.new("75706149017684", 0.08),	-- 5
				giflib.Frame.new("93666646688648", 0.08),	-- 6
				giflib.Frame.new("108839932127938", 0.08),	-- 7
				giflib.Frame.new("81644303475497", 0.08),	-- 8
				giflib.Frame.new("131056695027889", 0.08),	-- 9
				giflib.Frame.new("82185418640948", 0.08),	-- 10
				giflib.Frame.new("131056695027889", 0.08),	-- 11
				giflib.Frame.new("82185418640948", 0.08),	-- 12
			},
			["WalkUp"] = {
				giflib.Frame.new("131056695027889", 0.5),	-- 1
			},
			["WalkDown"] = {
				giflib.Frame.new("108839932127938", 0.5),	-- 1
			},
			["WalkLeft"] = {
				giflib.Frame.new("131056695027889", 0.5),	-- 1
			},
			["WalkRight"] = {
				giflib.Frame.new("82185418640948", 0.5),	-- 1
			}
		},
		8,
		{
			X = 0.12,
			Y = 0.2
		}
	),
	Map
)

