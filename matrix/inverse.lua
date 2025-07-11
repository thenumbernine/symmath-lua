--[[
TODO split this into a few functions ...
1) gaussJordan() - which would contain what it is right now for the n>3 case
2) adjoint() - create adj(A) = det(A) * A^-1 based on permutation tensor identity ... adj(A)^u_a = (A^-1)^u_a det(A) = 1/(n-1)! kronDelta^{u1..un}_{a1..an} A^a1_u1 * ... * A^an_un (MTW "Gravitation" def)
3) inverse() - to call the previous implementations (based on dimension?)
4) pseudoInverse() - same, but without constraint of m==n
5) linsolve() (or a better name) - A:linsolve(b) == solve for x when A x = b
	(or for :solve() compatability ... (A*x):eq(b):solve(x) ... but this would require defining 'x' as a matrix-of-variables up front ... or even just as a variable up front ...)


A = matrix to invert
AInv = vector to solve the linear system inverse of.  default: identity, to produce the inverse matrix.
callback = watch the progress!
allowRectangular = set this to true to perform Gaussian elimination on the rectangular linear system
A_det = assign this to substitute an expression into A_det.
	Only works for 2x2 and 3x3 for now.
	TODO do like maxima and leave the determinant factored out front?

TODO how to handle matrix inverses?
as a separate function? symmath.inverse.
same question with matrix multiplication
same question with per-component matrix multiplication
then there's the question of how to integrate arrays in general
then there's breaking down prune/simplify op visitors into rules, so I could quickly insert a new rule when using matrices

returns AInv, A, and any errors encountered during the simplification
(should I favor consistency of return argument order, like pcall?
or should I favor assert() compatability?)


--]]
return function(A, b, callback, allowRectangular, A_det)
	local Array = require 'symmath.Array'
	local Matrix = require 'symmath.Matrix'
	local Constant = require 'symmath.Constant'
	local simplify = require 'symmath.simplify'
	local clone = require 'symmath.clone'

	if Constant.isNumber(A) then return 1/Constant(A) end
	if not Array:isa(A) then return Constant(1)/A end

	-- expects A to be
	local dim = A:dim()
	if #dim ~= 2 then
		error("expected A to be a index-2 Array, found index-"..#dim)
	end

-- still toying with the notion of allowing rectangular matrices ...
-- and simply returning what progress was made in the inversion
-- along with any error messages along the way
-- I think I will make this assertion here for Matrix.inverse
-- then remove it for another function called 'linsolve'
-- and have the two use the same code
	if not allowRectangular then
		if dim[1] ~= dim[2] then
			error("expected A to be square, found dimensions "..dim[1]..", "..dim[2])
		end
	end

	local m, n = dim[1], dim[2]

	A = clone(A)

	-- assumes A is a rank-2 array with matching height
	local AInv = b and clone(b) or Matrix.identity(m)
	local invdim = AInv:dim()
	assert(#invdim == 2, "expect b to be a rank-2 Array")
	if invdim[1] ~= dim[1] then
		if b then
			error("expected A number of rows to match b number of rows.\n"
				.."found A to have "..m.." rows and b to have "..invdim[1].." rows")
		else
			error("hmm, you picked the wrong default number of rows for the result")
		end
	end

	-- shortcuts:
	if not b then
		if m == 1 and n == 1 then
			local A_11 = A[1][1]
			if Constant.isValue(A_11, 0) then
				return AInv, A, "determinant is zero"
			end
			local result = Matrix{(1/A_11)()}
			if b then result = (result * b)() end
			return result, Matrix.identity(invdim[1], invdim[2])
		elseif m == 2 and n == 2 then
			A_det = A_det or A:determinant()
			if not Constant.isValue(A_det, 0) then
				local result = (Matrix(
					{A[2][2], -A[1][2]},
					{-A[2][1], A[1][1]}
				) / A_det)()
				--if b then result = (result * b)() end
				return result, Matrix.identity(invdim[1], invdim[2])
			end
-- TODO maybe put GaussJordan in one method and have inverse() and pseudoInverse() etc call it
-- then give inverse() its own shortcut for the 2x2 and 3x3 methods?
-- because right now this function does a few things: inverse, pseudoinverse, linear system solution
		elseif m == 3 and n == 3 then
			A_det = A_det or A:determinant()
			if not Constant.isValue(A_det, 0) then
				-- transpose, +-+- sign stagger, for each element remove that row and column and
				local result = (Matrix(
					{A[2][2]*A[3][3]-A[2][3]*A[3][2], A[1][3]*A[3][2]-A[1][2]*A[3][3], A[1][2]*A[2][3]-A[1][3]*A[2][2]},
					{A[2][3]*A[3][1]-A[2][1]*A[3][3], A[1][1]*A[3][3]-A[1][3]*A[3][1], A[1][3]*A[2][1]-A[1][1]*A[2][3]},
					{A[2][1]*A[3][2]-A[2][2]*A[3][1], A[1][2]*A[3][1]-A[1][1]*A[3][2], A[1][1]*A[2][2]-A[1][2]*A[2][1]}
				) / A_det)()
				--if b then result = (result * b)() end
				return result, Matrix.identity(invdim[1], invdim[2])
			end
		end
	end

	local min = math.min(m,n)

	-- i is the column, which increases across the matrix
	-- row is the row, which only increases as we find a new linearly independent column
	local row = 1
	for i=1,min do
		-- if we have a zero on the diagonal...
		local found = true
		if Constant.isValue(A[row][i], 0) then
			-- pivot with a row beneath this one
			found = false
			for j=row+1,m do
				if not Constant.isValue(A[j][i], 0) then
					for k=1,n do
						A[j][k], A[row][k] = A[row][k], A[j][k]
					end
					for k=1,invdim[2] do
						AInv[j][k], AInv[row][k] = AInv[row][k], AInv[j][k]
					end
					A = simplify(A)
					AInv = simplify(AInv)
					found = true
					break
				end
			end
		end
		if not found then
			-- return the progress if things fail
			--return AInv, A, "couldn't find a row to pivot"
		else
			-- rescale diagonal
			if not Constant.isValue(A[row][i], 1) then
				-- rescale column
				local s = A[row][i]
--DEBUG(@5):print('rescaling row '..i..' by $'..(1/s):simplify()..'$<br>')
				for j=1,n do
					A[row][j] = A[row][j] / s
				end
				for j=1,invdim[2] do
					AInv[row][j] = AInv[row][j] / s
				end
				A = simplify(A)
				AInv = simplify(AInv)
--DEBUG(@5):print('$A =$ '..A..', $A^{-1}$ = '..AInv..'<br>')
				if callback then callback(AInv, A, row, i, nil, 'scale') end
			end
			-- eliminate columns apart from diagonal
			for j=1,m do
				if j ~= row then
					if not Constant.isValue(A[j][i], 0) then
						local s = A[j][i]
--DEBUG(@5):print('subtracting $'..s..'$ to row '..j..'<br>')
						for k=1,n do
							A[j][k] = A[j][k] - s * A[row][k]
						end
						for k=1,invdim[2] do
							AInv[j][k] = AInv[j][k] - s * AInv[row][k]
						end
--DEBUG(@5):print('$A = $'..A..'<br>')
--DEBUG(@5):print('simplifying A...<br>')
						A = simplify(A)
--DEBUG(@5):print('$A = $'..A..'<br>')
--DEBUG(@5):print('$A^{-1} = $'..AInv..'<br>')
--DEBUG(@5):print('simplifying A^{-1}...<br>')
						AInv = simplify(AInv)
--DEBUG(@5):print('$A^{-1} = $'..AInv..'<br>')
						if callback then callback(AInv, A, row, i, j, 'row') end
					end
				end
			end
			row = row + 1
		end
	end

	if m > n then
		-- if there are more rows than columns
		-- then the remaining columns must be zero
		-- and should be cut out?
		for i=n+1,m do
			for j=1,invdim[2] do
				if not Constant.isValue(AInv[i][j], 0) then
					return AInv, A, "system is overconstrained"
				end
			end
		end
	end

	return AInv, A
end
