local class = require 'ext.class'
local table = require 'ext.table'
local math = require 'ext.math'	-- cbrt
local Function = require 'symmath.Function'
local symmath

local cbrt = class(Function)
cbrt.name = 'cbrt'
cbrt.realFunc = math.cbrt
cbrt.cplxFunc = require 'symmath.complex'.cbrt

-- (u^(1/3))' =  u'/(3 u^(2/3))
function cbrt:evaluateDerivative(deriv, ...)
	local x = self[1]:clone()
	return deriv(x, ...) / (3 * cbrt(x)^2)
end

-- y = cbrt(x) => y^3 = x
function cbrt:reverse(soln, index)
	return soln^3
end

cbrt.getRealRange = require 'symmath.set.RealSubset'.getRealDomain_inc

cbrt.rules = table(cbrt.rules)

cbrt.rules.Prune = {
	{apply = function(prune, expr)
		symmath = symmath or require 'symmath'
		local div = symmath.op.div
		-- cbrt(a) = a^div(1,3)
		return prune:apply(expr[1]^div(1,3))
	end},
}

return cbrt
