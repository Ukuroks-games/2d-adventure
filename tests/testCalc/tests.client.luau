--!strict

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

local TestsNum = 1000

for i = 1, TestsNum do
	local Pos = Vector2.new(math.random(-256, 256), math.random(-256, 256))
	local Size = Vector3.new(
		math.random(-256, 256),
		math.random(-256, 256),
		math.random(-256, 256)
	)

	testlib:AddTest(
		testlib.test.new(
			"ReturnPos " .. i .. " " .. tostring(Pos),
			function(): boolean
				return Calc.ReturnPosition(
					Calc.CalcPosition(Pos, background),
					background
				) == Pos
			end
		)
	)

	testlib:AddTest(
		testlib.test.new(
			"ReturnSize " .. i .. " " .. tostring(Size),
			function(): boolean
				return Calc.ReturnSize(
					Calc.CalcSize(Size, background),
					background
				) == Size
			end
		)
	)
end

wait(1)

testlib:Summary()
