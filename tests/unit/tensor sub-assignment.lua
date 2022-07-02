#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'tests/unit/tensor sub-assignment')

t,x,y,z = vars('t','x','y','z') 
coords = {t,x,y,z}
spatialCoords = {x,y,z}
chart = Tensor.Chart{coords=coords}
spatialVars = Tensor.Chart{symbols='ijklmn',coords=spatialCoords}
chart_t = Tensor.Chart{symbols='t', coords={t}}
chart_x = Tensor.Chart{symbols='x', coords={x}}
chart_y = Tensor.Chart{symbols='y', coords={y}}
chart_z = Tensor.Chart{symbols='z', coords={z}}

timer(nil, function()

for _,line in ipairs(string.split(string.trim([=[

B = Tensor('^ij', function(i,j) return var'b'('^'..coords[i+1].name..' '..coords[j+1].name) end) 
printbr(Array(B:dim()))

printbr(B'^ix'())
printbr(Array(B'^ix'():dim()))

-- rank-1 subtensor assignment

-- A is from the txyz chart, so it will have 4 elements accordingly
A = Tensor('^a', function(a) return var'a'('^'..coords[a].name) end)
printbr('A = '..A)
assert(A[1] == var'a''^t')
assert(A[2] == var'a''^x')
assert(A[3] == var'a''^y')
assert(A[4] == var'a''^z')

-- B is from the xyz chart, so it will have 3 elements accordingly
B = Tensor('^i', function(i) return var'b'('^'..coords[i+1].name) end) 
printbr('B = '..B)
assert(B[1] == var'b''^x')
assert(B[2] == var'b''^y')
assert(B[3] == var'b''^z')


A2 = A:clone()
A2['^i'] = B'^i'()
printbr('A2 = '..A2)
assertEq(A2[1], A[1])
assertEq(A2[2], B[1])	-- B uses the xyz chart so B.x is B[1]
assertEq(A2[3], B[2])
assertEq(A2[4], B[3])
assertEq(A2, Tensor('^a', A[1], B[1], B[2], B[3]))

-- rank-2 subtensor assignment

A = Tensor('^ab', function(a,b) return var'a'('^'..coords[a].name..' '..coords[b].name) end) 
printbr('A = '..A)
for i=1,4 do for j=1,4 do assertEq(A[i][j], var'a'('^'..coords[i].name..coords[j].name)) end end

B = Tensor('^ij', function(i,j) return var'b'('^'..coords[i+1].name..' '..coords[j+1].name) end) 
printbr('B = '..B)
for i=1,3 do for j=1,3 do assertEq(B[i][j], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end

A['^ij'] = B'^ij'()
printbr('A = '..A)
for j=1,4 do assertEq(A[1][j], var'a'('^t'..coords[j].name)) end
for i=1,4 do assertEq(A[i][1], var'a'('^'..coords[i].name..'t')) end
for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end

C = Tensor('^i', function(i) return var'c'('^'..coords[i+1].name) end)
printbr('C = '..C)

A['^ti'] = C'^i'()
printbr('A = '..A)
for j=1,3 do assertEq(A[1][j+1], var'c'('^'..spatialCoords[j].name)) end
for i=1,4 do assertEq(A[i][1], var'a'('^'..coords[i].name..'t')) end
for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end

A['^it'] = B'^ix'()
printbr('A = '..A)
assertEq(A[1][1], var'a''^tt')
for j=1,3 do assertEq(A[1][j+1], var'c'('^'..spatialCoords[j].name)) end
for i=1,3 do assertEq(A[i+1][1], var'b'('^'..spatialCoords[i].name..'x')) end
for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end

A['^tt'] = 2
printbr('A = '..A)
assertEq(A[1][1], Constant(2))
for j=1,3 do assertEq(A[1][j+1], var'c'('^'..spatialCoords[j].name)) end
for i=1,3 do assertEq(A[i+1][1], var'b'('^'..spatialCoords[i].name..'x')) end
for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end

A['^ij'] = 1
printbr('A = '..A)
assertEq(A[1][1], Constant(2))
for j=1,3 do assertEq(A[1][j+1], var'c'('^'..spatialCoords[j].name)) end
for i=1,3 do assertEq(A[i+1][1], var'b'('^'..spatialCoords[i].name..'x')) end
for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], Constant(1)) end end

]=]), '\n')) do
	env.exec(line)
end

env.done()
end)
