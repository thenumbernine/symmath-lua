local class = require 'ext.class'
local table = require 'ext.table'
local Language = require 'symmath.export.Language'

local Mathematica = class(Language)

Mathematica.name = 'Mathematica'

Mathematica.lookupTable = {
	[require 'symmath.Constant'] = function(self, expr)
		return tostring(expr.value)
	end,
	[require 'symmath.Invalid'] = function(self, expr)
		return '(0/0)'
	end,
	[require 'symmath.Function'] = function(self, expr)
		--[[
		TODO
		'math.' .. expr.name <- only works for builtin functions
		others have to be defined somewhere they can be compiled in ...
		that means we might have to return a state object which has the compile string as well as a list of other functions to be defined
		--]]
		local predefs = table()
		local s = table()
		for i,x in ipairs(expr) do
			local sx1, sx2 = self:apply(x)
			s:insert(sx1)
			predefs = table(predefs, sx2)
		end
		s = s:concat', '
		
		local funcName
		if not expr.code then
			funcName = expr:nameForExporter(self)
		else
			funcName = expr:nameForExporter(self)
			predefs['local '..funcName..' = '..expr.code] = true
		end
		return funcName .. '[' .. s .. ']', predefs
	end,
	[require 'symmath.op.unm'] = function(self, expr)
		local sx1, sx2 = self:apply(expr[1])
		return '(-'..sx1..')', sx2
	end,
	[require 'symmath.op.Binary'] = function(self, expr)
		local predefs = table()
		local s = table()
		for i,x in ipairs(expr) do
			local sx1, sx2 = self:apply(x)
			s:insert(sx1)
			predefs = table(predefs, sx2)
		end
		s = s:concat(' '..expr:nameForExporter(self)..' ')
		return '('..s..')', predefs
	end,
	[require 'symmath.op.pow'] = function(self, expr)
		if expr[1] == require 'symmath'.e then
			local sx1, sx2 = self:apply(expr[2])
			return 'exp[' .. sx1 .. ']', sx2
		else
			local predefs = table()
			local s = table()
			for i,x in ipairs(expr) do
				local sx1, sx2 = self:apply(x)
				s:insert(sx1)
				predefs = table(predefs, sx2)
			end
			s = s:concat(' '..expr:nameForExporter(self)..' ')
			return '('..s..')', predefs
		end
	end,
	[require 'symmath.Variable'] = function(self, expr)
		return expr:nameForExporter(self)
	end,
	[require 'symmath.Derivative'] = function(self, expr) 
		error("can't compile differentiation.  replace() your diff'd content first!\n"
		..(require 'symmath.export.MultiLine')(expr))
	end,
	[require 'symmath.Array'] = function(self, expr)
		local predefs = table()
		local s = table()
		for i,x in ipairs(expr) do
			local sx1, sx2 = self:apply(x)
			s:insert(sx1)
			predefs = table(predefs, sx2)
		end
		s = s:concat', '
		return '{'..s..'}', predefs
	end,
}

-- TODO get 'toFuncCode' working by providing these correctly
Mathematica.generateParams = {
	lineEnd = ';',
	funcHeader = function(name, inputs)
		return name..'['..inputs:mapi(function(input)
			return input.name..'_'
		end):concat', '..'] :='
	end,
	returnCode = function(outputs)
		return '\t'
			..(#outputs > 1 and '[' or '')
			..outputs:mapi(function(output) 
				return output.name 
			end):concat', '
			..(#outputs > 1 and ']' or '')
			..';'
	end,
}

return Mathematica()	-- singleton
