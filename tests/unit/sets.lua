#!/usr/bin/env lua
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'sets')

timer(nil, function()

env.x = set.real:var'x'

for _,line in ipairs(string.split(string.trim([=[

-- TODO do unit tests with the RealInterval / RealSubset operators

-- subsets
-- TODO don't use ":contains()" except for element testing, as in sets-of-sets
-- instead here use isSubsetOf

assert(set.real:isSubsetOf(set.real) == true)
assert(set.positiveReal:isSubsetOf(set.real) == true)
assert(set.negativeReal:isSubsetOf(set.real) == true)
assert(set.integer:isSubsetOf(set.real) == true)
assert(set.evenInteger:isSubsetOf(set.real) == true)
assert(set.oddInteger:isSubsetOf(set.real) == true)

assert(set.real:isSubsetOf(set.integer) == nil)
assert(set.positiveReal:isSubsetOf(set.integer) == nil)
assert(set.negativeReal:isSubsetOf(set.integer) == nil)
assert(set.integer:isSubsetOf(set.integer) == true)
assert(set.evenInteger:isSubsetOf(set.integer) == true)
assert(set.oddInteger:isSubsetOf(set.integer) == true)

assert(set.real:isSubsetOf(set.evenInteger) == nil)
assert(set.positiveReal:isSubsetOf(set.evenInteger) == nil)
assert(set.negativeReal:isSubsetOf(set.evenInteger) == nil)
assert(set.integer:isSubsetOf(set.evenInteger) == nil)
assert(set.evenInteger:isSubsetOf(set.evenInteger) == true)
assert(set.oddInteger:isSubsetOf(set.evenInteger) == nil)

assert(set.real:isSubsetOf(set.oddInteger) == nil)
assert(set.positiveReal:isSubsetOf(set.oddInteger) == nil)
assert(set.negativeReal:isSubsetOf(set.oddInteger) == nil)
assert(set.integer:isSubsetOf(set.oddInteger) == nil)
assert(set.evenInteger:isSubsetOf(set.oddInteger) == nil)
assert(set.oddInteger:isSubsetOf(set.oddInteger) == true)


-- realinterval 

assert(set.RealInterval(-2, -1, true, true):isSubsetOf(set.RealInterval(1, 2, true, true)) == false)
assert(set.RealInterval(-2, -1, true, true):isSubsetOf(set.RealInterval(-1, 2, true, true)) == nil)
assert(set.RealInterval(-2, -1, true, true):isSubsetOf(set.RealInterval(-2, 2, true, true)) == true)
assert(set.RealInterval(-2, -1, true, true):isSubsetOf(set.RealInterval(-2, 2, false, true)) == nil)

local A = set.RealInterval(0, 1, false, true) printbr(A, 'isSubsetOf', A) assert(A:isSubsetOf(A))

-- realsubset

local A = set.RealSubset(0, 1, false, true) printbr(A, 'isSubsetOf', A) assert(A:isSubsetOf(A))

local A = set.RealSubset(0, 1, false, true) local B = set.RealSubset{{-1, 0, true, false}, {0, 1, false, true}} printbr(A, 'isSubsetOf', B) assert(A:isSubsetOf(B))
assert(set.RealSubset(0, math.huge, false, true):isSubsetOf(set.RealSubset{{-math.huge, 0, true, false}, {0, math.huge, false, true}}))

-- containing constants

assert(set.real:contains(inf) == true)	-- TODO technically that makes set.real the extended reals.  should I distinguish between real and extended real?
assert(set.positiveReal:contains(inf) == true)
assert(set.negativeReal:contains(inf) == false)
assert(set.nonNegativeReal:contains(inf) == true)
assert(set.nonPositiveReal:contains(inf) == false)
assert(set.positiveReal:contains(-inf) == nil)
assert(set.negativeReal:contains(-inf) == true)
assert(set.nonNegativeReal:contains(-inf) == nil)
assert(set.nonPositiveReal:contains(-inf) == true)


-- containing ranges of expressions

assert(set.real:contains(x))


-- x is in (-inf, inf).  
-- is x in (0, inf)?  
-- maybe.  
-- not certainly yes (subset).  
-- not certainly no (complement intersection / set subtraction is empty).  
-- so return nil
-- if x's set is a subset of this set then return true
-- if x's set is an intersection of this set then return nil
-- if x's set does not intersect this set then return false
assert(set.positiveReal:contains(x) == nil)	

assert(set.real:contains(sin(x)))
assert(set.RealSubset(-1,1,true,true):contains(sin(x)))

assert(not set.positiveReal:contains(abs(x)))
assert(set.nonNegativeReal:contains(abs(x)))

assert(set.complex:contains(x))

(function() local x = set.RealSubset(-1,1,true,true):var'x' assert(set.real:contains(asin(x))) end)()
(function() local x = set.RealSubset(-1,1,true,true):var'x' assert(set.real:contains(acos(x))) end)()

print(acos(x):getRealRange())
(function() local x = set.RealSubset(1,math.huge,true,true):var'x' assert(not set.real:contains(acos(x))) end)()	-- TODO eventually return uncertain / touches but not contains
(function() local x = set.RealSubset(1,math.huge,false,true):var'x' assert(not set.real:contains(acos(x))) end)()	-- TODO return definitely false

(function() local x = set.RealSubset(1,1,true,true):var'x' assert(set.real:contains(acos(x))) end)()

(function() local x = set.real:var'x' assert(abs(x)() == abs(x)) end)()

(function() local x = set.nonNegativeReal:var'x' assert(abs(x)() == x) end)()

(function() local x = set.nonNegativeReal:var'x' assert(abs(sinh(x))() == sinh(x)) end)()


-- x^2 should be positive
assert((x^2):getRealRange() == set.nonNegativeReal)
assert(set.nonNegativeReal:contains(x^2))

assert((Constant(2)^2):getRealRange() == set.RealSubset(4,4,true,true))
assert((Constant(-2)^2):getRealRange() == set.RealSubset(4,4,true,true))

assert(set.nonNegativeReal:contains(exp(x)))

-- 1/x should be disjoint
print((1/x):getRealRange())
assert((1/x):getRealRange():contains(0) == false)
assert((1/x):getRealRange():contains(1))

assert((1/x):getRealRange():contains(set.positiveReal))

-- ../../sin.lua:function sin:getRealRange()
-- ../../sin.lua:	local Is = self[1]:getRealRange()
-- ../../asinh.lua:asinh.getRealRange = require 'symmath.set.RealSubset'.getRealDomain_inc
-- ../../atan.lua:atan.getRealRange = require 'symmath.set.RealSubset'.getRealDomain_inc
-- ../../cosh.lua:cosh.getRealRange = require 'symmath.set.RealSubset'.getRealDomain_evenIncreasing
-- ../../acos.lua:function acos:getRealRange()
-- ../../acos.lua:	local Is = self[1]:getRealRange()
-- ../../tanh.lua:tanh.getRealRange = require 'symmath.set.RealSubset'.getRealDomain_inc
-- ../../asin.lua:asin.getRealRange = require 'symmath.set.RealSubset'.getRealDomain_pmOneInc
-- ../../sqrt.lua:sqrt.getRealRange = require 'symmath.set.RealSubset'.getRealDomain_posInc_negIm
-- ../../log.lua:log.getRealRange = require 'symmath.set.RealSubset'.getRealDomain_posInc_negIm
-- ../../acosh.lua:function acosh:getRealRange()
-- ../../acosh.lua:	local Is = x[1]:getRealRange()
-- ../../atanh.lua:atanh.getRealRange = require 'symmath.set.RealSubset'.getRealDomain_pmOneInc
-- ../../tan.lua:function tan:getRealRange()
-- ../../tan.lua:	local Is = self[1]:getRealRange()
-- ../../cos.lua:function cos:getRealRange()
-- ../../cos.lua:	local Is = self[1]:getRealRange()
-- ../../cos.lua:		-- here I'm going to add pi/2 and then just copy the sin:getRealRange() code
-- ../../sinh.lua:sinh.getRealRange = require 'symmath.set.RealSubset'.getRealDomain_inc
-- ../../abs.lua:abs.getRealRange = require 'symmath.set.RealSubset'.getRealDomain_evenIncreasing
-- 
-- ../../Constant.lua:function Constant:getRealRange()
-- ../../Expression.lua:function Expression:getRealRange()
-- ../../Variable.lua:function Variable:getRealRange()
-- 
-- ../../op/mul.lua:function mul:getRealRange()
-- ../../op/mul.lua:	local I = self[1]:getRealRange()
-- ../../op/mul.lua:		local I2 = self[i]:getRealRange()
-- ../../op/div.lua:function div:getRealRange()
-- ../../op/div.lua:	local I = self[1]:getRealRange()
-- ../../op/div.lua:	local I2 = self[2]:getRealRange()
-- ../../op/sub.lua:function sub:getRealRange()
-- ../../op/sub.lua:	local I = self[1]:getRealRange()
-- ../../op/sub.lua:		local I2 = self[i]:getRealRange()
-- ../../op/add.lua:function add:getRealRange()
-- ../../op/add.lua:	local I = self[1]:getRealRange()
-- ../../op/add.lua:		local I2 = self[i]:getRealRange()
-- ../../op/pow.lua:function pow:getRealRange()
-- ../../op/pow.lua:	local I = self[1]:getRealRange()
-- ../../op/pow.lua:	local I2 = self[2]:getRealRange()
-- ../../op/unm.lua:function unm:getRealRange()
-- ../../op/unm.lua:	local I = self[1]:getRealRange()
-- 
-- ../../set/RealSubset.lua:-- commonly used versions of the Expression:getRealRange function
-- ../../set/RealSubset.lua:function RealSubset.getRealDomain_evenIncreasing(x)
-- ../../set/RealSubset.lua:	local Is = x[1]:getRealRange()
-- ../../set/RealSubset.lua:function RealSubset.getRealDomain_posInc_negIm(x)
-- ../../set/RealSubset.lua:	local Is = x[1]:getRealRange()
-- ../../set/RealSubset.lua:function RealSubset.getRealDomain_pmOneInc(x)
-- ../../set/RealSubset.lua:	local Is = x[1]:getRealRange()
-- ../../set/RealSubset.lua:function RealSubset.getRealDomain_inc(x)
-- ../../set/RealSubset.lua:	local Is = x[1]:getRealRange()
-- ../../set/RealInterval.lua:	local I = x:getRealRange()

]=]), '\n')) do
	env.exec(line)
end

end)
