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
	local I = x[1]:getRealDomain()
	if I == nil then return nil end
	if I.start < 1 then return nil end
	return require 'symmath.set.RealInterval'(
		x.realFunc(I.start),
		x.realFunc(I.finish),
		I.includeStart,
		I.includeFinish
	)
end

return acosh
