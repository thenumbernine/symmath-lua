local table = require 'ext.table'
local Language = require 'symmath.export.Language'


local C = Language:subclass()

C.name = 'C'

--[[
This is really being used for OpenCL
--]]

function C:wrapStrOfChildWithParenthesis(parent, child, ...)
	local s, predef = self:apply(child, ...)
	if not s then return false end
	if self:testWrapStrOfChildWithParenthesis(parent, child) then
		s = self.parOpenSymbol .. s .. self.parCloseSymbol
	end
	return s, predef
end

C.numberType = 'double'

C.constantPeriodRequired = true

C.lookupTable = table(C.lookupTable):union{
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
	[require 'symmath.Heaviside'] = function(self, expr)
		local xs = self:apply(expr[1])
		return '('..xs..' >= 0 ? 1 : 0)'
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
				local result1, result2 = self:apply(symmath.op.mul(table.rep({expr[1]}, expr[2].value):unpack()))
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
}:setmetatable(nil)

C.generateParams = {
	localType = function(self) return self.numberType end,
	lineEnd = ';',

	funcHeaderStart = function(self, name, inputs)
		-- technically this is straying into C++ realm...
		local prefix = name and ('void '..name) or '[]'

		return prefix..'('..self.numberType..'* out'
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
