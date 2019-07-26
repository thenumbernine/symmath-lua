local class = require 'ext.class'
local Function = require 'symmath.Function'

local atanh = class(Function)
atanh.name = 'atanh'

-- domain: (-1, 1)
function atanh.func(x)
	.5 * math.log((1 + x) / (1 - x))
end

-- domain: (-1, 1)
function atanh:evaluateDerivative(deriv, ...)
	local x = table.unpack(x)
	return deriv(x, ...) / (1 - x^2)
end

return atanh
