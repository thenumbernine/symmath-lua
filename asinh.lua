local class = require 'ext.class'
local Function = require 'symmath.Function'

local asinh = class(Function)
asinh.name = 'asinh'

-- domain: reals
function asinh.func(x)
	return math.log(x + math.sqrt(x*x + 1))
end

-- domain: reals
function asinh:evaluateDerivative(deriv, ...)
	local x = table.unpack(self)
	local sqrt = require 'symmath.sqrt'
	return deriv(x, ...) / sqrt(x^2 + 1)
end

function asinh:reverse(soln, index)
	return require 'symmath.sinh'(soln)
end

return asinh
