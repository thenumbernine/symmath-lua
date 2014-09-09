require 'ext'
local Function = require 'symmath.Function'
local diff = require 'symmath.diff'
local atan2 = class(Function)
atan2.name = 'atan2'
atan2.func = math.atan2
function atan2:diff(...)
	local y, x = unpack(self.xs)
	return diff(y/x, ...) / (1 + (y/x)^2)
end
return atan2

