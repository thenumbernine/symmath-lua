require 'ext'
local EquationOp = require 'symmath.EquationOp'
local lessThanOrEquals = class(EquationOp)
lessThanOrEquals.name = '<='
function lessThanOrEquals:switch()
	local a,b = table.unpack(self)
	return b:greaterThanOrEquals(a)
end
return lessThanOrEquals
