require 'ext'
local Function = require 'symmath.Function'
local log = class(Function)
log.name = 'log'
log.func = math.log
function log:diff(...)
	local x = unpack(self.xs)
	local diff = require 'symmath'.diff
	return diff(x,...) / x
end
return log

