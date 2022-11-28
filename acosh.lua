local class = require 'ext.class'
local Function = require 'symmath.Function'
local symmath

local acosh = class(Function)
acosh.name = 'acosh'

-- domain: [1, inf]
function acosh.realFunc(x)
	return math.log(x + math.sqrt(x*x - 1))
end

acosh.cplxFunc = require 'complex'.acosh

-- domain: (1, inf]
function acosh:evaluateDerivative(deriv, ...)
	local x = table.unpack(self)
	symmath = symmath or require 'symmath'
	return deriv(x, ...) / symmath.sqrt(x^2 - 1)
end

-- [1,inf]
function acosh:getRealDomain()
	symmath = symmath or require 'symmath'
	return symmath.set.RealSubset(1, math.huge, true, true)
end

-- (0,inf] increasing, [-inf,0) imaginary
function acosh:getRealRange()
	if self.cachedSet then return self.cachedSet end
	local Is = x[1]:getRealRange()
	if Is == nil then 
		self.cachedSet = nil
		return nil 
	end
	for _,I in ipairs(Is) do
		if I.start < 1 then 
			self.cachedSet = nil
			return nil 
		end
	end
	
	symmath = symmath or require 'symmath'
	local RealSubset = symmath.set.RealSubset
	
	self.cachedSet = RealSubset(table.mapi(Is, function(I)
		return RealSubset(
			x.realFunc(I.start),
			x.realFunc(I.finish),
			I.includeStart,
			I.includeFinish)
	end))
	return self.cachedSet
end

function acosh:evaluateLimit(x, a, side)
	symmath = symmath or require 'symmath'
	local Constant = symmath.Constant
	local Limit = symmath.Limit

	local L = symmath.prune(Limit(self[1], x, a, side))
	if Constant.isValue(L, 1) then
		if side == Limit.Side.plus then
			return Constant(0)
		end
		return symmath.invalid
	end
	
	return Limit.evaluateLimit_ifInDomain(self, L)
end

acosh.rules = {
	Prune = {
		{apply = function(prune, expr)
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant
			
			local x = expr[1]

			if Constant.isValue(x, 1) then
				return Constant(0)
			end

			if x == symmath.inf then
				return symmath.inf
			end
			
			-- TODO this should be on all Function's prune()'s
			if expr:getRealDomain():complement():open():contains(x) then
				return symmath.invalid
			end
		end},
	},
}

return acosh
