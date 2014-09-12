require 'ext'
local EquationOp = require 'symmath.EquationOp'
local lessThanOrEquals = class(EquationOp)
lessThanOrEquals.name = '<='
function lessThanOrEquals:switch()
	local a,b = unpack(self.xs)
	return b:greaterThanOrEquals(a)
end
return lessThanOrEquals
