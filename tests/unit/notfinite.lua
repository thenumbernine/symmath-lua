#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'tests/unit/notfinite')

timer(nil, function()

env.x = symmath.Variable('x')
env.y = symmath.Variable('y')

for _,line in ipairs(string.split(string.trim([=[

-- infinite.  
-- using https://en.wikipedia.org/wiki/Limit_of_a_function 
-- TODO should these be valid, or should they always produce 'invalid' 
-- and only Limit() produce valid operations on infinity?

simplifyAssertEq(inf, inf)
simplifyAssertNe(inf, -inf)
simplifyAssertNe(inf, invalid)

-- q + inf = inf for q != -inf
simplifyAssertEq(inf + inf, inf)
simplifyAssertEq(inf + 0, inf)
simplifyAssertEq(inf + 1, inf)
simplifyAssertEq(inf - 1, inf)
simplifyAssertEq(inf + x + y, inf)

-- q * inf = inf for q > 0 (incl q == inf)
-- q * inf = -inf for q < 0 (incl q == -inf)
simplifyAssertEq((inf * inf), inf)
simplifyAssertEq((inf * -inf), -inf)
simplifyAssertEq((inf * -1), -inf)
simplifyAssertEq((inf * -1 * -2), inf)
simplifyAssertEq((inf * 1 * 2), inf)
simplifyAssertEq(inf * x, inf)		-- TODO this should be unknown unless x is defined as a positive or negative real
simplifyAssertEq(inf / 2, inf)

-- 0 * inf = invalid
simplifyAssertEq(inf * 0, invalid)
simplifyAssertEq(inf / 0, invalid)

-- q / inf = 0 for q != inf and q != -inf
simplifyAssertEq(-2 / inf, 0)
simplifyAssertEq(-1 / inf, 0)
simplifyAssertEq(-.5 / inf, 0)
simplifyAssertEq(0 / inf, 0)
simplifyAssertEq(.5 / inf, 0)
simplifyAssertEq(1 / inf, 0)
simplifyAssertEq(2 / inf, 0)

-- inf^q = 0 for q < 0
-- inf^q = inf for q > 0
simplifyAssertEq(inf ^ -inf, invalid)
simplifyAssertEq(inf ^ -2, 0)
simplifyAssertEq(inf ^ -1, 0)
simplifyAssertEq(inf ^ -.5, 0)
simplifyAssertEq(inf ^ 0, invalid)
simplifyAssertEq(inf ^ .5, inf)
simplifyAssertEq(inf ^ 1, inf)
simplifyAssertEq(inf ^ 2, inf)
simplifyAssertEq(inf ^ inf, inf)

-- q^inf = 0 for 0 < q < 1
-- q^inf = inf for 1 < q
simplifyAssertEq((-2) ^ inf, invalid)
simplifyAssertEq((-.5) ^ inf, invalid)
simplifyAssertEq(0 ^ inf, invalid)
simplifyAssertEq(.5 ^ inf, 0)
simplifyAssertEq(2 ^ inf, inf)

-- q^-inf = inf for 0 < q < 1
-- q^-inf = 0 for 1 < q
simplifyAssertEq((-2) ^ -inf, invalid)
simplifyAssertEq((-.5) ^ -inf, invalid)
simplifyAssertEq(0 ^ -inf, invalid)
simplifyAssertEq(.5 ^ -inf, inf)
simplifyAssertEq(2 ^ -inf, 0)

-- indeterminant:
simplifyAssertEq(Constant(0) / 0, invalid)
simplifyAssertEq(-inf / inf, invalid)
simplifyAssertEq(inf / inf, invalid)
simplifyAssertEq(inf / -inf, invalid)
simplifyAssertEq(-inf / -inf, invalid)
simplifyAssertEq(0 * inf, invalid)
simplifyAssertEq(0 * -inf, invalid)
simplifyAssertEq(inf + -inf, invalid)
simplifyAssertEq(Constant(0) ^ 0, invalid)
simplifyAssertEq(inf ^ 0, invalid)
simplifyAssertEq((-1) ^ inf, invalid)
simplifyAssertEq((-1) ^ -inf, invalid)
simplifyAssertEq(1 ^ inf, invalid)
simplifyAssertEq(1 ^ -inf, invalid)

]=]), '\n')) do
	env.exec(line)
end

end)
