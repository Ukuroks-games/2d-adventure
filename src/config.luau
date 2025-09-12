--!strict

--[=[
	@class config 

	Configuration
]=]
local config = {}

--[=[
	@prop ShowHitboxes boolean
	@within config
]=]
config.ShowHitboxes = false

--[=[
	@prop HitboxesTransparent number
	@within config
]=]
config.HitboxesTransparent = 0.75

--[=[
	@prop AudioPosition Vector3
	@within config
	@tag Audio
	@since v0.6.0
]=]
config.AudioPosition = Vector3.new()

--[=[
	by default 5
	@prop AudioDistanceFactor number
	@within config
	@tag Audio
	@since v0.6.0
]=]
config.AudioDistanceFactor = 5

return config
