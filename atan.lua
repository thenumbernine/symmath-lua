local class = require 'ext.class'
local Function = require 'symmath.Function'
local symmath

local atan = class(Function)
atan.name = 'atan'
atan.realFunc = math.atan
atan.cplxFunc = require 'symmath.complex'.atan

function atan:evaluateDerivative(deriv, ...)
	local x = table.unpack(self):clone()
	return deriv(x, ...) / (1 + x^2)
end

function atan:reverse(soln, index)
	symmath = symmath or require 'symmath'
	return symmath.tan(soln)
end

-- technically this is a Riemann surface, and the codomain repeats every pi
atan.getRealRange = require 'symmath.set.RealSubset'.getRealDomain_inc

return atan
