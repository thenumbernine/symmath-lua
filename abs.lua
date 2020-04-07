local class = require 'ext.class'
local table = require 'ext.table'
local Heaviside = require 'symmath.Heaviside'
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

-- returns true if the domain of x is a subset of [0, inf)
local function isNonNegative(x)
	local symmath = require 'symmath'
	
	if Constant.is(x) then
		return x.value >= 0
	end

	--[[
	if symmath.op.unm.is(x)
	and isNonPositive(x[1])
	then
		return true
	end
	--]]

	if Variable.is(x) then
		if x.value and x.value >= 0 then return true end
	
		-- TODO subsets / intervals / domains
		if require 'symmath.set.Real':contains(x)
		and x.isNonNegative 
		then 
			return true 
		end
	end

	-- |(x^n)| = x^n for n even
	if symmath.op.pow.is(x)
	and require 'symmath.set.EvenInteger':contains(x[2])
	and require 'symmath.set.Real':contains(x[1])
	then
		return true
	end

	return false
end

abs.rules = {
	Prune = {
		{apply = function(prune, expr)
			-- unm's are converted to -1 * 's
			local mul = require 'symmath.op.mul'
			local Constant = require 'symmath.Constant'
			
			local x = expr[1]	-- abs(x)
			
			if mul.is(x) 
			and Constant.is(x[1])
			and x[1].value < 0
			then
				return prune:apply(
					mul(
						Constant(math.abs(x[1].value)),
						table.unpack(x, 2)
					)
				)
			end
		
			if Constant.is(x)
			and x.value < 0
			then
				return prune:apply(Constant(math.abs(x.value)))
			end
		
			if isNonNegative(x) then
				return x
			end
		end},
	},
}

return abs
