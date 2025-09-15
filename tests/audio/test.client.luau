--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local player = require(StarterPlayer.StarterPlayerScripts.shared.player)
local audioAnalyser = require(ReplicatedStorage.DevPackages.audioAnalyser)
local adventure2d = require(ReplicatedStorage.Packages["2d-adventure"])
local Object2d = require(ReplicatedStorage.Packages["2d-adventure"].Object2d)


adventure2d.config.ShowHitboxes = true

Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

local GameFrame = Players.LocalPlayer.PlayerGui.ScreenGui.Frame
GameFrame.Size = UDim2.fromScale(1, 1)

local obj = Object2d.new(
	Vector2.new(100, 100),
	Vector3.new(100, 100, 50),
	adventure2d.ExImage.new("176572847")
)

local _game = adventure2d.Game.new(
	GameFrame,
	player,
	adventure2d.Map.new(
		Vector2.new(1, 1),
		adventure2d.Camera2d.new(1),
		"114575775575709",
		{
			obj,
		},
		Vector2.new(80, 300),
		Vector3.new(22, 48, 8)
	)
)

local player = Instance.new("AudioPlayer")
player.Asset = "rbxassetid://90342360691837"
player.Looping = true
player.Parent = workspace

local wire = Instance.new("Wire")
wire.SourceInstance = player
wire.Parent = workspace

local emitter = adventure2d.AudioEmitter.new(obj, wire)

local out = Instance.new("AudioDeviceOutput")
out.Parent = workspace

local input = Instance.new("Wire")
input.Parent = workspace

local listener = adventure2d.AudioListener.new(_game.Player, input)

local w = Instance.new("Wire")
w.TargetInstance = out
w.SourceInstance = listener.Listener
w.Parent = workspace

local ChannelsGraph = Instance.new("Frame")
ChannelsGraph.Parent = Players.LocalPlayer.PlayerGui.ScreenGui
ChannelsGraph.Size = UDim2.fromScale(0.6, 0.3)
ChannelsGraph.ZIndex = 999

audioAnalyser.new(ChannelsGraph, nil, input)

local function setZIndex(list)
	for _, v in pairs(list) do
		v.ZIndex = 999
		setZIndex(v:GetChildren())
	end
end

setZIndex(ChannelsGraph:GetChildren())

_game:Loading().Done:Wait()

_game:Start()

player:Play()

_game.Player.Move:Connect(function()
	emitter:UpdatePosition()
	listener:UpdatePosition()
end)
