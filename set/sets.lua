-- should these be singletons or classes?  how about singletons?
local RealInterval = require 'symmath.set.RealInterval'
local RealSubset = require 'symmath.set.RealSubset'

--[[
so with exporters, I had the .lua file return an instance of the class.
and I had subclasses subclass the singleton's .class.

But here I'm putting both singletones and classes in the table, exposed.

Which is better design?
--]]
return {
	-- classes
	Universal = require 'symmath.set.Universal',
	Null = require 'symmath.set.Null',
	Complex = require 'symmath.set.Complex',
	
	--Real = require 'symmath.set.Real',
	
--[[
TODO instead: Real with conditions:
x in Real, min {< | <=} x && x {< | <=} max 
so now we now need boolean operations:
set cond: 
	_or(
		(min1:l|le(x)):_and(x:l|le(max1)),
		...
		(minN:l|le(x)):_and(x:l|le(maxN))
	)

then ... how do you determine if one logical expression implies another logical impression?

evaluate A:_impl(B), which is equivalent to _not(A):_or(B)

triangle inequality: a <= b, b <= c implies a <= c

so how do we evaluate whether the expression is true?

	_and( a:le(b), b:le(c) ):impl( a:le(c) ):isTrue() == true
	- but how do we do this? 
	-- how does the triangle inequality result in this to be true?
	- and what constitutes as 'false' ?

--]]
	RealInterval = RealInterval,
	
	RealSubset = RealSubset,
	Integer = require 'symmath.set.Integer',
	EvenInteger = require 'symmath.set.EvenInteger',
	OddInteger = require 'symmath.set.OddInteger',
	Natural = require 'symmath.set.Natural',

	-- singletons
	universal = require 'symmath.set.Universal'(),
	null = require 'symmath.set.Null'(),
	complex = require 'symmath.set.Complex'(),
	-- reals = (-inf, inf)
	-- extended reals = [-inf,inf]
	-- but do other CAS's distinguish?
	real = RealSubset(-math.huge, math.huge, true, true),
	-- [[ TODO instead of these, use expressions to define the regions
	-- and then use :solve() and :isTrue() to evaluate
	-- and try to do the same thing with integers, esp for {Z mod p = q}
	-- ... but this gets into automatic proof solving
	negativeReal = RealSubset(-math.huge, 0, true, false),
	positiveReal = RealSubset(0, math.huge, false, true),
	nonPositiveReal = RealSubset(-math.huge, 0, true, true),
	nonNegativeReal = RealSubset(0, math.huge, true, true),
	--]]
	integer = require 'symmath.set.Integer'(),
	-- TODO integer quotient ring coset, as a generalization of these:
	evenInteger = require 'symmath.set.EvenInteger'(),
	oddInteger = require 'symmath.set.OddInteger'(),
	-- TODO positiveInteger, negativeInteger, nonPositiveInteger, nonNegativeInteger
	-- TODO TODO do this via behaviors that restrict 'containsNumber'
	-- TODO make natural just a reference
	natural = require 'symmath.set.Natural'(),
}
