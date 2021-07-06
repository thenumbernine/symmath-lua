#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'matrix')

timer(nil, function()

for n in ([[a b c d t t_x t_y t_z]]):gmatch'%S+' do
	env[n] = env.var(n)
end
env.theta = env.var'\\theta'

-- vectors
exec[[printbr(Array(1,2,3))]]

exec[[printbr(Array(1,2) + Array(3,4))]]
exec[[printbr((Array(1,2) + Array(3,4))())]]
exec[[asserteq((Array(1,2) + Array(3,4))(), Array(4,6))]]

-- numeric example

exec[[printbr(Matrix({1,2},{3,4}))]]
exec[[printbr(Matrix({1,2},{3,4}):inverse())]]
exec[[asserteq(Matrix({1,2},{3,4}):inverse(), Matrix({-2,1},{frac(3,2),-frac(1,2)}))]]

-- 2D variable example

exec[[printbr(Matrix({a,b},{c,d}))]]
exec[[printbr(Matrix({a,b},{c,d}):inverse())]]
exec[[asserteq(Matrix({a,b},{c,d}):inverse(), Matrix( {frac(d, a*d-b*c), frac(-b, a*d-b*c)}, {frac(-c, a*d-b*c), frac(a, a*d-b*c)} ))]]

-- 4D translation matrix

exec[[printbr(Matrix({1,0,0,t_x},{0,1,0,t_y},{0,0,1,t_z},{0,0,0,1}))]]
exec[[printbr(Matrix({1,0,0,t_x},{0,1,0,t_y},{0,0,1,t_z},{0,0,0,1}):inverse())]]
exec[[asserteq(Matrix({1,0,0,t_x},{0,1,0,t_y},{0,0,1,t_z},{0,0,0,1}):inverse(), Matrix({1,0,0,-t_x},{0,1,0,-t_y},{0,0,1,-t_z},{0,0,0,1}))]]

-- 2D rotation matrix

env.m = Matrix({cos(theta), -sin(theta)}, {sin(theta), cos(theta)})
env.mInv = m:inverse()

exec[[printbr(m + mInv)]]
exec[[printbr((m + mInv)())]]
exec[[printbr(m * mInv)]]
exec[[printbr((m * mInv)())]]
exec[[asserteq( (m*mInv)(), Matrix({1,0},{0,1}) )]]

exec[[printbr(m*m)]]
exec[[printbr((m*m)())]]

env.m1 = Matrix({1,a},{0,1})
env.m2 = Matrix({1,0},{b,1})
exec[[printbr(m1)]]
exec[[printbr(m2)]]
exec[[printbr((m1*m2):eq((m1*m2)()))]]
exec[[printbr((m2*m1):eq((m2*m1)()))]]
exec[[printbr(m1:eq(m2))]]
exec[[assertne(m1, m2)]]

exec[[printbr((m1*m2):eq(m2*m1))]]
exec[[assertne(m1*m2, m2*m1)]]

exec[[printbr((m1*m2):eq(m1*m2))]]
exec[[asserteq(m1*m2, m1*m2)]]

exec[[printbr((m1*m2):eq(m2*m1)())]]
exec[[assertne((m1*m2)(), (m2*m1)())]]

exec[[printbr((Matrix({a},{b}) + Matrix({c},{d})) / t)]]
exec[[printbr(((Matrix({a},{b}) + Matrix({c},{d})) / t)())]]
exec[[asserteq( ((Matrix({a},{b}) + Matrix({c},{d})) / t)(), Matrix({frac(a+c,t)}, {frac(b+d,t)}) )]]

-- linear system solver

exec[[printbr(Matrix({1,2},{3,4}):inverse(Matrix({5},{6})))]]
exec[[printbr((Matrix({1,2},{3,4})*Matrix({1,2},{3,4}):inverse(Matrix({5},{6})))())]]
exec[[asserteq( (Matrix({1,2},{3,4})*Matrix({1,2},{3,4}):inverse(Matrix({5},{6})))(), Matrix({5},{6}) )]]

end)
