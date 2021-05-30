local class = require 'ext.class'
local table = require 'ext.table'
local Language = require 'symmath.export.Language'

local Mathematica = class(Language)

Mathematica.name = 'Mathematica'

Mathematica.lookupTable = table(Mathematica.lookupTable):union{
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
			-- TODO this is legacy stuff copied from export.Lua that was later half-replaced by the export.Language
			-- (though there is still a legitimate need for custom function exporting)
			-- so maybe get rid of it
			predefs['local '..funcName..' = '..expr.code] = true
		end
		return funcName .. '[' .. s .. ']', predefs
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
}:setmetatable(nil)

-- TODO get 'toFuncCode' working by providing these correctly
Mathematica.generateParams = {
	lineEnd = ';',
	funcHeader = function(name, inputs)
		return 
			(name or '')	-- TODO what is Mathematica lambda syntax?
			..'['..inputs:mapi(function(input)
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
