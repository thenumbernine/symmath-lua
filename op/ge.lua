local class = require 'ext.class'
local Equation = require 'symmath.op.Equation'
local ge = class(Equation)
ge.name = '>='
function ge:switch()
	local a,b = table.unpack(self)
	return b:lessThanOrEquals(a)
end
return ge
