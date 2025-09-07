# Audio in 2d-adventure

Just use [roblox API](https://create.roblox.com/docs/audio)!

As [`AudioEmitter`](https://create.roblox.com/docs/reference/engine/classes/AudioEmitter) 
and [`AudioListener`](https://create.roblox.com/docs/reference/engine/classes/AudioListener)
you can use [`AudioEmitter2d`](../api/AudioEmitter2d) and [`AudioListener2d`](../api/AudioListener2d).

You still can use 

## How use [`AudioEmitter2d`](../api/AudioEmitter2d) and [`AudioListener2d`](../api/AudioListener2d)

abstract example:
```lua
local obj = adventure2d.Object2d.new(--[[ args ]])
local player = adventure2d.Player2d.new(--[[ args ]])

local audioPlayer = Instance.new("AudioPlayer")
local wire = Instance.new("Wire")
wire.SourceInstance = audioPlayer

local output = Instance.new("AudioDeviceOut")
local wire2 = Instance.new("Wire")
wire.TargetInstance = output

local emitter = adventure2d.AudioEmitter2d.new(obj, wire)


local listener = adventure2d.AudioListener2d.new(player, wire2)
```
