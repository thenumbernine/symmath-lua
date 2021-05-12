-- should these be singletons or classes?  how about singletons?
local RealInterval = require 'symmath.set.RealInterval'
local RealSubset = require 'symmath.set.RealSubset'

return {
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
	evenInteger = require 'symmath.set.EvenInteger'(),
	oddInteger = require 'symmath.set.OddInteger'(),
}
