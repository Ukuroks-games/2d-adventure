--!strict

--[=[
	@class config 
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
]=]
config.AudioPosition = Vector3.new()

return config
