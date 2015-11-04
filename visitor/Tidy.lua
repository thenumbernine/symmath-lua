--[[
post-simplify change from canonical form to make the equation look more presentable 
--]]
local class = require 'ext.class'
local unmOp = require 'symmath.unmOp'
local addOp = require 'symmath.addOp'
local divOp = require 'symmath.divOp'
local mulOp = require 'symmath.mulOp'
local powOp = require 'symmath.powOp'
local Constant = require 'symmath.Constant'
local Visitor = require 'symmath.visitor.Visitor'

local Tidy = class(Visitor)
Tidy.name = 'Tidy'

Tidy.lookupTable = {
	[Constant] = function(tidy, expr)
		-- for formatting's sake ...
		if expr.value == 0 then	-- which could possibly be -0 ...
			return Constant(0)
		end
		-- -c => -(c)
		if expr.value < 0 then
			return tidy:apply(unmOp(Constant(-expr.value)))
		end
	end,
	
	[unmOp] = function(tidy, expr)
		-- --x => x
		if expr[1]:isa(unmOp) then
			return tidy:apply(expr[1][1])
		end
		
		-- distribute through addition/subtraction
		if expr[1]:isa(addOp) then
			return addOp(
				table.map(expr[1], function(x,k) 
					if type(k) ~= 'number' then return end
					return -x 
				end):unpack()
			)
		end
	end,
	
	[addOp] = function(tidy, expr)
		for i=1,#expr-1 do
			-- x + -y => x - y
			if expr[i+1]:isa(unmOp) then
				local a = table.remove(expr, i)
				local b = table.remove(expr, i)[1]
				assert(a)
				assert(b)
				table.insert(expr, i, a - b)
				
				assert(#expr > 0)
				if #expr == 1 then
					expr = expr[1]
				end
				assert(#expr > 1)
				return tidy:apply(expr)
			end
		end
	end,
	
	[mulOp] = function(tidy, expr)
		-- -x * y * z => -(x * y * z)
		-- -x * y * -z => x * y * z
		do
			local unmOpCount = 0
			for i=1,#expr do
				local ch = expr[i]
				if ch:isa(unmOp) then
					unmOpCount = unmOpCount + 1
					expr[i] = ch[1]
				end
			end
			assert(#expr > 1)
			if unmOpCount % 2 == 1 then
				return -tidy:apply(expr)	-- move unm outside and simplify what's left
			elseif unmOpCount ~= 0 then
				return tidy:apply(expr)	-- got an even number?  remove it and simplify this
			end
		end
		
		-- (has to be solved post-prune() because tidy's Constant+unmOp will have made some new ones)
		-- 1 * x => x 	
		local first = expr[1]
		if first:isa(Constant) and first.value == 1 then
			table.remove(expr, 1)
			if #expr == 1 then
				expr = expr[1]
			end
			return tidy:apply(expr)
		end
	end,
	
	[divOp] = function(tidy, expr)
		local a, b = table.unpack(expr)
		local ua = a:isa(unmOp)
		local ub = b:isa(unmOp)
		if ua and ub then return tidy:apply(a[1] / b[1]) end
		if ua and a[1]:isa(Constant) then return tidy:apply(-(a[1] / b)) end
		if ub and b[1]:isa(Constant) then return tidy:apply(-(a / b[1])) end
	end,
	
	[powOp] = function(tidy, expr)
		-- [[ x^-a => 1/x^a ... TODO only do this when in a product?
		if expr[2]:isa(unmOp) then
			return tidy:apply(Constant(1)/expr[1]^expr[2][1])
		end
		--]]
		
		if expr[2] == Constant(.5)
		or expr[2] == Constant(1)/Constant(2)
		then
			return require 'symmath.sqrt'(expr[1])
		end
	end,
}

return Tidy
