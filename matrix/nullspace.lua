-- returns a matrix with column vectors of the nullspace basis, or an empty table for no nullspace
local function nullspace(A)
	local Constant = require 'symmath.Constant'
	local Matrix = require 'symmath.Matrix'
	
	local n = #A
	local _, reduce = A:inverse()

	-- find all non-leading columns
	local nonLeadingCols = table()
	local j = 1
	for i=1,n do
		while reduce[i][j] == Constant(0) and j <= n do
			nonLeadingCols:insert(j)
			j=j+1
		end
		if j > n then break end
		assert(reduce[i][j] == Constant(1), "found a column that doesn't lead with 1")
		j = j + 1
	end
	nonLeadingCols:append(range(j,n))
	if #nonLeadingCols > 0 then
		-- now build the eigenvector basis for this eigenvalue
		local ev = Matrix:zeros{n, #nonLeadingCols}
		
		-- cycle through the rows
		for i=1,n do
			local k = nonLeadingCols:find(i) 
			if k then
				ev[i][k] = Constant(1)
			else
				-- j is the free param # (eigenvector col)
				-- k is the non leading column
				-- everything else in reduce[i][*] should be zero, except the leading 1
				for k,j in ipairs(nonLeadingCols) do
					ev[i][k] = ev[i][k] - reduce[i][j]
				end
			end
		end
		
		ev = ev()
		return ev
	end
end

return nullspace
