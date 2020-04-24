#!/usr/bin/env luajit
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='wave equation ...', useCommaDerivative=true}}

local xs = table{vars('x','y','z')}
local n = #xs
Tensor.coords{{variables=xs}}
printbr('$x = \\{$', xs:mapi(tostring):concat', ', '$\\}$')

local alpha = var('\\alpha', xs)
local beta_u = Tensor('^i', function(i)
	return var('\\beta^'..xs[i].name, xs)
end)
local gamma_uu = Tensor('^ij', function(i,j)
	return var('\\gamma^{'..xs[i].name..xs[j].name..'}', xs)
end)
printbr(var'\\beta''^i':eq(beta_u))

--[[ including Phi makes the flux Jacobian not diagonalizable
local As = xs:mapi(function(x,j)
	return Matrix:lambda({n+2,n+2}, function(a,b)
		if a==1 then
			if b == 1 then return -beta_u[j] end
		elseif a >= 2 and a <= n+1 then
			local i = a-1
			if b == 1 then
				return -beta_u[j]:diff(xs[i])
			elseif b >= 2 and b <= n+1 then
				local k = b-1
				return i==k and -beta_u[j] or 0
			elseif b == n+2 then
				return i==j and -alpha or 0
			end
		elseif a == n+2 then
			if b >= 2 and b <= n+1 then
				local k = b-1
				return -alpha * gamma_uu[j][k]
			elseif b == n+2 then
				return -beta_u[j]
			end
		end
		return 0
	end)
end)
--]]
-- [[
local As = xs:mapi(function(x,j)
	return Matrix:lambda({n+1,n+1}, function(a,b)
		local i = a - 1
		local k = b - 1
		if a == 1 then
			if b == 1 then
				return -beta_u[j]
			elseif b >= 2 and b <= n+1 then
				return -alpha * gamma_uu[j][k]
			end
		elseif a >= 2 and a <= n+1 then
			if b == 1 then
				return i==j and -alpha or 0
			elseif b >= 2 and b <= n+1 then
				return i==k and -beta_u[j] or 0
			end
		end
		return 0
	end)
end)
--]]

for i,A in ipairs(As) do
	print'<hr>'
	printbr(var'A'('_'..xs[i].name):eq(A))

	local lambdaVar = var'\\lambda'
	local charPolyEqn = A:charpoly(lambdaVar)
	printbr'char poly:'
	printbr(charPolyEqn)

	-- TODO THIS EVENTUALLY
	local lambdas = table{
		-beta_u[i] - alpha * sqrt(gamma_uu[i][i]),
		-beta_u[i],
		-beta_u[i] + alpha * sqrt(gamma_uu[i][i])
	}
	printbr('lambdas', lambdas:mapi(tostring):concat', ')
	local evs = table()
	local multiplicity = table()
	for _,lambda in ipairs(lambdas) do
		printbr('for eigenvalue', lambdaVar:eq(lambda))
		local A_minus_lambda_I = (A - Matrix.identity(#A) * lambda)()
--printbr((var'A'-var'I'*lambdaVar):eq(A_minus_lambda_I))
		local cols = A_minus_lambda_I:nullspace()
		if not cols then
			printbr("found no eigenvectors associated with eigenvalue",lambda)
			error'here'
		else
			multiplicity:insert(#cols[1])
			printbr('eigenvectors are')
			printbr(cols)
			evs:insert(cols)
		end
	end

--[=[
assert(multiplicity[2] == 2)
multiplicity[2] = 3
local dbetais = range(n):mapi(function(j)
	return beta_u[i]:diff(xs[j])
end)
evs[2] = Matrix:lambda({5,3}, function(a,b)
	if b == 3 then
		local i2 = i%n+1
		local i3 = i2%n+1
		return ({
			--[[ looks like mathematica's answer, except mathematica provides in Jordan form with an off-diagonal '1'
			0,
			-alpha * (gamma_uu[i][i2] * dbetais[i2] + gamma_uu[i][i3] * dbetais[i3]) / (gamma_uu[i][i] * dbetais[i] + gamma_uu[i][i2] * dbetais[i2] + gamma_uu[i][i3] * dbetais[i3]),
			alpha * gamma_uu[i][i] * dbetais[i2] / (gamma_uu[i][i] * dbetais[i] + gamma_uu[i][i2] * dbetais[i2] + gamma_uu[i][i3] * dbetais[i3]),
			alpha * gamma_uu[i][i] * dbetais[i3] / (gamma_uu[i][i] * dbetais[i] + gamma_uu[i][i2] * dbetais[i2] + gamma_uu[i][i3] * dbetais[i3]),
			0,
			--]]
			-- [[
			0,
			1,
			0,
			0,
			0,
			--]]
		})[a]
	else
		return evs[2][a][b]
	end
end)
--]=]

	
	printbr('multiplicities', multiplicity:concat', ')	
	local lambdaMat = Matrix.diagonal( table():append(
		lambdas:map(function(lambda,j)
			return range(multiplicity[j]):map(function() return lambda end)
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

evRMat = (evRMat * Matrix.diagonal(
	1,
	gamma_uu[i][1],
	gamma_uu[i][1],
	1
))()

	-- TODO rescale rows if you want
	
	printbr('R:')
	printbr(evRMat)

	local evLMat, _, reason = evRMat:inverse()
	assert(not reason, reason)	-- hmm, make Matrix.inverse more assert-compatible?

	printbr('L:')
	printbr(evLMat)


	local A_check = (evRMat * lambdaMat * evLMat)()
	print('A check:', A_check)
	
	local A_diff = (A_check - A)()
	print('A diff:', A_diff)
end

--[[

[
[-b, 0, 0, 0, 0],
[-f, -b, 0, 0, -a],
[-g, 0, -b, 0, 0],
[-h, 0, 0, -b, 0],
[0, -a * c, -a * d, -a * e, -b]
]

--]]
