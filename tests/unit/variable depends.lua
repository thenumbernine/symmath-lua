#!/usr/bin/env lua
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'variable depends')

env.env = env
env.x = var'x'
env.z = var'z'
env.zero = Constant(0)

for _,line in ipairs(string.split(string.trim([=[

-- testing dependency

y = symmath.var'y'
assert(true == y:dependsOn(y))			-- depends regardless of specification
assert(false == y:dependsOn(y'^p'))		-- was not specified
assert(false == y'^p':dependsOn(y))		-- was not specified
assert(true == y'^p':dependsOn(y'^q'))	-- dependsregardless of specification

y = symmath.var'y'
y:setDependentVars(x'^a')
assert(false == y'^p':dependsOn(x))		-- was not specified
assert(false == y'^p':dependsOn(x'^q'))	-- was not specified
assert(true == y:dependsOn(x'^q'))		-- was specified
assert(false == y:dependsOn(x))			-- was not specified

y = symmath.var'y'
assert(false == y:dependsOn(x))			-- not by default
assert(false == y:dependsOn(x'^p'))
assert(false == y:dependsOn(x'^pq'))
assert(false == y'^i':dependsOn(x))
assert(false == y'^i':dependsOn(x'^p'))
assert(false == y'^i':dependsOn(x'^pq'))
assert(false == y'^ij':dependsOn(x))
assert(false == y'^ij':dependsOn(x'^p'))
assert(false == y'^ij':dependsOn(x'^pq'))
y:setDependentVars(x)
assert(true == y:dependsOn(x))
assert(false == y:dependsOn(x'^p'))
assert(false == y:dependsOn(x'^pq'))
assert(false == y'^i':dependsOn(x))
assert(false == y'^i':dependsOn(x'^p'))
assert(false == y'^i':dependsOn(x'^pq'))
assert(false == y'^ij':dependsOn(x))
assert(false == y'^ij':dependsOn(x'^p'))
assert(false == y'^ij':dependsOn(x'^pq'))
-- TODO this should be in tests/unit/diff.lua
assert(y:diff(x)() == y:diff(x))
assert(y:diff(x'^p')() == zero)
assert(y:diff(x'^pq')() == zero)
assert(y'^i':diff(x)() == zero)
assert(y'^i':diff(x'^p')() == zero)
assert(y'^i':diff(x'^pq')() == zero)
assert(y'^ij':diff(x)() == zero)
assert(y'^ij':diff(x'^p')() == zero)
assert(y'^ij':diff(x'^pq')() == zero)
assert(y:diff(x,z)() == zero)

y = symmath.var'y'
y:setDependentVars(x'^a')
assert(false == y:dependsOn(x))
assert(true == y:dependsOn(x'^p'))
assert(false == y:dependsOn(x'^pq'))
assert(false == y'^i':dependsOn(x))
assert(false == y'^i':dependsOn(x'^p'))
assert(false == y'^i':dependsOn(x'^pq'))
assert(false == y'^ij':dependsOn(x))
assert(false == y'^ij':dependsOn(x'^p'))
assert(false == y'^ij':dependsOn(x'^pq'))
assert(y:diff(x)() == zero)
assert(y:diff(x'^p')() == y:diff(x'^p'))
assert(y:diff(x'^pq')() == zero)
assert(y'^i':diff(x)() == zero)
assert(y'^i':diff(x'^p')() == zero)
assert(y'^i':diff(x'^pq')() == zero)
assert(y'^ij':diff(x)() == zero)
assert(y'^ij':diff(x'^p')() == zero)
assert(y'^ij':diff(x'^pq')() == zero)

y = symmath.var'y'
y'^a':setDependentVars(x)
assert(false == y:dependsOn(x))
assert(false == y:dependsOn(x'^p'))
assert(false == y:dependsOn(x'^pq'))
assert(true == y'^i':dependsOn(x))
assert(false == y'^i':dependsOn(x'^p'))
assert(false == y'^i':dependsOn(x'^pq'))
assert(false == y'^ij':dependsOn(x))
assert(false == y'^ij':dependsOn(x'^p'))
assert(false == y'^ij':dependsOn(x'^pq'))
assert(y:diff(x)() == zero)
assert(y:diff(x'^p')() == zero)
assert(y:diff(x'^pq')() == zero)
assert(y'^i':diff(x)() == y'^i':diff(x))
assert(y'^i':diff(x'^p')() == zero)
assert(y'^i':diff(x'^pq')() == zero)
assert(y'^ij':diff(x)() == zero)
assert(y'^ij':diff(x'^p')() == zero)
assert(y'^ij':diff(x'^pq')() == zero)

y = symmath.var'y'
y'^a':setDependentVars(x'^b')
assert(false == y:dependsOn(x))
assert(false == y:dependsOn(x'^p'))
assert(false == y:dependsOn(x'^pq'))
assert(false == y'^i':dependsOn(x))
assert(true == y'^i':dependsOn(x'^p'))
assert(false == y'^i':dependsOn(x'^pq'))
assert(false == y'^ij':dependsOn(x))
assert(false == y'^ij':dependsOn(x'^p'))
assert(false == y'^ij':dependsOn(x'^pq'))
assert(y:diff(x)() == zero)
assert(y:diff(x'^p')() == zero)
assert(y:diff(x'^pq')() == zero)
assert(y'^i':diff(x)() == zero)
assert(y'^i':diff(x'^p')() == y'^i':diff(x'^p'))
assert(y'^i':diff(x'^pq')() == zero)
assert(y'^ij':diff(x)() == zero)
assert(y'^ij':diff(x'^p')() == zero)
assert(y'^ij':diff(x'^pq')() == zero)

-- testing graph dependency z(y(x)), z depends on x
x = symmath.var'x'
y = symmath.var('y', {x})
z = symmath.var('z', {y})

assert(true == z:dependsOn(z))
assert(true == z:dependsOn(y))
assert(true == z:dependsOn(x))
assert(false == y:dependsOn(z))
assert(true == y:dependsOn(y))
assert(true == y:dependsOn(x))
assert(false == x:dependsOn(z))
assert(false == x:dependsOn(y))
assert(true == x:dependsOn(x))

assert(false == z:dependsOn(z'^I'))
assert(false == z:dependsOn(y'^I'))
assert(false == z:dependsOn(x'^I'))
assert(false == y:dependsOn(z'^I'))
assert(false == y:dependsOn(y'^I'))
assert(false == y:dependsOn(x'^I'))
assert(false == x:dependsOn(z'^I'))
assert(false == x:dependsOn(y'^I'))
assert(false == x:dependsOn(x'^I'))

assert(false == z'^I':dependsOn(z))
assert(false == z'^I':dependsOn(y))
assert(false == z'^I':dependsOn(x))
assert(false == y'^I':dependsOn(z))
assert(false == y'^I':dependsOn(y))
assert(false == y'^I':dependsOn(x))
assert(false == x'^I':dependsOn(z))
assert(false == x'^I':dependsOn(y))
assert(false == x'^I':dependsOn(x))

assert(true == z'^I':dependsOn(z'^I'))	-- by default
assert(false == z'^I':dependsOn(y'^I'))
assert(false == z'^I':dependsOn(x'^I'))
assert(false == y'^I':dependsOn(z'^I'))
assert(true == y'^I':dependsOn(y'^I'))	-- by default
assert(false == y'^I':dependsOn(x'^I'))
assert(false == x'^I':dependsOn(z'^I'))
assert(false == x'^I':dependsOn(y'^I'))
assert(true == x'^I':dependsOn(x'^I'))	-- by default


-- testing graph dependency z(y(x'^I')), z depends on x
x = symmath.var'x'
y = symmath.var'y'
y:setDependentVars(x'^I')
z = symmath.var'z'
z:setDependentVars(y)

assert(true == z:dependsOn(z))
assert(true == z:dependsOn(y))
assert(true == z:dependsOn(x'^I'))
assert(false == y:dependsOn(z))
assert(true == y:dependsOn(y))
assert(true == y:dependsOn(x'^I'))
assert(false == x'^I':dependsOn(z))
assert(false == x'^I':dependsOn(y))
assert(true == x'^I':dependsOn(x'^I'))

]=]), '\n')) do
	env.exec(line)
end
