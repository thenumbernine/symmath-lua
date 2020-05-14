#!/usr/bin/env lua

local symmath = require 'symmath'
local Wildcard = symmath.Wildcard
local Constant = symmath.Constant

local x = symmath.var'x'
local y = symmath.var'y'

-- [[
assert(x:match(x))
assert(x == x)
assert(x ~= y)
assert(not x:match(y))
assert((x + y) == (x + y))
assert((x + y):match(x + y))

-- add match to first term
local i = (x + y):match(Wildcard(1) + y)
assert(i == x)

-- add match to second term
local i = (x + y):match(x + Wildcard(1))
assert(i == y)

-- change order
local i = (x + y):match(y + Wildcard(1))
assert(i == x)

-- add match to zero, because nothing's left
local i = (x + y):match(x + y + Wildcard(1))
assert(i == Constant(0))

local i = (x + y):match(Wildcard(1))
assert(i == x + y)

-- TODO doubled-up matches should only work if they match
local i = (x + y):match(Wildcard(1) + Wildcard(1))
assert(i == false)

-- TODO this too, this would work only if x + x and not x + y
local i = (x + x):match(Wildcard(1) + Wildcard(1))
assert(i == x)
--]]

-- TODO this too, this would 
local i,j = (x + x):match(Wildcard{index=1, atMost=1} + Wildcard{index=2, atMost=1})
assert(i == x)
assert(j == x)

-- this should match (x+y), 0
local i,j = (x + y):match(Wildcard(1) + Wildcard(2))
assert(i == x + y)
assert(j == Constant(0))

local i,j = (x + y):match(Wildcard{index=1, atMost=1} + Wildcard{index=2, atMost=1})
assert(i == x)
assert(j == y)

-- same with mul
local i = (x * y):match(Wildcard(1) * y)
assert(i == x)

-- add match to second term
local i = (x * y):match(x * Wildcard(1))
assert(i == y)

-- change order
local i = (x * y):match(y * Wildcard(1))
assert(i == x)

-- add match to zero, because nothing's left
local i = (x * y):match(x * y * Wildcard(1))
assert(i == Constant(1))
