local stdlib = require(script.Parent.Parent.stdlib)
local algorithm = stdlib.algorithm

local physicObject = require(script.Parent.physicObject)

local PhysicController = {}

export type PhysicControllerStruct = {

	Objects: { [number]: physicObject.PhysicObject },
}

export type PhysicController = typeof(setmetatable(
	{} :: PhysicControllerStruct,
	{ __index = PhysicController }
))

function PhysicController.CalcPositions(self: PhysicController)
	for _, v in pairs(self.Objects) do
		v:CalcSizeAndPos()
	end
end

function PhysicController.CalcCollide(self: PhysicController)
	--[[
		Список объектов которые имеют коллизию
	]]
	local Objects: { physicObject.PhysicObject } = algorithm.copy_if(
		self.Objects,
		function(value): boolean
			return value.CanCollide
				and (value.PhysicMode > physicObject.PhysicMode.NoPhysic)
		end
	)

	for _, v: physicObject.PhysicObject in pairs(Objects) do
		v:StartPhysicCalc()
	end

	for _, v: physicObject.PhysicObject in pairs(Objects) do
		local i = algorithm.copy_if(
			Objects,
			function(value: physicObject.PhysicObject): boolean
				return value ~= v and physicObject.CheckCollision(v, value)
			end
		)

		for _, obj in pairs(i) do
			v.TouchedEvent:Fire(obj)
			v:CalcTouchedSide(obj)
		end
	end

	for _, v: physicObject.PhysicObject in pairs(Objects) do
		v:DonePhysicCalc()
	end
end
return PhysicController
