#!/usr/bin/env lua
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'tests/unit/match')

timer(nil, function()

env.W = Wildcard
env.const = Constant
env.zero = const(0)
env.one = const(1)
env.x = var'x'
env.y = var'y'
env.z = var'z'

for _,line in ipairs(string.split(string.trim([=[

simplifyAssertEq(x, x)
simplifyAssertNe(x, y)

assert(x:match(x))
assert(not x:match(y))

-- constants

simplifyAssertAllEq({const(2):match(const(2)*W(1))}, {const(1)})	-- implicit mul by 1
simplifyAssertAllEq({const(2):match(const(1)*W(1))}, {const(2)})
simplifyAssertAllEq({const(2):match(const(2)/W(1))}, {const(1)})	-- implicit divide by 1
simplifyAssertAllEq({const(4):match(const(2)*W(1))}, {const(2)})	-- implicit integer factoring

-- functions

simplifyAssertAllEq({sin(x):match(sin(W(1)))}, {x})

-- functions and mul mixed
simplifyAssertAllEq({sin(2*x):match(sin(W(1)))}, {2 * x})

simplifyAssertAllEq({sin(2*x):match(sin(2 * W(1)))}, {x})

-- matching c*f(x) => c*sin(a*x)
simplifyAssertAllEq({sin(2*x):match(W{1, dependsOn=x} * W{index=2, cannotDependOn=x})}, {sin(2*x), one})
simplifyAssertAllEq({sin(2*x):match(sin(W{1, cannotDependOn=x} * x))}, {const(2)})

-- add

simplifyAssertAllEq({x:match(W{2, cannotDependOn=x} + W{1, dependsOn=x})}, {x, zero})
simplifyAssertEq((x + y), (x + y))
assert((x + y):match(x + y))

-- add match to first term
simplifyAssertAllEq({(x + y):match(W(1) + y)}, {x})

-- add match to second term
simplifyAssertAllEq({(x + y):match(x + W(1))}, {y})

-- change order
simplifyAssertAllEq({(x + y):match(y + W(1))}, {x})

-- add match to zero, because nothing's left
simplifyAssertAllEq({(x + y):match(x + y + W(1))}, {zero})

simplifyAssertAllEq({(x + y):match(W(1))}, {x + y})

-- doubled-up matches should only work if they match
assert(not (x + y):match(W(1) + W(1)))

-- this too, this would work only if x + x and not x + y
simplifyAssertAllEq({(x + x):match(W(1) + W(1))}, {x})

-- this too
simplifyAssertAllEq({(x + x):match(W{1, atMost=1} + W{2, atMost=1})}, {x, x})

-- this should match (x+y), 0
simplifyAssertAllEq({(x + y):match(W(1) + W(2))}, {x + y, zero})

simplifyAssertAllEq({(x + y):match(W{1, atMost=1} + W{2, atMost=1})}, {x, y})

-- for these to work, I have to add the multi-wildcard stuff to the non-wildcard elements, handled in add.wildcardMatches
simplifyAssertAllEq({x:match(W(1) + W(2))}, {x, zero})

simplifyAssertAllEq({x:match(x + W(1) + W(2))}, {zero, zero})

simplifyAssertAllEq({x:match(W(1) + x + W(2))}, {zero, zero})

simplifyAssertAllEq({(x * y):match(W(1) + W(2))}, {x * y, zero})

-- make sure within add.wildcardMatches we greedy-match any wildcards with 'atLeast' before assigning the rest to zero
simplifyAssertAllEq({x:match(W(1) + W{2,atLeast=1} + W(3))}, {zero, x, zero})

-- now we match wildcards left-to-right, so the cannot-depend-on will match first
simplifyAssertAllEq({(x + y):match(W{1, cannotDependOn=x} + W{2, dependsOn=x})}, {y, x})

simplifyAssertAllEq({(x + y):match(W{1, cannotDependOn=x, atLeast=1} + W{2, dependsOn=x})}, {y, x})


-- same with mul

simplifyAssertAllEq({(x * y):match(y * W(1))}, {x})

simplifyAssertAllEq({(x * y):match(x * y * W(1))}, {one})

simplifyAssertAllEq({ (x * y):match(W(1))}, {x * y})

assert(not (x * y):match(W(1) * W(1)))

simplifyAssertAllEq({(x * x):match(W(1) * W(1))}, {x})

-- verify wildcards are greedy with multiple mul matching
-- the first will take all expressions, the second gets the empty set
simplifyAssertAllEq({(x * y):match(W(1) * W(2))}, {x * y, one})

-- verify 'atMost' works - since both need at least 1 entry, it will only match when each gets a separate term
simplifyAssertAllEq({(x * x):match(W{1, atMost=1} * W{2, atMost=1})}, {x, x})

-- verify 'atMost' cooperates with non-atMost wildcards
simplifyAssertAllEq({(x * y):match(W(1) * W{2, atLeast=1})}, {x, y})

simplifyAssertAllEq({(x * y):match(W{1, atMost=1} * W{2, atMost=1})}, {x, y})

assert( not( Constant(0):match(x) ) )
assert( not( Constant(0):match(x * y) ) )

simplifyAssertEq( zero:match(W(1) * x), zero )
assert( not zero:match(W{1, dependsOn=x} * x) )

simplifyAssertEq( zero:match(W(1) * x * y), zero )

simplifyAssertEq( one:match(1 + W(1)), zero )

simplifyAssertEq( one:match(1 + W(1) * x), zero )

simplifyAssertEq( one:match(1 + W(1) * x * y), zero )


-- how can you take x*y and match only the 'x'?

simplifyAssertAllEq({(x * y):match(W{index=2, cannotDependOn=x} * W{1, dependsOn=x})}, {x, y})

simplifyAssertAllEq({(x * y):match(W{1, dependsOn=x} * W{index=2, cannotDependOn=x})}, {x*y, 1})

simplifyAssertAllEq({(x * y):match(W{index=2, cannotDependOn=x} * W(1))}, {x, y})

simplifyAssertAllEq({(x * y):match(W(1) * W{index=2, cannotDependOn=x})}, {x*y, 1})

simplifyAssertAllEq({(x * y):match(W(1) * W(2))}, {x*y, 1})


-- combinations of add and mul


-- for this to work, add.wildcardMatches must call the wildcard-capable objects' own wildcard handlers correctly (and use push/pop match states, instead of assigning to wildcard indexes directly?)
-- also, because add.wildcardMatches assigns the extra wildcards to zero, it will be assigning (W(2) * W(3)) to zero ... which means it must (a) handle mul.wildcardMatches and (b) pick who of mul's children gets the zero and who doesn't
--  it also means that a situation like add->mul->add might have problems ... x:match(W(1) + (W(2) + W(3)) * (W(4) + W(5)))
do local i,j,k = x:match(W(1) + W(2) * W(3)) assertEq(i, x) assert(j == zero or k == zero) end


--  cross over add and mul ... not yet working
--local i = (x):match(W(1) + x)	-- works
do local i = (x * y):match(W(1) + x * y) assertEq(i, zero) end

-- either 1 or 2 must be zero, and either 3 or 4 must be zero
do local i,j,k,l = x:match(x + W(1) * W(2) + W(3) * W(4)) assert(i == zero or j == zero) assert(k == zero or l == zero) end

do local c, f = (2 * x):match(W{1, cannotDependOn=x} * W{2, dependsOn=x}) assertEq(c, const(2)) assertEq(f, x) end

do local c, f = (2 * x):match(W{1, cannotDependOn=x} * W{2, dependsOn=x}) assertEq(c, const(2)) assertEq(f, x) end

-- Put the 'cannotDependOn' wildcard first (leftmost) in the mul for it to greedily match non-dep-on-x terms
-- otherwise 'dependsOn' will match everything, since the mul of a non-dep and a dep itself is dep on 'x', so it will include non-dep-on-terms
do local c, f = (2 * 1/x):factorDivision():match(W{index=1, cannotDependOn=x} * W{2, dependsOn=x}) assertEq(c, const(2)) assertEq(f, 1/x) end

do local c, f = (2 * 1/x):factorDivision():match(W{1, cannotDependOn=x} * W(2)) assertEq(c, const(2)) assertEq(f, 1/x) end

simplifyAssertAllEq({ (x + 2*y):match(W(1) + W(2) * y) }, {x,2})

simplifyAssertAllEq({ (x + 2*y):match(W(1) * x + W(2) * y) }, {1,2})

simplifyAssertAllEq( {x:match( W(1)*x + W(2))}, {1, 0})

simplifyAssertAllEq( {x:match( W(1)*x + W(2)*y)}, {1, 0})

-- div


do local i = (1/x):match(1 / W(1)) assertEq(i, x) end

do local i = (1/x):match(1 / (W(1) * x)) assertEq(i, one) end

do local i = (1/x):match(1 / (W{1, cannotDependOn=x} * x)) assertEq(i, one) end

assert((2 * 1/x):match(2 * 1/x))

do local i = (2 * 1/x):match(2 * 1/W(1)) assertEq(i, x) end

do local i = (2 * 1/x):match(2 * 1/(W(1) * x)) assertEq(i, one) end

do local i, j = (2 * 1/x):factorDivision():match(W{1, atMost=1} * W{index=2, atMost=1}) assertEq(i, const(2)) assertEq(j, 1/x) end

do local a, b = (1/(x*(3*x+4))):match(1 / (x * (W{1, cannotDependOn=x} * x + W{2, cannotDependOn=x}))) assertEq(a, const(3)) assertEq(b, const(4)) end

do local a, b = (1/(x*(3*x+4))):factorDivision():match(1 / (W{1, cannotDependOn=x} * x * x + W{2, cannotDependOn=x} * x)) assertEq(a, const(3)) assertEq(b, const(4)) end

-- pow

simplifyAssertAllEq({(x^2):match(x^W(1))}, {const(2)})
simplifyAssertAllEq({(x^2):match(W(1)^2)}, {x})
simplifyAssertAllEq({(x^2):match(W(1)^W(2))}, {x, 2})
-- defaults:
simplifyAssertAllEq({(x):match(x^W(1))}, {const(1)})
simplifyAssertAllEq({(x):match(W(1)^1)}, {x})
simplifyAssertAllEq({(x):match(W(1)^W(2))}, {x, const(1)})

-- etc

do local expr = sin(2*x) + cos(3*x) local a,b = expr:match( sin(W(1)) + cos(W(2)) ) print(a[1], a[2] ,b) end
do local expr = sin(2*x) * cos(3*x) local a,b = expr:match( sin(W(1)) * cos(W(2)) ) print(a[1], a[2] ,b) end

do local expr = (3*x^2 + 1) printbr('expr', expr) local a, c = expr:match(W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x}) printbr('a', a) printbr('c', c) simplifyAssertAllEq({a, c}, {3, 1}) end

do local expr = (3*x^2 + 2*x + 1) printbr('expr', expr) local a, b, c = expr:match(W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x} * x + W{3, cannotDependOn=x}) printbr('a', a) printbr('b', b) printbr('c', c) simplifyAssertAllEq({a, b, c}, {3, 2, 1}) end

do local expr = (3*x^2 + 1):factorDivision() printbr('expr', expr) local a, b, c = expr:match(W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x} * x + W{3, cannotDependOn=x}) printbr('a', a) printbr('b', b) printbr('c', c) simplifyAssertAllEq({a, b, c}, {3, 0, 1}) end
do local expr = (3*x*x + 2*x + 1):factorDivision() printbr('expr', expr) local a, b, c = expr:match(W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x} * x + W{3, cannotDependOn=x}) printbr('a', a) printbr('b', b) printbr('c', c) simplifyAssertAllEq({a, b, c}, {3, 2, 1}) end
do local expr = (1/(3*x*x + 2*x + 1)):factorDivision() printbr('expr', expr) local a, b, c = expr:match(1 / (W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x} * x + W{3, cannotDependOn=x})) printbr('a', a) printbr('b', b) printbr('c', c) simplifyAssertAllEq({a, b, c}, {3, 2, 1}) end
do local expr = (x/(3*x*x + 2*x + 1)):factorDivision() printbr('expr', expr) local a, b, c = expr:match(1 / (W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x} * x + W{3, cannotDependOn=x})) printbr('a', a) printbr('b', b) printbr('c', c) simplifyAssertAllEq({a, b, c}, {3, 2, 1}) end

-- TensorRef

local a = x'^i':match(Tensor.Ref(x, W(1))) simplifyAssertEq(a, Tensor.Index{symbol='i', lower=false})


]=]), '\n')) do
	env.exec(line)
end

env.done()
end)
