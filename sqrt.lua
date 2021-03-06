local class = require 'ext.class'
local table = require 'ext.table'
local Function = require 'symmath.Function'
local symmath

local sqrt = class(Function)
sqrt.name = 'sqrt'
sqrt.realFunc = math.sqrt
sqrt.cplxFunc = require 'symmath.complex'.sqrt

function sqrt:evaluateDerivative(deriv, ...)
	local x = self[1]:clone()
	return deriv(x, ...) / (2 * sqrt(x))
end

-- y = sqrt(x) => y^2 = x
function sqrt:reverse(soln, index)
	return soln^2
end

sqrt.getRealDomain = require 'symmath.set.RealDomain'.getRealDomain_posInc_negIm

sqrt.rules = table(sqrt.rules)

sqrt.rules.Prune = {
	{apply = function(prune, expr)
		symmath = symmath or require 'symmath'
		local div = symmath.op.div
		-- sqrt(a) = a^div(1,2)
		return prune:apply(expr[1]^div(1,2))
	end},
}

return sqrt
