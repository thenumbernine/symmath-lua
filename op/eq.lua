local class = require 'ext.class'
local Equation = require 'symmath.op.Equation'

local eq = class(Equation)

eq.name = '='

function eq:isTrue()
	return self[1] == self[2]
end

return eq
