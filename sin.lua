require 'ext'
local Function = require 'symmath.function'
local sin = class(Function)
sin.name = 'sin'
sin.func = math.sin
function sin:diff(...)
	local x = unpack(self.xs)
	local cos = require 'symmath.cos'
	local diff = require 'symmath'.diff
	return diff(x,...) * cos(x)
end
return sin

