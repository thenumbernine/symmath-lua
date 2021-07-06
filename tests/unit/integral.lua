#!/usr/bin/env lua
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'integral')

timer(nil, function()

env.a = var'a'
env.b = var'b'
env.x = var'x'
env.y = var'y'
env.xL = var'xL'
env.xR = var'xR'
env.r = var'r'

for _,line in ipairs(string.split(string.trim([=[

-- integrate constants
asserteq(Constant(1):integrate(x), x)
asserteq(y:integrate(x), x * y)

asserteq(Constant(1):integrate(x, xL, xR), (xR - xL))

-- definite integral bounds:
--asserteq(x:integrate(x, xL, xR), ((xR^2 - xL^2)/2))	-- hmm, the infamous minus sign factoring simplificaiton error...
asserteq((x:integrate(x, xL, xR) - (xR^2 - xL^2)/2), Constant(0))	-- instead I'll just test this ...

-- $x^n$ integrals:
asserteq(x:integrate(x), x^2 / 2)
asserteq((x^2):integrate(x), x^3 / 3)
asserteq(((x^-2):integrate(x) - (-1/x)), Constant(0))
asserteq((1/x):integrate(x), log(abs(x)))
asserteq((x^-1):integrate(x), log(abs(x)))
asserteq((1/(2*x^2)):integrate(x), -(1/(2*x)))

asserteq((x^frac(1,2)):integrate(x), frac(2 * x * sqrt(x), 3))
asserteq(sqrt(x):integrate(x), frac(2 * x * sqrt(x), 3))

asserteq((1/x):integrate(x), log(abs(x)))

asserteq((2/x):integrate(x), (2*log(abs(x))))
asserteq((1/(2*x)):integrate(x), (log(abs(x))/2))

asserteq((1/(x*(3*x+4))):integrate(x)(), log(1 / abs( (4 + 3 * x) / x)^frac(1,4)))

asserteq(sin(x):integrate(x)(), -cos(x))
asserteq(cos(x):integrate(x)(), sin(x))

asserteq(sin(2*x):integrate(x)(), (-cos(2*x)/2))
asserteq(cos(y*x):integrate(x)(), (sin(y*x)/y))

asserteq((cos(x)/sin(x)):integrate(x), log(abs(sin(x))))

asserteq((cos(x)^2):integrate(x)(), frac(1,4) * (2 * x + sin(2 * x)))

asserteq(sinh(x):integrate(x), cosh(x))
asserteq(cosh(x):integrate(x), sinh(x))


-- multiple integrals

asserteq((x * y):integrate(x), frac(1,2) * x^2 * y)
asserteq((x * y):integrate(x)():integrate(y)(), frac(1,4) * x^2 * y^2)
asserteq((x * y):integrate(x):integrate(y)(), frac(1,4) * x^2 * y^2)
asserteq((r * cos(x)):integrate(r)():integrate(x)(), frac(1,2) * r^2 * sin(x))
asserteq((r * cos(x)):integrate(x)():integrate(r)(), frac(1,2) * r^2 * sin(x))

asserteq( ( cosh(a * x) * sinh(a * x) ):integrate(x), cosh(a * x)^2 / (2 * a) )
asserteq( ( cosh(a * x) * sinh(b * x) ):integrate(x), 1 / ((a + b) * (a - b)) * (-b * cosh(a*x) * cosh(b*x) + a * sinh(a*x) * sinh(b*x)) )

asserteq( ( sinh(a * x)^2 * cosh(a * x) ):integrate(x), sinh(a * x)^3 / (3 * a) )

]=]), '\n')) do
	env.exec(line)
end

end)
