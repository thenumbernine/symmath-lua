local class = require 'ext.class'
local table = require 'ext.table'
local range = require 'ext.range'
local Function = require 'symmath.Function'

local sin = class(Function)
sin.name = 'sin'
--sin.func = math.sin
sin.func = require 'symmath.complex'.sin

function sin:evaluateDerivative(...)
	local x = table.unpack(self):clone()
	local cos = require 'symmath.cos'
	local diff = require 'symmath'.diff
	return diff(x,...) * cos(x)
end

sin.visitorHandler = {
	Prune = function(prune, expr)
		local Constant = require 'symmath.Constant'
		local mulOp = require 'symmath.mulOp'
		
		-- sin(0) => 0
		if expr[1] == Constant(0) then
			return Constant(0)
		end
	
		-- sin(-c x y z) => -sin(c x y z)
		if mulOp.is(expr[1])
		and Constant.is(expr[1][1])
		and expr[1][1].value < 0
		then
			local mulArgs = range(#expr[1]):map(function(i)
				return expr[1][i]:clone()
			end)
			local c = -mulArgs:remove(1).value
			local theta = #mulArgs == 1 and mulArgs[1] or mulOp(mulArgs:unpack()) 
			return prune:apply(c == 1 and -sin(theta) or -sin(c * theta))
		end
	end,
}

return sin
