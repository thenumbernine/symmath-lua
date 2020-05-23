#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, implicitVars=true, fixVariableNames=true, MathJax={title='matrix', pathToTryToFindMathJax='..'}}

function asserteq(a,b)
	printbr(a:eq(b))
	if a() ~= b() then
		local errorstr = "expected "..a.." == "..b
		print(errorstr)
		error(errorstr)
	end
end

function assertne(a,b)
	printbr(a:ne(b))
	if a() == b() then
		local errorstr = "expected "..a.." $\\ne$ "..b
		print(errorstr)
		error(errorstr)
	end
end

local function exec(str)
	printbr('<code>'..str..'</code>')
	printbr(assert(load('return '..str, nil, nil, env))())
end

-- vectors
exec[[Array(1,2,3)]]

exec[[Array(1,2) + Array(3,4)]]
exec[[(Array(1,2) + Array(3,4))()]]
exec[[asserteq((Array(1,2) + Array(3,4))(), Array(4,6))]]

-- numeric example

exec[[Matrix({1,2},{3,4})]]
exec[[Matrix({1,2},{3,4}):inverse()]]
exec[[asserteq(Matrix({1,2},{3,4}):inverse(), Matrix({-2,1},{frac(3,2),-frac(1,2)}))]]

-- 2D variable example

exec[[Matrix({a,b},{c,d})]]
exec[[Matrix({a,b},{c,d}):inverse()]]
exec[[asserteq(Matrix({a,b},{c,d}):inverse(), Matrix( {frac(d, a*d-b*c), frac(-b, a*d-b*c)}, {frac(-c, a*d-b*c), frac(a, a*d-b*c)} ))]]

-- 4D translation matrix

exec[[Matrix({1,0,0,t_x},{0,1,0,t_y},{0,0,1,t_z},{0,0,0,1})]]
exec[[Matrix({1,0,0,t_x},{0,1,0,t_y},{0,0,1,t_z},{0,0,0,1}):inverse()]]
exec[[asserteq(Matrix({1,0,0,t_x},{0,1,0,t_y},{0,0,1,t_z},{0,0,0,1}):inverse(), Matrix({1,0,0,-t_x},{0,1,0,-t_y},{0,0,1,-t_z},{0,0,0,1}))]]

-- 2D rotation matrix

m = Matrix({cos(theta), -sin(theta)}, {sin(theta), cos(theta)})
mInv = m:inverse()

exec[[m + mInv]]
exec[[(m + mInv)()]]
exec[[m * mInv]]
exec[[(m * mInv)()]]
exec[[asserteq( (m*mInv)(), Matrix({1,0},{0,1}) )]]

exec[[m*m]]
exec[[(m*m)()]]

m1 = Matrix({1,a},{0,1})
m2 = Matrix({1,0},{b,1})
exec[[(m1)]]
exec[[(m2)]]
exec[[(m1*m2):eq((m1*m2)())]]
exec[[(m2*m1):eq((m2*m1)())]]
exec[[m1:eq(m2)]]
exec[[assertne(m1, m2)]]

exec[[(m1*m2):eq(m2*m1)]]
exec[[assertne(m1*m2, m2*m1)]]

exec[[(m1*m2):eq(m1*m2)]]
exec[[asserteq(m1*m2, m1*m2)]]

exec[[(m1*m2):eq(m2*m1)()]]
exec[[assertne((m1*m2)(), (m2*m1)())]]

exec[[(Matrix({a},{b}) + Matrix({c},{d})) / t]]
exec[[((Matrix({a},{b}) + Matrix({c},{d})) / t)()]]
exec[[asserteq( ((Matrix({a},{b}) + Matrix({c},{d})) / t)(), Matrix({frac(a+c,t)}, {frac(b+d,t)}) )]]

-- linear system solver

exec[[Matrix({1,2},{3,4}):inverse(Matrix({5},{6}))]]
exec[[(Matrix({1,2},{3,4})*Matrix({1,2},{3,4}):inverse(Matrix({5},{6})))()]]
exec[[asserteq( (Matrix({1,2},{3,4})*Matrix({1,2},{3,4}):inverse(Matrix({5},{6})))(), Matrix({5},{6}) )]]
