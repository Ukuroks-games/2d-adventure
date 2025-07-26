local Game = require(script.game)
local Object2d = require(script.Object2d)
local Player2d = require(script.player)
local PhysicObject = require(script.physicObject)
local Map = require(script.map)
local Camera2d = require(script.camera2d)
local GifInfo = require(script.gifInfo)
local ExImage = require(script.ExImage)
local config = require(script.config)

local lib = {
	Game = Game,
	Object2d = Object2d,
	Player2d = Player2d,
	PhysicObject = PhysicObject,
	Map = Map,
	Camera2d = Camera2d,
	GifInfo = GifInfo,
	ExImage = ExImage,
	config = config
}

export type Game = Game.Game
export type Object2d = Object2d.Object2d
export type Player2d = Player2d.Player2d
export type Map = Map.Map
export type Camera2d = Camera2d.Camera2d
export type ExImage = ExImage.ExImage

return lib
