#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'match')

for _,line in ipairs(string.split(string.trim([=[

a,b,c = symmath.vars('a', 'b', 'c')
x,y,z = symmath.vars('x', 'y', 'z')

expr = a * x + b * y + c * z
assert(expr:replace(a * x, 1) == 1 + b * y + c * z)
assert(expr:replace(b * y, 1) == 1 + a * x + c * z)
assert(expr:replace(c * z, 1) == 1 + a * x + b * y)
assert(expr:replace(a * x + b * y, 1) == 1 + c * z)
assert(expr:replace(a * x + c * z, 1) == 1 + b * y)
assert(expr:replace(b * y + c * z, 1) == 1 + a * x)
assert(expr:replace(b * y + c * z, 1) == 1 + a * x)
assert(expr:replace(a * x + b * y + c * z, 1) == symmath.Constant(1))

]=]), '\n')) do
	env.exec(line)
end
