#!/usr/bin/env lua
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'match')

env.x = set.real:var'x'

for _,line in ipairs(string.split(string.trim([=[

-- TODO do unit tests with the RealInterval / RealSubset operators

assert(set.positiveReal:contains(set.positiveReal))

assert(set.real:containsElement(x))
assert(set.RealSubset():contains(x))
assert(set.real:contains(x))
assert(set.positiveReal:contains(x) == nil)

assert(set.real:contains(sin(x)))
assert(set.RealSubset(-1,1,true,true):contains(sin(x)))

assert(not set.positiveReal:contains(abs(x)))
assert(set.nonNegativeReal:contains(abs(x)))

assert(set.complex:contains(x))

(function() local x = set.RealSubset(-1,1,true,true):var'x' assert(set.real:contains(asin(x))) end)()
(function() local x = set.RealSubset(-1,1,true,true):var'x' assert(set.real:contains(acos(x))) end)()

print(acos(x):getRealRange())
(function() local x = set.RealSubset(1,math.huge,true,false):var'x' assert(not set.real:contains(acos(x))) end)()	-- TODO eventually return uncertain / touches but not contains
(function() local x = set.RealSubset(1,math.huge,false,false):var'x' assert(not set.real:contains(acos(x))) end)()	-- TODO return definitely false

(function() local x = set.RealSubset(1,1,true,true):var'x' assert(set.real:contains(acos(x))) end)()

(function() local x = set.real:var'x' assert(abs(x)() == abs(x)) end)()

(function() local x = set.nonNegativeReal:var'x' assert(abs(x)() == x) end)()

(function() local x = set.nonNegativeReal:var'x' assert(abs(sinh(x))() == sinh(x)) end)()


-- x^2 should be positive
assert((x^2):getRealRange() == set.positiveReal)
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
