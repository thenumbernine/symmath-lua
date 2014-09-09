require 'ext'

local ToStringMethod = require 'symmath.ToStringMethod'

-- convert to Lua code.  use :compile to generate a function
local ToLuaCode = class(ToStringMethod)

ToLuaCode.lookupTable = {
	[require 'symmath.Constant'] = function(self, expr, vars)
		return tostring(expr.value) 
	end,
	[require 'symmath.Invalid'] = function(self, expr, vars)
		return '(0/0)'
	end,
	[require 'symmath.Function'] = function(self, expr, vars)
		return 'math.' .. expr.name .. '(' .. expr.xs:map(function(x) return self:apply(x, vars) end):concat(',') .. ')'
	end,
	[require 'symmath.unmOp'] = function(self, expr, vars)
		return '(-'..self:apply(expr.xs[1], vars)..')'
	end,
	[require 'symmath.BinaryOp'] = function(self, expr, vars)
		return '('..expr.xs:map(function(x) return self:apply(x, vars) end):concat(' '..expr.name..' ')..')'
	end,
	[require 'symmath.Variable'] = function(self, expr, vars)
		if table.find(vars, nil, function(var) return expr.name == var.name end) then
			return expr.name
		end
		error("tried to compile variable "..expr.name.." that wasn't in your function argument variable list")
	end,
	[require 'symmath.Derivative'] = function(self, expr) 
		error("can't compile differentiation.  replace() your diff'd content first!")
	end
}

function ToLuaCode:compile(expr, vars)
	local cmd = 'return function('..
		table.map(vars, function(var) return var.name end):concat(', ')
	..') return '..
		self:apply(expr, vars)
	..' end'
	return assert(loadstring(cmd))(), cmd
end

--singleton -- no instance creation
getmetatable(ToLuaCode).__call = function(self, ...) 
	return self:apply(...) 
end

return ToLuaCode

