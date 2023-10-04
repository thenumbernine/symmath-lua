-- https://en.wikipedia.org/wiki/Pauli_matrices
-- https://en.wikipedia.org/wiki/Gamma_matrices
local Matrix = require 'symmath.Matrix'
local i = require 'symmath'.i
local s0 = Matrix({1,0},{0,1})
local sx = Matrix({0,1},{1,0})
local sy = Matrix({0,-i},{i,0})
local sz = Matrix({1,0},{0,-1})

local Pauli = Matrix(sx,sy,sz)
local Pauli4 = Matrix(s0,sx,sy,sz)

local gamma0 = Matrix({1,0,0,0},{0,1,0,0},{0,0,-1,0},{0,0,-1,-1})
local gamma1 = Matrix({0,0,0,1},{0,0,1,0},{0,-1,0,0},{-1,0,0,0})
local gamma2 = Matrix({0,0,0,-i},{0,0,i,0},{0,i,0,0},{-i,0,0,0})
local gamma3 = Matrix({0,0,1,0},{0,0,0,-1},{-1,0,0,0},{0,1,0,0})

local Dirac4 = Matrix(gamma0,gamma1,gamma2,gamma3)

return {
	Pauli = Pauli,
	Pauli4 = Pauli4,
	Dirac = Dirac,
	-- WeylBasis
	-- WeylBasisAlt
	-- MajornaBasis
}
