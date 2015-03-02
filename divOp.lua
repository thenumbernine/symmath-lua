require 'ext'
local Constant = require 'symmath.Constant'
local BinaryOp = require 'symmath.BinaryOp'

local divOp = class(BinaryOp)
divOp.precedence = 3.5
divOp.name = '/'

function divOp:evaluateDerivative(...)
	local a, b = unpack(self)
	a, b = a:clone(), b:clone()
	local diff = require 'symmath'.diff
	local x = (diff(a, ...) * b - a * diff(b, ...)) / (b * b)
	return x
end

return divOp

