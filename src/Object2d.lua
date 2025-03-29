local Object2d = {}

Object2d.TouchSide = {
	NoTouched = 0,
	Up = 1,
	Down = 2,
	Right = 3,
	Left = 4
}

export type Object2d = {

	AnchorPosition: Vector2,

	Size: Vector2,

	CanCollide: boolean,

	Touched: RBXScriptSignal,

	TouchedSide: number,

	TouchedEvent: BindableEvent,
}

function Object2d.new(AnchorPosition: Vector2, Size: Vector2): Object2d
	
	local TouchedEvent = Instance.new("BindableEvent")

	local self = {
		AnchorPosition = AnchorPosition,
		Size = Size,
		CanCollide = true,
		Map = nil,
		TouchedSide = Object2d.TouchSide.NoTouched,	-- by default not touched
		Touched = TouchedEvent.Event,
		TouchedEvent = TouchedEvent
	}

	return self
end

return Object2d
