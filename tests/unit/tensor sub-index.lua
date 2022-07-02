#! /usr/bin/env luajit
--[[
this is to make sure I can do subsets of charts
--]]

local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'tests/unit/tensor sub-index')

timer(nil, function()

--[[
in the current model I am assuming all letters automatically belong to the chart
another option is maybe to have indexes mean nothing until they are explicitly declared what summation/basis they are related to
an advantage of this is i could automatically make indexes with matching variable names be treated as those variables
but in that case i'd have to have a global variable registry for assicating index symbols(strings) with variables(objects)
--]]
x,y,z = vars('x', 'y', 'z')
xs = {x,y,z}
Tensor.Chart{coords=xs}
Tensor.Chart{coords={y,z}, symbols='pqrstuv'}
Tensor.Chart{coords={x}, symbols='x'}
Tensor.Chart{coords={y}, symbols='y'}
Tensor.Chart{coords={z}, symbols='z'}

T = Tensor('_ab', function(a,b)
	return var('T_{'..xs[a].name..xs[b].name..'}')
end)

for _,line in ipairs(string.split(string.trim([=[
printbr(T)

-- writing apparently does

printbr(T'_ij':prune())		assertEq(T'_ij':prune(), T)
printbr(T'_xx':prune())		assertEq(T'_xx':prune(), T[1][1])
printbr(T'_xy':prune())		assertEq(T'_xy':prune(), T[1][2])
printbr(T'_xz':prune())		assertEq(T'_xz':prune(), T[1][3])
printbr(T'_yx':prune())		assertEq(T'_yx':prune(), T[2][1])
printbr(T'_yy':prune())		assertEq(T'_yy':prune(), T[2][2])
printbr(T'_yz':prune())		assertEq(T'_yz':prune(), T[2][3])
printbr(T'_zx':prune())		assertEq(T'_zx':prune(), T[3][1])
printbr(T'_zy':prune())		assertEq(T'_zy':prune(), T[3][2])
printbr(T'_zz':prune())		assertEq(T'_zz':prune(), T[3][3])
printbr(T'_xp':prune())		assertEq(T'_xp':prune(), Tensor('_p', T[1][2], T[1][3]))
printbr(T'_yp':prune())		assertEq(T'_yp':prune(), Tensor('_p', T[2][2], T[2][3]))
printbr(T'_zp':prune())		assertEq(T'_zp':prune(), Tensor('_p', T[3][2], T[3][3]))
printbr(T'_px':prune())		assertEq(T'_px':prune(), Tensor('_p', T[2][1], T[3][1]))
printbr(T'_py':prune())		assertEq(T'_py':prune(), Tensor('_p', T[2][2], T[3][2]))
printbr(T'_pz':prune())		assertEq(T'_pz':prune(), Tensor('_p', T[2][3], T[3][3]))
printbr(T'_pq':prune())		assertEq(T'_pq':prune(), Tensor('_pq', {T[2][2], T[2][3]}, {T[3][2], T[3][3]}))

-- reading by __index doesn't work?
-- I guess only writing by __index does for now
-- but why bother read by __index when you can just use the __call operator with strings?
-- printbr(T['_ij'])		assertEq(T['_ij'], T)
-- printbr(T['_xx'])		assertEq(T['_xx'], T[1][1])
-- printbr(T['_xy'])		assertEq(T['_xy'], T[1][2])
-- printbr(T['_xz'])		assertEq(T['_xz'], T[1][3])
-- printbr(T['_yx'])		assertEq(T['_yx'], T[2][1])
-- printbr(T['_yy'])		assertEq(T['_yy'], T[2][2])
-- printbr(T['_yz'])		assertEq(T['_yz'], T[2][3])
-- printbr(T['_zx'])		assertEq(T['_zx'], T[3][1])
-- printbr(T['_zy'])		assertEq(T['_zy'], T[3][2])
-- printbr(T['_zz'])		assertEq(T['_zz'], T[3][3])
-- printbr(T['_xp'])		assertEq(T['_xp'])
-- printbr(T['_yp'])		assertEq(T['_yp'])
-- printbr(T['_zp'])		assertEq(T['_zp'])
-- printbr(T['_px'])		assertEq(T['_px'])
-- printbr(T['_py'])		assertEq(T['_py'])
-- printbr(T['_pz'])		assertEq(T['_pz'])
-- printbr(T['_pq'])		assertEq(T['_pq'])

]=]), '\n')) do
	env.exec(line)
end

env.done()
end)
