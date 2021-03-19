#!/usr/bin/env luajit
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='GLM-Maxwell hyperbolic conservation law'}}
local printbr = symmath.tostring.print

local phi = var'\\phi'
local psi = var'\\psi'
local A = var'A'
local B = var'B'
local D = var'D'
local F = var'F'
local L = var'L'
local R = var'R'
local U = var'U'

local epsilon = var'\\epsilon'
local mu = var'\\mu'
local lambda = var'\\lambda'

local chi_phi = var'\\chi_\\phi'	-- wavespeed of div E
local chi_psi = var'\\chi_\\psi'	-- wavespeed of div B
local v_p = var'v_p'		-- phase velocity = 1/(epsilon * mu)

local Us = table{D'_x', D'_y', D'_z', B'_x', B'_y', B'_z', phi, psi}

local A_dense = Matrix(
	{0,			0,			0,					0,			0,			0,				chi_phi,	0},
	{0,			0,			0,					0,			0,			1/mu,			0,			0},
	{0,			0,			0,					0,			-1/mu,		0,				0,			0},
																								
	{0,			0,			0,					0,			0,			0,				0,			chi_psi},
	{0,			0,			-1/epsilon,			0,			0,			0,				0,			0},
	{0,			1/epsilon,	0,					0,			0,			0,				0,			0},
																					
	{chi_phi,	0,			0,					0,			0,			0,				0,			0},
	{0,			0,			0,					chi_psi, 	0,			0,				0,			0}
)

printbr'state:'
local U_def = Matrix(Us):T()
printbr(U:eq(U_def))

printbr'flux:'
local F_def = (A_dense * U_def)()
printbr(F:eq(F_def))

--[[
local A_dense = require 'symmath.factorLinearSystem'(
	F:T()[1],
	U:T()[1]
)
--]]
printbr'flux jacobian:'
local A_def = A:eq(A_dense)
printbr(A_def)

local ch = A_dense:charpoly():replace(var'lambda', lambda)
printbr(ch)
local solns = table{ch:solve(lambda)}
printbr(solns:mapi(tostring):concat',')
--[[
local eig = A_dense:eigen{dontCalcL=true}
for k,v in pairs(eig) do
	printbr(k,v)
end
eig.L = eig.R:inverse()

printbr(F'^I':diff(U'^J'):eq(eig.R * eig.Lambda * eig.L))
printbr()
os.exit()
--]]


local charpoly_eqn  = A_def[2]:charpoly(lambda)
printbr'char poly:'
printbr(charpoly_eqn)
-- TODO solve charpoly_eqn for lambda ...
-- gives solutions lambda = 0, lambda = +- 1/sqrt(mu epsilon) = +- c
local lambdas = table{
	-chi_phi, 
	-chi_psi, 
	-1/sqrt(mu * epsilon), 
	1/sqrt(mu * epsilon),
	chi_phi, 
	chi_psi, 
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
--		if lambda_ ~= Constant(0) then
--			cols = (cols / sqrt(2))()
--		end	
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

local evRMat = Matrix(
	table():append(
		evs:map(function(ev)
			return ev:transpose()
		end):unpack()
	):unpack()
):transpose()

-- rescale rows
evRMat = (evRMat * 
	Matrix.diagonal(
		1/sqrt(epsilon),
		1/sqrt(epsilon),
		sqrt(mu),
		sqrt(mu),
		sqrt(mu),
		sqrt(mu),
		1/sqrt(epsilon),
		1/sqrt(epsilon)
	)
)()

local evLMat, _, reason = evRMat:inverse()
assert(not reason, reason)	-- hmm, make Matrix.inverse more assert-compatible?

printbr'in the x direction:'
printbr(F'^I':diff(U'^J'):eq(evRMat * lambdaMat * evLMat))
printbr()

local A_check = (evRMat * lambdaMat * evLMat)()
local diff = (A_check - A_dense)()
for i=1,8 do
	for j=1,8 do
		if diff[i][j] ~= Constant(0) then
			error("eigensystem did not reproduce original")
		end
	end
end

local nls = Matrix:lambda({3,3}, function(i,j)
	return var('(n_'..i..')')('_'..j)
end)

local Nl = Matrix:lambda({8,8}, function(i,j)
	local u = math.floor((i-1)/3)+1
	local v = math.floor((j-1)/3)+1
	if u ~= v then return 0 end
	if u > 2 or v > 2 then return i == j and 1 or 0 end
	i = ((i-1)%3)+1
	j = ((j-1)%3)+1
	return nls[j][i]
end)

evRMat = Nl:T() * evRMat
evLMat = evLMat * Nl
local sqrt_det_g = var'\\sqrt{|g|}'
lambdaMat = (lambdaMat * Matrix.diagonal(range(8):mapi(function() return 1/sqrt_det_g end):unpack()))()

printbr'in a normal basis:'
printbr(F'^I':diff(U'^J'):eq(evRMat * lambdaMat * evLMat))
printbr()

evRMat = evRMat()
evLMat = evLMat()

printbr(F'^I':diff(U'^J'):eq(evRMat * lambdaMat * evLMat))
printbr()

evRMat = evRMat
	:replace(epsilon, 1/var'(eig)->sqrt_1_eps'^2)
	:replace(mu, 1/var'(eig)->sqrt_1_mu'^2)
	:simplify()

evLMat = evLMat
	:replace(epsilon, 1/var'(eig)->sqrt_1_eps'^2)
	:replace(mu, 1/var'(eig)->sqrt_1_mu'^2)
	:simplify()

local vs = range(0,n-1):map(function(i) return var('v_'..i) end)
local evrxform = (evRMat * Matrix:lambda({n,1}, function(i) return vs[i] end)):simplifyAddMulDiv():tidy()
local evlxform = (evLMat * Matrix:lambda({n,1}, function(i) return vs[i] end)):simplifyAddMulDiv():tidy()
printbr('R(v) = ', evrxform)
printbr('L(v) = ', evlxform)

local xs = table{'x', 'y', 'z'}
local args = table(vs)
	:append(table.mapi(nls[1], function(xi,i) return {['n_l.'..xs[i]] = xi} end))
	:append(table.mapi(nls[2], function(xi,i) return {['n2_l.'..xs[i]] = xi} end))
	:append(table.mapi(nls[3], function(xi,i) return {['n3_l.'..xs[i]] = xi} end))
	--:append(table.mapi(nus[1], function(xi,i) return {['n_u.'..xs[i]] = xi} end))
	--:append(table.mapi(nus[2], function(xi,i) return {['n2_u.'..xs[i]] = xi} end))
	--:append(table.mapi(nus[3], function(xi,i) return {['n3_u.'..xs[i]] = xi} end))
	:append{
		{sqrt_det_g = sqrt_det_g},
	}:append(
		vs:mapi(function(vi,i)
			return {['(X)->ptr['..(i-1)..']'] = vi}
		end)
	)

export.C.numberType = 'real const'

local evrcode = export.C:toCode{
	input = args,
	output = range(n):mapi(function(i)
		return {['(Y)->ptr['..(i-1)..']'] = evrxform[i][1]}
	end),
}
local evlcode = export.C:toCode{
	input = args,
	output = range(n):mapi(function(i)
		return {['(Y)->ptr['..(i-1)..']'] = evlxform[i][1]}
	end),
}
printbr'right transform code:'
printbr('<pre>'..evrcode..'</pre>')
printbr'left transform code:'
printbr('<pre>'..evlcode..'</pre>')
