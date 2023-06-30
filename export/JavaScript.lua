local table = require 'ext.table'
local class = require 'ext.class'
local Language = require 'symmath.export.Language'

-- TODO JavaScript is a Java derivative, which is a C++ derivative, which is a C derivative
-- so should JavaScript inherit from C?

-- convert to JavaScript code.  use :toCode to wrap in a function
local JavaScript = class(Language)

JavaScript.name = 'JavaScript'

JavaScript.arrayOpenSymbol = '['
JavaScript.arrayCloseSymbol = ']'

JavaScript.lookupTable = table(JavaScript.lookupTable):union{
	[require 'symmath.Function'] = function(self, expr)
		return 'Math.' .. expr:nameForExporter(self) .. '(' .. table.mapi(expr, function(x)
			return (self:apply(x))
		end):concat', ' .. ')'
	end,
	[require 'symmath.Heaviside'] = function(self, expr)
		local xs = self:apply(expr[1])
		return '('..xs..' >= 0 ? 1 : 0)'
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
}:setmetatable(nil)

JavaScript.generateParams = {
	localType = 'const',
	lineEnd = ';',

	funcHeaderStart = function(self, name, inputs)
		return 'function'..(name and (' '..name) or '')..'('
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
