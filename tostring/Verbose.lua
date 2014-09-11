require 'ext'

local ToString = require 'symmath.tostring.ToString'
local Verbose = class(ToString)

Verbose.lookupTable = {
	[require 'symmath.Constant'] = function(self, expr)
		return 'Constant['..tostring(expr.value)..']'
	end,
	[require 'symmath.Invalid'] = function(self, expr)
		return 'Invalid'
	end,
	[require 'symmath.unmOp'] = function(self, expr)
		return 'unm('..self:apply(expr.xs[1])..')'
	end,
	[require 'symmath.BinaryOp'] = function(self, expr)
		return 'BinaryOp{'..expr.name..'}['..expr.xs:map(tostring):concat(', ')..']'
	end,
	[require 'symmath.Function'] = function(self, expr)
		return 'Function{'..expr.name..'}[' .. expr.xs:map(tostring):concat(', ') .. ']'
	end,
	[require 'symmath.Variable'] = function(self, expr)
		local s = 'Variable['..expr.name..']'
		if expr.value then
			s = s .. '|' .. expr.value
		end
		return s	
	end,
	[require 'symmath.Derivative'] = function(self, expr) 
		return 'Derivative{'..expr.xs:map(self):concat(', ')..'}'
	end
}

--singleton -- no instance creation
getmetatable(Verbose).__call = function(self, ...) 
	return self:apply(...) 
end

return Verbose

