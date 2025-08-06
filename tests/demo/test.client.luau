local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local dialoglib = require(ReplicatedStorage.DevPackages.dialoglib)
local adventure2d = require(ReplicatedStorage.Packages["2d-adventure"])
local giflib = require(ReplicatedStorage.Packages.giflib)

local Game = adventure2d.Game
local Object2d = adventure2d.Object2d
local camera2d = adventure2d.Camera2d
local map = adventure2d.Map
local ExImage = adventure2d.ExImage
local player = adventure2d.Player2d
local gifInfo = adventure2d.GifInfo

--adventure2d.config.ShowHitboxes = true

local GameFrame = Players.LocalPlayer
	:WaitForChild("PlayerGui")
	:WaitForChild("ScreenGui").Frame
GameFrame.Size = UDim2.fromScale(1, 1)

local DialogFrame = Players.LocalPlayer
	:WaitForChild("PlayerGui")
	:WaitForChild("ScreenGui").Dialog
DialogFrame.Size = UDim2.fromScale(1, 0.3)
DialogFrame.Position = UDim2.fromScale(0, 0.7)
DialogFrame.ZIndex = 999

local Pause = Players.LocalPlayer
	:WaitForChild("PlayerGui")
	:WaitForChild("ScreenGui").Pause

Pause.Size = UDim2.fromScale(0.1, 0.1)
Pause.Position = UDim2.fromScale(0.9, 0.01)
Pause.ZIndex = 999

local cam = camera2d.new(1)

local changeMap = Object2d.new(
	Vector2.new(336, 94),
	Vector3.new(28, 69, 10),
	ExImage.new("84486373084684")
)

local shee = Object2d.new(
	Vector2.new(300, 140),
	Vector3.new(24, 50, 8),
	ExImage.new("75550147574274")
)

local map1 = map.new(Vector2.new(1, 1), cam, "114575775575709", {
	Object2d.new( -- door
		Vector2.new(157, 196),
		Vector3.new(28, 69, 10),
		ExImage.new("84486373084684")
	),
	changeMap,
	Object2d.new(
		Vector2.new(572, 133),
		Vector3.new(20, 33, 8),
		ExImage.new("76560541017161"),
		false,
		true,
		true,
		true
	),
	shee,
}, Vector2.new(80, 300), Vector3.new(22, 48, 8))

local map2 = map.new(Vector2.new(1, 1), cam, "131246783435400")

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
		}, true, true, giflib.gif.Mode.Replace, Enum.ResamplerMode.Pixelated),
		["WalkUp"] = gifInfo.new({
			giflib.Frame.new("137969061702953", 0.2), -- 1
			giflib.Frame.new("83379893118196", 0.2), -- 2
		}, true, false, giflib.gif.Mode.Replace, Enum.ResamplerMode.Pixelated),
		["WalkDown"] = gifInfo.new({
			giflib.Frame.new("80528378729899", 0.2), -- 1
			giflib.Frame.new("76126762386526", 0.2), -- 2
		}, true, false, giflib.gif.Mode.Replace, Enum.ResamplerMode.Pixelated),
		["WalkLeft"] = gifInfo.new({
			giflib.Frame.new("130325387410477", 0.2), -- 1
			giflib.Frame.new("134555323130510", 0.2), -- 2
			giflib.Frame.new("129026456910746", 0.23), -- 3
		}, true, false, giflib.gif.Mode.Replace, Enum.ResamplerMode.Pixelated),
		["WalkRight"] = gifInfo.new({
			giflib.Frame.new("75448470198348", 0.2), -- 1
			giflib.Frame.new("86103040112243", 0.2), -- 2
			giflib.Frame.new("121217812639445", 0.2), -- 3
			giflib.Frame.new("115170788363461", 0.23), -- 4
		}, true, false, giflib.gif.Mode.Replace, Enum.ResamplerMode.Pixelated),
		["WalkLeftDown"] = gifInfo.new({
			giflib.Frame.new("136521176957799", 0.2), -- 1
			giflib.Frame.new("87327527117896", 0.2), -- 2
			giflib.Frame.new("103358812367962", 0.2), --  3
			giflib.Frame.new("136354488624873", 0.2), -- 4
		}, true, false, giflib.gif.Mode.Replace, Enum.ResamplerMode.Pixelated),
		["WalkLeftUp"] = gifInfo.new({
			giflib.Frame.new("115357019166297", 0.2), -- 1
			giflib.Frame.new("131955103378417", 0.2), -- 2
			giflib.Frame.new("93896191427341", 0.2), -- 3
			giflib.Frame.new("103596248518223", 0.2), -- 4
		}, true, false, giflib.gif.Mode.Replace, Enum.ResamplerMode.Pixelated),
		["WalkRightDown"] = gifInfo.new({
			giflib.Frame.new("140606003074301", 0.2), -- 1
			giflib.Frame.new("79160010562415", 0.2), -- 2
			giflib.Frame.new("92726860268238", 0.2), -- 3
			giflib.Frame.new("133771113402094", 0.2), --4
		}, true, false, giflib.gif.Mode.Replace, Enum.ResamplerMode.Pixelated),
		["WalkRightUp"] = gifInfo.new({
			giflib.Frame.new("88352851617875", 0.2), -- 1
			giflib.Frame.new("103617057842315", 0.2), -- 2
			giflib.Frame.new("116455657084740", 0.2), -- 3
			giflib.Frame.new("130845587189191", 0.2), --3
		}, true, false, giflib.gif.Mode.Replace, Enum.ResamplerMode.Pixelated),
		["StayUp"] = gifInfo.new({
			giflib.Frame.new("137969061702953", 0.2), -- 1
		}, true, false, giflib.gif.Mode.Replace, Enum.ResamplerMode.Pixelated),
		["StayDown"] = gifInfo.new({
			giflib.Frame.new("80528378729899", 0.2), -- 1
		}, true, false, giflib.gif.Mode.Replace, Enum.ResamplerMode.Pixelated),
		["StayLeft"] = gifInfo.new({
			giflib.Frame.new("107191532188364", 0.2), -- 1
		}, true, false, giflib.gif.Mode.Replace, Enum.ResamplerMode.Pixelated),
		["StayRight"] = gifInfo.new({
			giflib.Frame.new("75448470198348", 0.2), -- 1
		}, true, false, giflib.gif.Mode.Replace, Enum.ResamplerMode.Pixelated),
		["StayLeftDown"] = gifInfo.new({
			giflib.Frame.new("87327527117896", 0.2),
		}, true, false, giflib.gif.Mode.Replace, Enum.ResamplerMode.Pixelated),
		["StayRightDown"] = gifInfo.new({
			giflib.Frame.new("133771113402094", 0.2),
		}, true, false, giflib.gif.Mode.Replace, Enum.ResamplerMode.Pixelated),
		["StayLeftUp"] = gifInfo.new({
			giflib.Frame.new("103596248518223", 0.2),
		}, true, false, giflib.gif.Mode.Replace, Enum.ResamplerMode.Pixelated),
		["StayRightUp"] = gifInfo.new({
			giflib.Frame.new("130845587189191", 0.2),
		}, true, false, giflib.gif.Mode.Replace, Enum.ResamplerMode.Pixelated),
	}, { X = 10, Y = 9 }, Vector3.new(25, 50, 4)),
	map1
)

_game:Loading().Done:Wait()

_game:Start()

changeMap.Touched:Connect(function(_)
	_game:SetMap(map2)
end)

local d = dialoglib.dialog.new(DialogFrame, {
	dialoglib.phrase.new("test", dialoglib.character.new("null")),
	dialoglib.phrase.new("test", dialoglib.character.new("null")),
})

local lock = false

shee.Touched:Connect(function(_)
	if not lock then
		lock = true
		DialogFrame.Visible = lock
		print("pause")
		_game:Pause()
		d:Next()
		UserInputService.InputBegan:Wait()
		d:Next()
		UserInputService.InputBegan:Wait()
		print("resume")
		_game:Resume()
		lock = false
		DialogFrame.Visible = lock
	end
end)

Pause.MouseButton1Click:Connect(function()
	if lock then
		_game:Resume()
	else
		_game:Pause()
	end
	lock = not lock
end)
