local class = require 'ext.class'
local table = require 'ext.table'
local Language = require 'symmath.export.Language'

local Mathematica = class(Language)

Mathematica.name = 'Mathematica'

Mathematica.lookupTable = {
	[require 'symmath.Constant'] = function(self, expr)
		return {tostring(expr.value)}
	end,
	[require 'symmath.Invalid'] = function(self, expr)
		return {'(0/0)'}
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
			local sx = self:apply(x)
			s:insert(sx[1])
			predefs = table(predefs, sx[2])
		end
		s = s:concat(', ')
		
		local funcName
		if not expr.code then
			funcName = 'math.'..expr.name
		else
			funcName = expr.name
			predefs['local '..funcName..' = '..expr.code] = true
		end
		return {funcName .. '[' .. s .. ']', predefs}
	end,
	[require 'symmath.op.unm'] = function(self, expr)
		local sx = self:apply(expr[1])
		return {'(-'..sx[1]..')', sx[2]}
	end,
	[require 'symmath.op.Binary'] = function(self, expr)
		local predefs = table()
		local s = table()
		for i,x in ipairs(expr) do
			local sx = self:apply(x)
			s:insert(sx[1])
			predefs = table(predefs, sx[2])
		end
		s = s:concat(' '..expr.name..' ')
		return {'('..s..')', predefs}
	end,
	[require 'symmath.op.pow'] = function(self, expr)
		if expr[1] == require 'symmath'.e then
			local sx = self:apply(expr[2])
			return {'exp[' .. sx[1] .. ']', sx[2]}
		else
			local predefs = table()
			local s = table()
			for i,x in ipairs(expr) do
				local sx = self:apply(x)
				s:insert(sx[1])
				predefs = table(predefs, sx[2])
			end
			s = s:concat(' '..expr.name..' ')
			return {'('..s..')', predefs}
		end
	end,
	[require 'symmath.Variable'] = function(self, expr)
		return {expr.name}
	end,
	[require 'symmath.Derivative'] = function(self, expr) 
		error("can't compile differentiation.  replace() your diff'd content first!\n"
		..(require 'symmath.export.MultiLine')(expr))
	end,
	[require 'symmath.Array'] = function(self, expr)
		local predefs = table()
		local s = table()
		for i,x in ipairs(expr) do
			local sx = self:apply(x)
			s:insert(sx[1])
			predefs = table(predefs, sx[2])
		end
		s = s:concat(', ')
		return {'{'..s..'}', predefs}
	end,
}

function Mathematica:compile(expr, paramInputs)
	local expr, vars = self:prepareForCompile(expr, paramInputs)
	local result = self:apply(expr)
	return result
end

function Mathematica:__call(...)
	return self:apply(...)[1]
end

return Mathematica()	-- singleton
