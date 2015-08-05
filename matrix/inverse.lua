--[[
A = matrix to invert
AInv = vector to solve the linear system inverse of.  default: identity, to produce the ivnerse matrix.

TODO how to handle matrix inverses?
as a separate function? symmath.inverse.
same question with matrix multiplication
same question with per-component matrix multiplication
then there's the question of how to integrate arrays in general
then there's breaking down prune/simplify op visitors into rules, so I could quickly insert a new rule when using matrices 
--]]
return function(A, AInv)
	local Array = require 'symmath.Array'
	local Matrix = require 'symmath.Matrix'
	local Constant = require 'symmath.Constant'
	local simplify = require 'symmath.simplify'
	local clone = require 'symmath.clone'
	
	if type(A) == 'number' then return 1/Constant(A) end
	if not (type(A) == 'table' and A.isa and A:isa(Array)) then return Constant(1)/A end

	-- ... and Array
	local dim = A:dim()
	assert(#dim == 2 and dim[1] == dim[2], "expected a square rank-2 array")
	local n = dim[1]

	A = clone(A)
	
	-- assumes A is a rank-2 array
	AInv = AInv and AInv:clone() or Matrix.identity(n)
	local invdim = AInv:dim()
	assert(#invdim == 2 and invdim[1] == dim[1], "expected vectors to invert to have same height as linear system")

	for i=1,n do
		-- if we have a zero on the diagonal...
		if A[i][i] == Constant(0) then
			-- pivot with a row beneath this one
			local found = false
			for j=i+1,n do
				if A[j][i] ~= Constant(0) then
					for k=1,n do
						A[j][k], A[i][k] = A[i][k], A[j][k]
					end
					for k=1,invdim[2] do
						AInv[j][k], AInv[i][k] = AInv[i][k], AInv[j][k]
					end
					A = simplify(A)
					AInv = simplify(AInv)
					found = true
					break
				end
			end
			if not found then
				error("couldn't find a row to pivot")
			end
		end
		-- rescale diagonal
		if A[i][i] ~= Constant(1) then
			-- rescale column
			local s = A[i][i]
--print('rescaling row '..i..' by \\('..(1/s):simplify()..'\\)<br>')
			for j=1,n do
				A[i][j] = A[i][j] / s
			end
			for j=1,invdim[2] do
				AInv[i][j] = AInv[i][j] / s
			end
			A = simplify(A)
			AInv = simplify(AInv)
--print('\\(A =\\) '..A..', \\(A^{-1}\\) = '..AInv..'<br>')
		end
		-- eliminate columns apart from diagonal
		for j=1,n do
			if j ~= i then
				if A[j][i] ~= Constant(0) then
					local s = A[j][i]
--print('subtracting \\('..s..'\\) to row '..j..'<br>')
					for k=1,n do
						A[j][k] = A[j][k] - s * A[i][k]
					end
					for k=1,invdim[2] do
						AInv[j][k] = AInv[j][k] - s * AInv[i][k]
					end
--print('\\(A = \\)'..A..'<br>')
--print('simplifying A...<br>')
					A = simplify(A)
--print('\\(A = \\)'..A..'<br>')
--print('\\(A^{-1} = \\)'..AInv..'<br>')
--print('simplifying A^{-1}...<br>')
					AInv = simplify(AInv)
--print('\\(A^{-1} = \\)'..AInv..'<br>')
				end
			end
		end
	end

	return AInv
end

