--!strict

local audio = {}

audio.Walk = Instance.new("AudioPlayer")
audio.Walk.Parent = workspace
audio.Walk.Asset = "rbxassetid://6563562192"
audio.Walk.Looping = true

audio.Stay = Instance.new("AudioPlayer")
audio.Stay.Parent = workspace
audio.Stay.Looping = true

local out = Instance.new("AudioDeviceOutput")
out.Parent = workspace

local w1 = Instance.new("Wire")
w1.Parent = workspace
w1.SourceInstance = audio.Walk
w1.TargetInstance = out

local w2 = Instance.new("Wire")
w2.Parent = workspace
w2.SourceInstance = audio.Stay
w2.TargetInstance = out


return audio
