local class = require 'ext.class'
local Function = require 'symmath.Function'

local acosh = class(Function)
acosh.name = 'acosh'

-- domain: [1, inf)
function acosh.realFunc(x)
	return math.log(x + math.sqrt(x*x - 1))
end

acosh.cplxFunc = require 'symmath.complex'.acosh

-- domain: x > 1
function acosh:evaluateDerivative(deriv, ...)
	local x = table.unpack(self)
	local sqrt = require 'symmath.sqrt'
	return deriv(x, ...) / sqrt(x^2 - 1)
end

return acosh
