local class = require 'ext.class'
local table = require 'ext.table'
-- single-line strings 
local Console = require 'symmath.export.Console'
local SingleLine = class(Console)

local function precedence(x)
	return x.precedence or 10
end

function SingleLine:testWrapStrOfChildWithParenthesis(parentNode, childIndex)
	local div = require 'symmath.op.div'
	local childNode = parentNode[childIndex]
	local childPrecedence = precedence(childNode)
	local parentPrecedence = precedence(parentNode)
	if div.is(parentNode) then parentPrecedence = parentPrecedence + .5 end
	if div.is(childNode) then childPrecedence = childPrecedence + .5 end
	local sub = require 'symmath.op.sub'
	if sub.is(parentNode) and childIndex > 1 then
		return childPrecedence <= parentPrecedence
	else
		return childPrecedence < parentPrecedence
	end
end

SingleLine.lookupTable = {
	--[[
	[require 'symmath.Expression'] = function(self, expr)
		local s = table()
		for k,v in pairs(expr) do s:insert(rawtostring(k)..'='..rawtostring(v)) end
		return 'Expression{'..s:concat(', ')..'}'
	end,
	--]]
	[require 'symmath.Constant'] = function(self, expr) 
		local symmath = require 'symmath'
		local symbol = expr.symbol	
		if symbol then
			if symmath.fixVariableNames then
				symbol = symmath.tostring:fixVariableName(symbol)
			end
			return symbol
		end
		return tostring(expr.value) 
	end,
	[require 'symmath.Invalid'] = function(self, expr)
		return 'Invalid'
	end,
	[require 'symmath.Function'] = function(self, expr)
		return expr.name..'(' .. table.map(expr, function(x,k)
			if type(k) ~= 'number' then return end
			return self:apply(x)
		end):concat(', ') .. ')'
	end,
	[require 'symmath.op.unm'] = function(self, expr)
		return '-'..self:wrapStrOfChildWithParenthesis(expr, 1)
	end,
	[require 'symmath.op.Binary'] = function(self, expr)
		return table.map(expr, function(x,i)
			if type(i) ~= 'number' then return end
			return self:wrapStrOfChildWithParenthesis(expr, i)
		end):concat(expr:getSepStr())
	end,
	[require 'symmath.Variable'] = function(self, expr)
		local symmath = require 'symmath'
		local name = expr.name
		if symmath.fixVariableNames then
			name = symmath.tostring:fixVariableName(name)
		end
		local s = name
		--if expr.value then s = s .. '|' .. expr.value end
		return s
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
		local diffexpr = self:apply(assert(expr[1]))
		return topText..'/{'..table.map(powersForDeriv, function(power, name, newtable)
			local s = 'd'..name
			if power > 1 then
				s = s .. '^' .. power
			end
			return s, #newtable+1
		end):concat(' ')..'}['..diffexpr..']'
	end,
	[require 'symmath.Integral'] = function(self, expr)
		return 'integrate('..table.map(expr, tostring):concat(', ')..' )'
	end,
	[require 'symmath.Array'] = function(self, expr)
		return '[' .. table.map(expr, function(x,k)
			if type(k) ~= 'number' then return end
			return self:apply(x)
		end):concat(', ') .. ']'
	end,
	[require 'symmath.tensor.TensorIndex'] = function(self, expr)
		return expr:__tostring()
	end,
	[require 'symmath.tensor.TensorRef'] = function(self, expr)
		return table.mapi(expr, tostring):concat()
	end,
}

return SingleLine()		-- singleton
