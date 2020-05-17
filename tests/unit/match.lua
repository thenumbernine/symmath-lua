#!/usr/bin/env lua

local symmath = require 'symmath'
local W = symmath.Wildcard
local const = symmath.Constant
local zero = const(0)
local one = const(1)
local sin = symmath.sin
local cos = symmath.cos


local x = symmath.var'x'
local y = symmath.var'y'

-- [[
assert(x:match(x))
assert(x == x)
assert(x ~= y)
assert(not x:match(y))

-- functions

local i = sin(x):match(sin(W(1)))
assert(i == x)

-- functions and mul mixed
local i = sin(2*x):match(sin(W(1)))
assert(i == 2 * x)

local i = sin(2*x):match(sin(2 * W(1)))
assert(i == x)

-- matching c*f(x) => c*sin(a*x)
local f, c = sin(2*x):match(W{1, dependsOn=x} * W{index=2, cannotDependOn=x})
local a = f:match(sin(W{1, cannotDependOn=x} * x))
assert(c == one)
assert(f == sin(2*x))
assert(a == const(2))

-- add

assert((x + y) == (x + y))
assert((x + y):match(x + y))

-- add match to first term
local i = (x + y):match(W(1) + y)
assert(i == x)

-- add match to second term
local i = (x + y):match(x + W(1))
assert(i == y)

-- change order
local i = (x + y):match(y + W(1))
assert(i == x)

-- add match to zero, because nothing's left
local i = (x + y):match(x + y + W(1))
assert(i == zero)

local i = (x + y):match(W(1))
assert(i == x + y)

-- doubled-up matches should only work if they match
local i = (x + y):match(W(1) + W(1))
assert(i == false)

-- this too, this would work only if x + x and not x + y
local i = (x + x):match(W(1) + W(1))
assert(i == x)

-- this too
local i,j = (x + x):match(W{1, atMost=1} + W{2, atMost=1})
assert(i == x)
assert(j == x)

-- this should match (x+y), 0
local i,j = (x + y):match(W(1) + W(2))
assert(i == x + y)
assert(j == zero)

local i,j = (x + y):match(W{1, atMost=1} + W{2, atMost=1})
assert(i == x)
assert(j == y)

-- for these to work, I have to add the multi-wildcard stuff to the non-wildcard elements, handled in add.wildcardMatches
local i,j = x:match(W(1) + W(2))
assert(i == x)
assert(j == zero)

local i,j = x:match(x + W(1) + W(2))
assert(i == zero)
assert(j == zero)

local i,j = x:match(W(1) + x + W(2))
assert(i == zero)
assert(j == zero)

local i,j = (x * y):match(W(1) + W(2))
assert(i == x * y)
assert(j == zero)

-- make sure within add.wildcardMatches we greedy-match any wildcards with 'atLeast' before assigning the rest to zero
local i,j,k = x:match(W(1) + W{2,atLeast=1} + W(3))
assert(i == zero)
assert(j == x)
assert(k == zero)

-- same with mul

local i = (x * y):match(y * W(1))
assert(i == x)

local i = (x * y):match(x * y * W(1))
assert(i == one)

local i = (x * y):match(W(1))
assert(i == x * y)

local i = (x * y):match(W(1) * W(1))
assert(i == false)

local i = (x * x):match(W(1) * W(1))
assert(i == x)

-- verify wildcards are greedy with multiple mul matching 
-- the first will take all expressions, the second gets the empty set
local i,j = (x * y):match(W(1) * W(2))
assert(i == x * y)
assert(j == one)

-- verify 'atMost' works - since both need at least 1 entry, it will only match when each gets a separate term
local i,j = (x * x):match(W{1, atMost=1} * W{2, atMost=1})
assert(i == x)
assert(j == x)

-- verify 'atMost' cooperates with non-atMost wildcards
local i,j = (x * y):match(W(1) * W{2, atLeast=1})
assert(i == x)
assert(j == y)

local i,j = (x * y):match(W{1, atMost=1} * W{2, atMost=1})
assert(i == x)
assert(j == y)

-- combinations of add and mul

-- for this to work, add.wildcardMatches must call the wildcard-capable objects' own wildcard handlers correctly (and use push/pop match states, instead of assigning to wildcard indexes directly?)
-- also, because add.wildcardMatches assigns the extra wildcards to zero, it will be assigning (W(2) * W(3)) to zero ... which means it must (a) handle mul.wildcardMatches and (b) pick who of mul's children gets the zero and who doesn't
--  it also means that a situation like add->mul->add might have problems ... x:match(W(1) + (W(2) + W(3)) * (W(4) + W(5)))
local i,j,k = x:match(W(1) + W(2) * W(3))
assert(i == x)
assert(j == zero or k == zero)

--  cross over add and mul ... not yet working
--local i = (x):match(W(1) + x)	-- works
local i = (x * y):match(W(1) + x * y)
assert(i == zero)

local i,j,k,l = x:match(x + W(1) * W(2) + W(3) * W(4))
-- either 1 or 2 must be zero, and either 3 or 4 must be zero
assert(i == zero or j == zero)
assert(k == zero or l == zero)

-- div

local i = (1/x):match(1 / W(1))
assert(i == x)

local i = (1/x):match(1 / (W(1) * x))
assert(i == one)

local i = (1/x):match(1 / (W{1, cannotDependOn=x} * x))
assert(i == one)

assert((2 * 1/x):match(2 * 1/x))

local i = (2 * 1/x):match(2 * 1/W(1))
assert(i == x)

local i = (2 * 1/x):match(2 * 1/(W(1) * x))
assert(i == one)

local i, j = (2 * 1/x):factorDivision():match(W{1, atMost=1} * W{index=2, atMost=1})
assert(i == const(2))
assert(j == 1/x)
--]]

-- [[ TODO working but now how I hoped
-- I would like this to match but it is matching to 0, (x+y).
-- I guess that is fair for greed matching of wildcards.
-- TODO maybe I should change things to match less first
-- The problem is that the algorithm tests the largest subset to each wildcard first
-- i.e. first (x+y) is tested to W(1) then to W(2) which it matches
-- For this match to work, I would want W(1) to greedily match first
-- (matching to 'y')
-- and then W(2) to greedily match next (matching to 'x')
-- Changing the match algo to match wildcards left-to-right in associative operators like + and * would also give the API user more control over what they wanted to match (as in this case).
local i, j = (x + y):match(W{1, cannotDependOn=x} + W{2, dependsOn=x})
assert(i == zero)
assert(j == x + y)
--]]

local i, j = (x + y):match(W{1, cannotDependOn=x, atLeast=1} + W{2, dependsOn=x})
assert(i == y)
assert(j == x)

local c, f = (2 * x):match(W{1, cannotDependOn=x} * W{2, dependsOn=x})
assert(c == const(2))
assert(f == x)


local c, f = (2 * x):factorDivision():match(W{1, cannotDependOn=x} * W{2, dependsOn=x})
assert(c == const(2))
assert(f == x)


-- use 'cannotDependOn' first for it to greedily match non-dep-on-x terms
-- otherwise 'dependsOn' will match everything, since the mul of a non-dep and a dep itself is dep on 'x', so it will include non-dep-on-terms
local c, f = (2 * 1/x):factorDivision():match(W{index=1, cannotDependOn=x} * W{2, dependsOn=x})
assert(c == const(2))
assert(f == 1/x)

local c, f = (2 * 1/x):factorDivision():match(W{1, cannotDependOn=x} * W(2))
assert(c == const(2))
assert(f == 1/x)
