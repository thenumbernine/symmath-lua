--[[
I've got Expand working with simplify() well (I think it's essential to the trig simplification)
-- and it works well without the power expansion

However I want power expansion for calculating polynomial coefficients
So I'm going to make this a separate expand for now ...

simplify() shouldn't need to expand powers of polys itself -- unless those powers are sum'd themselves (which means the Visitor needs to see the stack, or each node needs to see its parent)

NOTICE now that I've switched from visitor.lookupTable[getmetatable(expr)] to expr.rules[visitor.name]
all exprs' Expand entries should be ExpandPolynomial's as well
--]]
local Expand = require 'symmath.visitor.Expand'
local ExpandPolynomial = Expand:subclass()
ExpandPolynomial.name = 'ExpandPolynomial'
return ExpandPolynomial
