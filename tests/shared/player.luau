--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local animations = require(script.Parent.animations)
local adventure2d = require(ReplicatedStorage.Packages["2d-adventure"])

return adventure2d.Player2d.new(animations, { X = 10, Y = 9 }, Vector3.new(25, 50, 4))
