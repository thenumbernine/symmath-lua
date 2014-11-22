require 'ext'
local Function = require 'symmath.Function'
local log = class(Function)
log.name = 'log'
log.func = math.log
function log:evaluateDerivative(...)
	local x = unpack(self.xs):clone()
	local diff = require 'symmath'.diff
	return diff(x,...) / x
end
return log

