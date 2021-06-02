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
	RealInterval = RealInterval,
	RealSubset = RealSubset,
	--[[ these can just be RealInterval instances...
	NegativeReal = require 'symmath.set.NegativeReal',
	PositiveReal = require 'symmath.set.PositiveReal',
	NonNegativeReal = require 'symmath.set.NonNegativeReal',
	NonPositiveReal = require 'symmath.set.NonPositiveReal',
	--]]
	Integer = require 'symmath.set.Integer',
	EvenInteger = require 'symmath.set.EvenInteger',
	OddInteger = require 'symmath.set.OddInteger',
	Natural = require 'symmath.set.Natural',

	-- singletons
	universal = require 'symmath.set.Universal'(),
	null = require 'symmath.set.Null'(),
	complex = require 'symmath.set.Complex'(),
	real = RealSubset(-math.huge, math.huge, false, false),
	negativeReal = RealSubset(-math.huge, 0, false, false),
	positiveReal = RealSubset(0, math.huge, false, false),
	nonNegativeReal = RealSubset(0, math.huge, true, false),
	nonPositiveReal = RealSubset(-math.huge, 0, false, true),
	integer = require 'symmath.set.Integer'(),
	-- TODO integer quotient ring coset, as a generalization of these:
	evenInteger = require 'symmath.set.EvenInteger'(),
	oddInteger = require 'symmath.set.OddInteger'(),
	-- TODO positiveInteger, negativeInteger, nonPositiveInteger, nonNegativeInteger
	-- TODO TODO do this via behaviors that restrict 'containsNumber'
	-- TODO make natural just a reference
	natural = require 'symmath.set.Natural'(),
}
