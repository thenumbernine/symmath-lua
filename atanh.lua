local class = require 'ext.class'
local Function = require 'symmath.Function'

local atanh = class(Function)
atanh.name = 'atanh'

-- domain: (-1, 1)
function atanh.func(x)
	return .5 * math.log((1 + x) / (1 - x))
end

-- domain: (-1, 1)
function atanh:evaluateDerivative(deriv, ...)
	local x = table.unpack(x)
	return deriv(x, ...) / (1 - x^2)
end


atanh.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_plusMinusOneOpen
atanh.getRealRange = require 'symmath.set.RealSubset'.getRealRange_pmOneInc

atanh.evaluateLimit = require 'symmath.Limit'.evaluateLimit_plusMinusOne_to_plusMinusInf

atanh.rules = {
	Prune = {
		{apply = function(prune, expr)
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant

			local x = expr[1]

			if Constant.isValue(x, 0) then return Constant(0) end

-- [[ TODO this should be on all Function's prune()'s
			if expr:getRealDomain():complement():open():contains(x) then
				return symmath.invalid
			end
--]]
		end},
	},
}


return atanh
