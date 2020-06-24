#!/usr/bin/env luajit
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='Maxwell hyperbolic conservation law'}}

local D_x, D_y, D_z = vars('D_x', 'D_y', 'D_z')
local B_x, B_y, B_z = vars('B_x', 'B_y', 'B_z')
local Us = table{D_x, D_y, D_z, B_x, B_y, B_z}

local epsilon = var'\\epsilon'
local mu = var'\\mu'

local As = table{
	Matrix(
		{0,			0,			0,					0,			0,			0},
		{0,			0,			0,					0,			0,			1/mu},
		{0,			0,			0,					0,			-1/mu,		0},
																			 
		{0,			0,			0,					0,			0,			0},
		{0,			0,			-1/epsilon,			0,			0,			0},
		{0,			1/epsilon,	0,					0,			0,			0}
	),

	Matrix(
		{0,			0,			0,					0,			0,			-1/mu},
		{0,			0,			0,					0,			0,			0},
		{0,			0,			0,					1/mu,		0,			0},
																			 
		{0,			0,			1/epsilon,			0,			0,			0},
		{0,			0,			0,					0,			0,			0},
		{-1/epsilon,0,			0,					0,			0,			0}
	),

	Matrix(
		{0,			0,			0,					0,			1/mu,		0},
		{0,			0,			0,					-1/mu,		0,			0},
		{0,			0,			0,					0,			0,			0},
																			 
		{0,			-1/epsilon,	0,					0,			0,			0},
		{1/epsilon,	0,			0,					0,			0,			0},
		{0,			0,			0,					0,			0,			0}
	),

}

printbr'state:'
local U = Matrix(Us):T()
printbr(var'U':eq(U))

local A = var'A'
for side=1,3 do
	printbr('side',side)
	
	printbr'flux:'
	local F = (As[side] * U)()
	printbr(var'F':eq(F))

	printbr'flux jacobian:'
	local A_def = A:eq(As[side])
	printbr(A_def)


	local A_eig = As[side]:eigen()
	local evRMat = A_eig.R
	local evLMat = A_eig.L
	local lambdaMat = A_eig.Lambda
	
	printbr('$\\Lambda$:')
	printbr(lambdaMat)

	printbr('R:')
	printbr(evRMat)

	local evLMat, _, reason = evRMat:inverse()
	assert(not reason, reason)	-- hmm, make Matrix.inverse more assert-compatible?

	printbr('L:')
	printbr(evLMat)

	local A_check = (evRMat * lambdaMat * evLMat)()
	local diff = (A_check - As[side])()
	for i=1,6 do
		for j=1,6 do
			if diff[i][j] ~= Constant(0) then
				error("eigensystem did not reproduce original")
			end
		end
	end

	local n = #As[side]
	local vs = range(0,n-1):map(function(i) return var('v_'..i) end)
	local evrxform = (evRMat * Matrix:lambda({n,1}, function(i) return vs[i] end))()
	local evlxform = (evLMat * Matrix:lambda({n,1}, function(i) return vs[i] end))()
	printbr('R(v) = ', evrxform)
	printbr('L(v) = ', evlxform)

	local _, evrcode = evrxform:compile(table():append(vs, {epsilon, mu}), 'Lua')
	local _, evlcode = evlxform:compile(table():append(vs, {epsilon, mu}), 'Lua')
	printbr'right transform code:'
	printbr('<pre>'..evrcode..'</pre>')
	printbr'left transform code:'
	printbr('<pre>'..evlcode..'</pre>')
end
