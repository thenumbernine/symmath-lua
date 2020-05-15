#!/usr/bin/env lua

local symmath = require 'symmath'
local Wildcard = symmath.Wildcard
local Constant = symmath.Constant
local zero = Constant(0)
local one = Constant(1)

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
assert(i == zero)

local i = (x + y):match(Wildcard(1))
assert(i == x + y)

-- doubled-up matches should only work if they match
local i = (x + y):match(Wildcard(1) + Wildcard(1))
assert(i == false)

-- this too, this would work only if x + x and not x + y
local i = (x + x):match(Wildcard(1) + Wildcard(1))
assert(i == x)
--]]

-- this too
local i,j = (x + x):match(Wildcard{index=1, atMost=1} + Wildcard{index=2, atMost=1})
assert(i == x)
assert(j == x)

-- this should match (x+y), 0
local i,j = (x + y):match(Wildcard(1) + Wildcard(2))
assert(i == x + y)
assert(j == zero)

local i,j = (x + y):match(Wildcard{index=1, atMost=1} + Wildcard{index=2, atMost=1})
assert(i == x)
assert(j == y)

--[[ TODO alright, for these to work, I have to add the multi-wildcard stuff to the non-wildcard elements:
local i,j = x:match(Wildcard(1) + Wildcard(2))
assert(i == x)
assert(j == zero)
--]]

-- same with mul

local i = (x * y):match(y * Wildcard(1))
assert(i == x)

local i = (x * y):match(x * y * Wildcard(1))
assert(i == one)

local i = (x * y):match(Wildcard(1))
assert(i == x * y)

local i = (x * y):match(Wildcard(1) * Wildcard(1))
assert(i == false)

local i = (x * x):match(Wildcard(1) * Wildcard(1))
assert(i == x)

local i,j = (x * x):match(Wildcard{index=1, atMost=1} * Wildcard{index=2, atMost=1})
assert(i == x)
assert(j == x)

local i,j = (x * y):match(Wildcard(1) * Wildcard(2))
assert(i == x * y)
assert(j == one)

local i,j = (x * y):match(Wildcard{index=1, atMost=1} * Wildcard{index=2, atMost=1})
assert(i == x)
assert(j == y)
