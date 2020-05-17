#!/usr/bin/env lua
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'{env=env}

local x = var'x'
local y = var'y'
local xL = var'xL'
local xR = var'xR'

--[[
-- integrate constants
assert(Constant(1):integrate(x)() == x)
assert(y:integrate(x)() == x * y)

assert(Constant(1):integrate(x, xL, xR)() == (xR - xL)())

--]]
-- definite integral bounds:
--assert(x:integrate(x, xL, xR)() == ((xR^2 - xL^2)/2)())	-- hmm, the infamous minus sign factoring simplificaiton error...
print( x:integrate(x, xL, xR)() )
--assert((x:integrate(x, xL, xR) - (xR^2 - xL^2)/2)() == Constant(0))	-- instead I'll just test this ...
os.exit()

--x^n integrals:
assert(x:integrate(x)() == x^2 / 2)
assert((x^2):integrate(x)() == x^3 / 3)
assert(((x^-2):integrate(x) - (-1/x))() == Constant(0))
assert((1/x):integrate(x)() == log(abs(x)))
assert((x^-1):integrate(x)() == log(abs(x)))

-- [[ hmm, sqrt doesn't integrate yet..
assert((x^frac(1,2)):integrate(x)() == frac(2 * x * sqrt(x), 3)())
assert(sqrt(x):integrate(x)() == frac(2 * x * sqrt(x), 3)())

assert(sin(x):integrate(x)() == -cos(x))
assert(cos(x):integrate(x)() == sin(x))

assert(sin(2*x):integrate(x)() == (-cos(2*x)/2)())
assert(cos(y*x):integrate(x)() == (sin(y*x)/y)())

assert((1/x):integrate(x)() == log(abs(x)))
--]]

--print((2/x):integrate(x)() ..'\n'.. (2*log(abs(x)))())
assert((1/(2*x)):integrate(x)() == (log(abs(x))/2)())
