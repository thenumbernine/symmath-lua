local class = require 'ext.class'
local table = require 'ext.table'
local Export = require 'symmath.export.Export'
local tolua = require 'ext.tolua'

local SymMath = class(Export)

local tab = '\t'
SymMath.lookupTable = {
	[require 'symmath.Constant'] = function(self, x, indent)
		-- TODO only for simple numbers just return the value
		-- and only if it is a child of another expression.  don't assign Lua numbers to vars who are supposed to be symmath Constants
		return indent..x.name..'('..tolua(x.value)..')'
	end,
	[require 'symmath.Variable'] = function(self, x, indent)
		local s = indent..'var('..tolua(x.name)
		if x.dependentVars and #x.dependentVars > 0 then
			s = s .. ', {'..table.mapi(x.dependentVars, function(xi) 
				return xi.name
			end):concat', '..'}'
		elseif x.value then	-- only add ,nil if we need to pad our expr
			s = s .. ', nil'
		end
		if x.value then
			s = s .. ', '..tolua(s.value)
		end
		s = s ..')'
		return s
	end,
	[require 'symmath.op.Binary'] = function(self, x, indent)
		return indent..'(\n'
			..table.mapi(x, function(xi)
				return self:apply(xi, indent..tab)
			end):concat(' '..x.name..'\n')..'\n'
			..indent..')'
	end,
	-- 'unary' ?
	[require 'symmath.op.unm'] = function(self, x, indent)
		return indent..'-(\n'
			..self:apply(x[1], indent..tab)..'\n'
			..indent..')'
	end,
	[require 'symmath.tensor.TensorIndex'] = function(self, x, indent)
		local sep = ''
		local s = x.name..'{'
		if x.lower then s = s..sep..'lower='..tostring(x.lower) sep=', ' end
		if x.derivative then s = s..sep..'derivative='..tostring(x.derivative) sep=', ' end
		if x.symbol then s = s..sep..'symbol='..tostring(x.symbol) sep=', ' end
		if x.number then s = s..sep..'number='..tostring(x.number) sep=', ' end
		s = s ..'}'
		return s
	end,
	[require 'symmath.Tensor'] = function(self, x, indent)
		return indent..x.name..'(\n'
			..indent..tab..'{\n'
			..table.mapi(x.variance, function(xi)
				return self:apply(xi)
			end):concat(',\n')..'\n'
			..indent..tab..'},\n'
			..table.mapi(x, function(xi) 
				return self:apply(xi, indent..tab) 
			end):concat(',\n')..'\n'
			..indent..')'
	end,
	[require 'symmath.Expression'] = function(self, x, indent)
		local name = x.name
		return indent..x.name..'(\n'
			..table.mapi(x, function(xi) 
				return self:apply(xi, indent..tab) 
			end):concat(',\n')..'\n'
			..indent..')'
	end,
}

function SymMath:apply(x, indent, ...)
	return SymMath.super.apply(self, x, indent or '', ...)
end

return SymMath()
