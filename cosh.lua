local table = require 'ext.table'
local Function = require 'symmath.Function'
local symmath

local cosh = Function:subclass()
cosh.name = 'cosh'
cosh.realFunc = math.cosh
cosh.cplxFunc = require 'complex'.cosh

function cosh:evaluateDerivative(deriv, ...)
	local x = table.unpack(self):clone()
	symmath = symmath or require 'symmath'
	return deriv(x, ...) * symmath.sinh(x)
end

function cosh:reverse(soln, index)
	symmath = symmath or require 'symmath'
	return symmath.acosh(soln)
end

cosh.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_real
cosh.getRealRange = require 'symmath.set.RealSubset'.getRealRange_evenIncreasing

cosh.evaluateLimit = require 'symmath.Limit'.evaluateLimit_continuousFunction

cosh.rules = {
	Prune = {
		{apply = function(prune, expr)
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant
			local inf = symmath.inf

			local x = expr[1]

			if Constant.isValue(x, 0) then
				return Constant(1)
			end

			if x == inf then
				return inf
			end
			if x == Constant(-1) * inf then
				return inf
			end

--[[ TODO this should be on all Function's prune()'s
-- but this has domain real, so complement is empty
			if expr:getRealDomain():complement():open():contains(x) then
				return symmath.invalid
			end
--]]

		end},
	},
}

return cosh
