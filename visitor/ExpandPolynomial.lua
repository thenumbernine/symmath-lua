--[[
I've got Expand working with simplify() well (I think it's essential to the trig simplification)
-- and it works well without the power expansion

However I want power expansion for calculating polynomial coefficients
So I'm going to make this a separate expand for now ...

simplify() shouldn't need to expand powers of polys itself -- unless those powers are sum'd themselves (which means the Visitor needs to see the stack, or each node needs to see its parent)
--]]
local class = require 'ext.class'
local Expand = require 'symmath.visitor.Expand'

local ExpandPolynomial = class(Expand)
ExpandPolynomial.name = 'ExpandPolynomial'

-- copy inherited visitor lookup table (so we don't modify the parent's)
ExpandPolynomial.lookupTable = setmetatable(table(ExpandPolynomial.lookupTable, {

-- with this, polyCoeffs works
-- without this, equations look a whole lot cleaner during simplificaton
-- (and dividing polys works a bit better)
-- until factor() works, simplify() works better without this enabled ... but polyCoeffs() doesn't ... 
-- [[
	[require 'symmath.powOp'] = function(expand, expr)
		local clone = require 'symmath.clone'
		local Constant = require 'symmath.Constant'
		expr = clone(expr)
--local original = clone(expr)
		local maxPowerExpand = 10
		if expr[2]:isa(Constant) then
			local value = expr[2].value
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
--print('powOp a^0 => 1', require 'symmath.tostring.Verbose'(original), '=>', require 'symmath.tostring.Verbose'(Constant(1)))
					return Constant(1)
				end
				local terms = table()
				for i=1,num do
					terms:insert(expr[1]:clone())
				end
				if frac ~= 0 then
					terms:insert(expr[1]:clone()^frac)
				end
			
				assert(#terms > 0)
				
				if #terms == 1 then
					expr = terms[1]
				else
					local mulOp = require 'symmath.mulOp'
					expr = mulOp(terms:unpack())
				end
				
				if div then expr = 1/expr end
				
				return expand:apply(expr)
			end
		end
	end,
--]]

}), nil)

return ExpandPolynomial

