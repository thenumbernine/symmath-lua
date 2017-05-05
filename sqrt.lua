local class = require 'ext.class'
local table = require 'ext.table'
local Function = require 'symmath.Function'

local sqrt = class(Function)
sqrt.name = 'sqrt'
--sqrt.func = math.sqrt
sqrt.func = require 'symmath.complex'.sqrt

function sqrt:evaluateDerivative(...)
	local Constant = require 'symmath.Constant'
	local diff = require 'symmath.Derivative'
	local x = self[1]:clone()
	return diff(x, ...) / (Constant(2) * sqrt(x))
end

sqrt.visitorHandler = table(sqrt.visitorHandler)

sqrt.visitorHandler.Prune = function(prune, expr)
	local div = require 'symmath.op.div'
	return prune:apply(expr[1]^div(1,2))
end

return sqrt
