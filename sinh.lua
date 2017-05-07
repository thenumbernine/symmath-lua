local class = require 'ext.class'
local Function = require 'symmath.Function'

local sinh = class(Function)
sinh.name = 'sinh'
sinh.func = math.sinh

function sinh:evaluateDerivative(...)
	local x = table.unpack(self):clone()
	local cosh = require 'symmath.cosh'
	local diff = require 'symmath.Derivative'
	return diff(x,...) * cosh(x)
end

function sinh:reverse(soln, index)
	return require 'symmath.asinh'(soln)
end

return sinh
