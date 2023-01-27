local table = require 'ext.table'
local range = require 'ext.range'

-- returns a matrix with column vectors of the nullspace basis, or an empty table for no nullspace
local function nullspace(A, verbose)
	local Constant = require 'symmath.Constant'
	local Matrix = require 'symmath.Matrix'

	if verbose and type(verbose) ~= 'function' then
		verbose = _G.printbr or _G.print
	end

	local n = #A

	if verbose then
		verbose('calculating inverse...')
	end

	local _, reduce
	if not verbose then
		_, reduce = A:inverse()
	else
		local k = 0
		_, reduce = A:inverse(nil, function(AInv, A, row, i, j, op)
			k = k + 1
			verbose('op # '..k
				..' op = '..op
				..' row = '..row
				..' i,j = '..i..','..tostring(j)
				..' #nodes = '..AInv:countNodes()
			)
			--[[
			do --if k > 100 then
				verbose('A | AInv = '..Matrix{A, AInv})
			end
			--]]
		end)
		verbose('inverse result is: '.._)
		verbose('reduced result is: '..reduce)
	end

	-- find all non-leading columns
	local nonLeadingCols = table()
	local firstNonZeroColPerRow = table()
	local j = 1
	for i=1,n do
		while Constant.isValue(reduce[i][j], 0) and j <= n do
			nonLeadingCols:insert(j)
			j=j+1
		end
		if j > n then break end
		assert(Constant.isValue(reduce[i][j], 1), "found a column that doesn't lead with 1")
		firstNonZeroColPerRow[i] = j
		j = j + 1
	end
	local zeroRows = range(j,n)
	nonLeadingCols:append(zeroRows)
	firstNonZeroColPerRow:append(range(n-#firstNonZeroColPerRow):mapi(function() return n end))
	assert(#firstNonZeroColPerRow == n)
	local m = #nonLeadingCols
	if m > 0 then
		-- now build the eigenvector basis for this eigenvalue
		local ev = Matrix:zeros{n, m}

		for j,i in ipairs(nonLeadingCols) do
			ev[i][j] = Constant(1)
		end

		-- cycle bottom to top through the rows
		-- all zeroes = ignore
		-- nonzeros = replace elements to the right of the leading-1 with our newfound parameters,
		--  insert into the parameter column vectors accordingly
		for i=n,1,-1 do
			--if zeroRows:find(i) then
			-- all zeros, leave the components zero
			--else
			local j = firstNonZeroColPerRow[i]
			-- reduce[i][j] == 1
			-- sum k=j,n (reduce[i][k] x[i]) = 0
			-- reduce[i][j] x[j] + sum k=j+1,n (reduce[i][k] x[i]) = 0
			-- x[j] = (-1/reduce[i][j]) * sum k=j+1,n (reduce[i][k] x[i])
			for k=j+1,n do
				if not Constant.isValue(reduce[i][k], 0) then
					-- now we have to include this term in the results of x[j]
					-- but while simultaneously separating the coefficients into the u[l][m] locations
					local paramIndex = nonLeadingCols:find(k)
					if paramIndex then
						if verbose then
							verbose('A['..j..']['..paramIndex..'] = A['..j..']['..paramIndex..' - (AInv['..i..']['..k..'] = '..reduce[i][k]..') / (AInv['..i..']['..j..'] = '..reduce[i][j]..')')
						end
						-- if col 'k' is a free variable 'u'
						-- insert into u's row -reduce[i][k] / reduce[i][j]
						ev[j][paramIndex] = ev[j][paramIndex] - reduce[i][k] / reduce[i][j]
					else
						if verbose then
							verbose('row '..j..' = row '..j..' - row '..k..' * (AInv['..i..']['..k..'] = '..reduce[i][k]..') / (AInv['..i..']['..j..'] = '..reduce[i][j]..')')
						end
						-- else if col 'k' is a previous 'x' ...
						-- lookup the value of x[k] in terms of each u ...
						-- add -reduce[i][k] / reduce[i][j] times those u coeffs into this row's u's
						for l=1,m do
							ev[j][m] = ev[j][m] - reduce[i][k] / reduce[i][j] * ev[k][m]
						end
					end
				end
			end
		end

		ev = ev()

		return ev
	end
end

return nullspace
