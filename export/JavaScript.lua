local table = require 'ext.table'
local class = require 'ext.class'
local Language = require 'symmath.export.Language'

-- TODO JavaScript is a Java derivative, which is a C++ derivative, which is a C derivative
-- so should JavaScript inherit from C?

-- convert to JavaScript code.  use :toCode to wrap in a function
local JavaScript = class(Language)

JavaScript.name = 'JavaScript'

JavaScript.lookupTable = {
	[require 'symmath.Constant'] = function(self, expr)
		return tostring(expr.value) 
	end,
	[require 'symmath.Invalid'] = function(self, expr)
		return expr:nameForExporter(self)
	end,
	[require 'symmath.Function'] = function(self, expr)
		return 'Math.' .. expr:nameForExporter(self) .. '(' .. table.mapi(expr, function(x)
			return (self:apply(x))
		end):concat', ' .. ')'
	end,
	[require 'symmath.Heaviside'] = function(self, expr)
		local xs = self:apply(expr[1])
		return '('..xs..' >= 0 ? 1 : 0)'
	end,
	[require 'symmath.op.unm'] = function(self, expr)
		return '(-'..self:apply(expr[1])..')'
	end,
	[require 'symmath.op.Binary'] = function(self, expr)
		return '('..table.mapi(expr, function(x)
			return (self:apply(x))
		end):concat(expr:getSepStr(self))..')'
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
		return expr:nameForExporter(self)
	end,
	[require 'symmath.Derivative'] = function(self, expr) 
		error("can't compile differentiation.  replace() your diff'd content first!")
	end,
	[require 'symmath.Integral'] = function(self, expr) 
		error("can't compile integration.  replace() your integral content first!\n"
		..(require 'symmath.export.MultiLine')(expr))
	end,
	-- matches export/C.lua's symmath.Array export, except with different wrapping [] vs {}'s
	-- so TODO make a common function out of it?
	[require 'symmath.Array'] = function(self, expr)
		local predefs = table()
		return '['..table.mapi(expr, function(x, i)
			local sx1, sx2 = self:apply(x)
			predefs = table(predefs, sx2)
			return sx1
		end):concat', '..']', predefs
	end,

-- [[ TODO put this block in Language, and have subclasses copy over lookupTable
-- and then inline the Language:varNameForTensorRef function
	
	-- TODO re-encode to work with language valid variable names special chars 
	-- but looking at TensorIndex's own tostring(), looks like that could be merged with Variable's exporter too ...
	[require 'symmath.tensor.TensorIndex'] = function(self, expr)
		return (expr:__tostring()
			:gsub('_', '_D')
			:gsub('%^', '_U'))
	end,

	-- TODO inherit lookupTable entry from export/Language.lua instead of just inheriting its function call
	[require 'symmath.tensor.TensorRef'] = function(self, expr)
		return self:varNameForTensorRef(expr)
	end,
--]]
}

JavaScript.generateParams = {
	localType = 'var',
	lineEnd = ';',

	funcHeaderStart = function(self, name, inputs)
		return 'function '..name..'('
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
