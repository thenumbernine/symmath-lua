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

	local lambda = var'\\lambda'
	local charpolymat = (A_def[2] - Matrix.identity(#A_def[2]) * lambda)()
	local charpoly_eqn  = charpolymat:determinant():eq(0)
	printbr'char poly:'
	printbr(charpoly_eqn)
	-- TODO solve charpoly_eqn for lambda ...
	-- gives solutions lambda = 0, lambda = +- 1/sqrt(mu epsilon) = +- c
	local lambdas = table{
		-1/sqrt(mu * epsilon), 
		0,
		1/sqrt(mu * epsilon),
	}

	local n = #Us

	local evs = table()
	local multiplicity = table()
	for _,lambda_ in ipairs(lambdas) do
		local n = #A_def[2]
		local A_minus_lambda_I = ((A_def[2] - Matrix.identity(n) * lambda_))()

		local cols = A_minus_lambda_I:nullspace()
		if not cols then
			printbr("found no eigenvectors associated with eigenvalue",lambda_)
		else
			if lambda_ ~= Constant(0) then
				cols = (cols / sqrt(2))()
			end	
			multiplicity:insert(#cols[1])
			printbr('eigenvectors of ', lambda:eq(lambda_))
			printbr(cols)
			evs:insert(cols)
		end
	end
	local lambdaMat = Matrix.diagonal( table():append(
		lambdas:map(function(lambda,i)
			return range(multiplicity[i]):map(function() return lambda end)
		end):unpack()
	):unpack() )
	printbr('$\\Lambda$:')
	printbr(lambdaMat)

	local evRMat = Matrix(
		table():append(
			evs:map(function(ev)
				return ev:transpose()
			end):unpack()
		):unpack()
	):transpose()

	evRMat = (evRMat * ({
		Matrix.diagonal(sqrt(mu), sqrt(mu), 1, 1, sqrt(mu), sqrt(mu)),
		Matrix.diagonal(sqrt(mu), sqrt(mu), 1, 1, sqrt(mu), sqrt(mu)),
		Matrix.diagonal(sqrt(mu), sqrt(mu), 1, 1, sqrt(mu), sqrt(mu)),
	})[side])()

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

	local vs = range(0,5):map(function(i) return var('v_'..i) end)
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
