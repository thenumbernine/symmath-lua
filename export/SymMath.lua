local class = require 'ext.class'
local table = require 'ext.table'
local Export = require 'symmath.export.Export'
local tolua = require 'ext.tolua'

local SymMath = class(Export)

SymMath.name = 'SymMath'

local tab = '\t'
SymMath.lookupTable = {
	[require 'symmath.Constant'] = function(self, expr, indent)
		-- TODO only for simple numbers just return the value
		-- and only if it is a child of another expression.  don't assign Lua numbers to vars who are supposed to be symmath Constants
		return indent..expr:nameForExporter(self)..'('..tolua(expr.value)..')'
	end,
	[require 'symmath.Variable'] = function(self, expr, indent)
		local symmath = require 'symmath'
		-- check builtin vars
		for _,field in ipairs{'i', 'e', 'pi', 'inf'} do
			if rawequal(expr, symmath[field]) then return 'symmath.'..field end
		end

		local s = indent..'var('..tolua(expr:nameForExporter(self))
		-- TODO I don't have support for serializing depvars of TensorRefs
		if expr.dependentVars and #expr.dependentVars > 0 then
			s = s .. ', {'..expr.dependentVars:filter(function(depvar)
				return depvar.src == expr
			end):mapi(function(depvar) 
				return self:apply(depvar.wrt)
			end):concat', '..'}'
		elseif expr.value then	-- only add ,nil if we need to pad our expr
			s = s .. ', nil'
		end
		if expr.value then
			s = s .. ', '..tolua(s.value)
		end
		s = s ..')'
		return s
	end,
	[require 'symmath.op.Binary'] = function(self, expr, indent)
		return indent..'(\n'
			..table.mapi(expr, function(xi)
				return self:apply(xi, indent..tab)
			end):concat(' '..expr:nameForExporter(self)..'\n')..'\n'
			..indent..')'
	end,	
	[require 'symmath.op.Equation'] = function(self, expr, indent)
		return indent .. '(\n'
			..table.mapi(expr, function(xi)
				return self:apply(xi, indent..tab)
			end):concat('\n'..indent..'):'..expr:nameForExporter(self)..'(\n')..'\n'
			..indent..')'	
	end,
	-- TODO same with ne, ge, gt, le, lt
	-- 'unary' ?
	[require 'symmath.op.unm'] = function(self, expr, indent)
		return indent..'-(\n'
			..self:apply(expr[1], indent..tab)..'\n'
			..indent..')'
	end,
	[require 'symmath.tensor.TensorIndex'] = function(self, expr, indent)
		local sep = ''
		local s = expr:nameForExporter(self)..'{'
		if expr.lower ~= nil then s = s..sep..'lower='..tolua(expr.lower) sep=', ' end
		if expr.derivative ~= nil then s = s..sep..'derivative='..tolua(expr.derivative) sep=', ' end
		if expr.symbol ~= nil then s = s..sep..'symbol='..tolua(expr.symbol) sep=', ' end
		s = s ..'}'
		return indent .. s
	end,
	-- Tensor constructor is a mess
	[require 'symmath.Tensor'] = function(self, expr, indent)
		local s = indent..expr:nameForExporter(self)..'(\n'
		if #expr.variance > 0 then
			s = s ..indent..tab..'{\n'
				..table.mapi(expr.variance, function(xi)
					return self:apply(xi)
				end):concat(',\n')..'\n'
				..indent..tab..'},\n'
		end
		s = s ..table.mapi(expr, function(xi) 
				return self:apply(xi, indent..tab) 
			end):concat(',\n')..'\n'
			..indent..')'
		return s
	end,
	[require 'symmath.Invalid'] = function(self, expr)
		return expr:nameForExporter(self)
	end,
	[require 'symmath.Expression'] = function(self, expr, indent)
		local name = expr:nameForExporter(self)
		return indent..expr:nameForExporter(self)..'(\n'
			..table.mapi(expr, function(xi) 
				return self:apply(xi, indent..tab) 
			end):concat(',\n')..'\n'
			..indent..')'
	end,
}

function SymMath:apply(expr, indent, ...)
	return SymMath.super.apply(self, expr, indent or '', ...)
end

return SymMath()
