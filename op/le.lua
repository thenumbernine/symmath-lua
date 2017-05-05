local class = require 'ext.class'
local Equation = require 'symmath.op.Equation'
local le = class(Equation)
le.name = '<='
function le:switch()
	local a,b = table.unpack(self)
	return b:greaterThanOrEquals(a)
end
return le
