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
	[Constant] = function(tidy, expr)
		-- -c => -(c)
		if expr.value < 0 then
			return tidy(unmOp(Constant(-expr.value)))
		end
	end,
	[unmOp] = function(tidy, expr)
		-- --x => x
		if expr.xs[1]:isa(unmOp) then
			return tidy(expr.xs[1].xs[1]:clone())
		end

		-- distribute through addition/subtraction
		if expr.xs[1]:isa(addOp) then
			return addOp(unpack(
				expr.xs[1].xs:map(function(x) return -x end)
			))
		end
	end,
	[mulOp] = function(tidy, expr)
		-- -x * y * z => -(x * y * z)
		-- -x * y * -z => x * y * z
		do
			local unmOpCount = 0
			for i=1,#expr.xs do
				local ch = expr.xs[i]
				if ch:isa(unmOp) then
					unmOpCount = unmOpCount + 1
					expr.xs[i] = ch.xs[1]
				end
			end
			if unmOpCount % 2 == 1 then
				return -tidy(expr)	-- move unm outside and simplify what's left
			elseif unmOpCount ~= 0 then
				return tidy(expr)	-- got an even number?  remove it and simplify this
			end
		end
		
		local first = expr.xs[1]
		if first:isa(Constant) then
			-- (has to be solved post-prune() because tidy's Constant+unmOp will have made some new ones)
			-- 1 * x => x 	
			if first.value == 1 then
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
		end
	end,
	[addOp] = function(tidy, expr)
		for i=1,#expr.xs-1 do
			-- x + -y => x - y
			if expr.xs[i+1]:isa(unmOp) then
				expr = expr:clone()
				local a = expr.xs:remove(i)
				local b = expr.xs:remove(i).xs[1]
				expr.xs:insert(i, a - b)
				return tidy(expr)
			end
		end
	end,
}

return Tidy()

