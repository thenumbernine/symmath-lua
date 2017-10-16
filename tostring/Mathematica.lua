local class = require 'ext.class'
local table = require 'ext.table'
local Language = require 'symmath.tostring.Language'

local Mathematica = class(Language)

Mathematica.lookupTable = {
	[require 'symmath.Constant'] = function(self, expr, vars)
	end,
	[require 'symmath.Invalid'] = function(self, expr, vars)
		return '(0/0)'
	end,
	[require 'symmath.Function'] = function(self, expr, vars)
		return expr.name .. '[' .. table.map(expr, function(x,k)
			if type(k) ~= 'number' then return end
			return self:apply(x, vars)
		end):concat(',') .. ']'
	end,
	[require 'symmath.op.unm'] = function(self, expr, vars)
		return '(-'..self:apply(expr[1], vars)..')'
	end,
	[require 'symmath.op.Binary'] = function(self, expr, vars)
		return '('..table.map(expr, function(x,k)
			if type(k) ~= 'number' then return end
			return self:apply(x, vars)
		end):concat(' '..expr.name..' ')..')'
	end,
	[require 'symmath.op.pow'] = function(self, expr, vars)
		if expr[1] == require 'symmath'.e then
			return 'exp['..self:apply(expr[2], vars)..']'
		else
			local predefs = table()
			local s = table()
			for i,x in ipairs(expr) do
				local sx = self:apply(x, vars)
				s:insert(sx[1])
				predefs = table(predefs, sx[2])
			end
			s = s:concat(' '..expr.name..' ')
			return {'('..s..')', predefs}		
		end
	end,
	[require 'symmath.Variable'] = function(self, expr, vars)
		if table.find(vars, nil, function(var) 
			return expr.name == var.name 
		end) then
			return expr.name
		end
		error("tried to compile variable "..expr.name.." that wasn't in your function argument variable list")
	end,
	[require 'symmath.Derivative'] = function(self, expr) 
		error("can't compile differentiation.  replace() your diff'd content first!")
	end,

}

function Mathematica:compile(expr, paramInputs)
	local expr, vars = self:prepareForCompile(expr, paramInputs)
	local cmd = 'function tmp('..
		vars:map(function(var) return var.name end):concat(', ')
	..') { return '..
		self:apply(expr, vars)
	..'; }; tmp;'
	return cmd
end

function Mathematica:__call(...)
	return self:apply(...)[1]
end

return Mathematica()	-- singleton
