local class = require 'ext.class'
local Equation = require 'symmath.op.Equation'

local lt = class(Equation)

lt.name = '<'

function lt:switch()
	local a,b = table.unpack(self)
	return b:gt(a)
end

function lt:isTrue()
	if self[1]:getRealDomain():last().finish < self[2]:getRealDomain()[1].start then return true end
	if self[1]:getRealDomain()[1].start > self[2]:getRealDomain():last().finish then return false end
end

return lt
