require 'ext'
local Constant = require 'symmath.Constant'
local BinaryOp = require 'symmath.BinaryOp'

local divOp = class(BinaryOp)
divOp.precedence = 3
divOp.name = '/'

function divOp:evaluateDerivative(...)
	local a, b = unpack(self)
	a, b = a:clone(), b:clone()
	local diff = require 'symmath'.diff
	local x = (diff(a, ...) * b - a * diff(b, ...)) / (b * b)
	return x
end

function divOp:eval()
	local a, b = unpack(self)
	return a:eval() / b:eval()
end

return divOp

