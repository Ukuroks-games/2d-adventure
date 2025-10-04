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
	player,
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
