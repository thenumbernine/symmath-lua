-- https://en.wikipedia.org/wiki/Pauli_matrices
-- https://en.wikipedia.org/wiki/Gamma_matrices
local Matrix = require 'symmath.Matrix'
local i = require 'symmath'.i

local I2x2 = Matrix({1,0},{0,1})

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
local gamma1 = Matrix({0,0,0,1},{0,0,1,0},{0,-1,0,0},{-1,0,0,0})
local gamma2 = Matrix({0,0,0,-i},{0,0,i,0},{0,i,0,0},{-i,0,0,0})
local gamma3 = Matrix({0,0,1,0},{0,0,0,-1},{-1,0,0,0},{0,1,0,0})

local Dirac4 = Matrix(gamma0,gamma1,gamma2,gamma3)


return {
	QuaternionC2 = QuaternionC2,
	--QuaternionR4 = QuaternionC2:complexify(),	-- TODO 
	
	Pauli = Pauli,	-- TODO make this PauliC2, and make PauliR4
	Pauli4 = Pauli4,
	Dirac = Dirac,
	-- WeylBasis
	-- WeylBasisAlt
	-- MajornaBasis
}
