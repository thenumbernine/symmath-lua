local class = require 'ext.class'
local table = require 'ext.table'
local Function = require 'symmath.Function'
local symmath
local RealDomain 

local acos = class(Function)
acos.name = 'acos'
acos.realFunc = math.acos
acos.cplxFunc = require 'symmath.complex'.acos

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

-- technically a Riemann surface with a repeating codomain
-- (-1,1) => (-inf,inf) decreasing, (-inf,-1) and (1,inf) imaginary
function acos:getRealDomain()
	if self.cachedSet then return self.cachedSet end
	local Is = self[1]:getRealDomain()
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
	RealDomain = RealDomain or require 'symmath.set.RealDomain'	
	self.cachedSet = RealDomain(table.mapi(Is, function(I)
		return RealDomain(
			math.acos(I.finish),
			math.acos(I.start),
			I.includeFinish,
			I.includeStart)
	end))
	return self.cachedSet
end

return acos
