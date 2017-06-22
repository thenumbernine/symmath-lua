--[[ iterates through all permutations of the provided table
args:
	elements = what elements to permute
	callback = what to call back with
	[internal]
	index = constructed index to be passed to the callback
	[optional]
	size = how many elements to return.  default is the length
--]]

local table = require 'ext.table'
local range = require 'ext.range'

local function determinant(m)
	local Array = require 'symmath.Array'
	local Constant = require 'symmath.Constant'
	local simplify = require 'symmath.simplify'

	local original = m
	m = m:simplify()
	
	-- non-array?  return itself
	if not Array.is(m) then return original end

	local dim = m:dim()
	local volume = range(#dim):map(function(i)
		return dim[i].value
	end):combine(function(a,b) return a * b end) or 0

	-- 0x0 array?  return itself
	if volume == 0 then return Constant(1) end

	-- tempted to write a volume=1 rank=n return the n-th nested element condition ...

	-- not a rank-2 array? return nothing.  maybe error. 
	if #dim ~= 2 then return end

	-- not square?
	if dim[1] ~= dim[2] then error("determinant only works on square matrices") end

	local n = dim[1].value

	-- 1x1 matrix? 
	if n == 1 then
		return m[1][1]
	elseif n == 2 then
		return simplify(m[1][1] * m[2][2] - m[1][2] * m[2][1])
	end
	
	local Matrix = require 'symmath.Matrix'
	
	-- pick row (or column) with most zeroes
	local mostZerosOfRow, rowWithMostZeros = range(n):map(function(i)
		return range(n):map(function(j) return m[i][j] == Constant(0) and 1 or 0 end):sum()
	end):sup()
	local mostZerosOfCol, colWithMostZeros = range(n):map(function(j)
		return range(n):map(function(i) return m[i][j] == Constant(0) and 1 or 0 end):sum()
	end):sup()
	
	local useCol = mostZerosOfCol > mostZerosOfRow 
	local x = useCol and colWithMostZeros or rowWithMostZeros

	local result = Constant(0)
	for y=1,n do
		local i,j
		if useCol then i,j = y,x else i,j = x,y end
		local mij = m[i][j]
		-- if the # of flips is odd then scale by -1, if even then by +1 
		local sign = ((i+j)%2)==0 and 1 or -1
		if mij ~= Constant(0) then
			local submat = Matrix:lambda({n-1,n-1}, function(p,q)
				if p>=i then p=p+1 end
				if q>=j then q=q+1 end
				return m[p][q]
			end)
			result = result + sign * mij * determinant(submat)
		end
	end
	
	return simplify(result)
end

return determinant
