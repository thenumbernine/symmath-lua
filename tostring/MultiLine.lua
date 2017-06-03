-- multi-line strings
local class = require 'ext.class'
local table = require 'ext.table'
local range = require 'ext.range'
local Console = require 'symmath.tostring.Console'
local SingleLine = require 'symmath.tostring.SingleLine'

local strlen
do
	local has, utf8 = pcall(require, 'utf8')
	if has then
		strlen = utf8.len
	elseif rawlen then
		strlen = rawlen
	else
		strlen = function(s) return #s end
	end
end

local MultiLine = class(Console)

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
				line = line .. (' '):rep(strlen(side[1]))
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
function MultiLine:fraction(top, bottom)
	local res = table()
	local width = math.max(strlen(top[1]), strlen(bottom[1]))
	
	local topPadding = width - strlen(top[1]) + 1
	local topLeft = math.floor(topPadding/2)
	local topRight = topPadding - topLeft
	for i=1,#top do
		res:insert((' '):rep(topLeft+1)..top[i]..(' '):rep(topRight))
	end
	
	res:insert(('-'):rep(width+2))
	
	local bottomPadding = width - strlen(bottom[1]) + 1
	local bottomLeft = math.floor(bottomPadding/2)
	local bottomRight = bottomPadding - bottomLeft
	for i=1,#bottom do
		res:insert((' '):rep(bottomLeft+1)..bottom[i]..(' '):rep(bottomRight))
	end
	
	return res
end

function MultiLine:wrapStrOfChildWithParenthesis(parentNode, childIndex)
	local node = parentNode[childIndex]
	local res = self:apply(node)
	if self:testWrapStrOfChildWithParenthesis(parentNode, childIndex) then
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
		res = self:combine(res, self:apply(expr[1]))
		local sep = {', '}
		for i=2,#expr do
			res = self:combine(res, sep)
			res = self:combine(res, self:apply(expr[i]))
		end
		res = self:combine(res, {')'})
		return res
	end,
	[require 'symmath.op.unm'] = function(self, expr)
		local ch = self:wrapStrOfChildWithParenthesis(expr, 1)
		local sym = '-'
		if strlen(ch) > 1 then sym = '- ' end	-- so minus-fraction doesn't just blend the minus into the fraction
		return self:combine({sym}, ch)
	end,
	[require 'symmath.op.Binary'] = function(self, expr)
		local res = self:wrapStrOfChildWithParenthesis(expr, 1)
		local sep = {expr:getSepStr()}
		for i=2,#expr do
			res = self:combine(res, sep)
			res = self:combine(res, self:wrapStrOfChildWithParenthesis(expr, i))
		end
		return res
	end,
	[require 'symmath.op.div'] = function(self, expr)
		assert(#expr == 2)
		return self:fraction(self:apply(expr[1]), self:apply(expr[2]))
	end,
	[require 'symmath.op.pow'] = function(self, expr)
		if #expr ~= 2 then error("expected 2 children but found "..#expr.." in "..toLua(expr)) end
		local lhs = self:wrapStrOfChildWithParenthesis(expr, 1)
		local rhs = self:wrapStrOfChildWithParenthesis(expr, 2)
		local lhswidth = strlen(lhs[1])
		local rhswidth = strlen(rhs[1])
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
		--if expr.value then s = s .. '|' .. expr.value end
		return table{s}
	end,
	[require 'symmath.Derivative'] = function(self, expr)
		local topText = 'd'
		local diffVars = table.sub(expr, 2)
		local diffPower = #diffVars
		if diffPower > 1 then
			topText = topText .. '^'..diffPower
		end
		local powersForDeriv = {}
		for _,var in ipairs(diffVars) do
			powersForDeriv[var.name] = (powersForDeriv[var.name] or 0) + 1
		end
		local lhs = self:fraction(
			{topText},
			{table.map(powersForDeriv, function(power, name, newtable) 
				local s = 'd'..name
				if power > 1 then
					s = s .. '^'..power
				end
				return s, #newtable+1
			end):concat(' ')})
		local rhs = self:wrapStrOfChildWithParenthesis(expr, 1)
		return self:combine(lhs, rhs)
	end,
	[require 'symmath.Integral'] = function(self, expr)
		local s = self:combine({'integrate('}, self:apply(expr[1]))
		for i=2,#expr do
			s = self:combine(s, {', '})
			s = self:combine(s, self:apply(expr[i]))
		end
		s = self:combine(s, {')'})
		return s
	end,
	[require 'symmath.Array'] = function(self, expr)
		local rank = expr:rank()
		
		if rank == 0 then return table() end
		
		-- even if it doesn't have a Matrix metatable, if it's rank-2 then display it as a matrix ...
		-- TODO just put Matrix's entry here and get rid of its empty, let its subclass fall through to here instead
		if rank == 2 then

			local parts = table()
			for i=1,#expr do
				parts[i] = table()
				for j=1,#expr[1] do
					parts[i][j] = self:apply(expr[i][j])
				end
			end

			local allparts = table():append(parts:unpack())
		
			local width = allparts:map(function(part)
				return strlen(part[1]) 
			end):sup() or 0
			
			local height = allparts:map(function(part)
				return #part
			end):sup() or 0
			
			local res = table()

			for i,partrow in ipairs(parts) do
				local row = range(height):map(function() return '' end)
				local sep = ''
				for j,part in ipairs(partrow) do
					local cell = table()
					local padding = width - strlen(part[1])
					local leftWidth = padding - math.floor(padding/2)
					local rightWidth = padding - leftWidth
					local left = (' '):rep(leftWidth)
					local right = (' '):rep(rightWidth)
					for k=1,#part do
						part[k] = sep .. left .. part[k] .. right
					end
					row = self:combine(row, part)
					sep = ' '
				end
				res = res:append(row)
			end
		
			for i=1,#res do
				res[i] = '['..res[i]..']'
			end

			return res
		else
			local parts = table()
			for i=1,#expr do
				parts[i] = self:apply(expr[i])
			end
			
			local height = parts:map(function(part) 
				return #part
			end):sup() or 0
			
			local sep = table()
			for i=1,height do
				sep[i] = ' '
			end
			
			local res = parts[1]
			for i=2,#parts do
				res = self:combine(res, sep)
				res = self:combine(res, parts[i])
			end
			
			for i=1,height do
				res[i] = '['..res[i]..']'
			end
			
			return res
		end
	end,
	[require 'symmath.tensor.TensorIndex'] = function(self, expr)
		return {expr:__tostring()}
	end,
	[require 'symmath.tensor.TensorRef'] = function(self, expr)
		local t = expr[1]
		local indexes = {table.unpack(expr, 2)}

		local s = self:apply(t)
		for _,index in ipairs(indexes) do
			s = self:combine(s, self:apply(index))
		end
		
		return s
	end,
}

-- while most ToString.__call methods deal in strings,
--  MultiLine passes around an array of strings (per-newline)
-- so we recombine them into one string here at the end
function MultiLine:__call(...) 
	local result = MultiLine.super.__call(self, ...)
	if type(result) == 'string' then return '\n'..result end 
	return result:concat('\n')
end

return MultiLine()	-- singleton
