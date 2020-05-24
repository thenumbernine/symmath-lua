#!/usr/bin/env lua
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'unit'(env, 'integral')
env.x = var'x'
env.y = var'y'
env.xL = var'xL'
env.xR = var'xR'


for _,line in ipairs(string.split(string.trim([=[

-- integrate constants
assert(Constant(1):integrate(x)() == x)
assert(y:integrate(x)() == x * y)

assert(Constant(1):integrate(x, xL, xR)() == (xR - xL)())

-- definite integral bounds:
--assert(x:integrate(x, xL, xR)() == ((xR^2 - xL^2)/2)())	-- hmm, the infamous minus sign factoring simplificaiton error...
assert((x:integrate(x, xL, xR) - (xR^2 - xL^2)/2)() == Constant(0))	-- instead I'll just test this ...

-- $x^n$ integrals:
assert(x:integrate(x)() == x^2 / 2)
assert((x^2):integrate(x)() == x^3 / 3)
assert(((x^-2):integrate(x) - (-1/x))() == Constant(0))
assert((1/x):integrate(x)() == log(abs(x)))
assert((x^-1):integrate(x)() == log(abs(x)))
assert((1/(2*x^2)):integrate(x)() == -(1/(2*x)))

assert((x^frac(1,2)):integrate(x)() == frac(2 * x * sqrt(x), 3)())
assert(sqrt(x):integrate(x)() == frac(2 * x * sqrt(x), 3)())

assert((1/x):integrate(x)() == log(abs(x)))

assert((2/x):integrate(x)() == (2*log(abs(x)))())
assert((1/(2*x)):integrate(x)() == (log(abs(x))/2)())

asserteq((1/(x*(3*x+4))):integrate(x)(), log(1 / abs( (4 + 3 * x) / x)^frac(1,4)))

assert(sin(x):integrate(x)() == -cos(x))
assert(cos(x):integrate(x)() == sin(x))

assert(sin(2*x):integrate(x)() == (-cos(2*x)/2)())
assert(cos(y*x):integrate(x)() == (sin(y*x)/y)())

assert((cos(x)/sin(x)):integrate(x)() == log(abs(sin(x))))

assert(sinh(x):integrate(x)() == cosh(x))
assert(cosh(x):integrate(x)() == sinh(x))

]=]), '\n')) do
	env.exec(line)
end
