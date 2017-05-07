local class = require 'ext.class'
local table = require 'ext.table'
local range = require 'ext.range'
local Function = require 'symmath.Function'

local cos = class(Function)

cos.name = 'cos'
--cos.func = math.cos
cos.func = require 'symmath.complex'.cos

function cos:evaluateDerivative(...)
	local x = table.unpack(self):clone()
	local sin = require 'symmath.sin'
	local diff = require 'symmath.Derivative'
	return -diff(x,...) * sin(x)
end

function cos:reverse(soln, index)
	return require 'symmath.acos'(soln)
end

cos.visitorHandler = {
	Prune = function(prune, expr)
		local Constant = require 'symmath.Constant'
		local mul = require 'symmath.op.mul'
		
		-- cos(0) => 1
		if expr[1] == Constant(0) then 
			return Constant(1) 
		end
	
		-- cos(-c x y z) => cos(c x y z)
		if mul.is(expr[1])
		and Constant.is(expr[1][1])
		and expr[1][1].value < 0
		then
			local mulArgs = range(#expr[1]):map(function(i)
				return expr[1][i]:clone()
			end)
			local c = -mulArgs:remove(1).value
			local theta = #mulArgs == 1 and mulArgs[1] or mul(mulArgs:unpack()) 
			return prune:apply(c == 1 and cos(theta) or sin(c * theta))
		end
	end,
}

return cos
