local class = require 'ext.class'
local Equation = require 'symmath.op.Equation'

local gt = class(Equation)

gt.name = '>'

function gt:switch()
	local a,b = table.unpack(self)
	return b:lt(a)
end

function gt:isTrue()
	if self[1]:getRealDomain()[1].start > self[2]:getRealDomain():last().finish then return true end
	if self[1]:getRealDomain():last().finish < self[2]:getRealDomain()[1].start then return false end
end

return gt
