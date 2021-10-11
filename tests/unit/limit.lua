#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'tests/unit/limit')

timer(nil, function()

env.a = symmath.Variable('a')
env.b = symmath.Variable('b')
env.c = symmath.Variable('c')
env.g = symmath.Variable('g')
env.h = symmath.Variable('h')
env.n = symmath.Variable('n')
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
	simplifyAssertEq(limexpreval, diffexpreval)
end

-- constant simplificaiton
for _,line in ipairs(string.split(string.trim([=[

simplifyAssertEq(lim(x, x, a), a)
simplifyAssertEq(lim(x, x, a, '+'), a)
simplifyAssertEq(lim(x, x, a, '-'), a)

-- constants
simplifyAssertEq(lim(0, x, a), 0)
simplifyAssertEq(lim(1, x, a), 1)

-- ops
simplifyAssertEq(lim(x + 2, x, a), a + 2)
simplifyAssertEq(lim(x + x, x, a), 2 * a)
simplifyAssertEq(lim(x + a, x, a), 2 * a)
simplifyAssertEq(lim(a + a, x, a), 2 * a)
simplifyAssertEq(lim(x * 2, x, a), 2 * a)
simplifyAssertEq(lim(x / 2, x, a), a / 2)

-- involving infinity
simplifyAssertEq(lim(x, x, inf), inf)
simplifyAssertEq(lim(x, x, -inf), -inf)
simplifyAssertEq(lim(x, x, inf), inf)
simplifyAssertEq(lim(1/x, x, inf), 0)
simplifyAssertEq(lim(1/x, x, -inf), 0)
simplifyAssertEq(lim(1/x, x, 0), invalid)

simplifyAssertEq(lim(1/x, x, 0, '+'), inf)
simplifyAssertEq(lim(1/x, x, 0, '-'), -inf)

simplifyAssertEq(lim(1/x^2, x, 0, '+'), inf)
simplifyAssertEq(lim(1/x^2, x, 0, '-'), inf)

-- sqrts
simplifyAssertEq(lim(sqrt(x), x, 0), invalid)
simplifyAssertEq(lim(sqrt(x), x, 0, '-'), invalid)
simplifyAssertEq(lim(sqrt(x), x, 0, '+'), 0)
-- in each form ...
simplifyAssertEq(lim(x^frac(1,2), x, 0), invalid)
simplifyAssertEq(lim(x^frac(1,2), x, 0, '-'), invalid)
simplifyAssertEq(lim(x^frac(1,2), x, 0, '+'), 0)
-- and one more power up ...
simplifyAssertEq(lim(x^frac(1,4), x, 0), invalid)
simplifyAssertEq(lim(x^frac(1,4), x, 0, '-'), invalid)
simplifyAssertEq(lim(x^frac(1,4), x, 0, '+'), 0)


-- functions
--
-- TODO all of these are only good for 'a' in Real, not necessarily extended-Real, because I don't distinguish them
--
-- another thing to consider ... most these are set up so that the limit is the same as the evaluation without a limit
-- technically this is not true.  technically atan(inf) is not pi/2 but is instead undefined outside of the limit.
-- should I enforce this?
simplifyAssertEq(lim(sin(x), x, a), sin(a))
simplifyAssertEq(lim(sin(x), x, inf), invalid)
simplifyAssertEq(lim(sin(x), x, -inf), invalid)

simplifyAssertEq(lim(cos(x), x, a), cos(a))
simplifyAssertEq(lim(cos(x), x, inf), invalid)
simplifyAssertEq(lim(cos(x), x, -inf), invalid)

simplifyAssertEq(lim(abs(x), x, a), abs(a))
simplifyAssertEq(lim(abs(x), x, -inf), inf)
simplifyAssertEq(lim(abs(x), x, inf), inf)

simplifyAssertEq(lim(exp(x), x, a), exp(a))
simplifyAssertEq(lim(exp(x), x, -inf), 0)
simplifyAssertEq(lim(exp(x), x, inf), inf)

simplifyAssertEq(lim(atan(x), x, a), atan(a))
simplifyAssertEq(lim(atan(x), x, -inf), -pi/2)
simplifyAssertEq(lim(atan(x), x, inf), pi/2)

simplifyAssertEq(lim(tanh(x), x, a), tanh(a))
simplifyAssertEq(lim(tanh(x), x, -inf), -1)
simplifyAssertEq(lim(tanh(x), x, inf), 1)

simplifyAssertEq(lim(asinh(x), x, a), asinh(a))
simplifyAssertEq(lim(asinh(x), x, -inf), -inf)
simplifyAssertEq(lim(asinh(x), x, inf), inf)

simplifyAssertEq(lim(cosh(x), x, a), cosh(a))
simplifyAssertEq(lim(cosh(x), x, -inf), inf)
simplifyAssertEq(lim(cosh(x), x, inf), inf)

simplifyAssertEq(lim(sinh(x), x, a), sinh(a))
simplifyAssertEq(lim(sinh(x), x, -inf), -inf)
simplifyAssertEq(lim(sinh(x), x, inf), inf)

simplifyAssertEq(lim(sin(x), x, a), sin(a))
simplifyAssertEq(lim(sin(x), x, -inf), invalid)
simplifyAssertEq(lim(sin(x), x, inf), invalid)

simplifyAssertEq(lim(cos(x), x, a), cos(a))
simplifyAssertEq(lim(cos(x), x, -inf), invalid)
simplifyAssertEq(lim(cos(x), x, inf), invalid)

simplifyAssertEq(lim(tan(x), x, a), tan(a))
simplifyAssertEq(lim(tan(x), x, -inf), invalid)
simplifyAssertEq(lim(tan(x), x, -3*pi/2), invalid)
simplifyAssertEq(lim(tan(x), x, -pi), tan(-pi))
simplifyAssertEq(lim(tan(x), x, -pi/2), invalid)
simplifyAssertEq(lim(tan(x), x, 0), tan(0))
simplifyAssertEq(lim(tan(x), x, pi/2), invalid)
simplifyAssertEq(lim(tan(x), x, pi/2, '+'), -inf)
simplifyAssertEq(lim(tan(x), x, pi/2, '-'), inf)
simplifyAssertEq(lim(tan(x), x, pi), tan(pi))
simplifyAssertEq(lim(tan(x), x, 3*pi/2), invalid)
simplifyAssertEq(lim(tan(x), x, inf), invalid)

do local a = set.positiveReal:var'a' simplifyAssertEq(lim(log(x), x, a), log(a)) end	-- if the input is within the domain of the function then we can evaluate it for certain
do local a = set.negativeReal:var'a' simplifyAssertEq(lim(log(x), x, a), invalid) end	-- if the input is outside the domain of the function then we know the result is invalid. TODO is this the same as indeterminate?  Or should I introduce a new singleton?
do local a = set.real:var'a' print(lim(log(x), x, a):prune()) assert(lim(log(x), x, a):prune() == lim(log(x), x, a)) end	-- if the input covers both the domain and its complement, and we can't determine the limit evaluation, then don't touch the expression
simplifyAssertEq(lim(log(x), x, -inf), invalid)
simplifyAssertEq(lim(log(x), x, 0), invalid)
simplifyAssertEq(lim(log(x), x, 0, '+'), -inf)
simplifyAssertEq(lim(log(x), x, inf), inf)

do local a = set.RealSubset(-1, 1, false, false):var'a' simplifyAssertEq(lim(acosh(x), x, a), acosh(a)) end
do local a = set.RealSubset(-math.huge, -1, false, false):var'a' simplifyAssertEq(lim(acosh(x), x, a), invalid) end
do local a = set.real:var'a' print(lim(acosh(x), x, a):prune()) assert(lim(acosh(x), x, a):prune() == lim(acosh(x), x, a)) end
simplifyAssertEq(lim(acosh(x), x, -inf), invalid)
simplifyAssertEq(lim(acosh(x), x, 1), invalid)
simplifyAssertEq(lim(acosh(x), x, 1, '+'), 0)
simplifyAssertEq(lim(acosh(x), x, inf), inf)

do local a = set.RealSubset(-1, 1, false, false):var'a' simplifyAssertEq(lim(atanh(x), x, a), atanh(a)) end
do local a = set.RealSubset(-math.huge, -1, false, false):var'a' simplifyAssertEq(lim(atanh(x), x, a), invalid) end
do local a = set.real:var'a' print(lim(atanh(x), x, a):prune()) assert(lim(atanh(x), x, a):prune() == lim(atanh(x), x, a)) end
simplifyAssertEq(lim(atanh(x), x, -inf), invalid)
simplifyAssertEq(lim(atanh(x), x, -1), invalid)
simplifyAssertEq(lim(atanh(x), x, -1, '+'), -inf)
simplifyAssertEq(lim(atanh(x), x, 0), 0)
simplifyAssertEq(lim(atanh(x), x, 1), invalid)
simplifyAssertEq(lim(atanh(x), x, 1, '-'), inf)
simplifyAssertEq(lim(atanh(x), x, inf), invalid)

do local a = set.RealSubset(-1, 1, false, false):var'a' simplifyAssertEq(lim(asin(x), x, a), asin(a)) end
do local a = set.RealSubset(-math.huge, -1, false, false):var'a' simplifyAssertEq(lim(asin(x), x, a), invalid) end
do local a = set.real:var'a' print(lim(asin(x), x, a):prune()) assert(lim(asin(x), x, a):prune() == lim(asin(x), x, a)) end
simplifyAssertEq(lim(asin(x), x, -inf), invalid)
simplifyAssertEq(lim(asin(x), x, -1), invalid)
simplifyAssertEq(lim(asin(x), x, -1, '+'), -inf)
simplifyAssertEq(lim(asin(x), x, 0), 0)
simplifyAssertEq(lim(asin(x), x, 1), invalid)
simplifyAssertEq(lim(asin(x), x, 1, '-'), inf)
simplifyAssertEq(lim(asin(x), x, inf), invalid)

do local a = set.RealSubset(-1, 1, false, false):var'a' simplifyAssertEq(lim(acos(x), x, a), acos(a)) end
do local a = set.RealSubset(-math.huge, -1, false, false):var'a' simplifyAssertEq(lim(acos(x), x, a), invalid) end
do local a = set.real:var'a' print(lim(acos(x), x, a):prune()) assert(lim(acos(x), x, a):prune() == lim(acos(x), x, a)) end
simplifyAssertEq(lim(acos(x), x, -inf), invalid)
simplifyAssertEq(lim(acos(x), x, -1), invalid)
simplifyAssertEq(lim(acos(x), x, -1, '+'), inf)
simplifyAssertEq(lim(acos(x), x, 0), pi/2)
simplifyAssertEq(lim(acos(x), x, 1), invalid)
simplifyAssertEq(lim(acos(x), x, 1, '-'), -inf)
simplifyAssertEq(lim(acos(x), x, inf), invalid)

simplifyAssertEq(lim(Heaviside(x), x, a), Heaviside(a))
simplifyAssertEq(lim(Heaviside(x), x, -inf), 0)
simplifyAssertEq(lim(Heaviside(x), x, -1), 0)
simplifyAssertEq(lim(Heaviside(x), x, 0), invalid)
simplifyAssertEq(lim(Heaviside(x), x, 0, '-'), 0)
simplifyAssertEq(lim(Heaviside(x), x, 0, '+'), 1)
simplifyAssertEq(lim(Heaviside(x), x, 1), 1)
simplifyAssertEq(lim(Heaviside(x), x, inf), 1)

-- products of functions
simplifyAssertEq(lim(x * sin(x), x, a), a * sin(a))

-- TODO polynomial roots
simplifyAssertEq(lim(1 / (x - 1), x, 1), invalid)
simplifyAssertEq(lim(1 / (x - 1), x, 1, '+'), inf)
simplifyAssertEq(lim(1 / (x - 1), x, 1, '-'), -inf)
simplifyAssertEq(lim((x + 1) / (x^2 - 1), x, 1), invalid)
simplifyAssertEq(lim((x + 1) / (x^2 - 1), x, 1, '+'), inf)
simplifyAssertEq(lim((x + 1) / (x^2 - 1), x, 1, '-'), -inf)

-- can we evaluate derivatives as limits?  yes.
difftest(x)
difftest(c * x)
difftest(x^2)
difftest(x^3)
difftest(1/x)

-- can't handle these yet. 
-- TODO give unit tests a 'reach' section? 
-- so console can show that these tests aren't 100% certified.
-- use infinite taylor expansion?
-- or just use L'Hospital's rule -- that solves these too, because, basically, that replaces the limit with the derivative, so it will always be equal.
difftest(sqrt(x))
difftest(sin(x))
difftest(cos(x))
difftest(exp(x))

-- some other L'Hospital rule problems:
simplifyAssertEq(lim(sin(x) / x, x, 0), 1)
simplifyAssertEq(lim(exp(x) / x^2, x, inf), inf)
simplifyAssertEq(lim((e^x - 1) / (x^2 + x), x, 0), 1)
simplifyAssertEq(lim((2*sin(x) - sin(2*x)) / (x - sin(x)), x, 0), 6)

-- TODO this one, repeatedly apply L'Hospital until the power of x on top is <= 0
-- but this seems like it would need a special case of evaluating into a factorial
simplifyAssertEq(lim(x^n * e^x, x, 0), 0)

-- TODO this requires representing x ln x as (ln x) / (1/x) before applying L'Hospital
simplifyAssertEq(lim(x * log(x), x, 0, '+'), 0)

-- mortgage repayment formula -- works
simplifyAssertEq(lim( (a * x * (1 + x)^n) / ((1 + x)^n - 1), x, 0 ), a / n)

-- the infamous tanh(x) ... works?  hmm ... this is infamous for taking an infinite number of L'Hospital applications.  Why is it working?
print( ((e^x + e^-x) / (e^x - e^-x)):lim(x, inf):prune() )

]=]), '\n')) do
	env.exec(line)
end

end)
