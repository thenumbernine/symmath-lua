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

log.visitorHandler = {
	Prune = function(prune, expr)
		local symmath = require 'symmath'
		local Constant = symmath.Constant
		local x = table.unpack(expr)
		if x == symmath.e then
			return Constant(1)
		elseif x == Constant(0) then
			return -Constant.inf
		end
	end
}

return log
