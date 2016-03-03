local class = require 'ext.class'
local table = require 'ext.table'
local Function = require 'symmath.Function'
local sin = class(Function)
sin.name = 'sin'
sin.func = math.sin
function sin:evaluateDerivative(...)
	local x = table.unpack(self):clone()
	local cos = require 'symmath.cos'
	local diff = require 'symmath'.diff
	return diff(x,...) * cos(x)
end
return sin
