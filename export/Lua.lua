local class = require 'ext.class'
local table = require 'ext.table'
local Language = require 'symmath.export.Language'

local symmath

local Lua = class(Language)

Lua.name = 'Lua'

Lua.lookupTable = table(Lua.lookupTable):union{
	[require 'symmath.Function'] = function(self, expr)
		symmath = symmath or require 'symmath'
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
	
		-- if the Function has .code then use that
		-- put it before the actual function definition at the end
		local funcName
		if not expr.code then
			funcName = 'math.'..expr:nameForExporter(self)
		-- otherwise just use the function name
		else
			funcName = expr:nameForExporter(self)
			predefs['local '..funcName..' = '..expr.code] = true
		end
		
		if expr:nameForExporter(self) == 'cbrt' then
			-- shouldn't this be done somewhere else?
			-- either in cbrt or in tidy() but probably in cbrt() somewhere
			--return '('..s..') ^ (1/3)', predefs
			return self:apply(expr[1] ^ symmath.frac(1,3))
		else
			return funcName .. '(' .. s .. ')', predefs
		end
	end,
	[require 'symmath.Heaviside'] = function(self, expr)
		local xs = self:apply(expr[1])
		return '(('..xs..' >= 0) and 1 or 0)'
	end,
	[require 'symmath.op.pow'] = function(self, expr)
		symmath = symmath or require 'symmath'
		if expr[1] == symmath.e then
			local sx1, sx2 = self:apply(expr[2])
			return 'math.exp(' .. sx1 .. ')', sx2
		else
			local predefs = table()
			local s = table()
			for i,x in ipairs(expr) do
				local sx1, sx2 = self:wrapStrOfChildWithParenthesis(expr, expr[i])
				s:insert(sx1)
				predefs = table(predefs, sx2)
			end
			s = s:concat(' '..expr:nameForExporter(self)..' ')
			return s, predefs
		end
	end,
}:setmetatable(nil)

Lua.generateParams = {
	localType = 'local',

	funcHeaderStart = function(self, name, inputs)
		return 'function'..(name and (' '..name) or '')..'('
	end,
	funcHeaderEnd = ')',
	funcFooter = 'end',
}

-- returns (1) the function and (2) the code
-- see Language:getCompileParameters for a description of paramInputs
function Lua:toFunc(args)
	args = table(args)
	args.func = ''	-- toFunc returns a function object, this can't have a name, if you want it global then assign it once you get it
	local code = 'return '..self:toFuncCode(args)
	local result, err = load(code)
	if not result then return false, code, err end
	result = result()
	return result, code
end

return Lua()	-- singleton
