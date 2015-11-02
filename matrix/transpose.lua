return function(A)
	local Array = require 'symmath.Array'
	local Matrix = require 'symmath.Matrix'
	local clone = require 'symmath.clone'
	if not Array.is(A) then return A end
	local dim = A:dim()
	assert(#dim == 2, "expected a rank-2 array")
	local rows = {}
	for i=1,dim[2].value do
		local row = {}
		rows[i] = row
		for j=1,dim[1].value do
			row[j] = A[j][i]:clone()
		end
	end
	return Matrix(table.unpack(rows))
end

