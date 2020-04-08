local class = require 'ext.class'
local Function = require 'symmath.Function'

local cosh = class(Function)
cosh.name = 'cosh'
cosh.realFunc = math.cosh
cosh.cplxFunc = require 'symmath.complex'.cosh

function cosh:evaluateDerivative(deriv, ...)
	local x = table.unpack(self):clone()
	local sinh = require 'symmath.sinh'
	return deriv(x, ...) * sinh(x)
end

function cosh:reverse(soln, index)
	return require 'symmath.acosh'(soln)
end

return cosh
