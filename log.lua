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

log.getRealDomain = require 'symmath.set.RealDomain'.getRealDomain_posInc_negIm

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
			
			-- log(0) = -infinity
			if Constant.isValue(x, 0) then
				return -Constant.inf
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
