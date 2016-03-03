local class = require 'ext.class'
local table = require 'ext.table'
local Function = require 'symmath.Function'

local sqrt = class(Function)
sqrt.name = 'sqrt'
sqrt.func = math.sqrt

function sqrt:evaluateDerivative(...)
	local Constant = require 'symmath.Constant'
	local diff = require 'symmath'.diff
	local x = self[1]:clone()
	return diff(x, ...) / (Constant(2) * sqrt(x))
end

sqrt.visitorHandler = table(sqrt.visitorHandler)

sqrt.visitorHandler.Prune = function(prune, expr)
	local divOp = require 'symmath.divOp'
	return prune:apply(expr[1]^divOp(1,2))
end

return sqrt
