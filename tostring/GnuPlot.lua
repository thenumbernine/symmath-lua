local table = require 'ext.table'
local class = require 'ext.class'
local Language = require 'symmath.tostring.Language'

local GnuPlot = class(Language)

GnuPlot.lookupTable = {
	[require 'symmath.Constant'] = function(self, expr, vars)
		local s = tostring(expr.value)
		if not s:find'.' and not s:find'[eE]' then s = s .. '.' end
		return s
	end,
	[require 'symmath.Invalid'] = function(self, expr, vars)
		return '(0/0)'
	end,
	[require 'symmath.Function'] = function(self, expr, vars)
		return expr.name .. '(' .. table.map(expr, function(x,k)
			if type(k) ~= 'number' then return end
			return self:apply(x, vars)
		end):concat(',') .. ')'
	end,
	[require 'symmath.unmOp'] = function(self, expr, vars)
		return '(-'..self:apply(expr[1], vars)..')'
	end,
	[require 'symmath.BinaryOp'] = function(self, expr, vars)
		return '('..table.map(expr, function(x,k)
			if type(k) ~= 'number' then return end
			return self:apply(x, vars)
		end):concat(' '..expr.name..' ')..')'
	end,
	[require 'symmath.powOp'] = function(self, expr, vars)
		return '('..table.map(expr, function(x,k)
			if type(k) ~= 'number' then return end
			return self:apply(x, vars)
		end):concat(' ** ')..')'
	end,
	[require 'symmath.Variable'] = function(self, expr, vars)
		if table.find(vars, nil, function(var) return expr.name == var.name end) then
			return expr.name
		end
		error("tried to compile variable "..expr.name.." that wasn't in your function argument variable list")
	end,
	[require 'symmath.Derivative'] = function(self, expr) 
		error("can't compile differentiation.  replace() your diff'd content first!")
	end,
}

return GnuPlot()	-- singleton
