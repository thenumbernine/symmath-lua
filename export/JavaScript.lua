local table = require 'ext.table'
local class = require 'ext.class'
local Language = require 'symmath.export.Language'

-- convert to JavaScript code.  use :toCode to wrap in a function
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
		return 'Math.' .. expr.name .. '(' .. table.mapi(expr, function(x)
			return (self:apply(x))
		end):concat', ' .. ')'
	end,
	[require 'symmath.op.unm'] = function(self, expr)
		return '(-'..self:apply(expr[1])..')'
	end,
	[require 'symmath.op.Binary'] = function(self, expr)
		return '('..table.mapi(expr, function(x)
			return (self:apply(x))
		end):concat(' '..expr.name..' ')..')'
	end,
	[require 'symmath.op.pow'] = function(self, expr)
		if expr[1] == require 'symmath'.e then
			return 'Math.exp('..self:apply(expr[2])..')'
		else
			return 'Math.pow(' .. table.mapi(expr, function(x)
				return (self:apply(x))
			end):concat', '..')'
		end
	end,
	[require 'symmath.Variable'] = function(self, expr)
		return expr.name
	end,
	[require 'symmath.Derivative'] = function(self, expr) 
		error("can't compile differentiation.  replace() your diff'd content first!")
	end,
}

JavaScript.generateParams = {
	localType = 'var',
	lineEnd = ';',

	funcHeaderStart = function(inputs)
		return 'function generatedFunction('
	end,
	funcHeaderEnd = ') {',
	funcFooter = '}',
	returnCode = function(outputs)
		return '\treturn '
			..(#outputs > 1 and '[' or '')
			..outputs:mapi(function(output) 
				return output.name 
			end):concat', '
			..(#outputs > 1 and ']' or '')
			..';'
	end,
}

return JavaScript()		-- singleton
