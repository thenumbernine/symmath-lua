local class = require 'ext.class'
local Function = require 'symmath.Function'
local symmath

local sinh = class(Function)
sinh.name = 'sinh'
sinh.realFunc = math.sinh
sinh.cplxFunc = require 'symmath.complex'.sinh

function sinh:evaluateDerivative(deriv, ...)
	local x = table.unpack(self)
	symmath = symmath or require 'symmath'
	return deriv(x, ...) * symmath.cosh(x)
end

function sinh:reverse(soln, index)
	symmath = symmath or require 'symmath'
	return symmath.asinh(soln)
end

sinh.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_inc

return sinh
