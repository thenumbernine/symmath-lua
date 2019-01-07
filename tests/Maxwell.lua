#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup{tostring='MathJax', MathJax={title='GLM-Maxwell hyperbolic conservation law'}}
local printbr = symmath.tostring.print

local D_x, D_y, D_z = vars('D_x', 'D_y', 'D_z')
local B_x, B_y, B_z = vars('B_x', 'B_y', 'B_z')
local phi = var'\\phi'
local psi = var'\\psi'
local Us = table{D_x, D_y, D_z, B_x, B_y, B_z, phi, psi}

local epsilon = var'\\epsilon'
local mu = var'\\mu'

local chi_phi = var'\\chi_\\phi'	-- wavespeed of div E
local chi_psi = var'\\chi_\\psi'	-- wavespeed of div B
local v_p = var'v_p'		-- phase velocity = 1/(epsilon * mu)

local As = table{
	Matrix(
		{0,			0,			0,					0,			0,			0,				chi_phi,	0},
		{0,			0,			0,					0,			0,			1/mu,			0,			0},
		{0,			0,			0,					0,			-1/mu,		0,				0,			0},
																									
		{0,			0,			0,					0,			0,			0,				0,			chi_psi},
		{0,			0,			-1/epsilon,			0,			0,			0,				0,			0},
		{0,			1/epsilon,	0,					0,			0,			0,				0,			0},
																						
		{chi_phi / (epsilon * mu),	0,			0,					0,			0,			0,				0,			0},
		{0,			0,			0,					chi_psi / (epsilon * mu), 	0,			0,				0,			0}
	),

	Matrix(
		{0,			0,			0,					0,			0,			-1/mu,			0,			0},
		{0,			0,			0,					0,			0,			0,				chi_phi,	0},
		{0,			0,			0,					1/mu,		0,			0,				0,			0},
																									
		{0,			0,			1/epsilon,			0,			0,			0,				0,			0},
		{0,			0,			0,					0,			0,			0,				0,			chi_psi},
		{-1/epsilon,0,			0,					0,			0,			0,				0,			0},
																						
		{0,			chi_phi / (epsilon * mu),	0,					0,			0,			0,				0,			0},
		{0,			0,			0,					0, 			chi_psi / (epsilon * mu),	0,				0,			0}
	),

	Matrix(
		{0,			0,			0,					0,			1/mu,		0,				0,			0},
		{0,			0,			0,					-1/mu,		0,			0,				0,			0},
		{0,			0,			0,					0,			0,			0,				chi_phi,	0},
																									
		{0,			-1/epsilon,	0,					0,			0,			0,				0,			0},
		{1/epsilon,	0,			0,					0,			0,			0,				0,			0},
		{0,			0,			0,					0,			0,			0,				0,			chi_psi},
																						
		{0,			0,			chi_phi / (epsilon * mu),			0,			0,			0,				0,			0},
		{0,			0,			0,					0, 			0,			chi_psi / (epsilon * mu),		0,			0}
	),

}

local A = var'A'
for side=1,3 do
	printbr('side',side)
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
		-chi_phi / sqrt(mu * epsilon), 
		-chi_psi / sqrt(mu * epsilon), 
		-1/sqrt(mu * epsilon), 
		1/sqrt(mu * epsilon),
		chi_phi / sqrt(mu * epsilon), 
		chi_psi / sqrt(mu * epsilon), 
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

	-- rescale rows
	evRMat = (evRMat * ({
		Matrix.diagonal(1/sqrt(epsilon), 1/sqrt(epsilon), sqrt(mu), sqrt(mu), sqrt(mu), sqrt(mu), 1/sqrt(epsilon), 1/sqrt(epsilon)),
		Matrix.diagonal(1/sqrt(epsilon), 1/sqrt(epsilon), sqrt(mu), sqrt(mu), sqrt(mu), sqrt(mu), 1/sqrt(epsilon), 1/sqrt(epsilon)),
		Matrix.diagonal(1/sqrt(epsilon), 1/sqrt(epsilon), sqrt(mu), sqrt(mu), sqrt(mu), sqrt(mu), 1/sqrt(epsilon), 1/sqrt(epsilon)),
	})[side])()
	
	printbr('R:')
	printbr(evRMat)

	local evLMat, _, reason = evRMat:inverse()
	assert(not reason, reason)	-- hmm, make Matrix.inverse more assert-compatible?

	printbr('L:')
	printbr(evLMat)

	local A_check = (evRMat * lambdaMat * evLMat)()
	printbr('A check')
	printbr(A_check)

	local vs = range(0,7):map(function(i) return var('v_'..i) end)
	local evrxform = (evRMat * Matrix:lambda({n,1}, function(i) return vs[i] end))()
	local evlxform = (evLMat * Matrix:lambda({n,1}, function(i) return vs[i] end))()
	printbr('R(v) = ', evrxform)
	printbr('L(v) = ', evlxform)

	local _, evrcode = evrxform:compile(table():append(vs, {epsilon, mu}), 'Lua')
	local _, evlcode = evrxform:compile(table():append(vs, {epsilon, mu}), 'Lua')
	printbr'right transform code:'
	printbr('<pre>'..evrcode..'</pre>')
	printbr'left transform code:'
	printbr('<pre>'..evlcode..'</pre>')
end
