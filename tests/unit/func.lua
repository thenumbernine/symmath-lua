#!/usr/bin/env lua
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'func')

-- not sure if this should be unit/func or unit/diff or unit/Derivative
for _,line in ipairs(string.split(string.trim([=[

x = var'x'

y = func('y', {x}, x^2)
-- TODO what to display...
-- y = x
-- y(x) = x
-- y(x) := x
printbr(y:defeq())
assert(UserFunction.registeredFunctions.y == y)

f = func('f', {x, y}, x*y)
print(f:defeq())
assert(UserFunction.registeredFunctions.f == f)

-- diff() is total derivative
-- pdiff() is partial derivative

-- total derivative evaluation
-- substitute chain rule for all terms
-- df/dx, when simplified, does not go anywhere, because f is dependent on x
-- for that reason, I can just build the equality f:eq(f.def) and apply :diff() to the whole thing:
print(f:defeq():diff(x)())
print(f:defeq():diff(y)())

print(f:diff(x):eq(f.def:diff(x)()))
print(f:diff(y):eq(f.def:diff(y)()))

-- partial derivative evaluation ...
-- notice that var'f':pdiff(var'x') will return a zero, 
-- because the expression we are partially-differentiating against (f) does not contain the derivative variable (x)
-- so I have to construct each side of the equality separately for it to display correctly
print(f:pdiff(x):eq(f.def:pdiff(x)()))
print(f:pdiff(y):eq(f.def:pdiff(y)()))


]=]), '\n')) do
	env.exec(line)
end
