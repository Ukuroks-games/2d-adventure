
local Control = {}

export type Control = {
	Keyboard: {
		Up: Enum.KeyCode,
		Down: Enum.KeyCode,
		Left: Enum.KeyCode,
		Right: Enum.KeyCode,
	},
	Gamepad: {
		Up: Enum.KeyCode,
		Down: Enum.KeyCode,
		Left: Enum.KeyCode,
		Right: Enum.KeyCode,
	}
}

return Control
