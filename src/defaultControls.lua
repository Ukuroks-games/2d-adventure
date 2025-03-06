local control = require(script.Parent.controlType)

local DefaultControls: control.Control = {
	Keyboard = {
		Up = Enum.KeyCode.W,
		Down = Enum.KeyCode.S,
		Right = Enum.KeyCode.D,
		Left = Enum.KeyCode.A,
	},
	Gamepad = {
		Up = Enum.KeyCode.W,
		Down = Enum.KeyCode.W,
		Right = Enum.KeyCode.W,
		Left = Enum.KeyCode.W,
	}
}

return DefaultControls
