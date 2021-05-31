#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'limit')

timer(nil, function()

env.a = symmath.Variable('a')
env.b = symmath.Variable('b')
env.g = symmath.Variable('g')
env.s = symmath.Variable('s')
env.t = symmath.Variable('t')
env.v = symmath.Variable('v')
env.x = symmath.Variable('x')
env.y = symmath.Variable('y')

-- constant simplificaiton
for _,line in ipairs(string.split(string.trim([=[

asserteq(lim(x, x, a), a)
asserteq(lim(x, x, a, '+'), a)
asserteq(lim(x, x, a, '-'), a)

-- constants
asserteq(lim(0, x, a), 0)
asserteq(lim(1, x, a), 1)

-- ops
asserteq(lim(x + 2, x, a), a + 2)
asserteq(lim(x + x, x, a), 2 * a)
asserteq(lim(x + a, x, a), 2 * a)
asserteq(lim(a + a, x, a), 2 * a)
asserteq(lim(x * 2, x, a), 2 * a)
asserteq(lim(x / 2, x, a), a / 2)

-- involving infinity
asserteq(lim(x, x, inf), inf)
asserteq(lim(x, x, -inf), -inf)
asserteq(lim(x, x, inf), inf)
asserteq(lim(1/x, x, inf), 0)
asserteq(lim(1/x, x, -inf), 0)
asserteq(lim(1/x, x, 0), invalid)

asserteq(lim(1/x, x, 0, '+'), inf)
asserteq(lim(1/x, x, 0, '-'), -inf)

asserteq(lim(1/x^2, x, 0, '+'), inf)
asserteq(lim(1/x^2, x, 0, '-'), inf)

-- sqrts
asserteq(lim(sqrt(x), x, 0), invalid)
asserteq(lim(sqrt(x), x, 0, '-'), invalid)
asserteq(lim(sqrt(x), x, 0, '+'), 0)
-- in each form ...
asserteq(lim(x^frac(1,2), x, 0), invalid)
asserteq(lim(x^frac(1,2), x, 0, '-'), invalid)
asserteq(lim(x^frac(1,2), x, 0, '+'), 0)
-- and one more power up ...
asserteq(lim(x^frac(1,4), x, 0), invalid)
asserteq(lim(x^frac(1,4), x, 0, '-'), invalid)
asserteq(lim(x^frac(1,4), x, 0, '+'), 0)


-- functions
--
-- TODO all of these are only good for 'a' in Real, not necessarily extended-Real, because I don't distinguish them
--
-- another thing to consider ... most these are set up so that the limit is the same as the evaluation without a limit
-- technically this is not true.  technically atan(inf) is not pi/2 but is instead undefined outside of the limit.
-- should I enforce this?
asserteq(lim(sin(x), x, a), sin(a))
asserteq(lim(sin(x), x, inf), invalid)
asserteq(lim(sin(x), x, -inf), invalid)

asserteq(lim(cos(x), x, a), cos(a))
asserteq(lim(cos(x), x, inf), invalid)
asserteq(lim(cos(x), x, -inf), invalid)

asserteq(lim(abs(x), x, a), abs(a))
asserteq(lim(abs(x), x, -inf), inf)
asserteq(lim(abs(x), x, inf), inf)

asserteq(lim(exp(x), x, a), exp(a))
asserteq(lim(exp(x), x, -inf), 0)
asserteq(lim(exp(x), x, inf), inf)

asserteq(lim(atan(x), x, a), atan(a))
asserteq(lim(atan(x), x, -inf), -pi/2)
asserteq(lim(atan(x), x, inf), pi/2)

asserteq(lim(tanh(x), x, a), tanh(a))
asserteq(lim(tanh(x), x, -inf), -1)
asserteq(lim(tanh(x), x, inf), 1)

asserteq(lim(asinh(x), x, a), asinh(a))
asserteq(lim(asinh(x), x, -inf), -inf)
asserteq(lim(asinh(x), x, inf), inf)

asserteq(lim(cosh(x), x, a), cosh(a))
asserteq(lim(cosh(x), x, -inf), inf)
asserteq(lim(cosh(x), x, inf), inf)

asserteq(lim(sinh(x), x, a), sinh(a))
asserteq(lim(sinh(x), x, -inf), -inf)
asserteq(lim(sinh(x), x, inf), inf)

asserteq(lim(sin(x), x, a), sin(a))
asserteq(lim(sin(x), x, -inf), invalid)
asserteq(lim(sin(x), x, inf), invalid)

asserteq(lim(cos(x), x, a), cos(a))
asserteq(lim(cos(x), x, -inf), invalid)
asserteq(lim(cos(x), x, inf), invalid)

asserteq(lim(tan(x), x, a), tan(a))
asserteq(lim(tan(x), x, -inf), invalid)
asserteq(lim(tan(x), x, -3*pi/2), invalid)
asserteq(lim(tan(x), x, -pi), tan(-pi))
asserteq(lim(tan(x), x, -pi/2), invalid)
asserteq(lim(tan(x), x, 0), tan(0))
asserteq(lim(tan(x), x, pi/2), invalid)
asserteq(lim(tan(x), x, pi/2, '+'), -inf)
asserteq(lim(tan(x), x, pi/2, '-'), inf)
asserteq(lim(tan(x), x, pi), tan(pi))
asserteq(lim(tan(x), x, 3*pi/2), invalid)
asserteq(lim(tan(x), x, inf), invalid)

asserteq(lim(log(x), x, a), log(a))
asserteq(lim(log(x), x, -inf), invalid)
asserteq(lim(log(x), x, 0), invalid)
asserteq(lim(log(x), x, 0, '+'), -inf)
asserteq(lim(log(x), x, inf), inf)

asserteq(lim(acosh(x), x, a), acosh(a))
asserteq(lim(acosh(x), x, -inf), invalid)
asserteq(lim(acosh(x), x, 1), invalid)
asserteq(lim(acosh(x), x, 1, '+'), 0)
asserteq(lim(acosh(x), x, inf), inf)

asserteq(lim(atanh(x), x, a), atanh(a))
asserteq(lim(atanh(x), x, -inf), invalid)
asserteq(lim(atanh(x), x, -1), invalid)
asserteq(lim(atanh(x), x, -1, '+'), -inf)
asserteq(lim(atanh(x), x, 0), 0)
asserteq(lim(atanh(x), x, 1), invalid)
asserteq(lim(atanh(x), x, 1, '-'), inf)
asserteq(lim(atanh(x), x, inf), invalid)

asserteq(lim(asin(x), x, a), asin(a))
asserteq(lim(asin(x), x, -inf), invalid)
asserteq(lim(asin(x), x, -1), invalid)
asserteq(lim(asin(x), x, -1, '+'), -inf)
asserteq(lim(asin(x), x, 0), 0)
asserteq(lim(asin(x), x, 1), invalid)
asserteq(lim(asin(x), x, 1, '-'), inf)
asserteq(lim(asin(x), x, inf), invalid)

asserteq(lim(acos(x), x, a), acos(a))
asserteq(lim(acos(x), x, -inf), invalid)
asserteq(lim(acos(x), x, -1), invalid)
asserteq(lim(acos(x), x, -1, '+'), inf)
asserteq(lim(acos(x), x, 0), pi/2)
asserteq(lim(acos(x), x, 1), invalid)
asserteq(lim(acos(x), x, 1, '-'), -inf)
asserteq(lim(acos(x), x, inf), invalid)

asserteq(lim(Heaviside(x), x, a), Heaviside(a))
asserteq(lim(Heaviside(x), x, -inf), 0)
asserteq(lim(Heaviside(x), x, -1), 0)
asserteq(lim(Heaviside(x), x, 0), invalid)
asserteq(lim(Heaviside(x), x, 0, '-'), 0)
asserteq(lim(Heaviside(x), x, 0, '+'), 1)
asserteq(lim(Heaviside(x), x, 1), 1)
asserteq(lim(Heaviside(x), x, inf), 1)

-- products of functions
asserteq(lim(x * sin(x), x, a), a * sin(a))

-- polynomial roots ... this is going to be tough


]=]), '\n')) do
	env.exec(line)
end

end)
