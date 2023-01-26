-- multi-line strings
-- TODO subclass SingleLine, rewrite the apply() to handle string results (implicitly wrap in {}, and viola. win.)
local class = require 'ext.class'
local table = require 'ext.table'
local range = require 'ext.range'
local SingleLine = require 'symmath.export.SingleLine'
local symmath

-- luajit can do fine with unicode strings within the .lua file
-- however what it can't do is compute their length in characters.
-- that's why I'm defaulting to non-unicode characters.

-- [3][2] of the border chars of a box
local box = {
	{'┌', '┐'},
	{'│', '│'},
	{'└', '┘'},
	{'[', ']'},
}
-- [3][2] of the border chars of parenthesis
local par = {
	{'╭', '╮'},
	{'│', '│'},
	{'╰', '╯'},
	{'(', ')'},
}
local line = {'╶', '─', '╴'}
local intname = {
	'⌠',
	'│',
	'⌡',
	'∫',
}
local downarrow = '↓'
local rightarrow = '→'


-- borp = box or par [4][2]
local function wrap(rows, n, borp)
	n = n or #rows
	if n == 1 then
		rows[1] = borp[4][1] .. rows[1] .. borp[4][2]
	else
		for i=1,n do
			if i == 1 then
				rows[i] = borp[1][1] .. rows[i] .. borp[1][2]
			elseif i == n then
				rows[i] = borp[3][1] .. rows[i] .. borp[3][2]
			else
				rows[i] = borp[2][1] .. rows[i] .. borp[2][2]
			end
		end
	end
end

local function vert(n)
	if n == 0 then return '' end
	if n == 1 then return '-' end
	return line[1]..line[2]:rep(n-2)..line[3]
end

local MultiLine = class(SingleLine.class)

MultiLine.name = 'MultiLine'

local strlen = MultiLine.strlen

--[[
produces:
  bbb
aabbb
aabbb

TODO alignment
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

	res:insert(vert(width+2))

	local bottomPadding = width - strlen(bottom[1]) + 1
	local bottomLeft = math.floor(bottomPadding/2)
	local bottomRight = bottomPadding - bottomLeft
	for i=1,#bottom do
		res:insert((' '):rep(bottomLeft+1)..bottom[i]..(' '):rep(bottomRight))
	end

	return res
end

function MultiLine:wrapStrOfChildWithParenthesis(parent, child)
	local res = self:apply(child)
	if self:testWrapStrOfChildWithParenthesis(parent, child) then
		wrap(res, nil, par)
	end
	return res
end

function MultiLine:matrixBody(parts)
	local matheight = #parts
	local matwidth = #parts[1]
	parts = table(parts)
	for i=1,#parts do
		parts[i] = table(parts[i])
	end

	local allparts = table():append(parts:unpack())

	local partwidths = range(matheight):mapi(function(i)
		return range(matwidth):mapi(function(j)
			return (table.mapi(parts[i][j], function(l) return strlen(l) end):sup())
		end)
	end)

	local widths = range(matwidth):mapi(function(j)
		return (range(matheight):mapi(function(i)
			return partwidths[i][j]
		end):sup() or 0)
	end)

	local heights = range(matheight):mapi(function(i)
		return (range(matwidth):mapi(function(j)
			return #parts[i][j]
		end):sup() or 0)
	end)

	local res = table()

	for i,partrow in ipairs(parts) do
		local row = range(heights[i]):mapi(function() return '' end)
		local sep = ''
		for j,part in ipairs(partrow) do
			local cell = table()
			local padding = widths[j] - partwidths[i][j]
			local leftWidth = padding - math.floor(padding/2)
			local rightWidth = padding - leftWidth
			local left = (' '):rep(leftWidth)
			local right = (' '):rep(rightWidth)
			for k=1,#part do
				part[k] = sep .. left .. part[k] .. right
			end
			row = self:combine(row, part)
			sep = '  '
		end
		if i > 1 then
			res:insert((' '):rep(strlen(res[1])))
		end
		res = res:append(row)
	end

	res:insert((' '):rep(strlen(res[1])))
	res:insert(1, (' '):rep(strlen(res[1])))

	return res

end

MultiLine.lookupTable = table(MultiLine.lookupTable):union{
	[require 'symmath.Function'] = function(self, expr)
		local name = expr:nameForExporter(self)
		--[[ single-par
		local res = {name..'('}
		res = self:combine(res, self:apply(expr[1]))
		--]]
		-- [[ tall par
		local res = self:apply(expr[1])
		--]]
		local sep = {', '}
		for i=2,#expr do
			res = self:combine(res, sep)
			res = self:combine(res, self:apply(expr[i]))
		end
		--[[ single-par
		res = self:combine(res, {')'})
		--]]
		-- [[ tall par
		wrap(res, nil, par)
		--]]
		res = self:combine({name}, res)
		return res
	end,
	[require 'symmath.abs'] = function(self, expr)
		local x = self:apply(expr[1])
		local bar = range(#x):mapi(function() return par[2][1] end)
		return self:combine(self:combine(bar, x), bar)
	end,
	[require 'symmath.op.unm'] = function(self, expr)
		local ch = self:wrapStrOfChildWithParenthesis(expr, expr[1])
		local sym = '-'
		if strlen(ch[1]) > 1 then sym = ' - ' end	-- so minus-fraction doesn't just blend the minus into the fraction
		return self:combine({sym}, ch)
	end,
	[require 'symmath.op.Binary'] = function(self, expr)
		local res = self:wrapStrOfChildWithParenthesis(expr, expr[1])
		local sep = {expr:getSepStr(self)}
		for i=2,#expr do
			res = self:combine(res, sep)
			res = self:combine(res, self:wrapStrOfChildWithParenthesis(expr, expr[i]))
		end
		return res
	end,
	[require 'symmath.op.add'] = function(self, expr)
		symmath = symmath or require 'symmath'
		local unm = symmath.op.unm
		local res = self:wrapStrOfChildWithParenthesis(expr, expr[1])
		local sep = {expr:getSepStr(self)}
		for i=2,#expr do
			if not unm:isa(expr[i]) then
				res = self:combine(res, sep)
			end
			res = self:combine(res, self:wrapStrOfChildWithParenthesis(expr, expr[i]))
		end
		return res
	end,
	[require 'symmath.op.div'] = function(self, expr)
		assert(#expr == 2)
		return self:fraction(self:apply(expr[1]), self:apply(expr[2]))
	end,
	[require 'symmath.op.pow'] = function(self, expr)
		if #expr ~= 2 then error("expected 2 children but found "..#expr.." in "..toLua(expr)) end
		local lhs = self:wrapStrOfChildWithParenthesis(expr, expr[1])
		local rhs = self:wrapStrOfChildWithParenthesis(expr, expr[2])
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
	[require 'symmath.Limit'] = function(self, expr)
		local f, x, a, side = table.unpack(expr)
		local astr = self:apply(a)
		if side.name and side.name ~= '' then
			astr = self:combine(astr, {side.name})
		end
		return self:combine(
			self:matrixBody{
				-- 1,1 block
				{
					{'lim'},
				},
				-- 1,2 block
				{
					self:combine(
						self:apply(x),
						self:combine(
							{'→'},
							astr
						)
					)
				}
			},
			self:combine(
				{' '},
				self:wrapStrOfChildWithParenthesis(expr, expr[1])
			)
		)
	end,
	[require 'symmath.Derivative'] = function(self, expr)
		local d = expr:nameForExporter(self)
		local topText = d
		local diffVars = table.sub(expr, 2)
		local diffPower = #diffVars
		if diffPower > 1 then
			topText = topText .. '^'..diffPower
		end

		topText = {topText}
		symmath = symmath or require 'symmath'
		local diffIsVar = symmath.Variable:isa(expr[1])
		if diffIsVar then
			local varText = self:apply(expr[1])
			if diffPower > 1 then
				varText = self:combine({' '}, varText)
			end
			topText = self:combine(topText, varText)
		end

		local powersForDeriv = {}
		for _,var in ipairs(diffVars) do
			-- TODO this will call SingleLine's var:nameForExporter
			-- so overrides specified for MultiLine will be ignored
			local varname = SingleLine(var)
			powersForDeriv[varname] = (powersForDeriv[varname] or 0) + 1
		end
		local text = self:fraction(
			topText,
			{
				table.keys(powersForDeriv):sort():mapi(function(name, i, newtable)
					local power = powersForDeriv[name]
					local s = d..name
					if power > 1 then
						s = s .. '^'..power
					end
					return s, #newtable+1
				end):concat' '
			})

		-- vars go on the top, exprs go to the right
		if not diffIsVar then
			local rhs = self:wrapStrOfChildWithParenthesis(expr, expr[1])
			text = self:combine(text, rhs)
		end
		return text
	end,
	[require 'symmath.Integral'] = function(self, expr)
		local s = self:apply(expr[1])

		local xL = expr[3]
		local xR = expr[4]

		local dx = self:combine({' d'}, self:apply(expr[2]))
		s = self:combine(s, dx)

		local n = math.max(2, #s)
		local sLR
		if xL and xR then
			sLR = table()
			local sL = xL and self:apply(xL) or nil
			local sR = xR and self:apply(xR) or nil
			if sL or sR then
				if sR then
					for _,l in ipairs(sR) do
						sLR:insert(l)
					end
				end
				for i=1,math.max(1, n - #sL - #sR) do
					sLR:insert''
				end
				if sL then
					for _,l in ipairs(sL) do
						sLR:insert(l)
					end
				end
			end
			local maxwidth = sLR:mapi(function(l) return strlen(l) end):sup()
			for i=1,#sLR do
				sLR[i] = sLR[i] .. (' '):rep(maxwidth-strlen(sLR[i]))
			end
			n = math.max(n, #sLR)
		end

		-- TODO n should be the max of either the inner height or the sL height + sR height + padding

		local intstr = {}
		for i=1,n do
			if i == 1 then
				intstr[i] = intname[1]
			elseif i == n then
				intstr[i] = intname[3]
			else
				intstr[i] = intname[2]
			end
		end
		if sLR then
			intstr = self:combine(intstr, sLR)
		end
		s = self:combine(self:combine(intstr, {' '}), s)

		return s
	end,
	[require 'symmath.Array'] = function(self, expr)
		local degree = expr:degree()

		if degree == 0 then return table() end

		-- even if it doesn't have a Matrix metatable, if it's degree-2 then display it as a matrix ...
		-- TODO just put Matrix's entry here and get rid of its empty, let its subclass fall through to here instead
		if degree % 2 == 0 then
			local strs = {}
			for i,row in ipairs(expr) do
				strs[i] = {}
				for j,cell in ipairs(row) do
					strs[i][j] = self:apply(expr[i][j])
				end
			end
			local res = self:matrixBody(strs)
			wrap(res, nil, box)
			return res
		else
			local strs = {}
			for i=1,#expr do
				strs[i] = {self:apply(expr[i])}
			end
			local res = self:matrixBody(strs)
			wrap(res, nil, box)
			return res
		end
	end,
	[require 'symmath.Tensor'] = function(self, expr)
		local s = self:applyForClass(require 'symmath.Tensor'.super, expr)
		local arrows = {downarrow, rightarrow}
		if #expr.variance > 0 then
			local prefix = ''
			for i=#expr.variance,1,-1 do
				local var = expr.variance[i]
				local arrowIndex = (#expr.variance + i + 1) % 2 + 1
				prefix = var..(i == 1 and arrows[1] or arrows[arrowIndex])..prefix
				if arrowIndex == 1 and i ~= 1 then prefix = '['..prefix..']' end
			end
			local pad = (' '):rep(math.floor(math.max(strlen(s[1]) - strlen(prefix), 0) / 2))
			prefix = pad .. prefix
			table.insert(s, 1, prefix)
			local l = table.mapi(s, function(l) return strlen(l) end):sup()
			for i=1,#s do
				s[i] = s[i] .. (' '):rep(l - strlen(s[i]))
			end
		end
		return s
	end,
	[require 'symmath.tensor.Index'] = function(self, expr)
		return {expr:__tostring()}
	end,
	[require 'symmath.tensor.Ref'] = function(self, expr)
		symmath = symmath or require 'symmath'
		local Array = symmath.Array
		local TensorRef = require 'symmath.tensor.Ref'
		local Variable = symmath.Variable

		local t = expr[1]
		local indexes = table.sub(expr,2)
		local separateVarianceSymbols
		local indexStrs = indexes:mapi(function(index)
			local s = self:apply(index)
			if strlen(s[1]:sub(2)) > 1 then
				separateVarianceSymbols = true
			end
			return s
		end)

		local s = self:apply(t)
		if not (Variable:isa(t) or Array:isa(t) or TensorRef:isa(t)) then
			s = self:combine(
				range(#s):mapi(function() return '(' end),
				self:combine(
					s,
					range(#s):mapi(function() return ')' end)
				)
			)
		end

		--[[ trusting the TensorIndex for proper generation
		for _,index in ipairs(indexes) do
			s = self:combine(s, self:apply(index))
		end
		--]]
		-- [[ compacting a few symbols
		local lastLower
		for i,index in ipairs(indexes) do
			local is = indexStrs[i]
			local lower = index.lower or false
			if not separateVarianceSymbols
			and i ~= 1
			and lower == lastLower
			then
				is[1] = is[1]:sub(2)
			end
			lastLower = lower
			-- TODO combine valign to top or bottom
			s = self:combine(s, is)
		end
		--]]

		return s
	end,
}:setmetatable(nil)

-- MultiLine passes around tables of strings, but sometimes falls back on SingleLine.
-- In that case just wrap it in {} so MultiLine:apply() will always return a table-of-strings
function MultiLine:apply(...)
	local result = table.pack(MultiLine.super.apply(self, ...))
	if type(result[1]) == 'string' then result[1] = table{result[1]} end
	return result:unpack()
end

-- while most Export.__call methods deal in strings,
--  MultiLine passes around an array of strings (per-newline)
-- so we recombine them into one string here at the end
function MultiLine:__call(...)
	local result = MultiLine.super.__call(self, ...)
	if type(result) == 'string' then return '\n'..result end
	return result:concat('\n')
end

return MultiLine()	-- singleton
