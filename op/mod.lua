local class = require 'ext.class'
local table = require 'ext.table'
local Binary = require 'symmath.op.Binary'

local mod = class(Binary)
mod.precedence = 3
mod.name = '%'

--[[
d/dx[a%b] is da/dx, except when a = b * k for some integer k
--]]
function mod:evaluateDerivative(deriv, ...)
	local a, b = table.unpack(self)
	a, b = a:clone(), b:clone()
	return deriv(a, ...)
end

mod.rules = {
	Eval = {
		{apply = function(eval, expr)
			local a, b = table.unpack(expr)
			return eval:apply(a) % eval:apply(b)
		end},
	},
}

return mod
