local class = require 'ext.class'
local Function = require 'symmath.Function'
local tan = class(Function)
tan.name = 'tan'
--tan.func = math.tan
tan.func = require 'symmath.complex'.tan
function tan:evaluateDerivative(...)
	local x = table.unpack(self):clone()
	local cos = require 'symmath.cos'
	local diff = require 'symmath'.diff
	return diff(x,...) / cos(x)^2
end
return tan
