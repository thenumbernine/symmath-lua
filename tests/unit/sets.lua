#!/usr/bin/env lua
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'unit'(env, 'match')

env.x = set.real:var'x'

for _,line in ipairs(string.split(string.trim([=[

assert(set.real:containsElement(x))
assert(set.RealDomain():contains(x))
assert(set.real:contains(x))
assert(set.positiveReal:contains(x) == nil)

assert(set.real:contains(sin(x)))
assert(set.RealDomain(-1,1,true,true):contains(sin(x)))

assert(not set.positiveReal:contains(abs(x)))
assert(set.nonNegativeReal:contains(abs(x)))

assert(set.complex:contains(x))

(function() local x = set.RealDomain(-1,1,true,true):var'x' assert(set.real:contains(asin(x))) end)()
(function() local x = set.RealDomain(-1,1,true,true):var'x' assert(set.real:contains(acos(x))) end)()

(function() local x = set.RealDomain(1,math.huge,true,false):var'x' assert(not set.real:contains(acos(x))) end)()	-- TODO eventually return uncertain / touches but not contains

(function() local x = set.RealDomain(1,math.huge,false,false):var'x' assert(not set.real:contains(acos(x))) end)()	-- TODO return definitely false

(function() local x = set.RealDomain(1,1,true,true):var'x' assert(set.real:contains(acos(x))) end)()

(function() local x = set.real:var'x' assert(abs(x)() == abs(x)) end)()

(function() local x = set.nonNegativeReal:var'x' assert(abs(x)() == x) end)()

(function() local x = set.nonNegativeReal:var'x' assert(abs(sinh(x))() == sinh(x)) end)()

-- ../../sin.lua:function sin:getRealDomain()
-- ../../sin.lua:	local Is = self[1]:getRealDomain()
-- ../../asinh.lua:asinh.getRealDomain = require 'symmath.set.RealDomain'.getRealDomain_inc
-- ../../atan.lua:atan.getRealDomain = require 'symmath.set.RealDomain'.getRealDomain_inc
-- ../../cosh.lua:cosh.getRealDomain = require 'symmath.set.RealDomain'.getRealDomain_evenIncreasing
-- ../../acos.lua:function acos:getRealDomain()
-- ../../acos.lua:	local Is = self[1]:getRealDomain()
-- ../../tanh.lua:tanh.getRealDomain = require 'symmath.set.RealDomain'.getRealDomain_inc
-- ../../asin.lua:asin.getRealDomain = require 'symmath.set.RealDomain'.getRealDomain_pmOneInc
-- ../../sqrt.lua:sqrt.getRealDomain = require 'symmath.set.RealDomain'.getRealDomain_posInc_negIm
-- ../../log.lua:log.getRealDomain = require 'symmath.set.RealDomain'.getRealDomain_posInc_negIm
-- ../../acosh.lua:function acosh:getRealDomain()
-- ../../acosh.lua:	local Is = x[1]:getRealDomain()
-- ../../atanh.lua:atanh.getRealDomain = require 'symmath.set.RealDomain'.getRealDomain_pmOneInc
-- ../../tan.lua:function tan:getRealDomain()
-- ../../tan.lua:	local Is = self[1]:getRealDomain()
-- ../../cos.lua:function cos:getRealDomain()
-- ../../cos.lua:	local Is = self[1]:getRealDomain()
-- ../../cos.lua:		-- here I'm going to add pi/2 and then just copy the sin:getRealDomain() code
-- ../../sinh.lua:sinh.getRealDomain = require 'symmath.set.RealDomain'.getRealDomain_inc
-- ../../abs.lua:abs.getRealDomain = require 'symmath.set.RealDomain'.getRealDomain_evenIncreasing
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
-- ../../set/RealDomain.lua:-- commonly used versions of the Expression:getRealDomain function
-- ../../set/RealDomain.lua:function RealDomain.getRealDomain_evenIncreasing(x)
-- ../../set/RealDomain.lua:	local Is = x[1]:getRealDomain()
-- ../../set/RealDomain.lua:function RealDomain.getRealDomain_posInc_negIm(x)
-- ../../set/RealDomain.lua:	local Is = x[1]:getRealDomain()
-- ../../set/RealDomain.lua:function RealDomain.getRealDomain_pmOneInc(x)
-- ../../set/RealDomain.lua:	local Is = x[1]:getRealDomain()
-- ../../set/RealDomain.lua:function RealDomain.getRealDomain_inc(x)
-- ../../set/RealDomain.lua:	local Is = x[1]:getRealDomain()
-- ../../set/RealInterval.lua:	local I = x:getRealDomain()

]=]), '\n')) do
	env.exec(line)
end
