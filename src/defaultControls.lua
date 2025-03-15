local ControlType = require(script.Parent.ControlType)

local DefaultControls: ControlType.Control = {
	Keyboard = {
		Up = Enum.KeyCode.W,
		Down = Enum.KeyCode.S,
		Right = Enum.KeyCode.D,
		Left = Enum.KeyCode.A,
	},
	Gamepad = {
		Up = Enum.KeyCode.ButtonA,
		Down = Enum.KeyCode.ButtonB,
		Right = Enum.KeyCode.ButtonR1,
		Left = Enum.KeyCode.ButtonR2,
	}
}

return DefaultControls
