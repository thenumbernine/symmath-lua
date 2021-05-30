local class = require 'ext.class'
local Function = require 'symmath.Function'
local symmath

local acosh = class(Function)
acosh.name = 'acosh'

-- domain: [1, inf)
function acosh.realFunc(x)
	return math.log(x + math.sqrt(x*x - 1))
end

acosh.cplxFunc = require 'symmath.complex'.acosh

-- domain: x > 1
function acosh:evaluateDerivative(deriv, ...)
	local x = table.unpack(self)
	symmath = symmath or require 'symmath'
	return deriv(x, ...) / symmath.sqrt(x^2 - 1)
end

-- (1,inf) increasing, (-inf,1) imaginary
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
		end},
	},
}

return acosh
