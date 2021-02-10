local class = require 'ext.class'
local Function = require 'symmath.Function'
local symmath

local asinh = class(Function)
asinh.name = 'asinh'

-- domain: reals
function asinh.realFunc(x)
	return math.log(x + math.sqrt(x*x + 1))
end

asinh.cplxFunc = require 'symmath.complex'.asinh

-- domain: reals
function asinh:evaluateDerivative(deriv, ...)
	local x = table.unpack(self)
	symmath = symmath or require 'symmath'
	return deriv(x, ...) / symmath.sqrt(x^2 + 1)
end

function asinh:reverse(soln, index)
	symmath = symmath or require 'symmath'
	return symmath.sinh(soln)
end

asinh.getRealDomain = require 'symmath.set.RealDomain'.getRealDomain_inc

return asinh
