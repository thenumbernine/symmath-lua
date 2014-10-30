require 'ext'

local ToString = require 'symmath.tostring.ToString'
local SingleLine = require 'symmath.tostring.SingleLine'

-- multi-line strings
local MultiLine = class(ToString)

--[[
produces:
  bbb
aabbb
aabbb
--]]
function MultiLine:combine(lhs, rhs)
	if type(lhs) ~= 'table' then error("expected lhs to be table, found "..type(lhs)) end
	if type(rhs) ~= 'table' then error("expected rhs to be table, found "..type(rhs)) end
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
function MultiLine:fraction(lhs, rhs)
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

function MultiLine:wrapStrWithParenthesis(node, parentNode)
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
		res = self:combine(lhs, res)
		res = self:combine(res, rhs)
	end
	return res
end



MultiLine.lookupTable = {
	[require 'symmath.Constant'] = function(self, expr)
		return table{SingleLine(expr)}
	end,
	[require 'symmath.Invalid'] = function(self, expr)
		return table{SingleLine(expr)}
	end,
	[require 'symmath.Function'] = function(self, expr)
		local res = {expr.name..'('}
		res = self:combine(res, self:apply(expr.xs[1]))
		local sep = {', '}
		for i=2,#expr.xs do
			res = self:combine(res, sep)
			res = self:combine(res, self:apply(expr.xs[i]))
		end
		res = self:combine(res, {')'})
		return res
	end,
	[require 'symmath.unmOp'] = function(self, expr)
		return self:combine({'-'}, self:wrapStrWithParenthesis(expr.xs[1], expr))
	end,
	[require 'symmath.BinaryOp'] = function(self, expr)
		local res = self:wrapStrWithParenthesis(expr.xs[1], expr)
		local sep = {expr:getSepStr()}
		for i=2,#expr.xs do
			res = self:combine(res, sep)
			res = self:combine(res, self:wrapStrWithParenthesis(expr.xs[i], expr))
		end
		return res
	end,
	[require 'symmath.divOp'] = function(self, expr)
		assert(#expr.xs == 2)
		return self:fraction(self:apply(expr.xs[1]), self:apply(expr.xs[2]))
	end,
	[require 'symmath.powOp'] = function(self, expr)
		assert(#expr.xs == 2)
		local lhs = self:wrapStrWithParenthesis(expr.xs[1], expr)
		local rhs = self:wrapStrWithParenthesis(expr.xs[2], expr)
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
	[require 'symmath.Variable'] = function(self, expr)
		local s = expr.name
		if expr.value then s = s .. '|' .. expr.value end
		return table{s}
	end,
	[require 'symmath.Derivative'] = function(self, expr)
		assert(#expr.xs >= 2)
		local lhs = self:fraction({'d'}, {'d'..table{unpack(expr.xs, 2)}:map(function(x) return x.name end):concat()})
		local rhs = self:wrapStrWithParenthesis(expr.xs[1], expr)
		return self:combine(lhs, rhs)
	end,
}

-- while most ToString.__call methods deal in strings,
--  MultiLine passes around an array of strings (per-newline)
-- so we recombine them into one string here at the end
MultiLine.__call = function(self, ...) 
	local result = MultiLine.super.__call(self, ...)
	if type(result) == 'string' then return '\n'..result end 
	return '\n' ..result:concat('\n')
end

return MultiLine()

