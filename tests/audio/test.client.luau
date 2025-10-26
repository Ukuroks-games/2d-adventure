--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")


local audioAnalyser = require(ReplicatedStorage.DevPackages.audioAnalyser)
local adventure2d = require(ReplicatedStorage.Packages["2d-adventure"])

adventure2d.config.ShowHitboxes = true

local player = require(StarterPlayer.StarterPlayerScripts.shared.player)

local gui = Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui")

local GameFrame = gui:WaitForChild("Frame") :: Frame

local obj = adventure2d.Object2d.new(
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

local audioPlayer = Instance.new("AudioPlayer")
audioPlayer.Asset = "rbxassetid://90342360691837"
audioPlayer.Looping = true
audioPlayer.Parent = workspace

local wire = Instance.new("Wire")
wire.SourceInstance = audioPlayer
wire.Parent = workspace

local emitter = _game.AudioEmitter.new(obj, wire)

local out = Instance.new("AudioDeviceOutput")
out.Parent = workspace

local input = Instance.new("Wire")
input.Parent = workspace

local listener = _game.AudioListener.new(_game.Player, input)

local w = Instance.new("Wire")
w.TargetInstance = out
w.SourceInstance = listener.Listener
w.Parent = workspace

local ChannelsGraph = gui:WaitForChild("ChannelsGraph") :: Frame

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

audioPlayer:Play()

