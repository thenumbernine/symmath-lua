require 'ext'
local EquationOp = require 'symmath.EquationOp'
local greaterThanOrEquals = class(EquationOp)
greaterThanOrEquals.name = '>='
function greaterThanOrEquals:switch()
	local a,b = unpack(self)
	return b:lessThanOrEquals(a)
end
return greaterThanOrEquals
