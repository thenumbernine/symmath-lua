#!/usr/bin/env lua
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'tests/unit/integral')

timer(nil, function()

env.a = var'a'
env.b = var'b'
env.x = var'x'
env.y = var'y'
env.xL = var'xL'
env.xR = var'xR'
env.r = var'r'

env.f = var('f', {x})

for _,line in ipairs(string.split(string.trim([=[

-- integrate constants
simplifyAssertEq(Constant(1):integrate(x), x)
simplifyAssertEq(y:integrate(x), x * y)

simplifyAssertEq(Constant(1):integrate(x, xL, xR), (xR - xL))

-- definite integral bounds:
--simplifyAssertEq(x:integrate(x, xL, xR), ((xR^2 - xL^2)/2))	-- hmm, the infamous minus sign factoring simplificaiton error...
simplifyAssertEq((x:integrate(x, xL, xR) - (xR^2 - xL^2)/2), Constant(0))	-- instead I'll just test this ...

-- $x^n$ integrals:
simplifyAssertEq(x:integrate(x), x^2 / 2)
simplifyAssertEq((x^2):integrate(x), x^3 / 3)
simplifyAssertEq(((x^-2):integrate(x) - (-1/x)), Constant(0))
simplifyAssertEq((1/x):integrate(x), log(abs(x)))
simplifyAssertEq((x^-1):integrate(x), log(abs(x)))
simplifyAssertEq((1/(2*x^2)):integrate(x), -(1/(2*x)))

simplifyAssertEq((x^frac(1,2)):integrate(x), frac(2 * x * sqrt(x), 3))
simplifyAssertEq(sqrt(x):integrate(x), frac(2 * x * sqrt(x), 3))

simplifyAssertEq((1/x):integrate(x), log(abs(x)))

simplifyAssertEq((2/x):integrate(x), (2*log(abs(x))))
simplifyAssertEq((1/(2*x)):integrate(x), (log(abs(x))/2))

simplifyAssertEq((1/(x*(3*x+4))):integrate(x)(), log(1 / abs( (4 + 3 * x) / x)^frac(1,4)))

simplifyAssertEq(f:diff(x):integrate(x)(), f)
simplifyAssertEq(f:integrate(x):diff(x)(), f)
simplifyAssertEq(f:diff(x,x):integrate(x)(), f:diff(x))
simplifyAssertEq(f:integrate(x):integrate(x):diff(x)(), f:integrate(x))
simplifyAssertEq(f:integrate(x):diff(x,x)(), f:diff(x))

simplifyAssertEq(sin(x):integrate(x)(), -cos(x))
simplifyAssertEq(cos(x):integrate(x)(), sin(x))

simplifyAssertEq(sin(2*x):integrate(x)(), (-cos(2*x)/2))
simplifyAssertEq(cos(y*x):integrate(x)(), (sin(y*x)/y))

simplifyAssertEq((cos(x)/sin(x)):integrate(x), log(abs(sin(x))))

simplifyAssertEq((cos(x)^2):integrate(x)(), frac(1,4) * (2 * x + sin(2 * x)))

simplifyAssertEq(sinh(x):integrate(x), cosh(x))
simplifyAssertEq(cosh(x):integrate(x), sinh(x))


-- multiple integrals

simplifyAssertEq((x * y):integrate(x), frac(1,2) * x^2 * y)
simplifyAssertEq((x * y):integrate(x)():integrate(y)(), frac(1,4) * x^2 * y^2)
simplifyAssertEq((x * y):integrate(x):integrate(y)(), frac(1,4) * x^2 * y^2)
simplifyAssertEq((r * cos(x)):integrate(r)():integrate(x)(), frac(1,2) * r^2 * sin(x))
simplifyAssertEq((r * cos(x)):integrate(x)():integrate(r)(), frac(1,2) * r^2 * sin(x))

simplifyAssertEq( ( cosh(a * x) * sinh(a * x) ):integrate(x), cosh(a * x)^2 / (2 * a) )
simplifyAssertEq( ( cosh(a * x) * sinh(b * x) ):integrate(x), 1 / ((a + b) * (a - b)) * (-b * cosh(a*x) * cosh(b*x) + a * sinh(a*x) * sinh(b*x)) )

simplifyAssertEq( ( sinh(a * x)^2 * cosh(a * x) ):integrate(x), sinh(a * x)^3 / (3 * a) )

]=]), '\n')) do
	env.exec(line)
end

env.done()
end)
