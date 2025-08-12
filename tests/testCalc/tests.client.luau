local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local testlib = require(ReplicatedStorage.DevPackages.testlib)
local Calc = require(ReplicatedStorage.Packages["2d-adventure"].Calc)
local ExImage = require(ReplicatedStorage.Packages["2d-adventure"].ExImage)

local GameFrame: Frame = Players.LocalPlayer
	:WaitForChild("PlayerGui")
	:WaitForChild("ScreenGui").Frame
GameFrame.Size = UDim2.fromScale(1, 1)

local background = ExImage.new("114575775575709")
background.ImageInstance.Parent = GameFrame
background.ImageInstance.Size = UDim2.fromScale(1, 1)

local Pos = Vector2.new(10, 10)
local Size = Vector3.new(10, 10, 10)

testlib:AddTest(testlib.test.new("ReturnPos", function(): boolean
	return Calc.ReturnPosition(Calc.CalcPosition(Pos, background), background)
		== Pos
end))

testlib:AddTest(testlib.test.new("ReturnSize", function(): boolean
	return Calc.ReturnSize(Calc.CalcSize(Size, background), background) == Size
end))
