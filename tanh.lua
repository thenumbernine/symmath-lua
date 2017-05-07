local class = require 'ext.class'
local Function = require 'symmath.Function'

local tanh = class(Function)
tanh.name = 'tanh'
tanh.func = math.tanh

function tanh:evaluateDerivative(...)
	local x = table.unpack(self)
	local cosh = require 'symmath.cosh'
	local diff = require 'symmath.Derivative'
	return diff(x,...) / cosh(x)^2
end

function tanh:reverse(soln, index)
	return require 'symmath.atanh'(soln)
end

return tanh
