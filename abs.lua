local table = require 'ext.table'
local Heaviside = require 'symmath.Heaviside'
local Function = require 'symmath.Function'
local symmath

local abs = Function:subclass()
abs.name = 'abs'
abs.realFunc = math.abs
abs.cplxFunc = require 'complex'.abs

function abs:evaluateDerivative(deriv, ...)
	local x = self[1]
	return (Heaviside(x) - Heaviside(-x)) * deriv(x, ...)
end

function abs:reverse(soln, index)
	-- y = |x| => x = y, x = -y
	return soln, -soln
end

abs.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_real
abs.getRealRange = require 'symmath.set.RealSubset'.getRealRange_evenIncreasing

abs.evaluateLimit = require 'symmath.Limit'.evaluateLimit_continuousFunction

abs.rules = {
	Prune = {
		{apply = function(prune, expr)
			symmath = symmath or require 'symmath'
			-- unm's are converted to -1 * 's
			local mul = symmath.op.mul
			local Constant = symmath.Constant

			local x = expr[1]	-- abs(x)

			if mul:isa(x)
			and Constant:isa(x[1])
			and x[1].value < 0
			then
				return prune:apply(
					mul(
						Constant(math.abs(x[1].value)),
						table.unpack(x, 2)
					)
				)
			end

			if Constant:isa(x)
			and x.value < 0
			then
				return prune:apply(Constant(math.abs(x.value)))
			end

			if symmath.set.nonNegativeReal:contains(x) then
				return x
			end

--[[ TODO this should be on all Function's prune()'s
-- but for this set the complement of real is empty
			if expr:getRealDomain():complement():open():contains(x) then
				return symmath.invalid
			end
--]]
		end},
	},
}

return abs
