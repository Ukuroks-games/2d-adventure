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

function physicObject.new(image: ImageType, canCollide: boolean?): PhysicObject
	local TouchedEvent = Instance.new("BindableEvent")

	local this = {
		Touched = TouchedEvent.Event,
		TouchedEvent = TouchedEvent,
		Image = image,
		CanCollide = canCollide or true,
	}

	return this
end

return physicObject
