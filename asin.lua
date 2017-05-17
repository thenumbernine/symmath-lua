local class = require 'ext.class'
local Function = require 'symmath.Function'

local asin = class(Function)
asin.name = 'asin'
--asin.func = math.asin
asin.func = require 'symmath.complex'.asin

function asin:evaluateDerivative(deriv, ...)
	local x = table.unpack(self):clone()
	local sqrt = require 'symmath.sqrt'
	return deriv(x, ...) / sqrt(1 - x^2)
end

function asin:reverse(soln, index)
	return require 'symmath.sin'(soln)
end

return asin
