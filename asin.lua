local Function = require 'symmath.Function'
local symmath

local asin = Function:subclass()
asin.name = 'asin'
asin.realFunc = math.asin
asin.cplxFunc = require 'complex'.asin

function asin:evaluateDerivative(deriv, ...)
	local x = table.unpack(self):clone()
	symmath = symmath or require 'symmath'
	return deriv(x, ...) / symmath.sqrt(1 - x^2)
end

function asin:reverse(soln, index)
	symmath = symmath or require 'symmath'
	return symmath.sin(soln)
end

asin.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_plusMinusOneClosed
asin.getRealRange = require 'symmath.set.RealSubset'.getRealRange_pmOneInc

asin.evaluateLimit = require 'symmath.Limit'.evaluateLimit_plusMinusOne_to_plusMinusInf

asin.rules = {
	Prune = {
		{apply = function(prune, expr)
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant

			local x = expr[1]

			if Constant.isValue(x, 0) then
				return Constant(0)
			end

-- [[ TODO this should be on all Function's prune()'s
			if expr:getRealDomain():complement():open():contains(x) then
				return symmath.invalid
			end
--]]
		end},
	},
}

return asin
