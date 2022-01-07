local class = require 'ext.class'
local Function = require 'symmath.Function'
local symmath

local asinh = class(Function)
asinh.name = 'asinh'

-- domain: reals
function asinh.realFunc(x)
	return math.log(x + math.sqrt(x*x + 1))
end

asinh.cplxFunc = require 'symmath.complex'.asinh

-- domain: reals
function asinh:evaluateDerivative(deriv, ...)
	local x = table.unpack(self)
	symmath = symmath or require 'symmath'
	return deriv(x, ...) / symmath.sqrt(x^2 + 1)
end

function asinh:reverse(soln, index)
	symmath = symmath or require 'symmath'
	return symmath.sinh(soln)
end

-- TODO FIXME
-- this, combined with op/mul.lua:855 "inf * anything = inf" rule, is causing crashes
--asinh.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_real
--asinh.getRealRange = require 'symmath.set.RealSubset'.getRealRange_inc

asinh.evaluateLimit = require 'symmath.Limit'.evaluateLimit_continuousFunction

asinh.rules = {
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
		
--[[ TODO this should be on all Function's prune()'s
-- but in this case it is empty anyways
			if expr:getRealDomain():complement():open():contains(x) then
				return symmath.invalid
			end
--]]
		end},
	},
}

return asinh
