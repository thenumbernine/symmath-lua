local class = require 'ext.class'
local table = require 'ext.table'
local Export = require 'symmath.export.Export'


local Verbose = class(Export)

Verbose.name = 'Verbose'

Verbose.lookupTable = table(Verbose.lookupTable):union{
	[require 'symmath.Constant'] = function(self, expr)
		--return 'Constant['..tostring(expr.value)..']'
		return tostring(expr.value)
	end,
	[require 'symmath.op.unm'] = function(self, expr)
		return 'unm('..self:apply(expr[1])..')'
	end,
	[require 'symmath.op.Binary'] = function(self, expr)
		--return 'Binary{'..expr:nameForExporter(self)..'}['..table.map(expr, function(x,k)
		return expr:nameForExporter(self)..'['..table.mapi(expr, function(x)
			return self(x)
		end):concat(', ')..']'
	end,
	[require 'symmath.Function'] = function(self, expr)
		--return 'Function{'..expr:nameForExporter(self)..'}[' .. table.map(expr, function(x,k)
		return expr:nameForExporter(self)..'[' .. table.mapi(expr, function(x)
			return (self(x))
		end):concat', ' .. ']'
	end,
	[require 'symmath.Variable'] = function(self, expr)
		--local s = 'Variable['..expr:nameForExporter(self)..']'
		local s = expr:nameForExporter(self)
		if expr.value then
			s = s .. '|' .. expr.value
		end
		return s	
	end,
	[require 'symmath.Expression'] = function(self, expr)
		return expr:nameForExporter(self)..'{'..table.mapi(expr, function(x)
			return self(x)
		end):concat', '..'}'
	end,
	[require 'symmath.tensor.Index'] = function(self, expr)
		-- NOTICE if TensorIndex ever became an Expression then its __tostring would be overriding the original
		-- and if it didn't override the original ... then this tostring() call would be a recursive call
		return expr:nameForExporter(self)..'{'..tostring(expr)..'}'
	end,
	[require 'symmath.Wildcard'] = function(self, expr)
		return expr:nameForExporter(self)..'{'
			..'index='..expr.index
			..(expr.atLeast and (', atLeast='..expr.atLeast) or '')
			..(expr.atMost and (', atMost='..expr.atMost) or '')
			..(expr.wildcardDependsOn and (', dependsOn='..self:apply(expr.wildcardDependsOn)) or '')
			..(expr.wildcardCannotDependOn and (', cannotDependOn='..self:apply(expr.wildcardCannotDependOn)) or '')
		..'}'
	end,
	[require 'symmath.Tensor'] = function(self, expr)
		return self:applyForClass(require 'symmath.Tensor'.super, expr)
			..table.mapi(expr.variance, tostring):concat()
	end,
}:setmetatable(nil)

return Verbose()	-- singleton
