-- https://en.wikipedia.org/wiki/Pauli_matrices
-- https://en.wikipedia.org/wiki/Gamma_matrices
local table = require 'ext.table'
local Matrix = require 'symmath.Matrix'

local symmath = require 'symmath'
local i = symmath.i
local Re = symmath.Re
local Im = symmath.Im

local i2x2 = Matrix({0,-1}, {1,0})
local I2x2 = Matrix({1,0}, {0,1})

-- TODO make this for Matrix, or Array, or something,
-- and make it with split/merge dimensions / reshape / outer product
-- also TODO, when do we want to conjugate?
-- TODO: return src:outer(i2x2):mergeDims({1,3},{2,4})
local function complexify(src)
	local dim = src:dim()
	assert(#dim == 2)
	return Matrix:lambda({2*dim[1], 2*dim[2]}, function(i,j)
		local c = src[math.floor((i-1)/2+1)][math.floor((j-1)/2+1)]
		local u = (i-1)%2+1
		local v = (j-1)%2+1
		return (I2x2[u][v] * Re(c) + i2x2[u][v] * Im(c))()
	end)
end


local qex = Matrix({i, 0}, {0, -i})
local qey = Matrix({0, 1}, {-1, 0})
local qez = Matrix({0, i}, {i, 0})

local QuaternionC2 = Matrix(I2x2, qex, qey, qez)


local sigmax = Matrix({0,1},{1,0})
local sigmay = Matrix({0,-i},{i,0})
local sigmaz = Matrix({1,0},{0,-1})

-- Pauli = take Quaternion (from Hamilton, from a century before Pauli ...) spatial basis, then swap x and z, then multiply by 'i'
local Pauli = Matrix(sigmax,sigmay,sigmaz)
local Pauli4 = Matrix(I2x2,sigmax,sigmay,sigmaz)


local gamma0 = Matrix({1,0,0,0},{0,1,0,0},{0,0,-1,0},{0,0,0,-1})
local gamma0Chiral = Matrix({0,0,1,0},{0,0,0,1},{1,0,0,0},{0,1,0,0})
-- should be -matrixOuter(i2x2, sigma1)
local gamma1 = Matrix({0,0,0,1},{0,0,1,0},{0,-1,0,0},{-1,0,0,0})
-- should be -matrixOuter(i2x2, sigma2)
local gamma2 = Matrix({0,0,0,-i},{0,0,i,0},{0,i,0,0},{-i,0,0,0})
-- should be -matrixOuter(i2x2, sigma3)
local gamma3 = Matrix({0,0,1,0},{0,0,0,-1},{-1,0,0,0},{0,1,0,0})

local Dirac = Matrix(gamma0,gamma1,gamma2,gamma3)
local DiracChiral = Matrix(gamma0Chiral,gamma1,gamma2,gamma3)

return {
	QuaternionC2 = QuaternionC2,
	QuaternionR4 = Matrix( table.mapi(QuaternionC2, function(m) return complexify(m) end):unpack() ),
	
	Pauli = Pauli,	-- TODO make this PauliC2, and make PauliR4
	Pauli4 = Pauli4,
	Dirac = Dirac,
	DiracChiral = DiracChiral,
	-- WeylBasis
	-- WeylBasisAlt
	-- MajornaBasis
}
