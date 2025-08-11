--!strict

local Control = {}

export type ControlButtons = {

	Up: Enum.KeyCode,
	Down: Enum.KeyCode,
	Left: Enum.KeyCode,
	Right: Enum.KeyCode,
}

export type Control = {
	Keyboard: ControlButtons,
	Gamepad: ControlButtons
}

return Control
