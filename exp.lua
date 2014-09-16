require 'ext'
local Function = require 'symmath.Function'
local exp = class(Function)
exp.name = 'exp'
exp.func = math.exp
function exp:diff(...)
	local x = unpack(self.xs)
	local diff = require 'symmath'.diff
	return diff(x,...) * x
end
return exp

