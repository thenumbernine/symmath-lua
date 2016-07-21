local class = require 'ext.class'
local table = require 'ext.table'
local Function = require 'symmath.Function'
local log = class(Function)
log.name = 'log'
log.func = math.log
function log:evaluateDerivative(...)
	local x = table.unpack(self):clone()
	local diff = require 'symmath'.diff
	return diff(x,...) / x
end
return log
