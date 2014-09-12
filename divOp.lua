require 'ext'
local Constant = require 'symmath.Constant'
local BinaryOp = require 'symmath.BinaryOp'

local divOp = class(BinaryOp)
divOp.precedence = 3
divOp.name = '/'

function divOp:diff(...)
	local a, b = unpack(self.xs)
	local diff = require 'symmath'.diff
	local x = (diff(a, ...) * b - a * diff(b, ...)) / (b * b)
--	x = prune(x)
	return x
end

function divOp:eval()
	local a, b = unpack(self.xs)
	return a:eval() / b:eval()
end

return divOp

