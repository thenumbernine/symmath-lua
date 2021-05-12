local table = require 'ext.table'
local class = require 'ext.class'
local Function = require 'symmath.Function'
local symmath

local tanh = class(Function)
tanh.name = 'tanh'
tanh.realFunc = math.tanh
tanh.cplxFunc = require 'symmath.complex'.tanh

function tanh:evaluateDerivative(deriv, ...)
	symmath = symmath or require 'symmath'
	local x = table.unpack(self)
	local cosh = symmath.cosh
	return deriv(x, ...) / cosh(x)^2
end

function tanh:reverse(soln, index)
	symmath = symmath or require 'symmath'
	return symmath.atanh(soln)
end

tanh.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_inc

return tanh
