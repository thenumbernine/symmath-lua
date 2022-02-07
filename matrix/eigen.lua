local table = require 'ext.table'

--[[
A = square matrix

returns: table with the following fields set:
	lambdas = table of the following entries:
		expr = expression of the eigenvalue
		mult = multiplicity of the eigenvalue
	defective = true if the matrix is defective (i.e. if an eigenvalue multiplicity is greater than the eigenvector dimension / (A - λ I)-nullspace dimension )
	
(TODO maybe don't return the rest of these,
but provide functions for producing them?)
	allLambdas = table of eigenvalues, with duplicates equal to the eigenvalue multiplicity, in the matching order of 'lambdas' above.
	Lambda = diagonal matrix of the eigenvalues.  equivalent of Matrix.diag(allLambdas:unpack())
	R = right eigenvectors, matching 1-1 with allLambdas
	L = left eigenvectors.  produced by R:inverse()  these don't exist if A is defective.

args:
	dontCalcL = don't calculate L = R:inverse()
	lambdaVar = which λ variable to use.  defaults to 'λ'.
	lambdas = provide eigen with a list of lambdas, since its weakness is solving the char poly
	verbose = this will show each set of eigenvectors for each eigenvalue as they are calculated
	nullspaceVerbose = (forwarded to nullspace()) this shows step-by-step the nullspace calculation, and can produce a lot of output
	generalize = don't just report defective linear systems, instead solve for the generalized system
--]]

local function eigen(A, args)
	args = args or {}
	local symmath = require 'symmath'
	local Matrix = symmath.Matrix
	local var = symmath.var
	local eigenVerbose = args.verbose or Matrix.eigenVerbose
	
	local printbr	--debugging
	if eigenVerbose then
		printbr = _G.printbr or _G.print
		printbr(var'A':eq(A))
	end
	A = A:clone()

	local lambda = args.lambdaVar or var'λ'
	A:map(function(x) assert(x ~= lambda) end)

	-- λ * log(x) => log(x^λ) is messing this up ...
	-- TODO what if the rule was already pushed, then popping will incorrectly restore it to the caller
	local pushMulPruneLogPow = symmath.op.mul:pushRule'Prune/logPow'	-- push a log(b) => log(b^a)
	local pushLogExpandApply = symmath.log:pushRule'Expand/apply'		-- push log(a*b) => log(a) + log(b)

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
		if eigenVerbose then
			printbr('finding nullspace for ', lambdaInfo.expr)
		end
		local AminusLambdaI = (A - lambda * I)()
		local Ri = AminusLambdaI:nullspace(args.nullspaceVerbose)
		if eigenVerbose then
			printbr(Ri)
		end
		local n = Ri and Ri:dim()[2] or 0
		-- ex: A[1][2] = 1 otherwise A[i][j] = 0.  charpoly is lambda=0 mult4, nullspace is dim=3
		if lambdaInfo.mult ~= n then
			defective = true
			if eigenVerbose then
				printbr'...is defective, gathering more generalized eigenvectors'
			end
			if n > 0
			and args.generalize
			then
				if eigenVerbose then
					printbr'trying again for generalized eigensystem...'
				end
				local Constant = require 'symmath.Constant'
				local AminusLambdaIToTheP = AminusLambdaI:clone()
				-- TODO do I want to repeat by the dim of the matrix?
				--local targetNumberOfEigenvectors = #Ri
				-- or do I want to repeat by the multiplicity of the current eigenvalue?
				local targetNumberOfEigenvectors = lambdaInfo.mult
				local done
				for p=2,targetNumberOfEigenvectors do
					AminusLambdaIToTheP = (AminusLambdaIToTheP * AminusLambdaI)()
					if eigenVerbose then
						printbr('finding nullspace of (A - I λ)^'..p..' = '..AminusLambdaIToTheP)
					end
					local RiP = AminusLambdaIToTheP:nullspace(args.nullspace)
					
					-- TODO here only add the columns of RiP when they are linearly independent of Ri
					-- so what's an easy linear independence test?
					-- i don't have a guaranteed full basis so I can't just use det == 0
					-- so https://www.impan.pl/~pmh/teach/algebra/additional/eigen.pdf
					-- looks like we can mul each column vector by (A - I λ), and if it's zero then we ignore it ... ?
					-- ((mul by A - I λ)^k for some int k, and ignore if it's zero, or if it's a previous vector?)
					if eigenVerbose then
						printbr('which is '..RiP)
					end
					
					local n2 = RiP and RiP:dim()[2] or 0	-- should this be the same as n?
					printbr("nullspace dim of (A - I λ)^"..p.." =", n2)
					if n2 > 0 then
						-- (A - I λ) * RiP and look at which columns are not zero
						-- or is it (A - I λ)^(p-1) * RiP?
						-- or is it look at columns that are not already generalized eigenvectors?
						-- or is it look at the columns not a linear combination of already found generalized eigenvectors?
						local bleh = (AminusLambdaI * RiP)()
						if eigenVerbose then
							printbr('...times (A - λ I) is '..bleh)
						end
						for j,prodcol in ipairs(bleh:T()) do	-- for each column ...
							local prodcol = Matrix(prodcol):T()
							
							-- [[ see if the column vector product with AminusLambdaI is zero
							printbr('checking new potential vector product', prodcol:T()[1])
							local allZero = true
							for i=1,#prodcol do
								if not Constant.isValue(prodcol[i][1], 0) then
									allZero = false
									break
								end
							end
							if allZero then
								printbr"...and it's all zeroes so we already considered this vector"
							end
							local good = not allZero
							--]]
							--[[ see if the column vector product with AminusLambdaI hasn't been used yet
							-- no no no, if the product result is a previous vector then that's fine
							-- I guess it only matters if the new candidate vector is orthogonal to the current generalized eigenvector space
							if good then
								local prodcolasrow = prodcol:T()[1]
								printbr('checking new nullspace vector', prodcolasrow)
								local found
								for _,prevvec in ipairs(Ri:T()) do
									printbr('...comparing to '..prevvec)
									if prevvec == prodcolasrow then
										printbr'...and it was already used'
										found = true
										break
									end
								end
								good = not found
							end
							--]]
							
							if good then
								if eigenVerbose then
									printbr('adding col '..j)
								end
								-- TODO insert unique / linearly independent
								for i=1,#Ri do
									table.insert(Ri[i], RiP[i][j])
								end
								allLambdas:insert(lambdaInfo.expr)
								-- stop when we have full rank?
								if #Ri[1] == targetNumberOfEigenvectors then
									done = true
								end
							end
						end
						if done then break end
						-- TODO only insert non-linearly-independent rows
					end
				end
			end
		end
		--for i=1,lambdaInfo.mult do
		for i=1,n do
			allLambdas:insert(lambdaInfo.expr)
		end
		return Ri and Ri:T() or nil
	end)
	if eigenVerbose then
		for i,lambda in ipairs(lambdas) do
			printbr('right eigenvector of λ=', lambda.expr, 'is', Rs[i]:T())
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
	if R then
		local Rdim = R:dim()
		if not args.dontCalcL
		and #Rdim == 2
		and Rdim[1] == Rdim[2]
		then
			L = R:inverse()
			if eigenVerbose then
				printbr(var'L':eq(L))
			end
		end
	end
	
	local Lambda = Matrix.diagonal( allLambdas:unpack() )
	if eigenVerbose then
		printbr(var'Λ':eq(Lambda))
	end
	if eigenVerbose and L then
		printbr'verify:'
		printbr( (R * Lambda * L):eq( (R * Lambda * L)() ) )
	end

	-- only pop rules if they had been pushed
	if pushMulPruneLogPow then
		symmath.op.mul:popRule'Prune/logPow'
	end
	if pushLogExpandApply then
		symmath.log:popRule'Expand/apply'
	end
 
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
