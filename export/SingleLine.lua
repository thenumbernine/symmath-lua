local table = require 'ext.table'
-- single-line strings
local Console = require 'symmath.export.Console'
local symmath


local SingleLine = Console:subclass()

SingleLine.name = 'SingleLine'

local strlen = SingleLine.strlen

local function precedence(x)
	return x.precedence or 10
end

function SingleLine:testWrapStrOfChildWithParenthesis(parent, child)
	symmath = symmath or require 'symmath'
	local div = symmath.op.div
	local childPrecedence = precedence(child)
	local parentPrecedence = precedence(parent)
	if div:isa(parent) then parentPrecedence = parentPrecedence + .5 end
	if div:isa(child) then childPrecedence = childPrecedence + .5 end
	--[[ hmm, can't do this if I'm using parent/child objects
	-- which I'm using because I've turned the sub's into add+unm's
	-- so maybe I won't need it?
	local sub = require 'symmath.op.sub'
	if sub:isa(parent) and childIndex > 1 then
		return childPrecedence <= parentPrecedence
	else
		return childPrecedence < parentPrecedence
	end
	--]]
	-- [[
	return childPrecedence < parentPrecedence
	--]]
end

SingleLine.lookupTable = table(SingleLine.lookupTable):union{
	--[[
	[require 'symmath.Expression'] = function(self, expr)
		local s = table()
		for k,v in pairs(expr) do s:insert(rawtostring(k)..'='..rawtostring(v)) end
		return 'Expression{'..s:concat(', ')..'}'
	end,
	--]]

	[require 'symmath.Function'] = function(self, expr)
		local name = expr:nameForExporter(self)
		return name..'(' .. table.mapi(expr, function(x)
			return (self:apply(x))
		end):concat(', ') .. ')'
	end,
	[require 'symmath.abs'] = function(self, expr)
		return '|'..self:apply(expr[1])..'|'
	end,
	[require 'symmath.op.unm'] = function(self, expr)
		return '-'..self:wrapStrOfChildWithParenthesis(expr, expr[1])
	end,
	[require 'symmath.op.Binary'] = function(self, expr)
		return table.mapi(expr, function(x,i)
			return self:wrapStrOfChildWithParenthesis(expr, expr[i])
		end):concat(expr:getSepStr(self))
	end,
	[require 'symmath.op.add'] = function(self, expr)
		symmath = symmath or require 'symmath'
		local unm = symmath.op.unm
		local res = table()
		for i=1,#expr do
			local ei = expr[i]
			if i > 1
			and not unm:isa(ei)	-- if it's a - then just let the - do the talking
			then
				res:insert(expr:getSepStr(self))
				res:insert(self:wrapStrOfChildWithParenthesis(expr, expr[i]))
			else
				-- if we are an unm and beyond the 1st entry then space out the - sign
				if i > 1 and unm:isa(ei) then
					res:insert' - '
					res:insert(self:wrapStrOfChildWithParenthesis(expr, expr[i][1]))
				else
					res:insert(self:wrapStrOfChildWithParenthesis(expr, expr[i]))
				end
			end
		end
		return res:concat()
	end,
	[require 'symmath.factorial'] = function(self, expr)
		return self:apply(expr[1])..'!'
	end,
	[require 'symmath.Wildcard'] = function(self, expr)
		return '$'..expr.index
	end,
	[require 'symmath.Limit'] = function(self, expr)
		local f, x, a, side = table.unpack(expr)
		side = side.name or ''
		return 'lim_'..self:apply(x)..'→'..self:apply(a)..side..' '..self:apply(f)
	end,
	[require 'symmath.Derivative'] = function(self, expr)
		symmath = symmath or require 'symmath'
		local d = expr:nameForExporter(self)
		local topText = d
		local diffVars = table.sub(expr, 2)
		local diffPower = #diffVars
		if diffPower > 1 then
			topText = topText .. '^'..diffPower
		end
		local powersForDeriv = {}

		-- used to look the var back up for calling nameForExporter
		-- this means multiple Variable objects with separate nameForExporterTable's will have undefined behavior
		-- good thing Variable:clone() returns the original var
		local varForName = diffVars:mapi(function(var) return var, var.name end)

		for _,var in ipairs(diffVars) do
			-- don't fix name -- since var.name is used for variable equality
			powersForDeriv[var.name] = (powersForDeriv[var.name] or 0) + 1
		end
		local diffexpr = self:apply(assert(expr[1]))
		return topText..'/{'..
			table.keys(powersForDeriv):sort():mapi(function(name, i, newtable)
				local power = powersForDeriv[name]

				-- get the var for this name
				local var = varForName[name]

				-- get the var's name for this exporter
				name = var:nameForExporter(self)

				local s = d..name
				if power > 1 then
					s = s .. '^' .. power
				end
				return s, #newtable+1
			end):concat(' ')..'}['..diffexpr..']'
	end,
	[require 'symmath.Integral'] = function(self, expr)
		return '∫('..table.mapi(expr, function(x)
			return (self:apply(x))
		end):concat', '..' )'
	end,
	[require 'symmath.Array'] = function(self, expr)
		return '[' .. table.mapi(expr, function(x)
			return (self:apply(x))
		end):concat', ' .. ']'
	end,
	[require 'symmath.tensor.Index'] = function(self, expr)
		return expr:__tostring()
	end,
	[require 'symmath.tensor.Ref'] = function(self, expr)

		local indexes = table.sub(expr,2)
		local separateVarianceSymbols
		local indexStrs = indexes:mapi(function(index)
			local s = self:apply(index)
			if strlen(s:sub(2)) > 1 then
				separateVarianceSymbols = true
			end
			return s
		end)

		local s = self:apply(expr[1])
		local lastLower
		for i,index in ipairs(indexes) do
			local is = indexStrs[i]
			local lower = index.lower or false
			if not separateVarianceSymbols
			and i ~= 1
			and lower == lastLower
			then
				is = is:sub(2)
			end
			lastLower = lower
			s = s .. is
		end
		return s
	end,
}:setmetatable(nil)

return SingleLine()		-- singleton
