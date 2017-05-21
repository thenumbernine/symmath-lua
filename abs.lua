local class = require 'ext.class'
local table = require 'ext.table'
local Function = require 'symmath.Function'

local abs = class(Function)
abs.name = 'abs'
--abs.func = math.abs
abs.func = require 'symmath.complex'.abs

function abs:evaluateDerivative(deriv, ...)
	local x = self[1]
	return (Heaviside(x) - Heaviside(-x)) * deriv(x, ...)
end

function abs:reverse(soln, index)
	-- y = |x| => x = y, x = -y
	return soln, -soln
end

abs.visitorHandler = {
	Prune = function(prune, expr)
		-- unm's are converted to -1 * 's
		local mul = require 'symmath.op.mul'
		local Constant = require 'symmath.Constant'
		if mul.is(expr[1]) 
		and Constant.is(expr[1][1])
		and expr[1][1].value < 0
		then
			return prune:apply(
				mul(
					Constant(math.abs(expr[1][1].value)),
					table.unpack(expr[1], 2)
				)
			)
		end
	
		if Constant.is(expr[1])
		and expr[1].value < 0
		then
			return prune:apply(Constant(math.abs(expr[1].value)))
		end
	end,
}

return abs
