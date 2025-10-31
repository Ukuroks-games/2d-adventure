--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local animations = require(StarterPlayer.StarterPlayerScripts.shared.animations)
local player = require(StarterPlayer.StarterPlayerScripts.shared.player)
local dialoglib = require(ReplicatedStorage.DevPackages.dialoglib)
local InputLib = require(ReplicatedStorage.Packages.InputLib)
local stdlib = require(ReplicatedStorage.Packages.stdlib)
local adventure2d = require(ReplicatedStorage.Packages["2d-adventure"])

local Game = adventure2d.Game
local Object2d = adventure2d.Object2d
local camera2d = adventure2d.Camera2d
local map = adventure2d.Map
local ExImage = adventure2d.ExImage

adventure2d.config.ShowHitboxes = true

local GameFrame = Players.LocalPlayer
	:WaitForChild("PlayerGui")
	:WaitForChild("ScreenGui")
	:WaitForChild("Frame") :: Frame

local DialogFrame = Players.LocalPlayer
	:WaitForChild("PlayerGui")
	:WaitForChild("ScreenGui")
	:WaitForChild("Dialog") :: Frame

local Pause = Players.LocalPlayer
	:WaitForChild("PlayerGui")
	:WaitForChild("ScreenUI")
	:WaitForChild("Pause") :: TextButton

local cam = camera2d.new(1)

local changeMap = Object2d.new(
	Vector2.new(336, 94),
	Vector3.new(28, 69, 10),
	ExImage.new("84486373084684")
)

local shee = adventure2d.Character2d.new(
	stdlib.utility.clone(animations),
	{X = 9, Y= 9},
	Vector3.new(24, 50, 8)
)
shee:SetPosition(Vector2.new(300, 140))
shee:SetAnimation("IDLE")
shee.Anchored = true


local map1 = map.new(Vector2.new(1, 1), cam, "114575775575709", {
	Object2d.new( -- door
		Vector2.new(157, 196),
		Vector3.new(28, 69, 10),
		ExImage.new("84486373084684")
	),
	changeMap,
	Object2d.new( -- plant
		Vector2.new(572, 133),
		Vector3.new(20, 33, 12),
		ExImage.new("76560541017161"),
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

local map2 = map.new(Vector2.new(1, 1), cam, "113837532573611", {
	ChangeBack2,
})

local _game = Game.new(GameFrame, player, map1)


local a = adventure2d.Calc.CalcSize(
			Vector3.new(_game.Player.WalkSpeed.X, _game.Player.WalkSpeed.Y, 0),
			map1.Image
		)
shee.WalkSpeed.Calculated = Vector2.new(a.X, a.Y)

_game:Loading().Done:Wait()

_game:Start()

changeMap.Touched:Connect(function(_)
	_game:SetMap(map2)
end)

ChangeBack2.Touched:Connect(function()
	_game:SetMap(map1)
end)

local faceId: string = "rbxassetid://117978347308606"
local d = dialoglib.dialog.new(DialogFrame, {
	dialoglib.phrase.new(
		"This is a demo. Nothing",
		dialoglib.character.new(faceId)
	),
	dialoglib.phrase.new("test", dialoglib.character.new(faceId)),
	dialoglib.phrase.new("Go away!", dialoglib.character.new(faceId)),
})
d.Text.ZIndex = 999
d.CharFace.ZIndex = 999
d.MainFrame.Visible = false

local Paused = false

shee.Touched:Connect(function(_)
	if not d.MainFrame.Visible then
		d.MainFrame.Visible = true
		if not Paused then
			Paused = true
			_game:Pause()
		end

		d:Next()

		InputLib.OnUserInput({
			Enum.UserInputType.Touch,
			Enum.UserInputType.MouseButton1,
			Enum.UserInputType.Gamepad1,
		}, {}).Event
			:Wait()

		_game:Resume()
		Paused = false
		d.MainFrame.Visible = false
		shee:WalkTo(Vector2.new(1, 1))
	end
end)

Pause.MouseButton1Click:Connect(function()
	if Paused then
		_game:Resume()
	else
		_game:Pause()
	end
	Paused = not Paused
end)
