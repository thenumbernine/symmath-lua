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
		name = 'polar, orthonormal',
		coords = {r, phi},
		conns = {
			Matrix.diagonal(0, 0),
			Matrix({0, -1}, {1, 0}),	-- 1/r but scaled by r
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
	{
		name = 'spherical, orthonormal:',
		coords = {r, theta, phi},
		conns = {
			Matrix.diagonal(0, 0, 0),
			Matrix(
				{0, -1, 0},		-- 1/r 
				{1, 0, 0}, 
				{0, 0, 0}
			),
			Matrix(
				{0, 0, -sin(theta)}, 
				{0, 0, -cos(theta)}, 
				{sin(theta), cos(theta), 0}
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

		local origIntConn = Integral(conn, coord, coord'_L', coord'_R')
		print(origIntConn)
		local intConn = origIntConn()
		printbr('=', intConn)
		printbr()

		print(exp(-origIntConn))
		local negIntConn = (-intConn)()
		--[[ you could exp, and that will eigen-decompose ...
		local expNegIntExpr = negIntConn:exp()
		local expIntExpr = expNegIntExpr:inverse()
		--]]
		-- [[ but eigen will let inverting be easy
		local ev = negIntConn:eigen()
		local R, L, allLambdas = ev.R, ev.L, ev.allLambdas
		local expLambda = Matrix.diagonal( allLambdas:mapi(function(lambda) 
			return exp(lambda) 
		end):unpack() )
		local expNegIntExpr = (R * expLambda * L)()
		local invExpLambda = Matrix.diagonal( allLambdas:mapi(function(lambda) 
			return exp(-lambda) 
		end):unpack() )
		local expIntExpr = (R * invExpLambda * L)()
		--]]
		printbr('=', expNegIntExpr)
		printbr()
	
		print(exp(origIntConn))
		printbr('=', expIntExpr)
		printbr()
	end
end
