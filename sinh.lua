local class = require 'ext.class'
local Function = require 'symmath.Function'
local symmath

local sinh = class(Function)
sinh.name = 'sinh'
sinh.realFunc = math.sinh
sinh.cplxFunc = require 'symmath.complex'.sinh

function sinh:evaluateDerivative(deriv, ...)
	local x = table.unpack(self)
	symmath = symmath or require 'symmath'
	return deriv(x, ...) * symmath.cosh(x)
end

function sinh:reverse(soln, index)
	symmath = symmath or require 'symmath'
	return symmath.asinh(soln)
end

sinh.getRealRange = require 'symmath.set.RealSubset'.getRealDomain_inc

sinh.evaluateLimit = require 'symmath.Limit'.evaluateLimit_continuousFunction

sinh.rules = {
	Prune = {
		{apply = function(prune, expr)
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant
			
			if expr[1] == symmath.inf then
				return symmath.inf
			end
			if expr[1] == Constant(-1) * symmath.inf then
				return Constant(-1) * symmath.inf
			end
		end},
	},
}

return sinh
