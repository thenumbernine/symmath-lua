#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup{tostring='MathJax', MathJax={title='Maxwell'}}
local printbr = symmath.tostring.print

local eps = var'\\epsilon'
local mu = var'\\mu'

local A = var'A'
local A_def = A:eq(Matrix(
	{0,0,0, 0,0,0},
	{0,0,0, 0,0,1/mu},
	{0,0,0, 0,-1/mu,0},
	
	{0,0,0, 0,0,0},
	{0,0,-1/eps, 0,0,0},
	{0,1/eps,0, 0,0,0}
))
printbr(A_def)

local lambda = var'\\lambda'
local charpolymat = (A_def[2] - Matrix.identity(#A_def[2]) * lambda)()
local charpoly_eqn  = charpolymat:determinant():eq(0)
printbr'char poly:'
printbr(charpoly_eqn)
-- TODO solve charpoly_eqn for lambda ...
-- gives solutions lambda = 0, lambda = +- 1/sqrt(mu epsilon) = +- c
local lambdas = table{-1/sqrt(mu * eps), 0, 1/sqrt(mu * eps)}


local evs = table()
local multiplicity = table()
for _,lambda_ in ipairs(lambdas) do
	local n = #A_def[2]
	local A_minus_lambda_I = ((A_def[2] - Matrix.identity(n) * lambda_))()

	local cols = A_minus_lambda_I:nullspace()
	if not cols then
		printbr("found no eigenvectors associated with eigenvalue",lambda_)
	else
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
printbr('R:')
printbr(evRMat)

local evLMat, _, reason = evRMat:inverse()
assert(not reason, reason)	-- hmm, make Matrix.inverse more assert-compatible?

printbr('L:')
printbr(evLMat)

local A_check = (evRMat * lambdaMat * evLMat)()
printbr('A check')
printbr(A_check)
