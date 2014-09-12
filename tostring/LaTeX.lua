require 'ext'

local ToString = require 'symmath.tostring.ToString'

local LaTeX = class(ToString)

LaTeX.lookupTable = {
	[require 'symmath.Constant'] = function(self, expr)
		return '{' .. tostring(expr.value)  .. '}'
	end,
	[require 'symmath.Invalid'] = function(self, expr)
		return '?'
	end,
	[require 'symmath.Function'] = function(self, expr)
		return expr.name .. '\\left (' .. expr.xs:map(function(x) return '{' .. self(x) .. '}' end):concat(',') .. '\\right )'
	end,
	[require 'symmath.unmOp'] = function(self, expr)
		return '{-{'..self:wrapStrWithParenthesis(expr.xs[1], expr)..'}}'
	end,
	[require 'symmath.BinaryOp'] = function(self, expr)
		return '{'..expr.xs:map(function(x) 
			return '{' .. self:wrapStrWithParenthesis(x, expr) .. '}'
		end):concat(expr:getSepStr())..'}'
	end,
	[require 'symmath.divOp'] = function(self, expr)
		return '{{' .. self(expr.xs[1]) .. '} \\over {' .. self(expr.xs[2]) .. '}}'
	end,
	[require 'symmath.Variable'] = function(self, expr)
		local s = expr.name
		if expr.value then
			s = s .. '|' .. expr.value
		end
		return s
	end,
	[require 'symmath.Derivative'] = function(self, expr) 
		--[[ for single variables 
		return '{{d' .. self(expr.xs[1]) .. '} \\over {' .. 
			table{unpack(expr.xs, 2)}:map(function(x) return 'd{' .. self(x) .. '}' end):concat(',') 
			.. '}}'
		--]]
		-- [[ for complex expressions
		return '{d \\over {' .. 
			table{unpack(expr.xs, 2)}:map(function(x) return 'd{' .. self(x) .. '}' end):concat(',') 
			.. '}} \\left (' .. self(expr.xs[1]) .. '\\right )'
		--]]
	end
}

return LaTeX()

