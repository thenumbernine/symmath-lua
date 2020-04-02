#!/usr/bin/env luajit
require 'ext'
require 'symmath'{MathJax={title='Parallel Propagtors'}}

-- TODO incorporate this with the metric catalog?


local r = var'r'
local phi = var'\\phi'
local theta = var'\\theta'

for _,info in ipairs{
	{
		name = 'polar, coordinate',
		coords = {r, phi},
		conns = {
			Matrix.diagonal(0, 1/r),
			Matrix({0, -r}, {1/r, 0}),
		},
	},
	{
		name = 'spherical, coordinate:',
		coords = {r, theta, phi},
		conns = {
			Matrix.diagonal(0, 1/r, 1/r),
			Matrix(
				{0, -r, 0}, 
				{1/r, 0, 0}, 
				{0, 0, cos(theta)/sin(theta)}
			),
			Matrix(
				{0, 0, -r*sin(theta)^2}, 
				{0, 0, -sin(theta)*cos(theta)}, 
				{1/r, cos(theta)/sin(theta), 0}
			),
		},
	},
} do

	printbr(info.name..':')
	printbr()

	local coords = info.coords
	local conns = info.conns

	printbr'connections:'
	printbr()

	for i, coord in ipairs(coords) do
		local conn = conns[i]
		
		printbr(var('[\\Gamma_'..coords[i].name..']'):eq(conn))
		printbr()

		local origExpr = Integral(conn, coord, coord'_L', coord'_R')
		print(origExpr)
		local expr = origExpr()
		printbr('=', expr)
		printbr()

		print(exp(-origExpr))
		local expNegIntExpr = (-expr)():exp()
		printbr('=', expNegIntExpr)
		printbr()
	
		print(exp(origExpr))
		local expIntExpr = expNegIntExpr:inverse()
		printbr('=', expIntExpr)
		printbr()
	end
end
