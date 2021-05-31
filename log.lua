local class = require 'ext.class'
local table = require 'ext.table'
local Function = require 'symmath.Function'
local symmath

local log = class(Function)
log.name = 'log'
log.realFunc = math.log
log.cplxFunc = require 'symmath.complex'.log

function log:evaluateDerivative(deriv, ...)
	local x = table.unpack(self):clone()
	return deriv(x, ...) / x
end

function log:reverse(soln, index)
	symmath = symmath or require 'symmath'
	return symmath.e ^ soln
end

log.getRealRange = require 'symmath.set.RealSubset'.getRealDomain_posInc_negIm

function log:evaluateLimit(x, a, side)
	symmath = symmath or require 'symmath'
	local prune = symmath.prune
	local Constant = symmath.Constant
	local Limit = symmath.Limit

	local L = prune(Limit(self[1], x, a, side))
	if symmath.set.positiveReal:contains(L) then
		return log(L)
	end
	if symmath.set.negativeReal:contains(L) then
		return symmath.invalid
	end
	if Constant.isValue(L, 0) then
		if side == Limit.Side.plus then
			return Constant(-1) * symmath.inf
		end
		return symmath.invalid
	end
	
	-- TODO only for L contained within the domain of H
	return log(L)
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
