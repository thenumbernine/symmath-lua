local class = require 'ext.class'
local Function = require 'symmath.Function'
local symmath

local cosh = class(Function)
cosh.name = 'cosh'
cosh.realFunc = math.cosh
cosh.cplxFunc = require 'symmath.complex'.cosh

function cosh:evaluateDerivative(deriv, ...)
	local x = table.unpack(self):clone()
	symmath = symmath or require 'symmath'
	return deriv(x, ...) * symmath.sinh(x)
end

function cosh:reverse(soln, index)
	symmath = symmath or require 'symmath'
	return symmath.acosh(soln)
end

cosh.getRealDomain = require 'symmath.set.RealDomain'.getRealDomain_evenIncreasing

return cosh
