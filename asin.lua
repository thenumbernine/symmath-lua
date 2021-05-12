local class = require 'ext.class'
local Function = require 'symmath.Function'
local symmath

local asin = class(Function)
asin.name = 'asin'
asin.realFunc = math.asin
asin.cplxFunc = require 'symmath.complex'.asin

function asin:evaluateDerivative(deriv, ...)
	local x = table.unpack(self):clone()
	symmath = symmath or require 'symmath'
	return deriv(x, ...) / symmath.sqrt(1 - x^2)
end

function asin:reverse(soln, index)
	symmath = symmath or require 'symmath'
	return symmath.sin(soln)
end

asin.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_pmOneInc

return asin
