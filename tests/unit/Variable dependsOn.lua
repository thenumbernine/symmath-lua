#!/usr/bin/env lua
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'tests/unit/Variable dependsOn')

timer(nil, function()

env.env = env
env.x = var'x'
env.z = var'z'
env.zero = Constant(0)
env.delta = Tensor:deltaSymbol()
env.g = Tensor:metricSymbol()

-- TODO how about an 'simplifyAssertEq' and an 'assertsimplifyeq'
for _,line in ipairs(string.split(string.trim([=[

-- testing dependency

y = symmath.var'y'
assertEq(#y:getDependentVars(), 0)
assertEq(#y'^p':getDependentVars(), 0)
assertEq(true, y:dependsOn(y))			-- depends regardless of specification
assertEq(false, y:dependsOn(y'^p'))		-- was not specified
assertEq(false, y'^p':dependsOn(y))		-- was not specified
assertEq(true, y'^p':dependsOn(y'^q'))	-- depends regardless of specification

y = symmath.var'y'
y:setDependentVars(x'^a')
assertEq(#y:getDependentVars() == 1 and y:getDependentVars()[1], x'^a')
assertEq(#y'^p':getDependentVars(), 0)
assertEq(#y'^pq':getDependentVars(), 0)
assertEq(false, y'^p':dependsOn(x))		-- was not specified
assertEq(false, y'^p':dependsOn(x'^q'))	-- was not specified
assertEq(true, y:dependsOn(x'^q'))		-- was specified
assertEq(false, y:dependsOn(x))			-- was not specified

y = symmath.var'y'
assertEq(false, y:dependsOn(x))			-- not by default
assertEq(false, y:dependsOn(x'^p'))
assertEq(false, y:dependsOn(x'^pq'))
assertEq(false, y'^i':dependsOn(x))
assertEq(false, y'^i':dependsOn(x'^p'))
assertEq(false, y'^i':dependsOn(x'^pq'))
assertEq(false, y'^ij':dependsOn(x))
assertEq(false, y'^ij':dependsOn(x'^p'))
assertEq(false, y'^ij':dependsOn(x'^pq'))
y:setDependentVars(x)
assertEq(#y:getDependentVars() == 1 and y:getDependentVars()[1], x)
assertEq(#y'^p':getDependentVars(), 0)
assertEq(#y'^pq':getDependentVars(), 0)
assertEq(true, y:dependsOn(x))
assertEq(false, y:dependsOn(x'^p'))
assertEq(false, y:dependsOn(x'^pq'))
assertEq(false, y'^i':dependsOn(x))
assertEq(false, y'^i':dependsOn(x'^p'))
assertEq(false, y'^i':dependsOn(x'^pq'))
assertEq(false, y'^ij':dependsOn(x))
assertEq(false, y'^ij':dependsOn(x'^p'))
assertEq(false, y'^ij':dependsOn(x'^pq'))

-- TODO this should be in tests/unit/diff.lua
simplifyAssertEq(y:diff(y), 1)
assertEq(y:diff(x)(), y:diff(x))	-- assert and not simplifyAssertEq so the rhs doesn't simplify
simplifyAssertEq(y:diff(x'^p'), zero)
simplifyAssertEq(y:diff(x'^pq'), zero)
simplifyAssertEq(y'^i':diff(x), zero)
simplifyAssertEq(y'^i':diff(x'^p'), zero)
simplifyAssertEq(y'^i':diff(x'^pq'), zero)
simplifyAssertEq(y'^ij':diff(x), zero)
simplifyAssertEq(y'^ij':diff(x'^p'), zero)
simplifyAssertEq(y'^ij':diff(x'^pq'), zero)
simplifyAssertEq(y:diff(x,z), zero)

simplifyAssertEq(y'^p':diff(y'^q'), delta'^p_q')
simplifyAssertEq(y'_p':diff(y'_q'), delta'_p^q')
simplifyAssertEq(y'_p':diff(y'^q'), g'_pq')
simplifyAssertEq(y'^p':diff(y'_q'), g'^pq')

simplifyAssertEq(y'^pq':diff(y'^rs'), delta'^p_r' * delta'^q_s')


y = symmath.var'y'
y:setDependentVars(x'^a')
assertEq(#y:getDependentVars(), 1)
assertEq(#y'^a':getDependentVars(), 0)
assertEq(false, y:dependsOn(x))
assertEq(true, y:dependsOn(x'^p'))
assertEq(false, y:dependsOn(x'^pq'))
assertEq(false, y'^i':dependsOn(x))
assertEq(false, y'^i':dependsOn(x'^p'))
assertEq(false, y'^i':dependsOn(x'^pq'))
assertEq(false, y'^ij':dependsOn(x))
assertEq(false, y'^ij':dependsOn(x'^p'))
assertEq(false, y'^ij':dependsOn(x'^pq'))
simplifyAssertEq(y:diff(x), zero)
simplifyAssertEq(y:diff(x'^p'), y:diff(x'^p'))
simplifyAssertEq(y:diff(x'^pq'), zero)
simplifyAssertEq(y'^i':diff(x), zero)
simplifyAssertEq(y'^i':diff(x'^p'), zero)
simplifyAssertEq(y'^i':diff(x'^pq'), zero)
simplifyAssertEq(y'^ij':diff(x), zero)
simplifyAssertEq(y'^ij':diff(x'^p'), zero)
simplifyAssertEq(y'^ij':diff(x'^pq'), zero)

y = symmath.var'y'
y'^a':setDependentVars(x)
assertEq(#y:getDependentVars(), 0)
assertEq(#y'^a':getDependentVars(), 1)
assertEq(false, y:dependsOn(x))
assertEq(false, y:dependsOn(x'^p'))
assertEq(false, y:dependsOn(x'^pq'))
assertEq(true, y'^i':dependsOn(x))
assertEq(false, y'^i':dependsOn(x'^p'))
assertEq(false, y'^i':dependsOn(x'^pq'))
assertEq(false, y'^ij':dependsOn(x))
assertEq(false, y'^ij':dependsOn(x'^p'))
assertEq(false, y'^ij':dependsOn(x'^pq'))
simplifyAssertEq(y:diff(x), zero)
simplifyAssertEq(y:diff(x'^p'), zero)
simplifyAssertEq(y:diff(x'^pq'), zero)
simplifyAssertEq(y'^i':diff(x), y'^i':diff(x))
simplifyAssertEq(y'^i':diff(x'^p'), zero)
simplifyAssertEq(y'^i':diff(x'^pq'), zero)
simplifyAssertEq(y'^ij':diff(x), zero)
simplifyAssertEq(y'^ij':diff(x'^p'), zero)
simplifyAssertEq(y'^ij':diff(x'^pq'), zero)

y = symmath.var'y'
y'^a':setDependentVars(x'^b')
assertEq(false, y:dependsOn(x))
assertEq(false, y:dependsOn(x'^p'))
assertEq(false, y:dependsOn(x'^pq'))
assertEq(false, y'^i':dependsOn(x))
assertEq(true, y'^i':dependsOn(x'^p'))
assertEq(false, y'^i':dependsOn(x'^pq'))
assertEq(false, y'^ij':dependsOn(x))
assertEq(false, y'^ij':dependsOn(x'^p'))
assertEq(false, y'^ij':dependsOn(x'^pq'))
simplifyAssertEq(y:diff(x), zero)
simplifyAssertEq(y:diff(x'^p'), zero)
simplifyAssertEq(y:diff(x'^pq'), zero)
simplifyAssertEq(y'^i':diff(x), zero)
simplifyAssertEq(y'^i':diff(x'^p'), y'^i':diff(x'^p'))
simplifyAssertEq(y'^i':diff(x'^pq'), zero)
simplifyAssertEq(y'^ij':diff(x), zero)
simplifyAssertEq(y'^ij':diff(x'^p'), zero)
simplifyAssertEq(y'^ij':diff(x'^pq'), zero)

-- testing graph dependency z(y(x)), z depends on x
x = symmath.var'x'
y = symmath.var('y', {x})
z = symmath.var('z', {y})

assertEq(true, z:dependsOn(z))
assertEq(true, z:dependsOn(y))
-- hmm, how to handle graph dependencies ...
-- I'm not going to evaluate them for now, because they cause 
--  (1) infinite loops (unless I track search state) and 
--  (2) {u,v} depends on {t,x} makes a graph search produce u depends on v ...
--assertEq(true, z:dependsOn(x))
assertEq(false, y:dependsOn(z))
assertEq(true, y:dependsOn(y))
assertEq(true, y:dependsOn(x))
assertEq(false, x:dependsOn(z))
assertEq(false, x:dependsOn(y))
assertEq(true, x:dependsOn(x))

assertEq(false, z:dependsOn(z'^I'))
assertEq(false, z:dependsOn(y'^I'))
assertEq(false, z:dependsOn(x'^I'))
assertEq(false, y:dependsOn(z'^I'))
assertEq(false, y:dependsOn(y'^I'))
assertEq(false, y:dependsOn(x'^I'))
assertEq(false, x:dependsOn(z'^I'))
assertEq(false, x:dependsOn(y'^I'))
assertEq(false, x:dependsOn(x'^I'))

assertEq(false, z'^I':dependsOn(z))
assertEq(false, z'^I':dependsOn(y))
assertEq(false, z'^I':dependsOn(x))
assertEq(false, y'^I':dependsOn(z))
assertEq(false, y'^I':dependsOn(y))
assertEq(false, y'^I':dependsOn(x))
assertEq(false, x'^I':dependsOn(z))
assertEq(false, x'^I':dependsOn(y))
assertEq(false, x'^I':dependsOn(x))

assertEq(true, z'^I':dependsOn(z'^I'))	-- by default
assertEq(false, z'^I':dependsOn(y'^I'))
assertEq(false, z'^I':dependsOn(x'^I'))
assertEq(false, y'^I':dependsOn(z'^I'))
assertEq(true, y'^I':dependsOn(y'^I'))	-- by default
assertEq(false, y'^I':dependsOn(x'^I'))
assertEq(false, x'^I':dependsOn(z'^I'))
assertEq(false, x'^I':dependsOn(y'^I'))
assertEq(true, x'^I':dependsOn(x'^I'))	-- by default


-- testing graph dependency z(y(x'^I')), z depends on x
x = symmath.var'x'
y = symmath.var'y'
y:setDependentVars(x'^I')
z = symmath.var'z'
z:setDependentVars(y)

assertEq(true, z:dependsOn(z))
assertEq(true, z:dependsOn(y))
-- same as above, not doing a graph search.  should I?
--assertEq(true, z:dependsOn(x'^I'))
assertEq(false, y:dependsOn(z))
assertEq(true, y:dependsOn(y))
assertEq(true, y:dependsOn(x'^I'))
assertEq(false, x'^I':dependsOn(z))
assertEq(false, x'^I':dependsOn(y))
assertEq(true, x'^I':dependsOn(x'^I'))


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
