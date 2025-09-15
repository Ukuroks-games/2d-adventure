--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local player = require(StarterPlayer.StarterPlayerScripts.shared.player)
local adventure2d = require(ReplicatedStorage.Packages["2d-adventure"])

adventure2d.config.ShowHitboxes = true

Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

local GameFrame = Players.LocalPlayer.PlayerGui.ScreenGui.Frame
GameFrame.Size = UDim2.fromScale(1, 1)

local _game = adventure2d.Game.new(
	GameFrame,
	player,
	adventure2d.Map.new(
		Vector2.new(1, 1),
		adventure2d.Camera2d.new(1),
		"114575775575709",
		{
			adventure2d.Object2d.new(
				Vector2.new(200, 200),
				Vector3.new(20, 33, 12),
				adventure2d.ExImage.new("76560541017161"),
				false,
				true,
				true,
				false
			),
			adventure2d.Object2d.new(
				Vector2.new(200, 220),
				Vector3.new(20, 33, 12),
				adventure2d.ExImage.new("76560541017161"),
				false,
				true,
				true,
				false
			),
			adventure2d.Object2d.new(
				Vector2.new(200, 240),
				Vector3.new(20, 33, 12),
				adventure2d.ExImage.new("76560541017161"),
				false,
				true,
				true,
				false
			),

			adventure2d.Object2d.new(
				Vector2.new(200, 260),
				Vector3.new(20, 33, 12),
				adventure2d.ExImage.new("76560541017161"),
				false,
				true,
				true,
				false
			),
			adventure2d.Object2d.new(
				Vector2.new(200, 280),
				Vector3.new(20, 33, 12),
				adventure2d.ExImage.new("76560541017161"),
				false,
				true,
				true,
				false
			),
			adventure2d.Object2d.new(
				Vector2.new(200, 300),
				Vector3.new(20, 33, 12),
				adventure2d.ExImage.new("76560541017161"),
				false,
				true,
				true,
				false
			),
			adventure2d.Object2d.new(
				Vector2.new(220, 200),
				Vector3.new(20, 33, 12),
				adventure2d.ExImage.new("76560541017161"),
				false,
				true,
				true,
				false
			),
			adventure2d.Object2d.new(
				Vector2.new(220, 220),
				Vector3.new(20, 33, 12),
				adventure2d.ExImage.new("76560541017161"),
				false,
				true,
				true,
				false
			),
			adventure2d.Object2d.new(
				Vector2.new(220, 240),
				Vector3.new(20, 33, 12),
				adventure2d.ExImage.new("76560541017161"),
				false,
				true,
				true,
				false
			),

			adventure2d.Object2d.new(
				Vector2.new(220, 260),
				Vector3.new(20, 33, 12),
				adventure2d.ExImage.new("76560541017161"),
				false,
				true,
				true,
				false
			),
			adventure2d.Object2d.new(
				Vector2.new(220, 280),
				Vector3.new(20, 33, 12),
				adventure2d.ExImage.new("76560541017161"),
				false,
				true,
				true,
				false
			),
			adventure2d.Object2d.new(
				Vector2.new(220, 300),
				Vector3.new(20, 33, 12),
				adventure2d.ExImage.new("76560541017161"),
				false,
				true,
				true,
				false
			),
		},
		Vector2.new(80, 300),
		Vector3.new(22, 48, 8)
	)
)

_game:Loading().Done:Wait()

_game.Player.Move:Connect(function()
	print("Player pos:", _game.Player:GetCoordinates())
end)

_game:Start()
