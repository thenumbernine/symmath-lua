require 'ext'
local Function = require 'symmath.Function'
local atan = class(Function)
atan.name = 'atan'
atan.func = math.atan
function atan:evaluateDerivative(...)
	local x = unpack(self):clone()
	local diff = require 'symmath'.diff
	return diff(x,...) / (1 + x^2)
end
return atan

