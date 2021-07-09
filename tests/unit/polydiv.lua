#!/usr/bin/env lua
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'polydiv')

timer(nil, function()

env.a = var'a'
env.x = var'x'
env.verbose = false

_G.printbr = printbr

for _,line in ipairs(string.split(string.trim([=[

assertalleq({(x - a):polydivr(x - a, x, verbose)}, {1,0})
assertalleq({(x^2 - a):polydivr(x - sqrt(a), x, verbose)}, {x + sqrt(a),0})

assertalleq({(x^2 + 2 * x * a + a^2):polydivr(x + a, x, verbose)}, {x + a, 0})
assertalleq({(x^2 - 2 * x * a + a^2):polydivr(x - a, x, verbose)}, {x - a, 0})

assertalleq({(x^2 - a^2):polydivr(x - a, x, verbose)}, {x + a, 0})		
assertalleq({(x^2 - a^2):polydivr(x + a, x, verbose)}, {x - a, 0})

]=]), '\n')) do
	env.exec(line)
end

end)
