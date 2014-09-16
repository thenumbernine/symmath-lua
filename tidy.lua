--[[
post-simplify change from canonical form to make the equation look more presentable 
--]]
local unmOp = require 'symmath.unmOp'
local addOp = require 'symmath.addOp'
local mulOp = require 'symmath.mulOp'
local Constant = require 'symmath.Constant'
local Visitor = require 'symmath.Visitor'
local Tidy = class(Visitor)

Tidy.lookupTable = {
	-- -x => -(x)
	[Constant] = function(tidy, expr)
		if expr.value < 0 then
			return tidy(unmOp(Constant(-expr.value)))
		end
	end,
	[unmOp] = function(tidy, expr)
		-- --x => x
		if expr.xs[1]:isa(unmOp) then
			return tidy(expr.xs[1].xs[1]:clone())
		end
	end,
	[mulOp] = function(tidy, expr)
		local first = expr.xs[1]
		if first == Constant(1) 
		or first == -Constant(1)
		then
			expr = expr:clone()
			expr.xs:remove(1)
			local result
			if #expr.xs == 1 then
				result = expr.xs[1]
			else
				result = expr
			end
			if first == -Constant(1) then
				return -expr
			else
				return expr
			end
		end
	end,
	[addOp] = function(tidy, expr)
		for i=1,#expr.xs-1 do
			-- x + -y => x - y
			if expr.xs[i+1]:isa(unmOp) then
				expr = expr:clone()
				local a = expr.xs:remove(i)
				local b = expr.xs[i].xs[1]
				expr.xs[i] = a - b
				return tidy(expr)
			end
		end
	end,
}

return Tidy()

