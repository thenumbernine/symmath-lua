local class = require 'ext.class'
local table = require 'ext.table'
local range = require 'ext.range'
local Language = require 'symmath.export.Language'


local C = class(Language)

C.name = 'C'

--[[
This is really being used for OpenCL
--]]

function C:wrapStrOfChildWithParenthesis(parentNode, childIndex, ...)
	local node = parentNode[childIndex]
	local s, predef = self:apply(node, ...)
	if not s then return false end
	if self:testWrapStrOfChildWithParenthesis(parentNode, childIndex) then
		s = '(' .. s .. ')'
	end
	return s, predef
end

C.numberType = 'double'

C.lookupTable = {
	[require 'symmath.Constant'] = function(self, expr)
		local s = tostring(expr.value)
		if not s:find'e' then
			if not s:find'%.' then s = s .. '.' end
		end
		return s
	end,
	[require 'symmath.Invalid'] = function(self, expr)
		return 'NAN'
	end,
	[require 'symmath.Function'] = function(self, expr)
		local predefs = table()
		local s = table()
		for i,x in ipairs(expr) do
			local sx1, sx2 = self:apply(x)
			s:insert(sx1)
			predefs = table(predefs, sx2)
		end
		s = s:concat(', ')
		
		local funcName
		if not expr.code then
			funcName = expr:nameForExporter(self)
		else
			funcName = expr:nameForExporter(self)
			predefs[self.numberType..' '..funcName..'('..self.numberType..' x) {'..expr.code..'}'] = true
		end
		return funcName .. '(' .. s .. ')', predefs
	end,
	[require 'symmath.op.unm'] = function(self, expr)
		local sx1, sx2 = self:wrapStrOfChildWithParenthesis(expr, 1)
		return '-'..sx1, sx2
	end,
	[require 'symmath.op.pow'] = function(self, expr)
		local symmath = require 'symmath'
		if expr[1] == symmath.e then
			local sx1, sx2 = self:apply(expr[2])
			return 'exp(' .. sx1 .. ')', sx2
		else
			-- represent integers as expanded multiplication
			local Constant = symmath.Constant
			if Constant:isa(expr[2])
			and expr[2].value == math.floor(expr[2].value)
			and expr[2].value > 1
			and expr[2].value < 100
			then
				local result1, result2 = self:apply(setmetatable(table.rep({expr[1]}, expr[2].value), symmath.op.mul))
				-- precedence will see pow and not give correct parenthesis
				-- so manually add parenthesis here
				return '('..result1..')', result2
			-- non-integer exponent? use pow()
			else
				local predefs = table()
				local s = table()
				for i,x in ipairs(expr) do
					local sx1, sx2 = self:apply(x)
					s:insert(sx1)
					predefs = table(predefs, sx2)
				end
				s = s:concat(', ')
				return 'pow(' .. s .. ')', predefs
			end
		end
	end,
	[require 'symmath.op.Binary'] = function(self, expr)
		local predefs = table()
		return table.mapi(expr, function(x,i)
			local sx1, sx2 = self:wrapStrOfChildWithParenthesis(expr, i)
			predefs = table(predefs, sx2)
			return sx1
		end):concat(' '..expr:nameForExporter(self)..' '), predefs
	end,
	[require 'symmath.Variable'] = function(self, expr)
		return expr:nameForExporter(self)
	end,
	[require 'symmath.Derivative'] = function(self, expr) 
		error("can't compile differentiation.  replace() your diff'd content first!\n"
		..(require 'symmath.export.MultiLine')(expr))
	end,
	[require 'symmath.Integral'] = function(self, expr) 
		error("can't compile integration.  replace() your diff'd content first!\n"
		..(require 'symmath.export.MultiLine')(expr))
	end,
	[require 'symmath.Array'] = function(self, expr)
		local predefs = table()
		return '{'..table.mapi(expr, function(x, i)
			local sx1, sx2 = self:apply(x)
			predefs = table(predefs, sx2)
			return sx1
		end):concat', '..'}', predefs
	end,
}

C.generateParams = {
	localType = function(self) return self.numberType end,
	lineEnd = ';',
	
	funcHeaderStart = function(self, name, inputs)
		return 'void '..name..'('..self.numberType..'* out'
			..(#inputs > 0 and ', ' or '')
	end,
	funcArgType = function(self) return self.numberType end,
	funcHeaderEnd = ') {',
	prepareOutputs = function(outputs) 
		return 
			outputs:mapi(function(output,i)
				return '\tout['..(i-1)..'] = '..output.name..';'
			end):concat'\n'
	end,
	returnCode = function() end,
	funcFooter = '}',
}

return C()	-- singleton
