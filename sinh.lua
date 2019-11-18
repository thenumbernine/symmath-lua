local class = require 'ext.class'
local Function = require 'symmath.Function'

local sinh = class(Function)
sinh.name = 'sinh'
sinh.func = math.sinh

function sinh:evaluateDerivative(deriv, ...)
	local x = table.unpack(self)
	local cosh = require 'symmath.cosh'
	return deriv(x, ...) * cosh(x)
end

function sinh:reverse(soln, index)
	return require 'symmath.asinh'(soln)
end

return sinh
