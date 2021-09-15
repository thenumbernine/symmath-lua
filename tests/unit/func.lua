#!/usr/bin/env lua
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'func')

timer(nil, function()

-- not sure if this should be unit/func or unit/diff or unit/Derivative
for _,line in ipairs(string.split(string.trim([=[

x = var'x'

y = func('y', {x}, x^2)
-- TODO what to display...
-- y = x
-- y(x) = x
-- y(x) := x
print(y(x))
print(y(x)())
printbr(y:defeq())
assert(UserFunction.registeredFunctions.y == y)

-- if UserFunction is not a Variable then this is invalid
-- because you cannot have Functions as Variables in the arg list
-- f = func('f', {x, y}, x*y)
-- print(f:defeq())
-- assert(UserFunction.registeredFunctions.f == f)

-- instead, if UserFunction returns Functions, this is what you would see
-- and with this the derivative evaluation is obvious
f = func('f', {x}, x*y(x))
print(f:defeq())
assert(UserFunction.registeredFunctions.f == f)

-- diff() is partial derivative
-- totalDiff() is total derivative

-- total derivative evaluation
-- substitute chain rule for all terms
-- df/dx, when simplified, does not go anywhere, because f is dependent on x
-- for that reason, I can just build the equality f:eq(f.def) and apply :diff() to the whole thing:
print(f:defeq():diff(x):prune())
-- but TODO wrt total derivatives ... diff(y) ...
-- y(x) above is a UserFunction subclass
-- which means it isn't a Variable
-- which means you can't diff(y) ...
-- though you could diff(y(x)) ...
-- but that would be diff'ing wrt expressions, which I don't have support for
print(f:defeq():diff(y):prune())
print(f:defeq():diff(y(x)):prune())

s = var's'
t = var't'
x = func('x', {s,t})
y = func('y', {s,t})
f = func('f', {x,y})
print(f:diff(x):prune())	-- ∂f/∂x
print(f:diff(y):prune())	-- ∂f/∂y
print(f:diff(s):prune())	-- ∂f/∂x ∂x/∂s + ∂f/∂y ∂y/∂s
print(f:diff(t):prune())	-- ∂f/∂x ∂x/∂t + ∂f/∂y ∂y/∂t
-- TODO I need something to represent ∂/∂x "the def of f", rather than ∂/∂x "f", which is zero.
-- in contrast ∂/∂x "the def of f" would be a placeholder (in absense of f's provided definition)

]=]), '\n')) do
	env.exec(line)
end

end)
