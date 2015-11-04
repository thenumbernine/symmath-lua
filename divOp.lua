local class = require 'ext.class'
local BinaryOp = require 'symmath.BinaryOp'

local divOp = class(BinaryOp)
divOp.precedence = 3.5
divOp.name = '/'

function divOp:evaluateDerivative(...)
	local a, b = self[1], self[2]
	a, b = a:clone(), b:clone()
	local diff = require 'symmath'.diff
	return (diff(a, ...) * b - a * diff(b, ...)) / (b * b)
end

return divOp
