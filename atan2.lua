local class = require 'ext.class'
local Function = require 'symmath.Function'
local atan2 = class(Function)
atan2.name = 'atan2'
atan2.func = math.atan2
function atan2:evaluateDerivative(...)
	local y, x = table.unpack(self)
	y, x = y:clone(), x:clone()
	local diff = require 'symmath.Derivative'
	return diff(y/x, ...) / (1 + (y/x)^2)
end
return atan2
