require 'ext'

local Language = require 'symmath.tostring.Language'

-- convert to Lua code.  use :compile to generate a function
local Lua = class(Language)

Lua.lookupTable = {
	[require 'symmath.Constant'] = function(self, expr, vars)
		return tostring(expr.value) 
	end,
	[require 'symmath.Invalid'] = function(self, expr, vars)
		return '(0/0)'
	end,
	[require 'symmath.Function'] = function(self, expr, vars)
		return 'math.' .. expr.name .. '(' .. table.map(expr, function(x,k)
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
	end
}

-- returns (1) the function and (2) the code
-- see Language:getCompileParameters for a description of paramInputs
function Lua:compile(expr, paramInputs)
	local expr, vars = self:prepareForCompile(expr, paramInputs)
	local cmd = 'return function('..
		vars:map(function(var) return var.name end):concat(', ')
	..') return '..
		self:apply(expr, vars)
	..' end'
	return assert(loadstring(cmd))(), cmd
end

return Lua()	-- singleton

