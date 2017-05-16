local table = require 'ext.table'
local class = require 'ext.class'
local Language = require 'symmath.tostring.Language'

-- convert to JavaScript code.  use :compile to wrap in a function
local JavaScript = class(Language)

JavaScript.lookupTable = {
	[require 'symmath.Constant'] = function(self, expr, vars)
		return tostring(expr.value) 
	end,
	[require 'symmath.Invalid'] = function(self, expr, vars)
		return '(0/0)'
	end,
	[require 'symmath.Function'] = function(self, expr, vars)
		return 'Math.' .. expr.name .. '(' .. table.map(expr, function(x,k)
			if type(k) ~= 'number' then return end
			return self:apply(x, vars)
		end):concat(',') .. ')'
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
			return 'Math.exp('..self:apply(expr[2], vars)..')'
		else
			return 'Math.pow(' .. table.map(expr, function(x,k)
				if k ~= 'number' then return end
				return self:apply(x, vars)
			end):concat(',')..')'
		end
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

-- returns code that can be eval()'d to return a function
-- see Language:getCompileParameters for a description of paramInputs
function JavaScript:compile(expr, paramInputs)
	local expr, vars = self:prepareForCompile(expr, paramInputs)
	local cmd = 'function tmp('..
		vars:map(function(var) return var.name end):concat(', ')
	..') { return '..
		self:apply(expr, vars)
	..'; }; tmp;'
	return cmd
end

return JavaScript()		-- singleton

