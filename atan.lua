local class = require 'ext.class'
local Function = require 'symmath.Function'
local atan = class(Function)
atan.name = 'atan'
--atan.func = math.atan
atan.func = require 'symmath.complex'.atan
function atan:evaluateDerivative(...)
	local x = table.unpack(self):clone()
	local diff = require 'symmath.Derivative'
	return diff(x,...) / (1 + x^2)
end
return atan
