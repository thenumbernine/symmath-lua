#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'solve')

env.x = var'x'

for _,line in ipairs(string.split(string.trim([=[

asserteq(#{x:eq(0):solve(x)}, 1)
asserteq(x:eq(0):solve(x), x:eq(0))

asserteq(#{x:eq(1):solve(x)}, 1)
asserteq(x:eq(1):solve(x), x:eq(1))

asserteq(#{(x+1):eq(0):solve(x)}, 1)
asserteq((x+1):eq(0):solve(x), x:eq(-1))

asserteq(#{(x^2):eq(0):solve(x)}, 1)	-- TODO only return a single value if it is duplicated? or is multiplicity important? what does the eigenvalue solver think of this?
asserteq((x^2):eq(0):solve(x), x:eq(0))

asserteq(#{(x^2):eq(1):solve(x)}, 2)
asserteq((x^2):eq(1):solve(x), x:eq(1))
asserteq(select(2, (x^2):eq(1):solve(x)), x:eq(-1))

asserteq(#{(x^2):eq(-1):solve(x)}, 2)
asserteq((x^2):eq(-1):solve(x), x:eq(i))
asserteq(select(2, (x^2):eq(-1):solve(x)), x:eq(-i))

-- distinguish between x*(x^2 + 2x + 1) and (x^3 + 2x^2 + x) , because the solver handles one but not the other
asserteq(#{(x * (x^2 + 2*x + 1)):eq(0)}, 3)
asserteq(#{(x^3 + 2*x^2 + x):eq(0)}, 3)

]=]), '\n')) do
	env.exec(line)
end
