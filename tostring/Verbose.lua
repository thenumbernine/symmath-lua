local class = require 'ext.class'
local table = require 'ext.table'
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
	[require 'symmath.Expression'] = function(self, expr)
		return expr.name..'{'..table.map(expr, function(x,k)
			if type(k) ~= 'number' then return end
			return self(x)
		end):concat(', ')..'}'
	end,
	[require 'symmath.tensor.TensorIndex'] = function(self, expr)
		-- NOTICE if TensorIndex ever became an Expression then its __tostring would be overriding the original
		-- and if it didn't override the original ... then this tostring() call would be a recursive call
		return expr.name..'{'..tostring(expr)..'}'
	end,
}

return Verbose()	-- singleton
