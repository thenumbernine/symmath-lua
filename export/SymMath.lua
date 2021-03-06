local class = require 'ext.class'
local table = require 'ext.table'
local Export = require 'symmath.export.Export'
local tolua = require 'ext.tolua'

local SymMath = class(Export)

SymMath.name = 'SymMath'

local tab = '\t'
SymMath.lookupTable = {
	[require 'symmath.Constant'] = function(self, x, indent)
		-- TODO only for simple numbers just return the value
		-- and only if it is a child of another expression.  don't assign Lua numbers to vars who are supposed to be symmath Constants
		return indent..x.name..'('..tolua(x.value)..')'
	end,
	[require 'symmath.Variable'] = function(self, x, indent)
		local s = indent..'var('..tolua(x.name)
		-- TODO I don't have support for serializing depvars of TensorRefs
		if x.dependentVars and #x.dependentVars > 0 then
			s = s .. ', {'..x.dependentVars:filter(function(depvar)
				return depvar.src == x
			end):mapi(function(depvar) 
				return self:apply(depvar.wrt)
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
	-- these don't directly translate to their name, as math operators do
	[require 'symmath.op.eq'] = function(self, x, indent)
		return indent .. '(\n'
			.. indent .. self:apply(x[1], indent..tab)
			.. '\n'
			.. indent .. '):eq(\n'
			..table.sub(x,2):mapi(function(xi)
				return self:apply(xi, indent..tab)
			end):concat(' '..x.name..'\n')..'\n'
			..indent..')'
	end,
	-- TODO same with ne, ge, gt, le, lt
	-- 'unary' ?
	[require 'symmath.op.unm'] = function(self, x, indent)
		return indent..'-(\n'
			..self:apply(x[1], indent..tab)..'\n'
			..indent..')'
	end,
	[require 'symmath.tensor.TensorIndex'] = function(self, x, indent)
		local sep = ''
		local s = x.name..'{'
		if x.lower ~= nil then s = s..sep..'lower='..tolua(x.lower) sep=', ' end
		if x.derivative ~= nil then s = s..sep..'derivative='..tolua(x.derivative) sep=', ' end
		if x.symbol ~= nil then s = s..sep..'symbol='..tolua(x.symbol) sep=', ' end
		s = s ..'}'
		return indent .. s
	end,
	-- Tensor constructor is a mess
	[require 'symmath.Tensor'] = function(self, x, indent)
		local s = indent..x.name..'(\n'
		if #x.variance > 0 then
			s = s ..indent..tab..'{\n'
				..table.mapi(x.variance, function(xi)
					return self:apply(xi)
				end):concat(',\n')..'\n'
				..indent..tab..'},\n'
		end
		s = s ..table.mapi(x, function(xi) 
				return self:apply(xi, indent..tab) 
			end):concat(',\n')..'\n'
			..indent..')'
		return s
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
