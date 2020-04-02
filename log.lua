local class = require 'ext.class'
local table = require 'ext.table'
local Function = require 'symmath.Function'

local log = class(Function)
log.name = 'log'
--log.func = math.log
log.func = require 'symmath.complex'.log

function log:evaluateDerivative(deriv, ...)
	local x = table.unpack(self):clone()
	return deriv(x, ...) / x
end

function log:reverse(soln, index)
	return require 'symmath'.e ^ soln
end

log.rules = {
	Prune = {
		{apply = function(prune, expr)
			local symmath = require 'symmath'
			local Constant = symmath.Constant
			local x = table.unpack(expr)
		
			-- log(e) = 1
			if x == symmath.e then
				return Constant(1)
			end
			
			-- log(1) = 0
			if x == Constant(1) then
				return Constant(0)
			end
			
			-- log(0) = -infinity
			if x == Constant(0) then
				return -Constant.inf
			end
		end},
	},

	Expand = {
		{apply = function(expand, expr)
			local symmath = require 'symmath'
			local x = expr[1]
			
			-- log(a^b) = b log(a)
			if symmath.op.pow.is(x) then
				return expand:apply(x[2] * log(x[1]))
			end	
		
			-- log(ab) = log(a) + log(b)
			if symmath.op.mul.is(x) then
				return op.add(table.mapi(x, function(xi)
					return log(xi)
				end):unpack())
			end
		
			-- log(a/b) = log(a) - log(b)
			if symmath.op.div.is(x) then
				return log(x[1]) - log(x[2])
			end
		end},
	},
}

return log
