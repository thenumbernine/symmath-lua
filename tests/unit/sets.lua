#!/usr/bin/env lua
require 'symmath'()

x = set.real:var'x'
assert(set.real:contains(x))
assert(set.positiveReal:contains(x) == nil)

assert(set.real:contains(sin(x)))
assert(set.RealInterval(-1,1,true,true):contains(sin(x)))

assert(not set.positiveReal:contains(abs(x)))
assert(set.nonNegativeReal:contains(abs(x)))

assert(set.complex:contains(x))

x = set.RealInterval(-1,1,true,true):var'x'
assert(set.real:contains(asin(x)))

x = set.nonNegativeReal:var'x'
assert(abs(x)() == x)
assert(abs(sinh(x))() == sinh(x))
