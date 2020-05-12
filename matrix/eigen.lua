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
--]]
local function eigen(A)
	local symmath = require 'symmath'
	local Matrix = symmath.Matrix
	local var = symmath.var
--printbr(var'A':eq(A))
	A = A:clone()
	
	local lambda = var'\\lambda'
	A:map(function(x) assert(x ~= lambda) end)

	-- lambda * log(x) => log(x^lambda) is messing this up ...
	symmath.op.mul:pushRule'Prune/logPow'	-- push a log(b) => log(b^a)
	symmath.log:pushRule'Expand/apply'		-- push log(a*b) => log(a) + log(b)

	-- eigen-decompose
	local I = Matrix.identity(#A)
--printbr(var'I':eq(I))
	local AminusLambda = (A - lambda * I)()
--printbr((var'A' - var'\\lambda' * var'I'):eq(AminusLambda))
	local charPoly = AminusLambda:det{dontSimplify=true}:eq(0)
--printbr(charPoly)
	local allLambdas = table{charPoly:solve(lambda)}
--printbr(allLambdas:mapi(tostring):concat', ')	
	allLambdas = allLambdas:mapi(function(eqn) return eqn:rhs() end)	-- convert to lambda equality
--printbr(lambda, '$= \\{$', allLambdas:mapi(tostring):concat', ', '$\\}$')
	local lambdas = symmath.multiplicity(allLambdas)	-- of equations
--for _,info in ipairs(lambdas) do
--	printbr('mult '..info.mult..' expr '..info.expr)
--end

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
--for i,lambda in ipairs(lambdas) do
--	printbr('right eigenvector of', lambda.expr, 'is', Rs[i]:T())
--end

	local R = #Rs > 0 and Matrix( 
		table():append(Rs:unpack()):unpack()
		--Rs:mapi(function(Ri) return Ri[1] end):unpack() 
	):T()
--printbr(var'R':eq(R))
	-- inverse() isn't possible if R isn't square ... which happens when the charpoly mult != the nullspace dim
	-- in that case, use SVD?
	-- or solve manually for left-eigenvectors?
	local L = not defective and R:inverse() or nil
--printbr(var'L':eq(L))
	local Lambda = Matrix.diagonal( allLambdas:unpack() )
--printbr(var'\\Lambda':eq(Lambda))
--printbr'verify:'
--printbr( (R * Lambda * L):eq( (R * Lambda * L)() ) )
	
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
