local class = require 'ext.class'
local Equation = require 'symmath.op.Equation'
local lt = class(Equation)
lt.name = '<'
function lt:switch()
	local a,b = table.unpack(self)
	return b:greaterThan(a)
end
return lt
