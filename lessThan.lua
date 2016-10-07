local class = require 'ext.class'
local EquationOp = require 'symmath.EquationOp'
local lessThan = class(EquationOp)
lessThan.name = '<'
function lessThan:switch()
	local a,b = table.unpack(self)
	return b:greaterThan(a)
end
return lessThan
