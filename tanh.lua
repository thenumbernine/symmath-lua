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

tanh.getRealRange = require 'symmath.set.RealSubset'.getRealDomain_inc

tanh.evaluateLimit = require 'symmath.Limit'.evaluateLimit_continuousFunction

tanh.rules = {
	Prune = {
		{apply = function(prune, expr)
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant

			local x = expr[1]

			if Constant.isValue(x, 0) then
				return Constant(0)
			end
			
			if x == symmath.inf then
				return Constant(1)
			end
			
			if x == Constant(-1) * symmath.inf then
				return Constant(-1)
			end
		end},
	},
}

return tanh
