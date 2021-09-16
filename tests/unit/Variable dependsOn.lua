#!/usr/bin/env lua
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'Variable dependsOn')

timer(nil, function()

env.env = env
env.x = var'x'
env.z = var'z'
env.zero = Constant(0)
env.delta = Tensor:deltaSymbol()
env.g = Tensor:metricSymbol()

-- TODO how about an 'asserteq' and an 'assertsimplifyeq'
for _,line in ipairs(string.split(string.trim([=[

-- testing dependency

y = symmath.var'y'
assert(#y:getDependentVars() == 0)
assert(#y'^p':getDependentVars() == 0)
assert(true == y:dependsOn(y))			-- depends regardless of specification
assert(false == y:dependsOn(y'^p'))		-- was not specified
assert(false == y'^p':dependsOn(y))		-- was not specified
assert(true == y'^p':dependsOn(y'^q'))	-- depends regardless of specification

y = symmath.var'y'
y:setDependentVars(x'^a')
assert(#y:getDependentVars() == 1 and y:getDependentVars()[1] == x'^a')
assert(#y'^p':getDependentVars() == 0)
assert(#y'^pq':getDependentVars() == 0)
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
assert(#y:getDependentVars() == 1 and y:getDependentVars()[1] == x)
assert(#y'^p':getDependentVars() == 0)
assert(#y'^pq':getDependentVars() == 0)
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
asserteq(y:diff(y), 1)
assert(y:diff(x)() == y:diff(x))	-- assert and not asserteq so the rhs doesn't simplify
asserteq(y:diff(x'^p'), zero)
asserteq(y:diff(x'^pq'), zero)
asserteq(y'^i':diff(x), zero)
asserteq(y'^i':diff(x'^p'), zero)
asserteq(y'^i':diff(x'^pq'), zero)
asserteq(y'^ij':diff(x), zero)
asserteq(y'^ij':diff(x'^p'), zero)
asserteq(y'^ij':diff(x'^pq'), zero)
asserteq(y:diff(x,z), zero)

asserteq(y'^p':diff(y'^q'), delta'^p_q')
asserteq(y'_p':diff(y'_q'), delta'_p^q')
asserteq(y'_p':diff(y'^q'), g'_pq')
asserteq(y'^p':diff(y'_q'), g'^pq')

asserteq(y'^pq':diff(y'^rs'), delta'^p_r' * delta'^q_s')


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
asserteq(y:diff(x), zero)
asserteq(y:diff(x'^p'), y:diff(x'^p'))
asserteq(y:diff(x'^pq'), zero)
asserteq(y'^i':diff(x), zero)
asserteq(y'^i':diff(x'^p'), zero)
asserteq(y'^i':diff(x'^pq'), zero)
asserteq(y'^ij':diff(x), zero)
asserteq(y'^ij':diff(x'^p'), zero)
asserteq(y'^ij':diff(x'^pq'), zero)

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
asserteq(y:diff(x), zero)
asserteq(y:diff(x'^p'), zero)
asserteq(y:diff(x'^pq'), zero)
asserteq(y'^i':diff(x), y'^i':diff(x))
asserteq(y'^i':diff(x'^p'), zero)
asserteq(y'^i':diff(x'^pq'), zero)
asserteq(y'^ij':diff(x), zero)
asserteq(y'^ij':diff(x'^p'), zero)
asserteq(y'^ij':diff(x'^pq'), zero)

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
asserteq(y:diff(x), zero)
asserteq(y:diff(x'^p'), zero)
asserteq(y:diff(x'^pq'), zero)
asserteq(y'^i':diff(x), zero)
asserteq(y'^i':diff(x'^p'), y'^i':diff(x'^p'))
asserteq(y'^i':diff(x'^pq'), zero)
asserteq(y'^ij':diff(x), zero)
asserteq(y'^ij':diff(x'^p'), zero)
asserteq(y'^ij':diff(x'^pq'), zero)

-- testing graph dependency z(y(x)), z depends on x
x = symmath.var'x'
y = symmath.var('y', {x})
z = symmath.var('z', {y})

assert(true == z:dependsOn(z))
assert(true == z:dependsOn(y))
-- hmm, how to handle graph dependencies ...
-- I'm not going to evaluate them for now, because they cause 
--  (1) infinite loops (unless I track search state) and 
--  (2) {u,v} depends on {t,x} makes a graph search produce u depends on v ...
--assert(true == z:dependsOn(x))
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
-- same as above, not doing a graph search.  should I?
--assert(true == z:dependsOn(x'^I'))
assert(false == y:dependsOn(z))
assert(true == y:dependsOn(y))
assert(true == y:dependsOn(x'^I'))
assert(false == x'^I':dependsOn(z))
assert(false == x'^I':dependsOn(y))
assert(true == x'^I':dependsOn(x'^I'))


-- make definite variable objects in our scope so implicit variable creation doesn't replace them and reset their state
-- alright, I'm at an impass here ...
-- before I fixed chain dependencies, I had a good system where {u,v}:depends{t,x} would only produce du/dt du/dx dv/dt dv/dx
-- but now, with chain dependencies, I'm also getting dv/du, du/dv, dt/dx, dx/dt ... and this is incorrect
u,v,t,x,y,z = vars('u','v','t','x','y','z')
u:setDependentVars(t,x)
v:setDependentVars(t,x)
t:setDependentVars(u,v)
x:setDependentVars(u,v)
allvars = table{u,v,t,x,y,z}
all = Matrix(allvars):T()
varofall = var('\\{'..allvars:mapi(function(v) return v.name end):concat','..'\\}')
print(varofall:diff(varofall):eq(Matrix:lambda({#all,#all}, function(i,j) return allvars[i]:diff(allvars[j])() end)))



]=]), '\n')) do
	env.exec(line)
end

end)
