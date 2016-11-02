local class = require 'ext.class'
local BinaryOp = require 'symmath.BinaryOp'
local modOp = class(BinaryOp)

modOp.precedence = 3
modOp.name = '%'

--[[
d/dx[a%b] is da/dx, except when a = b * k for some integer k
--]]
function modOp:evaluateDerivative(...)
	local a, b = table.unpack(self)
	a, b = a:clone(), b:clone()
	local diff = require 'symmath'.diff
	local x = diff(a, ...)
	return x
end

modOp.visitorHandler = {
	Eval = function(eval, expr)
		local a, b = table.unpack(expr)
		return eval:apply(a) % eval:apply(b)
	end,
}

return modOp
