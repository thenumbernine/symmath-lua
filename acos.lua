require 'ext'
local Function = require 'symmath.Function'
local diff = require 'symmath.diff'
local acos = class(Function)
acos.name = 'acos'
acos.func = math.acos
function acos:diff(...)
	local x = unpack(self.xs)
	local sqrt = require 'symmath.sqrt'
	return -diff(x,...) / sqrt(1 - x^2)
end
return acos

