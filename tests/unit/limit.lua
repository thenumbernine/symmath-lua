#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'limit')

timer(nil, function()

env.a = symmath.Variable('a')
env.b = symmath.Variable('b')
env.c = symmath.Variable('c')
env.g = symmath.Variable('g')
env.h = symmath.Variable('h')
env.s = symmath.Variable('s')
env.t = symmath.Variable('t')
env.v = symmath.Variable('v')
env.x = symmath.Variable('x')
env.y = symmath.Variable('y')

function env.difftest(expr)
	local f = func('f', {x}, expr)
	local diffexpr = f(x):diff(x)
	local diffexpreval = diffexpr:prune()
	local limexpr = ((f(x + h) - f(x)) / h):lim(h, 0, '+')
	local limexpreval = limexpr:prune()
	printbr(f:defeq())
	printbr('limit:', limexpr:eq(limexpreval))
	printbr('derivative:', diffexpr:eq(diffexpreval))
	asserteq(limexpreval, diffexpreval)
end

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

do local a = set.positiveReal:var'a' asserteq(lim(log(x), x, a), log(a)) end	-- if the input is within the domain of the function then we can evaluate it for certain
do local a = set.negativeReal:var'a' asserteq(lim(log(x), x, a), invalid) end	-- if the input is outside the domain of the function then we know the result is invalid. TODO is this the same as indeterminate?  Or should I introduce a new singleton?
do local a = set.real:var'a' print(lim(log(x), x, a):prune()) assert(lim(log(x), x, a):prune() == lim(log(x), x, a)) end	-- if the input covers both the domain and its complement, and we can't determine the limit evaluation, then don't touch the expression
asserteq(lim(log(x), x, -inf), invalid)
asserteq(lim(log(x), x, 0), invalid)
asserteq(lim(log(x), x, 0, '+'), -inf)
asserteq(lim(log(x), x, inf), inf)

do local a = set.RealSubset(-1, 1, false, false):var'a' asserteq(lim(acosh(x), x, a), acosh(a)) end
do local a = set.RealSubset(-math.huge, -1, false, false):var'a' asserteq(lim(acosh(x), x, a), invalid) end
do local a = set.real:var'a' print(lim(acosh(x), x, a):prune()) assert(lim(acosh(x), x, a):prune() == lim(acosh(x), x, a)) end
asserteq(lim(acosh(x), x, -inf), invalid)
asserteq(lim(acosh(x), x, 1), invalid)
asserteq(lim(acosh(x), x, 1, '+'), 0)
asserteq(lim(acosh(x), x, inf), inf)

do local a = set.RealSubset(-1, 1, false, false):var'a' asserteq(lim(atanh(x), x, a), atanh(a)) end
do local a = set.RealSubset(-math.huge, -1, false, false):var'a' asserteq(lim(atanh(x), x, a), invalid) end
do local a = set.real:var'a' print(lim(atanh(x), x, a):prune()) assert(lim(atanh(x), x, a):prune() == lim(atanh(x), x, a)) end
asserteq(lim(atanh(x), x, -inf), invalid)
asserteq(lim(atanh(x), x, -1), invalid)
asserteq(lim(atanh(x), x, -1, '+'), -inf)
asserteq(lim(atanh(x), x, 0), 0)
asserteq(lim(atanh(x), x, 1), invalid)
asserteq(lim(atanh(x), x, 1, '-'), inf)
asserteq(lim(atanh(x), x, inf), invalid)

do local a = set.RealSubset(-1, 1, false, false):var'a' asserteq(lim(asin(x), x, a), asin(a)) end
do local a = set.RealSubset(-math.huge, -1, false, false):var'a' asserteq(lim(asin(x), x, a), invalid) end
do local a = set.real:var'a' print(lim(asin(x), x, a):prune()) assert(lim(asin(x), x, a):prune() == lim(asin(x), x, a)) end
asserteq(lim(asin(x), x, -inf), invalid)
asserteq(lim(asin(x), x, -1), invalid)
asserteq(lim(asin(x), x, -1, '+'), -inf)
asserteq(lim(asin(x), x, 0), 0)
asserteq(lim(asin(x), x, 1), invalid)
asserteq(lim(asin(x), x, 1, '-'), inf)
asserteq(lim(asin(x), x, inf), invalid)

do local a = set.RealSubset(-1, 1, false, false):var'a' asserteq(lim(acos(x), x, a), acos(a)) end
do local a = set.RealSubset(-math.huge, -1, false, false):var'a' asserteq(lim(acos(x), x, a), invalid) end
do local a = set.real:var'a' print(lim(acos(x), x, a):prune()) assert(lim(acos(x), x, a):prune() == lim(acos(x), x, a)) end
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

-- TODO polynomial roots
asserteq(lim( 1 / (x - 1), x, 1), invalid)
asserteq(lim( 1 / (x - 1), x, 1, '+'), inf)
asserteq(lim( 1 / (x - 1), x, 1, '-'), -inf)
asserteq(lim( (x + 1) / (x^2 - 1), x, 1), invalid)
asserteq(lim( (x + 1) / (x^2 - 1), x, 1, '+'), inf)
asserteq(lim( (x + 1) / (x^2 - 1), x, 1, '-'), -inf)

-- can we evaluate derivatives as limits?
difftest(x)
difftest(c * x)
difftest(x^2)
difftest(x^3)
difftest(1/x)

-- can't handle these yet. 
-- TODO give unit.lua a 'reach' section? 
-- so console can show that these tests aren't 100% certified.

-- TODO use infinite taylor expansion:
difftest(sqrt(x))
difftest(sin(x))
difftest(cos(x))
difftest(exp(x))

]=]), '\n')) do
	env.exec(line)
end

end)
