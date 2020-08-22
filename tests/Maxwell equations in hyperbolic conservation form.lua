#!/usr/bin/env luajit
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='Maxwell hyperbolic conservation law'}}

local B = var'B'
local D = var'D'
local F = var'F'
local J = var'J'
local U = var'U'
local g = var'g'
local n = var'n'
local t = var't'
local epsilon = var'\\epsilon'
local epsilonBar = var'\\bar{\\epsilon}'
local mu = var'\\mu'

printbr((D'^i_,t' - (frac(1,mu) * epsilon'^ijk' * B'_k')'_,j'):eq(0))
printbr((B'^i_,t' + (frac(1,epsilon) * epsilon'^ijk' * D'_k')'_,j'):eq(J'^i'))
printbr()

printbr((D'^i_,t' - (frac(1,mu) * epsilon'^ijk' * g'_kl' * B'^l')'_,j'):eq(0))
printbr((B'^i_,t' + (frac(1,epsilon) * epsilon'^ijk' * g'_kl' * D'^l')'_,j'):eq(J'^i'))
printbr()

printbr((D'^i_,t' 
	+ frac(1,mu^2) * mu'_,j' * epsilon'^ijk' * g'_kl' * B'^l'
	- frac(1,mu) * epsilon'^ijk_,j' * g'_kl' * B'^l'
	- frac(1,mu) * epsilon'^ijk' * g'_kl,j' * B'^l'
	- frac(1,mu) * epsilon'^ijk' * g'_kl' * B'^l_,j'
):eq(0))
printbr((B'^i_,t' 
	- frac(1,epsilon^2) * epsilon'_,j' * epsilon'^ijk' * g'_kl' * D'^l'
	+ frac(1,epsilon) * epsilon'^ijk_,j' * g'_kl' * D'^l'
	+ frac(1,epsilon) * epsilon'^ijk' * g'_kl,j' * D'^l'
	+ frac(1,epsilon) * epsilon'^ijk' * g'_kl' * D'^l_,j'
):eq(J'^i'))
printbr()

printbr((D'^i_,t' 
	+ frac(1,mu^2) * mu'_,j' * epsilon'^ijk' * g'_kl' * B'^l'
	- frac(1,mu) * (1/sqrt(g))'_,j' * epsilonBar'^ijk' * g'_kl' * B'^l'
	- frac(1,mu) * epsilon'^ijk' * g'_kl,j' * B'^l'
	- frac(1,mu) * epsilon'^ijk' * g'_kl' * B'^l_,j'
):eq(0))
printbr((B'^i_,t' 
	- frac(1,epsilon^2) * epsilon'_,j' * epsilon'^ijk' * g'_kl' * D'^l'
	+ frac(1,epsilon) * (1/sqrt(g))'_,j' * epsilonBar'^ijk' * g'_kl' * D'^l'
	+ frac(1,epsilon) * epsilon'^ijk' * g'_kl,j' * D'^l_,j'
	+ frac(1,epsilon) * epsilon'^ijk' * g'_kl' * D'^l_,j'
):eq(J'^i'))
printbr()

printbr((D'^i_,t' 
	- frac(1,mu) * epsilon'^ijk' * g'_kl' * B'^l_,j'
):eq(
	- frac(1,mu^2) * mu'_,j' * epsilon'^ijk' * g'_kl' * B'^l'
	- frac(1,mu) * frac(sqrt(g)'_,j', sqrt(g)) * epsilon'^ijk' * g'_kl' * B'^l'
	+ frac(1,mu) * epsilon'^ijk' * g'_kl,j' * B'^l'
))
printbr((B'^i_,t' 
	+ frac(1,epsilon) * epsilon'^ijk' * g'_kl' * D'^l_,j'
):eq(
	J'^i'
	+ frac(1,epsilon^2) * epsilon'_,j' * epsilon'^ijk' * g'_kl' * D'^l'
	+ frac(1,epsilon) * frac(sqrt(g)'_,j', sqrt(g)) * epsilon'^ijk' * g'_kl' * D'^l'
	- frac(1,epsilon) * epsilon'^ijk' * g'_kl,j' * D'^l_,j'
))
printbr()


printbr'Conserved quantities:'

printbr(U'^I':eq(Matrix{D'^i', B'^i'}:T()))
printbr()

printbr'Flux:'

printbr(F'^I':eq(Matrix{
	- (frac(1,mu) * epsilon'^ijk' * B'_k')'_,j',
	(frac(1,epsilon) * epsilon'^ijk' * D'_k')'_,j'
}:T()))
printbr()


printbr(
	(
		Matrix{D'^i', B'^i'}:T()'_,t'
		+ Matrix(
			{ 0, -frac(1,mu) * epsilon'^ilk' },
			{ frac(1,epsilon) * epsilon'^ilk', 0}
		) * Matrix{D'_k', B'_k'}:T()'_,j' * n'_l' * n'^j'
	):eq(
		Matrix{J'^i', 0}:T()
	)
)
printbr()

printbr'neglecting normal gradient (which should emerge as an extra extrinsic curvature source term):'

printbr(
	(
		Matrix{D'^i', B'^i'}:T()'_,t'
		+ Matrix(
			{ 0, -frac(1,mu) * epsilon'^ilk' * n'_l' },
			{ frac(1,epsilon) * epsilon'^ilk' * n'_l', 0}
		) * Matrix{D'_k', B'_k'}:T()'_,j' * n'^j'
	):eq(
		Matrix{J'^i', 0}:T()
	)
)
printbr()

os.exit()

local D_x, D_y, D_z = vars('D_x', 'D_y', 'D_z')
local B_x, B_y, B_z = vars('B_x', 'B_y', 'B_z')
local Us = table{D_x, D_y, D_z, B_x, B_y, B_z}


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

	local _, evrcode = evrxform:compile(table():append(vs, {{epsilon=epsilon}, {mu=mu}}))
	local _, evlcode = evlxform:compile(table():append(vs, {{epsilon=epsilon}, {mu=mu}}))
	printbr'right transform code:'
	printbr('<pre>'..evrcode..'</pre>')
	printbr'left transform code:'
	printbr('<pre>'..evlcode..'</pre>')
end
