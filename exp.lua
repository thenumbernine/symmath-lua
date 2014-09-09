require 'ext'
local Function = require 'symmath.function'
local diff = require 'symmath.diff'
local exp = class(Function)
exp.name = 'exp'
exp.func = math.exp
function exp:diff(...)
	local x = unpack(self.xs)
	return diff(x,...) * x
end
return exp

