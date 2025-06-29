local ControlType = require(script.Parent.ControlType)

local DefaultControls: ControlType.Control = {
	Keyboard = {
		Up = Enum.KeyCode.W,
		Down = Enum.KeyCode.S,
		Right = Enum.KeyCode.D,
		Left = Enum.KeyCode.A,
	},
	Gamepad = {
		Up = Enum.KeyCode.DPadUp,
		Down = Enum.KeyCode.DPadDown,
		Right = Enum.KeyCode.DPadRight,
		Left = Enum.KeyCode.DPadLeft,
	},
}

return DefaultControls
