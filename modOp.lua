require 'ext'

local BinaryOp = require 'symmath.BinaryOp'

local modOp = class(BinaryOp)
modOp.precedence = 3
modOp.name = '%'

--[[
d/dx[a%b] is da/dx, except when a = b * k for some integer k
--]]
function modOp:evaluateDerivative(...)
	local a, b = unpack(self)
	a, b = a:clone(), b:clone()
	local diff = require 'symmath'.diff
	local x = diff(a, ...)
	return x
end

return modOp

