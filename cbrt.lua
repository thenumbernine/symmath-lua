local class = require 'ext.class'
local table = require 'ext.table'
local math = require 'ext.math'	-- cbrt
local Function = require 'symmath.Function'
local symmath

local cbrt = class(Function)

cbrt.name = 'cbrt'
cbrt.nameForExporterTable = {}
--cbrt.nameForExporterTable.Console = '∛' -- not supported by Windows Consolas
cbrt.nameForExporterTable.LaTeX = '\\sqrt[3]'

cbrt.realFunc = math.cbrt
cbrt.cplxFunc = require 'complex'.cbrt

-- (u^(1/3))' =  u'/(3 u^(2/3))
function cbrt:evaluateDerivative(deriv, ...)
	local x = self[1]:clone()
	return deriv(x, ...) / (3 * cbrt(x)^2)
end

-- y = cbrt(x) => y^3 = x
function cbrt:reverse(soln, index)
	return soln^3
end

cbrt.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_real
cbrt.getRealRange = require 'symmath.set.RealSubset'.getRealRange_inc
cbrt.evaluateLimit = require 'symmath.Limit'.evaluateLiit_continuousFunction

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
