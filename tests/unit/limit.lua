#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'limit')

timer(nil, function()

env.a = symmath.Variable('a')
env.b = symmath.Variable('b')
env.g = symmath.Variable('g')
env.s = symmath.Variable('s')
env.t = symmath.Variable('t')
env.v = symmath.Variable('v')
env.x = symmath.Variable('x')
env.y = symmath.Variable('y')

-- constant simplificaiton
for _,line in ipairs(string.split(string.trim([=[

asserteq(lim(x, x, a), a)
asserteq(lim(x, x, a, '+'), a)
asserteq(lim(x, x, a, '-'), a)

-- constants
asserteq(lim(0, x, a), 0)
asserteq(lim(1, x, a), 1)

-- ops
asserteq(lim(x + 2, x, a), a + 2)
asserteq(lim(x + x, x, a), 2 * a)
asserteq(lim(x + a, x, a), 2 * a)
asserteq(lim(a + a, x, a), 2 * a)
asserteq(lim(x * 2, x, a), 2 * a)
asserteq(lim(x / 2, x, a), a / 2)

-- involving infinity
asserteq(lim(x, x, inf), inf)
asserteq(lim(x, x, -inf), -inf)
asserteq(lim(x, x, inf), inf)
asserteq(lim(1/x, x, inf), 0)
asserteq(lim(1/x, x, -inf), 0)
asserteq(lim(1/x, x, 0), invalid)

asserteq(lim(1/x, x, 0, '+'), inf)
asserteq(lim(1/x, x, 0, '-'), -inf)

asserteq(lim(1/x^2, x, 0, '+'), inf)
asserteq(lim(1/x^2, x, 0, '-'), inf)

-- functions
asserteq(lim(x * sin(x), x, a), a * sin(a))		-- functions


]=]), '\n')) do
	env.exec(line)
end

end)
