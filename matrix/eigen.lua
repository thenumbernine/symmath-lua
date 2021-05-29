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
	lambdaVar = which lambda variable to use.  defaults to 'lambda'.
	lambdas = provide eigen with a list of lambdas, since its weakness is solving the char poly
--]]

local function eigen(A, args)
	args = args or {}
	local symmath = require 'symmath'
	local Matrix = symmath.Matrix
	local var = symmath.var
	local eigenVerbose = Matrix.eigenVerbose	
	
	local printbr	--debugging
	if eigenVerbose then
		printbr = _G.printbr or _G.print
	end

	if eigenVerbose then
		printbr(var'A':eq(A))
	end
	A = A:clone()

	local lambda = args.lambdaVar or var'lambda'
	A:map(function(x) assert(x ~= lambda) end)

	-- lambda * log(x) => log(x^lambda) is messing this up ...
	symmath.op.mul:pushRule'Prune/logPow'	-- push a log(b) => log(b^a)
	symmath.log:pushRule'Expand/apply'		-- push log(a*b) => log(a) + log(b)

	-- eigen-decompose
	local I = Matrix.identity(#A)
	if eigenVerbose then
		printbr(var'I':eq(I))
	end	

	local charPoly
	local allLambdas
	if args.lambdas then
		allLambdas = table(args.lambdas)
	else
		local AminusLambda = (A - lambda * I)()
		if eigenVerbose then
			printbr((var'A' - lambda * var'I'):eq(AminusLambda))
		end	
	
		charPoly = AminusLambda:det{dontSimplify=true}:eq(0)
		if eigenVerbose then
			printbr('charPoly', charPoly)
		end

		-- I have a bad feeling about this ...
		charPoly = charPoly()
		if eigenVerbose then
			printbr('after simplify(), charPoly', charPoly)
		end
	
		allLambdas = table{charPoly:solve(lambda)}
		if eigenVerbose then
			printbr(allLambdas:mapi(tostring):concat', ')	
		end	
		allLambdas = allLambdas:mapi(function(eqn) return eqn:rhs() end)	-- convert to lambda equality
		if eigenVerbose then
			printbr(lambda, '$= \\{$', allLambdas:mapi(tostring):concat', ', '$\\}$')
		end	
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
		charPoly = charPoly,
		
		Lambda = Lambda,
		R = R,
		L = L,
	
		defective = defective,
	}
end

return eigen
