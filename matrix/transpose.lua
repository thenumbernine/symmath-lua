return function(A)
	local Tensor = require 'symmath.Tensor'
	local Matrix = require 'symmath.Matrix'
	local clone = require 'symmath.clone'
	if not (type(A) == 'table' and A.isa and A:isa(Tensor)) then return A end
	local dim = A:dim()
	assert(#dim == 2 and dim[1] == dim[2], "expected a square rank-2 tensor")
	local n = dim[1]
	return Matrix(
		range(n):map(function(i) 
			return range(n):map(function(j)
				return clone(A[j][i])
			end)
		end):unpack()
	)
end

