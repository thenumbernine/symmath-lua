local class = require 'ext.class'
local Function = require 'symmath.Function'

local atanh = class(Function)
atanh.name = 'atanh'

-- domain: (-1, 1)
function atanh.func(x)
	return .5 * math.log((1 + x) / (1 - x))
end

-- domain: (-1, 1)
function atanh:evaluateDerivative(deriv, ...)
	local x = table.unpack(x)
	return deriv(x, ...) / (1 - x^2)
end

atanh.getRealRange = require 'symmath.set.RealSubset'.getRealDomain_pmOneInc

return atanh
