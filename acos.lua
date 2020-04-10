local class = require 'ext.class'
local Function = require 'symmath.Function'

local acos = class(Function)
acos.name = 'acos'
acos.realFunc = math.acos
acos.cplxFunc = require 'symmath.complex'.acos

function acos:evaluateDerivative(deriv, ...)
	local x = table.unpack(self):clone()
	local sqrt = require 'symmath.sqrt'
	return -deriv(x, ...) / sqrt(1 - x^2)
end

function acos:reverse(soln, index)
	-- TODO domains
	return require 'symmath.cos'(soln)
end

-- (-1,1) => (-inf,inf) decreasing, (-inf,-1) and (1,inf) imaginary
function acos:getRealDomain()
	local I = x[1]:getRealDomain()
	if I == nil then return nil end
	-- not real
	if I.start < -1 or 1 < I.finish then return nil end
	return RealInterval(
		math.acos(I.finish),
		math.acos(I.start),
		I.includeFinish,
		I.includeStart
	)
end

return acos
