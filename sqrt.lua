local class = require 'ext.class'
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
return sqrt

