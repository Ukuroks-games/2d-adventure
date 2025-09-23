--!strict

local audio = {}

local sounds = workspace:WaitForChild("sounds")

audio.Walk = sounds:WaitForChild("Walk") :: AudioPlayer

audio.Stay = sounds:WaitForChild("Stay") :: AudioPlayer

local out = sounds:WaitForChild("Output")

local w1 = Instance.new("Wire")
w1.Parent = workspace
w1.SourceInstance = audio.Walk
w1.TargetInstance = out

local w2 = Instance.new("Wire")
w2.Parent = workspace
w2.SourceInstance = audio.Stay
w2.TargetInstance = out


return audio
