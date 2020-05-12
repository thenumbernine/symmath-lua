-- convert to Lua code.  use :compile to generate a function
local class = require 'ext.class'
local table = require 'ext.table'
local Language = require 'symmath.export.Language'


local Lua = class(Language)

Lua.name = 'Lua'

Lua.lookupTable = {
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
	
		-- if the Function has .code then use that
		-- put it before the actual function definition at the end
		local funcName
		if not expr.code then
			funcName = 'math.'..expr.name
		-- otherwise just use the function name
		else
			funcName = expr.name
			predefs['local '..funcName..' = '..expr.code] = true
		end
		
		if expr.name == 'cbrt' then
			return {'('..s..') ^ (1/3)', predefs}
		else
			return {funcName .. '(' .. s .. ')', predefs}
		end
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
		local symmath = require 'symmath'
		if expr[1] == symmath.e then
			local sx = self:apply(expr[2])
			return {'math.exp(' .. sx[1] .. ')', sx[2]}
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


--[[
TODO all other languages return the code from compile()
except Lua which returns function then code
it'd be nice to use compile() for functions and generate() for code
but that means putting prepareForCompile() in generate() as well
--]]


function Lua:generate(expr, vars)

	expr = expr:clone()

	local symmath = require 'symmath'
	local Expression = symmath.Expression
	local SingleLine = symmath.export.SingleLine
	local Variable = symmath.Variable
	local Constant = symmath.Constant

-- [=[ replace x^n for integer 1 <= n < 100 with (x * x * ... * ) x n
	-- represent integers as expanded multiplication
	expr = expr:map(function(x)
		if symmath.op.pow.is(x) then
			if Constant.is(x[2]) then
				local n = x[2].value
				if n == math.floor(n) and n >= 0 and n < 100 then
					if n == 0 then return Constant(1) end
					if n == 1 then return x end
					return setmetatable(table.rep({x[1]}, n), symmath.op.mul)
				end
			end
		end
	end)
--]=]

-- [=[
	local allsubexprinfos = table()	
	local function recurse(expr)
		local totalCount = 1
		for _,x in ipairs(expr) do
			if Expression.is(x) 
			and not Constant.is(x)
			then
				local count = recurse(x)
				totalCount = totalCount + count
				if count > 1 then
					allsubexprinfos:insert{expr=x, count=count}
				end
			else
				totalCount = totalCount + 1
			end
		end
		return totalCount
	end
	recurse(expr)

	-- sort by size, largest to smallest
	allsubexprinfos:sort(function(a,b)
		return a.count > b.count
	end)
	-- remove duplicates
	for i=#allsubexprinfos-1,1,-1 do
		if allsubexprinfos[i].expr == allsubexprinfos[i+1].expr then
			allsubexprinfos:remove(i)
		end
	end

--[[
print('FOR EXPR '..SingleLine(expr))
print'BEGIN ALL SUBEXPRS'
for _,s in ipairs(allsubexprinfos) do
	print(s.count, SingleLine(s.expr))
end
print'END ALL SUBEXPRS'
print()
--]]

	local varindex = 0
	-- TODO assert that this variable name doesn't exist in the expression
	local function newvarname()
		varindex = varindex + 1
		return 'tmp'..varindex
	end
	local tmpvardefs = table()
	for _,subexprinfo in ipairs(allsubexprinfos) do
		local subexpr = subexprinfo.expr
--[[
print('CHECKING SUBEXPR '..SingleLine(subexpr))
--]]
		-- first see how many occurences there are
		-- only replace the sub-expression if there are more than 1 occurrences of it
		local found
		local count = 0
		local function recurse(expr)
			for i=1,#expr do
				local x = expr[i]
				if Expression.is(x)
				and not Constant.is(x)
				then
					if x == subexpr then
						count = count + 1
						if count >= 2 then 
							found = true
							return
						end
					end
					recurse(x)
					if found then return end
				end
			end
		end
		for j=1,#tmpvardefs do
			recurse(tmpvardefs[j][2])
		end
		recurse(expr)

		if found then
			local tmpvar
			local function recurse(expr)
				for i=1,#expr do
					local x = expr[i]
					if Expression.is(x) 
					and not Constant.is(x)
					then
						if x == subexpr then
							if not tmpvar then
								tmpvar = Variable(newvarname())
								local tmpvardef = tmpvar:eq(subexpr)
--[[
print('REPLACING TMPVAR DEF '..SingleLine(tmpvardef))								
--]]
								tmpvardefs:insert(tmpvardef)
							end
							expr[i] = tmpvar
						end
						recurse(x)
					end
				end
			end
			for j=1,#tmpvardefs do
				recurse(tmpvardefs[j][2])
			end
			recurse(expr)
		end
	end
--[[
print('RESULTING EXPR '..SingleLine(expr))
--]]
--]=]

	local info = self:apply(expr, vars)
	local body = info[1]
	local predefs = info[2]
	
	local lines = table()

	-- TODO keep track of what vars are used, and compare it to the vars in the compile, to ensure correct code is generated.
	lines:insert('return function('..vars:map(function(var) return var.name end):concat(', ')..')')
-- [=[
	if predefs then
		lines:append(table.keys(predefs))
	end
	for i=#tmpvardefs,1,-1 do
		local tmpvardef = tmpvardefs[i]
		local subname,subexpr = table.unpack(tmpvardef)
		lines:insert('\tlocal '..subname.name..' = '..self:apply(subexpr)[1])
	end
--]=]
	lines:insert('\treturn '..body)
	lines:insert('end')
	return lines:concat'\n'
end

-- returns (1) the function and (2) the code
-- see Language:getCompileParameters for a description of paramInputs
function Lua:compile(expr, paramInputs)
	local expr, vars = self:prepareForCompile(expr, paramInputs)
	assert(vars)
	local cmd = self:generate(expr, vars)
	local result, err = load(cmd)
	if not result then return false, cmd, err end
	result = result()
	return result, cmd
end

-- hmm, using a direct call isn't favorable over using :compile()
function Lua:__call(...)
	return self:apply(...)[1]
end

return Lua()	-- singleton
