local ExImage = require(script.Parent.ExImage)
local physicObject = {}

export type ImageType = Frame | ExImage.ExImage

export type PhysicObject = {
	Touched: RBXScriptSignal,

	TouchedEvent: BindableEvent,

	Image: ImageType,

	CanCollide: boolean,
}

function physicObject.Destroy(self: PhysicObject)
	self.TouchedEvent:Destroy()
end

function physicObject.new(image: ImageType): PhysicObject
	local TouchedEvent = Instance.new("BindableEvent")

	local this = {
		Touched = TouchedEvent.Event,
		TouchedEvent = TouchedEvent,
		Image = image,
		CanCollide = true,
	}

	return this
end

return physicObject
