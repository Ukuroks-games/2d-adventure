local stdlib = require("../Packages/stdlib")
local Audio = {}

Audio.out = stdlib.utility.CreateOrFindInstance("AudioOut", "AudioDeviceOut", workspace)

local ListenerPart = Instance.new("Part")

local Listener = Instance.new("AudioListener")
Listener.Parent = ListenerPart

local w = Instance.new("Wire")

w.SourceInstance = Listener
w.TargetInstance = Audio.out



return Audio
