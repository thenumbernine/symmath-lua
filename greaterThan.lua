require 'ext'
local EquationOp = require 'symmath.EquationOp'
local greaterThan = class(EquationOp)
greaterThan.name = '>'
function greaterThan:switch()
	local a,b = table.unpack(self)
	return b:lessThan(a)
end
return greaterThan
