#!/usr/bin/env lua
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'{env=env}

local x = var'x'
local y = var'y'
local xL = var'xL'
local xR = var'xR'

-- integrate constants
assert(Constant(1):integrate(x)() == x)
assert(y:integrate(x)() == x * y)

assert(Constant(1):integrate(x, xL, xR)() == (xR - xL)())

-- definite integral bounds:
--assert(x:integrate(x, xL, xR)() == ((xR^2 - xL^2)/2)())	-- hmm, the infamous minus sign factoring simplificaiton error...
assert((x:integrate(x, xL, xR) - (xR^2 - xL^2)/2)() == Constant(0))	-- instead I'll just test this ...

--x^n integrals:
assert(x:integrate(x)() == x^2 / 2)
assert((x^2):integrate(x)() == x^3 / 3)
assert(((x^-2):integrate(x) - (-1/x))() == Constant(0))
assert((1/x):integrate(x)() == log(abs(x)))
assert((x^-1):integrate(x)() == log(abs(x)))

-- [[ hmm, sqrt doesn't integrate yet..
print((x^frac(1,2)):integrate(x)())
print(sqrt(x):integrate(x)())
print(1 / (2 * sqrt(x)))

assert(sin(x):integrate(x)() == -cos(x))
assert(cos(x):integrate(x)() == sin(x))
