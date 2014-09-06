-- Eigenvectors from Trangenstein J. A. "A Numerical Solution of Hyperbolic Partial Differential Equations"

require 'symmath'
require 'tensor'

-- ... until tensor incorporates multiline tostring ...
symmath.toStringMethod = symmath.ToSingleLineString

local function simplify(A)
	local simplified = tensor.Tensor(A.dim, function(i,j)
		local v = A[i][j]
		local srcv
		repeat
			srcv = v
			v = symmath.expand(v)
			v = symmath.factor(v)
			v = symmath.prune(v)
		until v == srcv
		--print('simplifying '..i..','..j..' from '..A[i][j]..' to '..v)
		return v
	end)
	--print('simplifying from '..A..' to '..simplified)
	return simplified
end

local function inverse(A)
	assert(A.dim[1] == A.dim[2])
	local n = A.dim[1]

	A = A:clone()
	print('A',A)
	
	-- assumes A is a rank-2 tensor
	local AInv = tensor.ident(2, n)

	for i=1,n do
		-- if we have a zero on the diagonal...
		if A[i][i] == 0 then
			-- pivot with a row beneath this one
			local found = false
			for j=i+1,n do
				if A[j][i] ~= 0 then
					for k=1,n do
						A[j][k], A[i][k] = A[i][k], A[j][k]
						AInv[j][k], AInv[i][k] = AInv[i][k], AInv[j][k]
					end
					A = simplify(A)
					AInv = simplify(AInv)
					print('pivot rows '..i..' and '..j..' A='..A..' AInv='..AInv)
					found = true
					break
				end
			end
			if not found then
				error("couldn't find a row to pivot")
			end
		end
		-- rescale diagonal
		if A[i][i] ~= 1 then
			-- rescale column
			local s = A[i][i]
			for j=1,n do
				A[i][j] = A[i][j] / s
				AInv[i][j] = AInv[i][j] / s
			end
			A = simplify(A)
			AInv = simplify(AInv)
			print('rescale row '..i..' A='..A..' AInv='..AInv)
		end
		-- eliminate columns apart from diagonal
		for j=1,n do
			if j ~= i then
				if A[j][i] ~= 0 then
					local s = A[j][i]
					for k=1,n do
						A[j][k] = A[j][k] - s * A[i][k]
						AInv[j][k] = AInv[j][k] - s * AInv[i][k]
					end
					A = simplify(A)
					AInv = simplify(AInv)
					print('removed entry '..j..','..i..' A='..A..' AInv='..AInv)
				end
			end
		end
	end
end


-- [[ 2x2 inverse
local a = symmath.Variable('a')
local b = symmath.Variable('b')
local c = symmath.Variable('c')
local d = symmath.Variable('d')
local m = tensor.Tensor(2,2, {{a,b},{c,d}})

print('m = '..m)
print('m[1,2] = '..m[1][2])
local mInv = inverse(m)
--]]

--[[
local bx = symmath.Variable('bx')
local by = symmath.Variable('by')
local bz = symmath.Variable('bz')
local sigma = symmath.Variable('sigma')
local rho = symmath.Variable('rho')
local cf = symmath.Variable('cf')
local c = symmath.Variable('c')
local cs = symmath.Variable('cs')

local bSq = bx^2 + by^2 + bz^2

local m = tensor.Tensor(8, 8, {
	{
		(rho * cf^2 - bSq) / c^2,
		0,
		(rho * cs^2 - bSq) / c^2,
		1,
		0,
		(rho * cs^2 - bSq) / c^2,
		0,
		(rho * cf^2 - bSq) / c^2
	},
	{
		-cf + bx^2 / (rho * cf),
		0,
		-cs + bx^2 / (rho * cs),
		0,
		0,
		cs - bx^2 / (rho * cs),
		0,
		cf - bx^2 / (rho * cf),
	},
	{
		bx * by / (rho * cf),
		bz * sigma,
		bx * by / (rho * cs),
		0,
		0,
		-bx * by / (rho * cs),
		-bz * sigma,
		-bx * by / (rho * cf),
	},
	{
		bx * bz / (rho * cf),
		-by * sigma,
		bx * bz / (rho * cs),
		0,
		0,
		-bx * bz / (rho * cs),
		by * sigma,
		-bx * bz / (rho * cf),
	},
	{
		0,
		0,
		0,
		0,
		1,
		0,
		0,
		0,
	},
	{
		by,
		bz * symmath.sqrt(rho),
		by,
		0,
		0,
		by,
		bz * symmath.sqrt(rho),
		by,
	},
	{
		bz,
		-by * symmath.sqrt(rho),
		bz,
		0,
		0,
		bz,
		-by * symmath.sqrt(rho),
		bz,
	},
	{
		rho * cf^2 - bSq,
		0,
		rho * cs^2 - bSq,
		0,
		0,
		rho * cs^2 - bSq,
		0,
		rho * cf^2 - bSq,
	}
})
print(m)
print(inverse(m))
--]]


