local class = require 'ext.class'
local Equation = require 'symmath.op.Equation'
local gt = class(Equation)
gt.name = '>'
function gt:switch()
	local a,b = table.unpack(self)
	return b:lessThan(a)
end
return gt
