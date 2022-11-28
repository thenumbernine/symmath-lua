local class = require 'ext.class'
local table = require 'ext.table'
local Function = require 'symmath.Function'
local symmath

local acos = class(Function)
acos.name = 'acos'
acos.realFunc = math.acos
acos.cplxFunc = require 'complex'.acos

function acos:evaluateDerivative(deriv, ...)
	local x = table.unpack(self):clone()
	symmath = symmath or require 'symmath'
	return -deriv(x, ...) / symmath.sqrt(1 - x^2)
end

function acos:reverse(soln, index)
	-- TODO incorporate domains
	symmath = symmath or require 'symmath'
	return symmath.cos(soln)
end

acos.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_plusMinusOneClosed

-- technically a Riemann surface with a repeating codomain
-- (-1,1) => (-inf,inf) decreasing, (-inf,-1) and (1,inf) imaginary
function acos:getRealRange()
	if self.cachedSet then return self.cachedSet end
	local Is = self[1]:getRealRange()
	if Is == nil then 
		self.cachedSet = nil
		return nil 
	end
	-- not real
	for _,I in ipairs(Is) do
		if I.start < -1 or 1 < I.finish then 
			self.cachedSet = nil
			return nil 
		end
	end
	
	symmath = symmath or require 'symmath'
	local RealSubset = symmath.set.RealSubset
	
	self.cachedSet = RealSubset(table.mapi(Is, function(I)
		return RealSubset(
			math.acos(I.finish),
			math.acos(I.start),
			I.includeFinish,
			I.includeStart)
	end))
	return self.cachedSet
end

acos.evaluateLimit = require 'symmath.Limit'.evaluateLimit_plusMinusOne_to_minusPlusInf

acos.rules = {
	Prune = {
		{apply = function(prune, expr)
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant

			local x = expr[1]

			if Constant.isValue(x, 0) then
				return symmath.pi / 2
			end
			
			if symmath.set.RealSubset(-math.huge, -1, false, true):contains(x) then
				return symmath.invalid
			end
			
			-- TODO this should be on all Function's prune()'s
			if expr:getRealDomain():complement():open():contains(x) then
				return symmath.invalid
			end
		end},
	},
}

return acos
