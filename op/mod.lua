local class = require 'ext.class'
local table = require 'ext.table'
local Binary = require 'symmath.op.Binary'

local mod = class(Binary)
mod.precedence = 3
mod.name = '%'

--[[
d/dx[a%b] is da/dx, except when a = b * k for some integer k
--]]
function mod:evaluateDerivative(...)
	local a, b = table.unpack(self)
	a, b = a:clone(), b:clone()
	local diff = require 'symmath.Derivative'
	local x = diff(a, ...)
	return x
end

mod.visitorHandler = {
	Eval = function(eval, expr)
		local a, b = table.unpack(expr)
		return eval:apply(a) % eval:apply(b)
	end,
}

return mod
