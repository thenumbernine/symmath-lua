#!/usr/bin/env luajit
require 'ext'
require 'symmath'{MathJax={title='Parallel Propagtors'}}

-- TODO incorporate this with the metric catalog?

local lambda = var'\\lambda'

-- TODO return multiplicity
local function unique(t)
	local n = table()
	for i,ti in ipairs(t) do
		local found
		for j=1,#n do
			if ti == n[j] then
				found = true
				break
			end
		end
		if not found then
			n:insert(ti)
		end
	end
	return n
end

local function eigen(A)
--printbr(var'A':eq(A))
	A = A:clone()
	A:map(function(x) assert(x ~= lambda) end)

	-- lambda * log(x) => log(x^lambda) is messing this up ...
	symmath.op.mul:pushRule'Prune/logPow'	-- push a log(b) => log(b^a)
	symmath.log:pushRule'Expand/apply'		-- push log(a*b) => log(a) + log(b)

	-- eigen-decompose
	local I = Matrix.identity(#A)
--printbr(var'I':eq(I))
	local AminusLambda = (A - lambda * I)()
--printbr((var'A' - var'\\lambda' * var'I'):eq(AminusLambda))
	local charPoly = AminusLambda:det():eq(0)
--printbr(charPoly)
	local allLambdas = table{charPoly:solve(lambda)}
--printbr(allLambdas:mapi(tostring):concat', ')	
	allLambdas = allLambdas:mapi(function(eqn) return eqn:rhs() end)	-- convert to lambda equality
--printbr(lambda, '$= \\{$', allLambdas:mapi(tostring):concat', ', '$\\}$')
	local uniqueLambdas = unique(allLambdas)	-- of equations
	
	local Rs = uniqueLambdas:mapi(function(lambda) 
		local ns = (A - lambda * I)():nullspace()
		-- TODO assert multiplicity matches the unique lambda multiplicity
		return ns:T()
	end)
--for i,lambda in ipairs(uniqueLambdas) do
--	printbr('right eigenvector of', lambda, 'is', Rs[i]:T())
--end

	local R = Matrix( 
		table():append(Rs:unpack()):unpack()
		--Rs:mapi(function(Ri) return Ri[1] end):unpack() 
	):T()
--printbr(var'R':eq(R))
	local L = R:inverse()
--printbr(var'L':eq(L))
	local Lambda = Matrix.diagonal( allLambdas:unpack() )
--printbr(var'\\Lambda':eq(Lambda))
--printbr'verify:'
--printbr( (R * Lambda * L):eq( (R * Lambda * L)() ) )
	
	symmath.op.mul:popRules()
	symmath.log:popRules()

assert( (R * Lambda * L - A)() == Matrix:zeros{#A, #A} )
	
	
	return {
		-- TODO multiplicity
		uniqueLambdas = uniqueLambdas,
		allLambdas = allLambdas,
		
		Lambda = Lambda,
		R = R,
		L = L,
	}
end

local function matrixExponent(A)
	local ev = eigen(A)
	local R, L, allLambdas = ev.R, ev.L, ev.allLambdas
	local expLambda = Matrix.diagonal( allLambdas:mapi(function(lambda) return exp(lambda) end):unpack() )
--printbr(R * expLambda * L)	
	return (R * expLambda * L)()
end


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
		local expNegIntExpr = matrixExponent((-expr)())
		printbr('=', expNegIntExpr)
		printbr()
	
		print(exp(origExpr))
		local expIntExpr = expNegIntExpr:inverse()
		printbr('=', expIntExpr)
		printbr()
	end
end
