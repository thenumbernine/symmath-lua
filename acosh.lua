local class = require 'ext.class'
local Function = require 'symmath.Function'

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
	local sqrt = require 'symmath.sqrt'
	return deriv(x, ...) / sqrt(x^2 - 1)
end

-- (1,inf) increasing, (-inf,1) imaginary
function acosh:getRealDomain()
	local Is = x[1]:getRealDomain()
	if Is == nil then return nil end
	for _,I in ipairs(Is) do
		if I.start < 1 then return nil end
	end
	local RealDomain = require 'symmath.set.RealDomain'
	return RealDomain(table.mapi(Is, function(I)
		return RealDomain(
			x.realFunc(I.start),
			x.realFunc(I.finish),
			I.includeStart,
			I.includeFinish)
	end))
end

return acosh
