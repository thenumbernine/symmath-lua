#!/usr/bin/env luajit
--[[
testing my linear solver, most of which I've crammed into symmath.matrix.inverse (even though this is now starting to include over- and under-constrained systems)
--]]
require 'ext'
local symmath = require 'symmath'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
print(MathJax.header)
local printbr = MathJax.print
local var = symmath.var
local frac = symmath.divOp

for _,info in ipairs{
	{
		A = {
			{3, 2, -1},
			{2, -2, 4},
			{-1, frac(1,2), -1}
		},
		b = {{1}, {-2}, {0}},
	},
	{
		A = {
			{2, 3},
			{4, 9},
		},
		b = {{6}, {15}},
	},

	-- over-constrained with solution
	{
--[[
for a specific inverse:
1	-2	|	-1
3	5	|	8
4	3	|	7

1	-2	|	-1
0	11	|	11	<- row2 - 3*row1
0	11	|	11	<- row3 - 4*row1

1	-2	|	-1
0	1	|	1	<- row2 / 11
0	11	|	11

1	0	|	1	<- row1 + 2*row2
0	1	|	1	
0	0	|	0	<- row3 - 11*row2

general:
1	-2	|	1	0 	1
3	5	|	0	1	0
4	3	|	0	0	1

1	-2	|	1	0 	1
0	11	|	-3	1	0	<- row2 - 3*row1
0	11	|	-4	0	1	<- row3 - 4*row1

1	-2	|	1		0 		1
0	1	|	-3/11	1/11	0	<- row2 / 11
0	11	|	-4		0		1	

1	0	|	5/11	2/11	1	<- row1 + 2*row2
0	1	|	-3/11	1/11	0	
0	0	|	-1		-1		1	<- row3 - 11*row2
--]]
		A = {
			{1, -2},
			{3, 5},
			{4, 3},
		},
		b = {{-1}, {8}, {7}},
	},
	-- no solutions
	{
		A = {
			{3, 2},
			{3, 2},
		},
		b = {{6}, {12}},
	},
	{
		A = {
			{1, 1},
			{2, 1},
			{3, 2},
		},
		b = {{1}, {1}, {3}},
	},
--[[
u = coord chart:
	x = r cos phi
	y = r sin phi
	z = z

inverse:
	phi = atan2(y,x)
	z = z

dx^i/du^j:
	dx/dphi, dy/dz = -r sin(phi), 0
	dy/dphi, dy/dz =  r cos*phi), 0
	dz/dphi, dz/dz = 0, 1

du^i/dx^j:
	dphi/dx, dphi/dy, dphi/dz 	= -sin(phi)/r, cos(phi)/r, 0
	dz/dx, dz/dy, dz/dz 		= 0, 0, 1

du^i/dx^k * dx^k/du^j:
	1, 0,
	0, 1

dx^i/du^k * du^k/dx^j:
	sin(phi)^2, -sin(phi) cos(phi), 0
	-sin(phi) cos(phi), cos(phi)^2, 0
	0, 0, 1
because the number of dimensions of the parameters is less than of the embedding, we don't get an inverse both ways

--]]
} do
	local A = symmath.Matrix(table.unpack(info.A))
	local b = symmath.Matrix(table.unpack(info.b))

	printbr(( var'A' * var'x' ):eq( var'b' ))
	local x = symmath.Matrix(range(#A[1]):map(function(i)
		return range(#b[1]):map(function(j)
			return var('x_{'..i..','..j..'}')
		end)
	end):unpack())
	printbr((A * x):eq(b))
	local AInv, AInv_extra, AInv_msg = A:inverse()
	local AInvB, AInvB_extra, AInvB_msg = A:inverse(b)
	printbr((var'A'^-1):eq(AInv), 'extra', AInv_extra, 'message', AInv_msg)
	printbr([[$A^{-1} \cdot b =$]],(AInv * b)())
	printbr(var'A'^-1,'$(b)=$', AInvB, 'extra', AInvB_extra, 'message', AInvB_msg)
	printbr(( var'A'^-1*var'A' ):eq( (AInv*A)() ))
	printbr()
	printbr()
	printbr()
end
