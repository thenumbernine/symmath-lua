require 'ext'
local Function = require 'symmath.function'
local diff = require 'symmath.diff'
local cos = class(Function)
cos.name = 'cos'
cos.func = math.cos
function cos:diff(...)
	local x = unpack(self.xs)
	local sin = require 'symmath.sin'
	return -diff(x,...) * sin(x)
end
return cos

