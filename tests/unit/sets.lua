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

print(acos(x):getRealDomain())
(function() local x = set.RealSubset(1,math.huge,true,false):var'x' assert(not set.real:contains(acos(x))) end)()	-- TODO eventually return uncertain / touches but not contains
(function() local x = set.RealSubset(1,math.huge,false,false):var'x' assert(not set.real:contains(acos(x))) end)()	-- TODO return definitely false

(function() local x = set.RealSubset(1,1,true,true):var'x' assert(set.real:contains(acos(x))) end)()

(function() local x = set.real:var'x' assert(abs(x)() == abs(x)) end)()

(function() local x = set.nonNegativeReal:var'x' assert(abs(x)() == x) end)()

(function() local x = set.nonNegativeReal:var'x' assert(abs(sinh(x))() == sinh(x)) end)()


-- x^2 should be positive
assert((x^2):getRealDomain() == set.positiveReal)
assert(set.nonNegativeReal:contains(x^2))

assert((Constant(2)^2):getRealDomain() == set.RealSubset(4,4,true,true))
assert((Constant(-2)^2):getRealDomain() == set.RealSubset(4,4,true,true))

assert(set.nonNegativeReal:contains(exp(x)))

-- 1/x should be disjoint
print((1/x):getRealDomain())
assert((1/x):getRealDomain():contains(0) == false)
assert((1/x):getRealDomain():contains(1))

assert((1/x):getRealDomain():contains(set.positiveReal))

-- ../../sin.lua:function sin:getRealDomain()
-- ../../sin.lua:	local Is = self[1]:getRealDomain()
-- ../../asinh.lua:asinh.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_inc
-- ../../atan.lua:atan.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_inc
-- ../../cosh.lua:cosh.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_evenIncreasing
-- ../../acos.lua:function acos:getRealDomain()
-- ../../acos.lua:	local Is = self[1]:getRealDomain()
-- ../../tanh.lua:tanh.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_inc
-- ../../asin.lua:asin.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_pmOneInc
-- ../../sqrt.lua:sqrt.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_posInc_negIm
-- ../../log.lua:log.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_posInc_negIm
-- ../../acosh.lua:function acosh:getRealDomain()
-- ../../acosh.lua:	local Is = x[1]:getRealDomain()
-- ../../atanh.lua:atanh.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_pmOneInc
-- ../../tan.lua:function tan:getRealDomain()
-- ../../tan.lua:	local Is = self[1]:getRealDomain()
-- ../../cos.lua:function cos:getRealDomain()
-- ../../cos.lua:	local Is = self[1]:getRealDomain()
-- ../../cos.lua:		-- here I'm going to add pi/2 and then just copy the sin:getRealDomain() code
-- ../../sinh.lua:sinh.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_inc
-- ../../abs.lua:abs.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_evenIncreasing
-- 
-- ../../Constant.lua:function Constant:getRealDomain()
-- ../../Expression.lua:function Expression:getRealDomain()
-- ../../Variable.lua:function Variable:getRealDomain()
-- 
-- ../../op/mul.lua:function mul:getRealDomain()
-- ../../op/mul.lua:	local I = self[1]:getRealDomain()
-- ../../op/mul.lua:		local I2 = self[i]:getRealDomain()
-- ../../op/div.lua:function div:getRealDomain()
-- ../../op/div.lua:	local I = self[1]:getRealDomain()
-- ../../op/div.lua:	local I2 = self[2]:getRealDomain()
-- ../../op/sub.lua:function sub:getRealDomain()
-- ../../op/sub.lua:	local I = self[1]:getRealDomain()
-- ../../op/sub.lua:		local I2 = self[i]:getRealDomain()
-- ../../op/add.lua:function add:getRealDomain()
-- ../../op/add.lua:	local I = self[1]:getRealDomain()
-- ../../op/add.lua:		local I2 = self[i]:getRealDomain()
-- ../../op/pow.lua:function pow:getRealDomain()
-- ../../op/pow.lua:	local I = self[1]:getRealDomain()
-- ../../op/pow.lua:	local I2 = self[2]:getRealDomain()
-- ../../op/unm.lua:function unm:getRealDomain()
-- ../../op/unm.lua:	local I = self[1]:getRealDomain()
-- 
-- ../../set/RealSubset.lua:-- commonly used versions of the Expression:getRealDomain function
-- ../../set/RealSubset.lua:function RealSubset.getRealDomain_evenIncreasing(x)
-- ../../set/RealSubset.lua:	local Is = x[1]:getRealDomain()
-- ../../set/RealSubset.lua:function RealSubset.getRealDomain_posInc_negIm(x)
-- ../../set/RealSubset.lua:	local Is = x[1]:getRealDomain()
-- ../../set/RealSubset.lua:function RealSubset.getRealDomain_pmOneInc(x)
-- ../../set/RealSubset.lua:	local Is = x[1]:getRealDomain()
-- ../../set/RealSubset.lua:function RealSubset.getRealDomain_inc(x)
-- ../../set/RealSubset.lua:	local Is = x[1]:getRealDomain()
-- ../../set/RealInterval.lua:	local I = x:getRealDomain()

]=]), '\n')) do
	env.exec(line)
end
