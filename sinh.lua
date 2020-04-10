local class = require 'ext.class'
local Function = require 'symmath.Function'

local sinh = class(Function)
sinh.name = 'sinh'
sinh.realFunc = math.sinh
sinh.cplxFunc = require 'symmath.complex'.sinh

function sinh:evaluateDerivative(deriv, ...)
	local x = table.unpack(self)
	local cosh = require 'symmath.cosh'
	return deriv(x, ...) * cosh(x)
end

function sinh:reverse(soln, index)
	return require 'symmath.asinh'(soln)
end

sinh.getRealDomain = require 'symmath.set.RealDomain'.getRealDomain_inc

return sinh
