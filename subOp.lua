require 'ext'
local BinaryOp = require 'symmath.BinaryOp'

local subOp = class(BinaryOp)
subOp.precedence = 2
subOp.name = '-'

function subOp:evaluateDerivative(...)
	local a, b = unpack(self)
	a, b = a:clone(), b:clone()
	local diff = require 'symmath'.diff
	local x = diff(a,...) - diff(b,...)
	return x
end

return subOp

