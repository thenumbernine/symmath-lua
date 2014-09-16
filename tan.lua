require 'ext'
local Function = require 'symmath.Function'
local tan = class(Function)
tan.name = 'tan'
tan.func = math.tan
function tan:diff(...)
	local x = unpack(self.xs)
	local cos = require 'symmath.cos'
	local diff = require 'symmath'.diff
	return diff(x,...) / cos(x)^2
end


