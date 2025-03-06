local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Game = require(ReplicatedStorage.shared.game)
local giflib = require(ReplicatedStorage.Packages.giflib)

local _game = Game.new(
	{
		["IDLE"] = {
			giflib.Frame.new("", 0.08)
		}
	},
	8,
	{
		X = 0.12,
		Y = 0.2
	}
)