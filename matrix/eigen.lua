local table = require 'ext.table'

--[[
A = square matrix

returns: table with the following fields set:
	lambdas = table of the following entries:
		expr = expression of the eigenvalue
		mult = multiplicity of the eigenvalue
	defective = true if the matrix is defective (i.e. if an eigenvalue multiplicity is greater than the eigenvector dimension / (A - lambda I)-nullspace dimension )
	
(TODO maybe don't return the rest of these, 
but provide functions for producing them?)
	allLambdas = table of eigenvalues, with duplicates equal to the eigenvalue multiplicity, in the matching order of 'lambdas' above.
	Lambda = diagonal matrix of the eigenvalues.  equivalent of Matrix.diag(allLambdas:unpack())
	R = right eigenvectors, matching 1-1 with allLambdas
	L = left eigenvectors.  produced by R:inverse()  these don't exist if A is defective.

args:
	dontCalcL = don't calculate L = R:inverse()
	lambda = which lambda variable to use.  defaults to \\lambda.  TODO default to 'lambda' and rely upon 'fixVariableNames' more, for utf8 console support as well?
--]]

local function eigen(A, args)
	args = args or {}
	local symmath = require 'symmath'
	local Matrix = symmath.Matrix
	local var = symmath.var
local eigenVerbose = Matrix.eigenVerbose	
if eigenVerbose then
	printbr(var'A':eq(A))
end
	A = A:clone()
	
	local lambda = args.lambda or var'\\lambda'
	A:map(function(x) assert(x ~= lambda) end)

	-- lambda * log(x) => log(x^lambda) is messing this up ...
	symmath.op.mul:pushRule'Prune/logPow'	-- push a log(b) => log(b^a)
	symmath.log:pushRule'Expand/apply'		-- push log(a*b) => log(a) + log(b)

	-- eigen-decompose
	local I = Matrix.identity(#A)
if eigenVerbose then
	printbr(var'I':eq(I))
end	
	local AminusLambda = (A - lambda * I)()
if eigenVerbose then
	printbr((var'A' - var'\\lambda' * var'I'):eq(AminusLambda))
end	
	local charPoly = AminusLambda:det{dontSimplify=true}:eq(0)
if eigenVerbose then
	printbr(charPoly)
end	
	local allLambdas = table{charPoly:solve(lambda)}
if eigenVerbose then
	printbr(allLambdas:mapi(tostring):concat', ')	
end	
	allLambdas = allLambdas:mapi(function(eqn) return eqn:rhs() end)	-- convert to lambda equality
if eigenVerbose then
	printbr(lambda, '$= \\{$', allLambdas:mapi(tostring):concat', ', '$\\}$')
end	
	local lambdas = symmath.multiplicity(allLambdas)	-- of equations
if eigenVerbose then
	for _,info in ipairs(lambdas) do
		printbr('mult '..info.mult..' expr '..info.expr)
	end
end

	local defective
	allLambdas = table()	-- redo allLambdas so the order matches the right-eigenvectors' order
	local Rs = lambdas:mapi(function(lambdaInfo) 
		local lambda = lambdaInfo.expr
		local Ri = (A - lambda * I)():nullspace()
		local n = Ri and #Ri[1] or 0
		-- ex: A[1][2] = 1 otherwise A[i][j] = 0.  charpoly is lambda=0 mult4, nullspace is dim=3
		if lambdaInfo.mult ~= n then
			defective = true
			--error("nullspace of "..lambda.." is "..n.." but multiplicity of eigenvalue is "..lambdaInfo.mult)
		end
		--for i=1,lambdaInfo.mult do
		for i=1,n do
			allLambdas:insert(lambdaInfo.expr)
		end
		return Ri and Ri:T() or nil
	end)
if eigenVerbose then
	for i,lambda in ipairs(lambdas) do
		printbr('right eigenvector of', lambda.expr, 'is', Rs[i]:T())
	end
end

	local R = #Rs > 0 and Matrix( 
		table():append(Rs:unpack()):unpack()
		--Rs:mapi(function(Ri) return Ri[1] end):unpack() 
	):T()
if eigenVerbose then
	printbr(var'R':eq(R))
end	
	-- inverse() isn't possible if R isn't square ... which happens when the charpoly mult != the nullspace dim
	-- in that case, use SVD?
	-- or solve manually for left-eigenvectors?
	local L
	if not (defective or args.dontCalcL) then
		L = R:inverse() 
if eigenVerbose then
		printbr(var'L':eq(L))
end	
	end
	
	local Lambda = Matrix.diagonal( allLambdas:unpack() )
if eigenVerbose then
	printbr(var'\\Lambda':eq(Lambda))
end
if eigenVerbose and L then
	printbr'verify:'
	printbr( (R * Lambda * L):eq( (R * Lambda * L)() ) )
end

	symmath.op.mul:popRules()
	symmath.log:popRules()

--assert( (R * Lambda * L - A)() == Matrix:zeros{#A, #A} )
	
	return {
		lambdas = lambdas,			-- this holds {expr=, mult=} multiplicity
		allLambdas = allLambdas,	-- this just holds a list
		
		Lambda = Lambda,
		R = R,
		L = L,
	
		defective = defective,
	}
end

return eigen
