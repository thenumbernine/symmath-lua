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
		return 'unm('..self:apply(expr[1])..')'
	end,
	[require 'symmath.BinaryOp'] = function(self, expr)
		return 'BinaryOp{'..expr.name..'}['..table.map(expr, function(x,k)
			if type(k) ~= 'number' then return end
			return self(x)
		end):concat(', ')..']'
	end,
	[require 'symmath.Function'] = function(self, expr)
		return 'Function{'..expr.name..'}[' .. table.map(expr, function(x,k)
			if type(k) ~= 'number' then return end
			return self(x)
		end):concat(', ') .. ']'
	end,
	[require 'symmath.Variable'] = function(self, expr)
		local s = 'Variable['..expr.name..']'
		if expr.value then
			s = s .. '|' .. expr.value
		end
		return s	
	end,
	[require 'symmath.Derivative'] = function(self, expr) 
		return 'Derivative{'..table.map(expr, function(x,k)
			if type(k) ~= 'number' then return end
			return self(x)
		end):concat(', ')..'}'
	end,
	[require 'symmath.Tensor'] = function(self, expr)
		return 'Tensor{'..table.map(expr, function(x,k)
			if type(k) ~= 'number' then return end
			return self(x)
		end):concat(', ')..'}'
	end,
}

return Verbose()	-- singleton

