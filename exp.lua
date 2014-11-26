require 'ext'
local Function = require 'symmath.Function'
local exp = class(Function)
exp.name = 'exp'
exp.func = math.exp
function exp:evaluateDerivative(...)
	local x = unpack(self):clone()
	local diff = require 'symmath'.diff
	return diff(x,...) * self:clone()
end
return exp

