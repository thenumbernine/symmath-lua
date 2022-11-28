local class = require 'ext.class'
local table = require 'ext.table'
local Function = require 'symmath.Function'
local symmath

local log = class(Function)
log.name = 'log'
log.realFunc = math.log
log.cplxFunc = require 'complex'.log

function log:evaluateDerivative(deriv, ...)
	local x = table.unpack(self):clone()
	return deriv(x, ...) / x
end

function log:reverse(soln, index)
	symmath = symmath or require 'symmath'
	return symmath.e ^ soln
end

log.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_positiveReal
log.getRealRange = require 'symmath.set.RealSubset'.getRealRange_posInc_negIm

function log:evaluateLimit(x, a, side)
	symmath = symmath or require 'symmath'
	local prune = symmath.prune
	local Constant = symmath.Constant
	local Limit = symmath.Limit

	local expr = self[1]

	-- special case: lim x -> 0+ (x * log(x)) == 0
	if expr == x ^ x
	and Constant.isValue(a, 0)
	then
		if side == Limit.Side.plus then return Constant(0) end
		if side == Limit.Side.minus then return symmath.invalid end
	end

	local L = prune(Limit(expr, x, a, side))

	if Constant.isValue(L, 0) then
		if side == Limit.Side.plus then
			return Constant(-1) * symmath.inf
		end
		return symmath.invalid
	end

	return Limit.evaluateLimit_ifInDomain(self, L)
end

log.rules = {
	Prune = {
		{apply = function(prune, expr)
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant
			local x = table.unpack(expr)
		
			-- log(e) = 1
			if x == symmath.e then
				return Constant(1)
			end
			
			-- log(1) = 0
			if Constant.isValue(x, 1) then
				return Constant(0)
			end

			if x == symmath.inf then
				return symmath.inf
			end
			
			-- log(0) = -infinity
			-- TODO technically, as a limit, it is only -inf when approached from +
			-- and because + and - differ, this is indeterminate
			if Constant.isValue(x, 0) then
				return -symmath.inf
			end
		
-- [[ TODO this should be on all Function's prune()'s
-- contains() should mean fully-contains, not intersects ...
			if expr:getRealDomain():complement():open():contains(x) then
				return symmath.invalid
			end
--]]
		end},
	},

	-- NOTE TO SELF - without calling expand:apply on the returned values, we get simplification loops
	Expand = {
		{apply = function(expand, expr)
			symmath = symmath or require 'symmath'
			local x = expr[1]
			
			-- log(a^b) = b log(a)
			if symmath.op.pow:isa(x) then
				return expand:apply(x[2] * log(x[1]))
			end	
		
			-- log(ab) = log(a) + log(b)
			if symmath.op.mul:isa(x) then
				return expand:apply(symmath.op.add(table.mapi(x, function(xi)
					return log(xi)
				end):unpack()))
			end
		
			-- log(a/b) = log(a) - log(b)
			if symmath.op.div:isa(x) then
				return expand:apply(log(x[1]) - log(x[2]))
			end
		end},
	},
}

return log
