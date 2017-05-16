-- convert to Lua code.  use :compile to generate a function
local class = require 'ext.class'
local table = require 'ext.table'
local Language = require 'symmath.tostring.Language'
local Lua = class(Language)

Lua.lookupTable = {
	[require 'symmath.Constant'] = function(self, expr, vars)
		return {tostring(expr.value)}
	end,
	[require 'symmath.Invalid'] = function(self, expr, vars)
		return {'(0/0)'}
	end,
	[require 'symmath.Function'] = function(self, expr, vars)
		--[[
		TODO
		'math.' .. expr.name <- only works for builtin functions
		others have to be defined somewhere they can be compiled in ...
		that means we might have to return a state object which has the compile string as well as a list of other functions to be defined
		--]]
		local predefs = table()
		local s = table()
		for i,x in ipairs(expr) do
			local sx = self:apply(x, vars)
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
		return {funcName .. '(' .. s .. ')', predefs}
	end,
	[require 'symmath.op.unm'] = function(self, expr, vars)
		local sx = self:apply(expr[1], vars)
		return {'(-'..sx[1]..')', sx[2]}
	end,
	[require 'symmath.op.Binary'] = function(self, expr, vars)
		local predefs = table()
		local s = table()
		for i,x in ipairs(expr) do
			local sx = self:apply(x, vars)
			s:insert(sx[1])
			predefs = table(predefs, sx[2])
		end
		s = s:concat(' '..expr.name..' ')
		return {'('..s..')', predefs}
	end,
	[require 'symmath.op.pow'] = function(self, expr, vars)
		if expr[1] == require 'symmath'.e then
			local sx = self:apply(expr[2], vars)
			return {'math.exp(' .. sx[1] .. ')', sx[2]}
		else
			local predefs = table()
			local s = table()
			for i,x in ipairs(expr) do
				local sx = self:apply(x, vars)
				s:insert(sx[1])
				predefs = table(predefs, sx[2])
			end
			s = s:concat(' '..expr.name..' ')
			return {'('..s..')', predefs}
		end
	end,
	[require 'symmath.Variable'] = function(self, expr, vars)
		if table.find(vars, nil, function(var) 
			return expr.name == var.name 
		end) then
			return {expr.name}
		end
		error("tried to compile variable "..expr.name.." that wasn't in your function argument variable list!\n"
		..(require 'symmath.tostring.MultiLine')(expr))
	end,
	[require 'symmath.Derivative'] = function(self, expr) 
		error("can't compile differentiation.  replace() your diff'd content first!\n"
		..(require 'symmath.tostring.MultiLine')(expr))
	end,
	[require 'symmath.Array'] = function(self, expr, vars)
		local predefs = table()
		local s = table()
		for i,x in ipairs(expr) do
			local sx = self:apply(x,vars)
			s:insert(sx[1])
			predefs = table(predefs, sx[2])
		end
		s = s:concat(', ')
		return {'{'..s..'}', predefs}
	end,
}


-- TODO all other languages return the code from compile()
-- except Lua which returns function then code
-- it'd be nice to use compile() for functions and generate() for code
-- but that means putting prepareForCompile() in generate() as well

function Lua:generate(expr, vars)
	local info = self:apply(expr, vars)
	local body = info[1]
	local predefs = info[2]
	local code = predefs and table.keys(predefs):concat'\n'..'\n' or ''
	return code..'return function('..
		vars:map(function(var) return var.name end):concat(', ')
	..') return '..body..' end'
end

-- returns (1) the function and (2) the code
-- see Language:getCompileParameters for a description of paramInputs
function Lua:compile(expr, paramInputs)
	local expr, vars = self:prepareForCompile(expr, paramInputs)
	assert(vars)
	local cmd = self:generate(expr, vars)
	return assert(load(cmd))(), cmd
end

function Lua:__call(...)
	return self:apply(...)[1]
end

return Lua()	-- singleton
