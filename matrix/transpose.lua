return function(A)
	local Array = require 'symmath.Array'
	local Matrix = require 'symmath.Matrix'
	local clone = require 'symmath.clone'
	if not (type(A) == 'table' and A.isa and A:isa(Array)) then return A end
	local dim = A:dim()
	assert(#dim == 2, "expected a rank-2 array")
	local rows = {}
	for i=1,dim[2] do
		local row = {}
		rows[i] = row
		for j=1,dim[1] do
			row[j] = A[j][i]:clone()
		end
	end
	return Matrix(table.unpack(rows))
end

