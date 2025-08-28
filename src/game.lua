local stdlib = require(script.Parent.Parent.stdlib)
local mutex = stdlib.mutex

local ControlType = require(script.Parent.ControlType)
local defaultControls = require(script.Parent.defaultControls)
local map = require(script.Parent.map)
local player = require(script.Parent.player)
local Control = require(script.Parent.Control)

--[[
	Класс игры
]]
local Game = setmetatable({}, { __index = Control })

export type GameStruct = {
	--[[
		Game background
	]]
	Frame: Frame,

	--[[
		Player
	]]
	Player: player.Player2d,

	--[[
	
	]]
	Connections: { RBXScriptConnection },

	--[[
	
	]]
	DestroyingEvent: BindableEvent,

	--[[
	
	]]
	CollideSteppedEvent: BindableEvent<>,

	ControlThread: thread?,
} & Control.ControlStruct

export type Game = GameStruct & typeof(Game) & Control.Control

--[[

]]
function Game.Destroy(self: GameStruct)
	self.DestroyingEvent:Fire()

	for _, v in pairs(self.DestroyableObjects) do
		if v then
			v:Destroy()
		end
	end

	for _, v in pairs(self.Connections) do
		if v then
			v:Disconnect()
		end
	end

	self.Frame:Destroy()
	self.CollideSteppedEvent:Destroy()
	self.Player:Destroy()
	self.DestroyingEvent:Destroy()
end

--[[
	Set current map
]]
function Game.SetMap(self: Game, newMap: map.Map)
	self.Map:Done(self.Player)
	self.Map = newMap
	newMap:Init(self.Player, self.Frame)
end

--[[
	Set player
]]
function Game.SetPlayer(self: Game, newPlayer: player.Player2d)
	self.Map:SetPlayer(newPlayer, self.Player)
	self.Player = newPlayer
end

--[[
	Loading game
]]
function Game.Loading(self: Game)
	local DoneEvent = Instance.new("BindableEvent")
	local Progress = Instance.new("NumberValue")

	task.spawn(function()
		self.Map:Loading(Progress)
		DoneEvent:Fire()
	end)

	local a = setmetatable({
		Wait = function(_)
			if Progress.Value < 1 then
				DoneEvent.Event:Wait()
			end
		end,
	}, { __index = DoneEvent.Event })

	return {
		Done = a,
		Progress = Progress,
		DoneEvent = DoneEvent,
	}
end

--[[
	Game constructor
]]
function Game.new(
	GameFrame: Frame,
	Player: player.Player2d,
	Map: map.Map,
	cooldownTime: number?,
	controllerSettings: ControlType.Control?
): Game
	local DestroyingEvent = Instance.new("BindableEvent")
	local CollideSteppedEvent = Instance.new("BindableEvent")

	local self: GameStruct = {
		Frame = GameFrame,
		Player = Player,
		Map = Map,
		Destroying = DestroyingEvent.Event,
		DestroyingEvent = DestroyingEvent,
		CollideStepped = CollideSteppedEvent.Event,
		CollideSteppedEvent = CollideSteppedEvent,
		CooldownTime = cooldownTime or 0.1,
		DestroyableObjects = {},
		Connections = {},
		MoveTween = nil,
		CollideMutex = mutex.new(true),
		Moving = false,
		ControlThread = nil,
		ControllerSettings = controllerSettings or defaultControls,
	}

	self.Player:SetParent(self.Frame)

	self.Map:Init(self.Player, self.Frame)

	setmetatable(self, { __index = Game })

	return self :: Game
end

return Game
