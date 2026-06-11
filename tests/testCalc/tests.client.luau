--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local testlib = require(ReplicatedStorage.DevPackages.testlib)
local stdlib = require(ReplicatedStorage.Packages.stdlib)
local Calc = require(ReplicatedStorage.Packages["2d-adventure"].Calc)
local ExImage = require(ReplicatedStorage.Packages["2d-adventure"].ExImage)

local Gui =
	Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

local GameFrame: Frame = Gui:WaitForChild("Frame") :: Frame

local background = ExImage.new("114575775575709")
background.ImageInstance.Parent = GameFrame
background.ImageInstance.Size = UDim2.fromScale(1, 1)
background.ImageInstance.ScaleType = Enum.ScaleType.Fit

local XSpace = Instance.new("Frame")
XSpace.Position = UDim2.fromScale(0, 0.5)
XSpace.Parent = Gui
XSpace.BackgroundColor3 = Color3.new()

local YSpace = Instance.new("Frame")
YSpace.Position = UDim2.fromScale(0.5, 0)
YSpace.Parent = Gui
YSpace.BackgroundColor3 = Color3.new()

GameFrame.Changed:Connect(function(_)
	local Pos = Calc.CalcPosition(Vector2.new(200, 200), background)

	XSpace.Size = UDim2.fromOffset(Pos.X, 64)
	YSpace.Size = UDim2.fromOffset(64, Pos.Y)
	XSpace.Position = UDim2.fromOffset(0, Pos.Y)
	YSpace.Position = UDim2.fromOffset(Pos.X, 0)
end)

local TestsNum = 1000

local diffsP = {}
local diffsS = {}

for i = 1, TestsNum do
	local Pos = Vector2.new(math.random(-4096, 4096), math.random(-4096, 4096))
	local Size = Vector3.new(
		math.random(-4096, 4096),
		math.random(-4096, 4096),
		math.random(-4096, 512)
	)

	testlib:AddTest(
		testlib.test.new(
			"ReturnPos " .. i .. " " .. tostring(Pos),
			function(): boolean
				local v = Calc.ReturnPosition(
					Calc.CalcPosition(Pos, background),
					background
				)

				table.insert(diffsP, math.abs(v.X - Pos.X))
				table.insert(diffsP, math.abs(v.Y - Pos.Y))

				return stdlib.math.floatcmp(v.X, Pos.X, 1.6e-5)
					and stdlib.math.floatcmp(v.Y, Pos.Y, 1.6e-5)
			end
		)
	)

	testlib:AddTest(
		testlib.test.new(
			"ReturnSize " .. i .. " " .. tostring(Size),
			function(): boolean
				local v =
					Calc.ReturnSize(Calc.CalcSize(Size, background), background)

				table.insert(diffsS, math.abs(v.X - Size.X))
				table.insert(diffsS, math.abs(v.Y - Size.Y))
				table.insert(diffsS, math.abs(v.Z - Size.Z))

				return stdlib.math.floatcmp(v.X, Size.X, 1.6e-5)
					and stdlib.math.floatcmp(v.Y, Size.Y, 1.6e-5)
					and stdlib.math.floatcmp(v.Z, Size.Z, 1.6e-5)
			end
		)
	)
end

wait(1)

testlib:Summary()

print("POSITION PRECISION", diffsP[table.maxn(diffsP)])
print("SIZE PRECISION", diffsS[table.maxn(diffsS)])
