#!/usr/bin/env lua

local symmath = require 'symmath'
local x = symmath.var'x'
local y = symmath.var'y'


assert(x:match(x))
assert(x == x)
assert(x ~= y)
assert(not x:match(y))
assert((x + y) == (x + y))
assert((x + y):match(x + y))

local i = (x + y):match(x + symmath.Wildcard(1))
print(i)
