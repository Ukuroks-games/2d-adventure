--[=[
	Сборник базовых функций для расчета физики

	@class Physic
]=]
local Physic = {}

--[=[
	Check frames collide
]=]
function Physic.CheckCollision(A: Frame, B: Frame): boolean
	local function Check(a: Frame, b: Frame)
		return (
			( -- тут тупо смотрим находится ли верхняя точка self где-то в other
				(
					a.AbsolutePosition.X
					<= (b.AbsolutePosition.X + b.AbsoluteSize.X)
				)
				and (
					(a.AbsolutePosition.X + a.AbsoluteSize.X)
					>= b.AbsolutePosition.X
				)
			)
			and (
				(
					a.AbsolutePosition.Y
					<= (b.AbsolutePosition.Y + b.AbsoluteSize.Y)
				)
				and (
					(a.AbsolutePosition.Y + a.AbsoluteSize.Y)
					>= b.AbsolutePosition.Y
				)
			)
		)
	end

	return Check(A, B) or Check(B, A)
end

return Physic
