require 'ext'

local ToString = require 'symmath.tostring.ToString'

-- convert to JavaScript code.  use :compile to wrap in a function
local JavaScript = class(ToString)

JavaScript.lookupTable = {
	[require 'symmath.Constant'] = function(self, expr, vars)
		return tostring(expr.value) 
	end,
	[require 'symmath.Invalid'] = function(self, expr, vars)
		return '(0/0)'
	end,
	[require 'symmath.Function'] = function(self, expr, vars)
		return 'Math.' .. expr.name .. '(' .. expr.xs:map(function(x) return self:apply(x, vars) end):concat(',') .. ')'
	end,
	[require 'symmath.unmOp'] = function(self, expr, vars)
		return '(-'..self:apply(expr.xs[1], vars)..')'
	end,
	[require 'symmath.BinaryOp'] = function(self, expr, vars)
		return '('..expr.xs:map(function(x) return self:apply(x, vars) end):concat(' '..expr.name..' ')..')'
	end,
	[require 'symmath.powOp'] = function(self, expr, vars)
		-- special case for constant integer powers
		local invert = false 
		local result
		if expr.xs[2]:isa(Constant) then
			local power = expr.xs[2].value
			if power == 0 then 
				return '1' 
			end
			if power < 0 then
				invert = true
				power = -power
			end	
			-- sqrt hack
			if power == .5 then
				result = 'Math.sqrt(' .. self:apply(expr.xs[1], vars) .. ')'
			-- integer-power hack
			elseif power > 0 and power == math.floor(power) then
				-- TODO declare beforehand as a variable
				local code = '(' .. self:apply(expr.xs[1], vars) .. ')'
				local reps = table()
				for i=1,power do
					reps:insert(code)
				end
				result = '(' .. reps:concat(' * ') .. ')'
			end
		end
		if not result then
			result = 'Math.pow(' .. expr.xs:map(function(x) return self:apply(x, vars) end):concat(',')..')'
		end
		if invert then
			result = '1 / (' .. result .. ')'
		end
		return result
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

-- returns code that can be eval()'d to return a function
function JavaScript:compile(expr, vars)
	local cmd = 'function tmp('..
		table.map(vars, function(var) return var.name end):concat(', ')
	..') { return '..
		self:apply(expr, vars)
	..'; }; tmp;'
	return cmd
end

return JavaScript()

