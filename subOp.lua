require 'ext'
local BinaryOp = require 'symmath.BinaryOp'

local subOp = class(BinaryOp)
subOp.precedence = 2
subOp.name = '-'

function subOp:diff(...)
	local a, b = unpack(self.xs)
	local diff = require 'symmath'.diff
	local x = diff(a,...) - diff(b,...)
--	x = prune(x)
	return x
end

function subOp:eval()
	local result = self.xs[1]:eval()
	for i=2,#self.xs do
		result = result - self.xs[i]:eval()
	end
	return result
end

return subOp

