local class = require 'ext.class'
local Function = require 'symmath.Function'

local atan = class(Function)
atan.name = 'atan'
atan.realFunc = math.atan
atan.cplxFunc = require 'symmath.complex'.atan

function atan:evaluateDerivative(deriv, ...)
	local x = table.unpack(self):clone()
	return deriv(x, ...) / (1 + x^2)
end

function atan:reverse(soln, index)
	return require 'symmath.tan'(soln)
end

return atan
