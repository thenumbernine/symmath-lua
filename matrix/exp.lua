local function matrixExponent(A)
	local symmath = require 'symmath'
	local exp = symmath.exp
	local Matrix = symmath.Matrix
	local ev = Matrix.eigen(A)
	local R, L, allLambdas = ev.R, ev.L, ev.allLambdas
	local expLambda = Matrix.diagonal( allLambdas:mapi(function(lambda) 
		return exp(lambda) 
	end):unpack() )
--printbr(R * expLambda * L)	
	return (R * expLambda * L)()
end

return matrixExponent
