module('symmath', package.seeall)

require 'symmath'	-- needed for symmath classes for lookup table

-- base class
ToStringMethod = class()

function ToStringMethod:apply(expr, ...)
	if type(expr) ~= 'table' then return tostring(expr) end
	local lookup = expr.class
	if not lookup then return tostring(expr) end
	-- traverse class parentwise til a key in the lookup table is found
	while not self.lookupTable[lookup] do
		lookup = lookup.super
	end
	if not lookup then
		return tostring(expr)
	else
		return (self.lookupTable[lookup])(self, expr, ...)
	end
end

function ToStringMethod:testWrapStrWithParenthesis(node, parentNode)
	return precedence(node) < precedence(parentNode)
end


-- single-line strings 

ToSingleLineString = class(ToStringMethod)

function ToSingleLineString:wrapStrWithParenthesis(node, parentNode)
	local s = ToSingleLineString(node)
	if self:testWrapStrWithParenthesis(node, parentNode) then
		s = '(' .. s .. ')'
	end
	return s
end

ToSingleLineString.lookupTable = {
	[Constant] = function(self, expr) 
		return tostring(expr.value) 
	end,
	[Invalid] = function(self, expr)
		return 'Invalid'
	end,
	[Function] = function(self, expr)
		return expr.name..'(' .. expr.xs:map(function(x) return self:apply(x) end):concat(', ') .. ')'
	end,
	[unmOp] = function(self, expr)
		return '-'..self:wrapStrWithParenthesis(expr.xs[1], expr)
	end,
	[BinaryOp] = function(self, expr)
		return expr.xs:map(function(x) 
			return self:wrapStrWithParenthesis(x, expr)
		end):concat(expr:getSepStr())
	end,
	[Variable] = function(self, expr)
		local s = expr.name
		if expr.value then
			s = s .. '|' .. expr.value
		end
		return s
	end,
	[Derivative] = function(self, expr) 
		local diffvar = self:apply(assert(expr.xs[1]))
		return 'd/d{'..table{unpack(expr.xs, 2)}:map(function(x) return self:apply(x) end):concat(',')..'}['..diffvar..']'
	end
}

--singleton -- no instance creation
getmetatable(ToSingleLineString).__call = function(self, ...) 
	return self:apply(...) 
end


-- multi-line strings
ToMultiLineString = class(ToStringMethod)

--[[
produces:
  bbb
aabbb
aabbb
--]]
function ToMultiLineString:multiLinesCombine(lhs, rhs)
	local res = table()
	local sides = {lhs, rhs}
	local maxheight = math.max(#lhs, #rhs)
	for i=1,maxheight do
		local line = ''
		for _,side in ipairs(sides) do
			local sideIndex = i - math.ceil((maxheight - #side) / 2)
			if sideIndex >= 1 and sideIndex <= #side then
				line = line .. side[sideIndex]
			else
				line = line .. (' '):rep(#side[1])
			end
		end
		res:insert(line)
	end
	return res
end

--[[
produces:
 a
---
 b
--]]
function ToMultiLineString:multiLinesFraction(lhs, rhs)
	local res = table()
	local width = math.max(#lhs[1], #rhs[1])
	for i=1,#lhs do
		res:insert(' '..lhs[i]..(' '):rep(width-#lhs[1]+1))
	end
	res:insert(('-'):rep(width+2))
	for i=1,#rhs do
		res:insert(' '..rhs[i]..(' '):rep(width-#rhs[1]+1))
	end
	return res
end

function ToMultiLineString:multiLinesWrapStrWithParenthesis(node, parentNode)
	local res = self:apply(node)
	if self:testWrapStrWithParenthesis(node, parentNode) then
		local height = #res
		local lhs = {}
		local rhs = {}
		if height < 3 then
			lhs[1] = '('
			rhs[1] = ')'
		else
			lhs[1] = ' /'
			rhs[1] = '\\ '
			for i=2,height-1 do
				lhs[i] = '| '
				rhs[i] = ' |'
			end
			lhs[height] = ' \\'
			rhs[height] = '/ '
		end
		res = self:multiLinesCombine(lhs, res)
		res = self:multiLinesCombine(res, rhs)
	end
	return res
end



ToMultiLineString.lookupTable = {
	[Constant] = function(self, expr)
		return table{ToSingleLineString(expr)}
	end,
	[Invalid] = function(self, expr)
		return table{ToSingleLineString(expr)}
	end,
	[Function] = function(self, expr)
		local res = {expr.name..'('}
		res = self:multiLinesCombine(res, self:apply(expr.xs[1]))
		local sep = {', '}
		for i=2,#expr.xs do
			res = self:multiLinesCombine(res, sep)
			res = self:multiLinesCombine(res, self:apply(expr.xs[i]))
		end
		res = self:multiLinesCombine(res, {')'})
		return res
	end,
	[unmOp] = function(self, expr)
		return self:multiLinesCombine({'-'}, self:multiLinesWrapStrWithParenthesis(expr.xs[1], expr))
	end,
	[BinaryOp] = function(self, expr)
		local res = self:multiLinesWrapStrWithParenthesis(expr.xs[1], expr)
		local sep = {expr:getSepStr()}
		for i=2,#expr.xs do
			res = self:multiLinesCombine(res, sep)
			res = self:multiLinesCombine(res, self:multiLinesWrapStrWithParenthesis(expr.xs[i], expr))
		end
		return res
	end,
	[divOp] = function(self, expr)
		assert(#expr.xs == 2)
		return self:multiLinesFraction(self:apply(expr.xs[1]), self:apply(expr.xs[2]))
	end,
	[powOp] = function(self, expr)
		assert(#expr.xs == 2)
		local lhs = self:multiLinesWrapStrWithParenthesis(expr.xs[1], expr)
		local rhs = self:multiLinesWrapStrWithParenthesis(expr.xs[2], expr)
		local lhswidth = #lhs[1]
		local rhswidth = #rhs[1]
		local res = table()
		for i=1,#rhs do
			res:insert((' '):rep(lhswidth)..rhs[i])
		end
		for i=1,#lhs do
			res:insert(lhs[i]..(' '):rep(rhswidth))
		end
		return res
	end,
	[Variable] = function(self, expr)
		local s = expr.name
		if expr.value then s = s .. '|' .. expr.value end
		return table{s}
	end,
	[Derivative] = function(self, expr)
		assert(#expr.xs >= 2)
		local lhs = self:multiLinesFraction({'d'}, {'d'..table{unpack(expr.xs, 2)}:map(function(x) return x.name end):concat()})
		local rhs = self:multiLinesWrapStrWithParenthesis(expr.xs[1], expr)
		return self:multiLinesCombine(lhs, rhs)
	end,
}

-- while most :apply methods deal in strings,
--  ToMultiLineString:apply passes around an array of strings (per-newline)
-- so we recombine them into one string here at the end
getmetatable(ToMultiLineString).__call = function(self, ...) 
	local result = self:apply(...)
	if type(result) == 'string' then return '\n'..result end 
	return '\n' ..result:concat('\n')
end


-- convert to Lua code.  use :compile to generate a function
ToLuaCode = class(ToStringMethod)

ToLuaCode.lookupTable = {
	[Constant] = function(self, expr, vars)
		return tostring(expr.value) 
	end,
	[Invalid] = function(self, expr, vars)
		return '(0/0)'
	end,
	[Function] = function(self, expr, vars)
		return 'math.' .. expr.name .. '(' .. expr.xs:map(function(x) return self:apply(x, vars) end):concat(',') .. ')'
	end,
	[unmOp] = function(self, expr, vars)
		return '(-'..self:apply(expr.xs[1], vars)..')'
	end,
	[BinaryOp] = function(self, expr, vars)
		return '('..expr.xs:map(function(x) return self:apply(x, vars) end):concat(' '..expr.name..' ')..')'
	end,
	[Variable] = function(self, expr, vars)
		if table.find(vars, nil, function(var) return expr.name == var.name end) then
			return expr.name
		end
		error("tried to compile variable "..expr.name.." that wasn't in your function argument variable list")
	end,
	[Derivative] = function(self, expr) 
		error("can't compile differentiation.  replace() your diff'd content first!")
	end
}

function ToLuaCode:compile(expr, vars)
	local cmd = 'return function('..
		table.map(vars, function(var) return var.name end):concat(', ')
	..') return '..
		self:apply(expr, vars)
	..' end'
	return assert(loadstring(cmd))(), cmd
end

--singleton -- no instance creation
getmetatable(ToLuaCode).__call = function(self, ...) 
	return self:apply(...) 
end


-- convert to JavaScript code.  use :compile to wrap in a function
ToJavaScriptCode = class(ToStringMethod)

ToJavaScriptCode.lookupTable = {
	[Constant] = function(self, expr, vars)
		return tostring(expr.value) 
	end,
	[Invalid] = function(self, expr, vars)
		return '(0/0)'
	end,
	[Function] = function(self, expr, vars)
		return 'Math.' .. expr.name .. '(' .. expr.xs:map(function(x) return self:apply(x, vars) end):concat(',') .. ')'
	end,
	[unmOp] = function(self, expr, vars)
		return '(-'..self:apply(expr.xs[1], vars)..')'
	end,
	[BinaryOp] = function(self, expr, vars)
		return '('..expr.xs:map(function(x) return self:apply(x, vars) end):concat(' '..expr.name..' ')..')'
	end,
	[powOp] = function(self, expr, vars)
		-- special case for constant integer powers
		if expr.xs[2]:isa(Constant) then
			-- sqrt hack
			if expr.xs[2].value == .5 then
				return 'Math.sqrt(' .. self:apply(expr.xs[1], vars) .. ')'
			-- integer-power hack
			elseif expr.xs[2].value > 0 and expr.xs[2].value == math.floor(expr.xs[2].value) then
				-- TODO declare beforehand as a variable
				local code = '(' .. self:apply(expr.xs[1], vars) .. ')'
				local reps = table()
				for i=1,expr.xs[2].value do
					reps:insert(code)
				end
				return '(' .. reps:concat(' * ') .. ')'
			end
		end
		return 'Math.pow(' .. expr.xs:map(function(x) return self:apply(x, vars) end):concat(',')..')'
	end,
	[Variable] = function(self, expr, vars)
		if table.find(vars, nil, function(var) return expr.name == var.name end) then
			return expr.name
		end
		error("tried to compile variable "..expr.name.." that wasn't in your function argument variable list")
	end,
	[Derivative] = function(self, expr) 
		error("can't compile differentiation.  replace() your diff'd content first!")
	end
}

-- returns code that can be eval()'d to return a function
function ToJavaScriptCode:compile(expr, vars)
	local cmd = 'function tmp('..
		table.map(vars, function(var) return var.name end):concat(', ')
	..') return '..
		self:apply(expr, vars)
	..'}; tmp;'
	return cmd
end

--singleton -- no instance creation
getmetatable(ToJavaScriptCode).__call = function(self, ...) 
	return self:apply(...) 
end





-- change the default as you see fit
toStringMethod = ToMultiLineString

