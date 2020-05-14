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

-- add match to first term
local i = (x + y):match(symmath.Wildcard(1) + y)
assert(i == x)

-- add match to second term
local i = (x + y):match(x + symmath.Wildcard(1))
assert(i == y)

-- change order
local i = (x + y):match(y + symmath.Wildcard(1))
assert(i == x)

-- add match to zero, because nothing's left
local i = (x + y):match(x + y + symmath.Wildcard(1))
assert(i == symmath.Constant(0))
