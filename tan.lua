require 'ext'
local Function = require 'symmath.function'
local diff = require 'symmath.diff'
local tan = class(Function)
tan.name = 'tan'
tan.func = math.tan
function tan:diff(...)
	local x = unpack(self.xs)
	local cos = require 'symmath.cos'
	return diff(x,...) / cos(x)^2
end


