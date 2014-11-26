require 'ext'
local Function = require 'symmath.Function'
local cos = class(Function)
cos.name = 'cos'
cos.func = math.cos
function cos:evaluateDerivative(...)
	local x = unpack(self):clone()
	local sin = require 'symmath.sin'
	local diff = require 'symmath'.diff
	return -diff(x,...) * sin(x)
end
return cos

