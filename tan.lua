local class = require 'ext.class'
local Function = require 'symmath.Function'

local tan = class(Function)
tan.name = 'tan'
--tan.func = math.tan
tan.func = require 'symmath.complex'.tan

function tan:evaluateDerivative(deriv, ...)
	local x = table.unpack(self):clone()
	local cos = require 'symmath.cos'
	return deriv(x, ...) / cos(x)^2
end

function tan:reverse(soln, index)
	return require 'symmath.atan'(soln)
end

tan.rules = {
	Prune = {
		{apply = function(prune, expr)
			local sin = require 'symmath.sin'
			local cos = require 'symmath.cos'
			local th = expr[1]
			return prune:apply(sin(th:clone()) / cos(th:clone()))
		end},
	},
}

return tan
