require 'ext'
-- single-line strings 
local ToStringMethod = require 'symmath.ToStringMethod'
local ToSingleLineString = class(ToStringMethod)

ToSingleLineString.lookupTable = {
	[require 'symmath.Constant'] = function(self, expr) 
		return tostring(expr.value) 
	end,
	[require 'symmath.Invalid'] = function(self, expr)
		return 'Invalid'
	end,
	[require 'symmath.Function'] = function(self, expr)
		return expr.name..'(' .. expr.xs:map(function(x) return self:apply(x) end):concat(', ') .. ')'
	end,
	[require 'symmath.unmOp'] = function(self, expr)
		return '-'..self:wrapStrWithParenthesis(expr.xs[1], expr)
	end,
	[require 'symmath.BinaryOp'] = function(self, expr)
		return expr.xs:map(function(x) 
			return self:wrapStrWithParenthesis(x, expr)
		end):concat(expr:getSepStr())
	end,
	[require 'symmath.Variable'] = function(self, expr)
		local s = expr.name
		if expr.value then
			s = s .. '|' .. expr.value
		end
		return s
	end,
	[require 'symmath.Derivative'] = function(self, expr) 
		local diffvar = self:apply(assert(expr.xs[1]))
		return 'd/d{'..table{unpack(expr.xs, 2)}:map(function(x) return self:apply(x) end):concat(',')..'}['..diffvar..']'
	end
}

--singleton -- no instance creation
getmetatable(ToSingleLineString).__call = function(self, ...) 
	return self:apply(...) 
end

return ToSingleLineString

