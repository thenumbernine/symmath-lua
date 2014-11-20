local unmOp = require 'symmath.unmOp'
local addOp = require 'symmath.addOp'
local subOp = require 'symmath.subOp'
local mulOp = require 'symmath.mulOp'
local powOp = require 'symmath.powOp'
local Constant = require 'symmath.Constant'
local Visitor = require 'symmath.Visitor'

local Expand = class(Visitor)

Expand.lookupTable = {
	[unmOp] = function(expand, expr)
		return expand(Constant(-1) * expr.xs[1])
	end,
	
	[mulOp] = function(expand, expr)
		expr = expr:clone()
local original = expr:clone()
local symmath = require 'symmath'	
		
		--[[
		a * (b + c) * d * e becomes
		(a * b * d * e) + (a * c * d * e)
		--]]

		for i,x in ipairs(expr.xs) do
			if x:isa(addOp) or x:isa(subOp) then
				local terms = table()
				for j,xch in ipairs(x.xs) do
					local term = expr:clone()
					term.xs[i] = xch:clone()
					terms:insert(term)
				end
				expr = getmetatable(x)(unpack(terms))
--print('mulOp a*(b+c) => a*b + a*c', symmath.Verbose(original), '=>', symmath.Verbose(expr))
				return expand(expr)
			
				--[[
				local newSelf = getmetatable(x)(unpack(expr.xs:filter(function(cx) 
					return cx ~= x
				end):map(function(cx)
					return mulOp(x:clone(), cx)
				end))
				--]]
				--[[
				local removedTerm = newSelf.xs:remove(i)
				print('removed ',removedTerm)
				local newe = expand(addOp(unpack(
					x.xs:map(function(addX)
						return mulOp(addX, unpack(newSelf))
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
		for i,x in ipairs(expr.xs) do
			if x:isa(addOp) then
				expr.xs:remove(i)
			
				local result = addOp()
				for j,ch in ipairs(x.xs) do
					result.xs[j] = expr * ch
				end
				--result = prune(result)
				return result
			end
		end
		--]]

	end,

--[[
	[powOp] = function(expand, expr)
		expr = expr:clone()
local original = expr:clone()
local symmath = require 'symmath'	
		local maxPowerExpand = 10
		if expr.xs[2]:isa(Constant) then
			local value = expr.xs[2].value
			local absValue = math.abs(value)
			if absValue < maxPowerExpand then
				local num, frac, div
				if value < 0 then
					div = true
					frac = math.ceil(value) - value
					num = -math.ceil(value)
				elseif value > 0 then
					frac = value - math.floor(value)
					num = math.floor(value)
				else
--print('powOp a^0 => 1', symmath.Verbose(original), '=>', symmath.Verbose(Constant(1)))
					return Constant(1)
				end
				local terms = table()
				for i=1,num do
					terms:insert(expr.xs[1]:clone())
				end
				if frac ~= 0 then
					terms:insert(expr.xs[1]:clone()^frac)
				end
				if div then
					expr = Constant(1)/mulOp(unpack(terms))
--print('powOp a^-c => 1/(a*a*a...)', symmath.Verbose(original), '=>', symmath.Verbose(expr))
					return expr
				else
					expr = mulOp(unpack(terms))
--print('powOp a^c => a*a*a...', symmath.Verbose(original), '=>', symmath.Verbose(expr))
					return expr
				end
			end
		end
	end,
--]]
}

return Expand()

