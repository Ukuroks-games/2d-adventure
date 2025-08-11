--!strict

local controlType = require(script.Parent.ControlType)
local defaultControls = require(script.Parent.defaultControls)

local Control = {}

function Control.new(data: { Keyboard: controlType.ControlButtons?, Gamepad: controlType.ControlButtons? }?): controlType.Control

	if data then
		local self: controlType.Control = {
			Keyboard = data.Keyboard or defaultControls.Keyboard,
			Gamepad = data.Gamepad or defaultControls.Gamepad
		}

		return self
	else
		return defaultControls
	end

end

return Control
