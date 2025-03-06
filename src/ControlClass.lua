local controlType = require(script.Parent.controlType)
local defaultControls = require(script.Parent.defaultControls)

local Control = {}

function Control.new(data: { Keyboard: {}?, Gamepad: {}? }?): controlType.Control

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
