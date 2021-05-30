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

atanh.getRealRange = require 'symmath.set.RealSubset'.getRealDomain_pmOneInc

atanh.rules = {
	Prune = {
		{apply = function(prune, expr)
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant
			
			local x = expr[1]

			if Constant.isValue(x, 0) then return Constant(0) end

			if symmath.set.RealSubset(-math.huge, -1, false, true):contains(x) then
				return symmath.invalid
			end
			
			if symmath.set.RealSubset(1, math.huge, true, false):contains(x) then
				return symmath.invalid
			end
		end},
	},
}


return atanh
