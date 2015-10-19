local unmOp = require 'symmath.unmOp'
local addOp = require 'symmath.addOp'
local subOp = require 'symmath.subOp'
local mulOp = require 'symmath.mulOp'
local powOp = require 'symmath.powOp'
local Constant = require 'symmath.Constant'
local Visitor = require 'symmath.singleton.Visitor'

local Expand = class(Visitor)

Expand.lookupTable = {
	[unmOp] = function(expand, expr)
		return expand:apply(Constant(-1) * expr[1])
	end,
	
	[mulOp] = function(expand, expr)
		expr = expr:clone()
local original = expr:clone()
local symmath = require 'symmath'	
		
		--[[
		a * (b + c) * d * e becomes
		(a * b * d * e) + (a * c * d * e)
		--]]

		for i,x in ipairs(expr) do
			if x:isa(addOp) or x:isa(subOp) then
				local terms = table()
				for j,xch in ipairs(x) do
					local term = expr:clone()
					term[i] = xch:clone()
					terms:insert(term)
				end
				expr = getmetatable(x)(table.unpack(terms))
--print('mulOp a*(b+c) => a*b + a*c', symmath.Verbose(original), '=>', symmath.Verbose(expr))
				return expand:apply(expr)
			
				--[[
				local newSelf = getmetatable(x)(table.unpack(table.filter(expr, function(cx,k)
					if type(k) ~= 'number' then return end
					return cx ~= x
				end):map(function(cx)
					return mulOp(x:clone(), cx)
				end))
				--]]
				--[[
				local removedTerm = table.remove(newSelf, i)
				print('removed ',removedTerm)
				local newe = expand:apply(addOp(table.unpack(
					table.map(x, function(addX,k)
						if type(k) ~= 'number' then return end
						return mulOp(addX, table.unpack(newSelf))
					end)
				)))
				print('new expand',newe)
				return newe
				--]]
			end
		end
	
		--[[
		-- distribute: a * (m + n) => a * m + a * n
		-- I have the opposite rule in addOp:prune, commented out
		-- to combine them both ...
		-- (a * (b + c * (d + e)) => (a * b + a * c * d + a * c * e)
		-- how about my canonical form is div, mul-non-const, add, mul-const
		-- ... such that if we have an add, mul-non-const then we know to perform the addOp:prune() on it
		-- however trig laws would need add, mul-non-const to optimize out correctly
		for i,x in ipairs(expr) do
			if x:isa(addOp) then
				table.remove(expr, i)
			
				local result = addOp()
				for j,ch in ipairs(x) do
					result[j] = expr * ch
				end
				--result = prune(result)
				return result
			end
		end
		--]]

	end,

	[subOp] = function(expand, expr)
		return expand:apply(expr[1] + -addOp(table.unpack(expr, 2)))
	end,
}

return Expand

