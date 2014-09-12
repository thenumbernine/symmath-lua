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
	[mulOp] = function(tidy, expr)
		-- --x => x
		if expr.xs[1]:isa(unmOp) then
			return tidy(expr.xs[1].xs[1]:clone())
		end
		--  -1 * x => -x
		if expr.xs[1] == Constant(-1) then
			expr = expr:clone()
			expr.xs:remove(1)
			if #expr.xs == 1 then expr = expr.xs[1] end
			return tidy(-expr)
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
			-- x + -z * y => x - z * y
			if expr.xs[i+1]:isa(mulOp)
			and expr.xs[i+1].xs[1]:isa(Constant)
			and expr.xs[i+1].xs[1].value < 0
			then
				expr = expr:clone()
				local a = expr.xs:remove(i)
				local b = expr.xs[i]
				b.xs[1] = Constant(-b.xs[1].value)
				expr.xs[i] = a - b
				return tidy(expr)
			end
		end
	end,
}

return Tidy()

