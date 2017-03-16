return function(A)
	local dim = A:dim()
	local m, n = dim[1].value, dim[2].value
	local sum = require 'symmath.Constant'(0)
	for i=1,math.min(m,n) do
		sum = sum + A[i][i]
	end
	return sum()
end
