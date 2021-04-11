local class = require 'ext.class'
local Equation = require 'symmath.op.Equation'

local le = class(Equation)

le.name = '<='

function le:switch()
	local a,b = table.unpack(self)
	return b:ge(a)
end

function le:isTrue()
	if self[1]:getRealDomain():last().finish <= self[2]:getRealDomain()[1].start then return true end
	if self[1]:getRealDomain()[1].start >= self[2]:getRealDomain():last().finish then return false end
end

return le
