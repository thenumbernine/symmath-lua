local table = require 'ext.table'
local class = require 'ext.class'
local Language = require 'symmath.export.Language'

-- convert to JavaScript code.  use :compile to wrap in a function
local JavaScript = class(Language)

JavaScript.name = 'JavaScript'

JavaScript.lookupTable = {
	[require 'symmath.Constant'] = function(self, expr)
		return tostring(expr.value) 
	end,
	[require 'symmath.Invalid'] = function(self, expr)
		return '(0/0)'
	end,
	[require 'symmath.Function'] = function(self, expr)
		return 'Math.' .. expr.name .. '(' .. table.map(expr, function(x,k)
			if type(k) ~= 'number' then return end
			return self:apply(x)
		end):concat(',') .. ')'
	end,
	[require 'symmath.op.unm'] = function(self, expr)
		return '(-'..self:apply(expr[1])..')'
	end,
	[require 'symmath.op.Binary'] = function(self, expr)
		return '('..table.map(expr, function(x,k)
			if type(k) ~= 'number' then return end
			return self:apply(x)
		end):concat(' '..expr.name..' ')..')'
	end,
	[require 'symmath.op.pow'] = function(self, expr)
		if expr[1] == require 'symmath'.e then
			return 'Math.exp('..self:apply(expr[2])..')'
		else
			return 'Math.pow(' .. table.map(expr, function(x,k)
				if k ~= 'number' then return end
				return self:apply(x)
			end):concat(',')..')'
		end
	end,
	[require 'symmath.Variable'] = function(self, expr)
		return expr.name
	end,
	[require 'symmath.Derivative'] = function(self, expr) 
		error("can't compile differentiation.  replace() your diff'd content first!")
	end,
}

function JavaScript:generate(expr, vars)
	local info = self:apply(expr, vars)
	local body = info[1]
	local predefs = info[2]
	local code = predefs and table.keys(predefs):concat'\n'..'\n' or ''
	-- TODO keep track of what vars are used, and compare it to the vars in the compile, to ensure correct code is generated.
	return code..'function tmp('
		..vars:map(function(var) return var.name end):concat(', ')
		..') { return '..body..'; }; tmp;'
end

-- returns code that can be eval()'d to return a function
-- see Language:getCompileParameters for a description of paramInputs
function JavaScript:compile(expr, paramInputs)
	local expr, vars = self:prepareForCompile(expr, paramInputs)
	local cmd = self:generate(expr, vars)
	return cmd
end

return JavaScript()		-- singleton
