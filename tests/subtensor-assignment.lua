#!/usr/bin/env luajit
require 'ext'
local symmath=require'symmath' 

local Tensor = symmath.Tensor 
local t,x,y,z = symmath.vars('t','x','y','z') 
local coords = {t,x,y,z}
Tensor.coords{
	{variables = {t,x,y,z}}, 
	{symbols = 'ijklmn',variables = {x,y,z}},
	{symbols = 't', variables={t}},
	{symbols = 'x', variables={x}},
	{symbols = 'y', variables={y}},
	{symbols = 'z', variables={z}},
}

print("rank-1 subtensor assignment")

A = Tensor('^a', function(a) return symmath.var('a^'..coords[a].name) end) 
B = Tensor('^i', function(i) return symmath.var('b^'..coords[i+1].name) end) 
print('A = '..A)
print('B = '..B)
A['^i'] = B'^i'()
print('A = '..A)

print("rank-2 subtensor assignment")

A = Tensor('^ab', function(a,b) return symmath.var('a^'..coords[a].name..coords[b].name) end) 
print('A = '..A)

B = Tensor('^ij', function(i,j) return symmath.var('b^'..coords[i+1].name..coords[j+1].name) end) 
print('B = '..B)

A['^ij'] = B'^ij'()
print('A = '..A)

C = Tensor('^i', function(i) return symmath.var('c^'..coords[i+1].name) end)
print('C = '..C)

A['^ti'] = C'^i'()
print('A = '..A)

A['^it'] = B'^ix'()
print('A = '..A)

-- TODO get rid of the requirement to wrap single-element assignmets in at least one single-rank, single-dim Tensor
A['^tt'] = Tensor('^t', 2)
print('A = '..A)
