local table = require 'ext.table'

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
	
	allLambdas = table()	-- redo allLambdas so the order matches the right-eigenvectors' order
	local Rs = lambdas:mapi(function(lambdaInfo) 
		local lambda = lambdaInfo.expr
		local Ri = (A - lambda * I)():nullspace()
		if lambdaInfo.mult ~= #Ri[1] then
			error("nullspace of "..lambda.." is "..#Ri[1].." but multiplicity of eigenvalue is "..lambdaInfo.mult)
		end
		for i=1,lambdaInfo.mult do
			allLambdas:insert(lambdaInfo.expr)
		end
		return Ri:T()
	end)
--for i,lambda in ipairs(lambdas) do
--	printbr('right eigenvector of', lambda.expr, 'is', Rs[i]:T())
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
		lambdas = lambdas,			-- this holds {expr=, mult=} multiplicity
		allLambdas = allLambdas,	-- this just holds a list
		
		Lambda = Lambda,
		R = R,
		L = L,
	}
end

return eigen
