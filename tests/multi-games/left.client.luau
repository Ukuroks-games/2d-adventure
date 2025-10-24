--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local adventure2d = require(ReplicatedStorage.Packages["2d-adventure"])

adventure2d.config.ShowHitboxes = true

local player = require(StarterPlayer.StarterPlayerScripts.shared.player)

local GameFrame = Players.LocalPlayer
	:WaitForChild("PlayerGui")
	:WaitForChild("ScreenGui")
	:WaitForChild("Left") :: CanvasGroup

local cam = adventure2d.Camera2d.new(1)

local changeMap = adventure2d.Object2d.new(
	Vector2.new(336, 94),
	Vector3.new(28, 69, 10),
	adventure2d.ExImage.new("84486373084684")
)

local shee = adventure2d.Object2d.new(
	Vector2.new(300, 140),
	Vector3.new(24, 50, 8),
	adventure2d.ExImage.new("75550147574274")
)

local map1 = adventure2d.Map.new(Vector2.new(1, 1), cam, "114575775575709", {
	adventure2d.Object2d.new( -- door
		Vector2.new(157, 196),
		Vector3.new(28, 69, 10),
		adventure2d.ExImage.new("84486373084684")
	),
	changeMap,
	adventure2d.Object2d.new( -- plant
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

local ChangeBack2 = adventure2d.Object2d.new(
	Vector2.new(15, 414),
	Vector3.new(65, 50, 50),
	adventure2d.ExImage.new("")
)

local map2 = adventure2d.Map.new(Vector2.new(1, 1), cam, "113837532573611", {
	ChangeBack2,
})

local Player = player:Clone()
local _game = adventure2d.Game.new(GameFrame, Player, map1)

_game:Loading().Done:Wait()

_game:Start()

print(Player)

changeMap.Touched:Connect(function(_)
	_game:SetMap(map2)
end)

ChangeBack2.Touched:Connect(function()
	_game:SetMap(map1)
end)
