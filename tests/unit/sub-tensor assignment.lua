#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup()
require 'symmath.tostring.MathJax'.setup()

local t,x,y,z = vars('t','x','y','z') 
local coords = {t,x,y,z}
Tensor.coords{
	{variables = {t,x,y,z}}, 
	{symbols = 'ijklmn',variables = {x,y,z}},
	{symbols = 't', variables={t}},
	{symbols = 'x', variables={x}},
	{symbols = 'y', variables={y}},
	{symbols = 'z', variables={z}},
}

printbr("rank-1 subtensor assignment")

A = Tensor('^a', function(a) return var'a'('^'..coords[a].name) end)
B = Tensor('^i', function(i) return var'b'('^'..coords[i+1].name) end) 
printbr('A = '..A)
printbr('B = '..B)
A['^i'] = B'^i'()
printbr('A = '..A)

printbr("rank-2 subtensor assignment")

A = Tensor('^ab', function(a,b) return var'a'('^'..coords[a].name..' '..coords[b].name) end) 
printbr('A = '..A)

B = Tensor('^ij', function(i,j) return var'b'('^'..coords[i+1].name..' '..coords[j+1].name) end) 
printbr('B = '..B)

A['^ij'] = B'^ij'()
printbr('A = '..A)

C = Tensor('^i', function(i) return var'c'('^'..coords[i+1].name) end)
printbr('C = '..C)

A['^ti'] = C'^i'()
printbr('A = '..A)

A['^it'] = B'^ix'()
printbr('A = '..A)

A['^tt'] = 2
printbr('A = '..A)

A['^ij'] = 1
printbr('A = '..A)
