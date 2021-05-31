local class = require 'ext.class'
local Function = require 'symmath.Function'
local symmath

local cosh = class(Function)
cosh.name = 'cosh'
cosh.realFunc = math.cosh
cosh.cplxFunc = require 'symmath.complex'.cosh

function cosh:evaluateDerivative(deriv, ...)
	local x = table.unpack(self):clone()
	symmath = symmath or require 'symmath'
	return deriv(x, ...) * symmath.sinh(x)
end

function cosh:reverse(soln, index)
	symmath = symmath or require 'symmath'
	return symmath.acosh(soln)
end

cosh.getRealRange = require 'symmath.set.RealSubset'.getRealDomain_evenIncreasing

cosh.evaluateLimit = require 'symmath.Limit'.evaluateLimit_continuousFunction

cosh.rules = {
	Prune = {
		{apply = function(prune, expr)
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant
			
			if expr[1] == symmath.inf then
				return symmath.inf
			end
			if expr[1] == Constant(-1) * symmath.inf then
				return symmath.inf
			end
		end},
	},
}

return cosh
