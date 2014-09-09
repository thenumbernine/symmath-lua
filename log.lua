require 'ext'
local Function = require 'symmath.function'
local diff = require 'symmath.diff'
local log = class(Function)
log.name = 'log'
log.func = math.log
function log:diff(...)
	local x = unpack(self.xs)
	return diff(x,...) / x
end
return log

