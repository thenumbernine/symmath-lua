#! /usr/bin/env luajit
require 'ext'
local symmath = require 'symmath'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
print(MathJax.header)
local printbr = MathJax.print
MathJax.usePartialLHSForDerivative = true

local Tensor = symmath.Tensor
local Matrix = symmath.Matrix
local TensorIndex = require 'symmath.tensor.TensorIndex'
local var = symmath.var
local vars = symmath.vars
local sqrt = symmath.sqrt
local sin = symmath.sin
local cos = symmath.cos
local frac = symmath.divOp

local t,r,phi,z = vars('t', 'r', '\\phi', 'z')
local pi = var'\\pi'

--[[
local eps0 = var'\\epsilon_0'
local mu0 = var'\\mu_0'
--]]
-- [[
local mu0 = 4 * pi 
local eps0 = 1 / mu0 
--]]

local spatialCoords = {r,phi,z}
local coords = table{t}:append(spatialCoords)

Tensor.coords{
	{variables=coords},
	{symbols='ijklmn', variables=spatialCoords},
	{symbols='t', variables={t}},
	{symbols='x', variables={x}},
	{symbols='y', variables={y}},
	{symbols='z', variables={z}},
}

local g = Tensor'_ab'
g['_ab'] = Tensor('_ab', table.unpack(Matrix.diagonal(-1, 1, r^2, 1))) 

local gU = Tensor'^ab'
gU['^ab'] = Tensor('^ab', table.unpack(Matrix.diagonal(-1, 1, r^-2, 1))) 

local gamma = Tensor('_ij', {1,0,0}, {0,r^2,0}, {0,0,1})
--printbr(var'\\gamma''_ij':eq(gamma'_ij'()))

local gammaU = Tensor('^ij', table.unpack((Matrix.inverse(gamma))))
--printbr(var'\\gamma''^ij':eq(gammaU'^ij'()))

Tensor.metric(g, gU)
Tensor.metric(gamma, gammaU, 'i')

local sqrt_det_gamma = sqrt(Matrix.determinant(gamma))()
--printbr(sqrt(var'\\gamma'):eq(sqrt_det_gamma))

local LeviCivita3 = Tensor('_ijk', function(i,j,k)
	if i%3+1 == j and j%3+1 == k then return sqrt_det_gamma end
	if k%3+1 == j and j%3+1 == i then return -sqrt_det_gamma end
	return 0
end)
--printbr(var'\\epsilon''_i^jk':eq(LeviCivita3'_i^jk'()))

local E = Tensor('_i', function(i) return var('E_'..spatialCoords[i].name, coords) end)
local Er, Ephi, Ez = table.unpack(E)

local B = Tensor('_i', function(i) return var('B_'..spatialCoords[i].name, coords) end)
local Br, Bphi, Bz = table.unpack(B)

local S = (LeviCivita3'_i^jk' * E'_j' * B'_k')()

--printbr(var'E''_i':eq(E))
--printbr(var'B''_i':eq(B))
--printbr(var'S''_i':eq(S))

local ESq_plus_BSq = (E'_i' * E'_j' * gammaU'^ij' + B'_i' * B'_j' * gammaU'^ij')()

-- taken from my electrovacuum.lua script
local Ricci_EM = Tensor'_ab'
Ricci_EM['_tt'] = Tensor('_tt', {ESq_plus_BSq})
Ricci_EM['_ti'] = Tensor('_ti', (-2 * S'_i')())
Ricci_EM['_it'] = Tensor('_ti', (-2 * S'_i')())
Ricci_EM['_ij'] = (-2 * E'_i' * E'_j' - 2 * B'_i' * B'_j' + ESq_plus_BSq * gamma'_ij')()

local lambda = var'\\lambda'
local I = var'I'
printbr'for a uniformly charged wire...'
-- TODO http://www.physicspages.com/2013/11/18/electric-field-outside-an-infinite-wire/
Ricci_EM = Ricci_EM
	-- http://farside.ph.utexas.edu/teaching/302l/lectures/node26.html
	:replace(Er, lambda / (2 * pi * eps0 * r))
	:replace(Ephi, 0)
	:replace(Ez, 0)
	-- http://hyperphysics.phy-astr.gsu.edu/hbase/magnetic/magcur.html
	:replace(Br, 0)
	:replace(Bphi, mu0 * I / (2 * pi * r))
	:replace(Bz, 0)
	:simplify()
--printbr(var'R''_ab':eq(Ricci_EM'_ab'()))

local Conn = Tensor'^a_bc'

Conn[2][1][1] = 2 * I / r^2
Conn[1][1][1] = 2 * I / r^2
Conn[1][2][2] = 2 * I / r^2
Conn[1][3][3] = 2 * I / r^2
Conn[1][4][4] = 2 * I / r^2

--[[ 
-- C^x_tt = E x
-- C^t_tt = C^t_yy = C^t_zz = sqrt(E) 
-- => R_tt = R_yy = R_zz = E
Conn[1][1][1] = sqrt(E)
Conn[2][1][1] = -sqrt(E)-- with C^t_xt = C^t_tx = sqrt(E) this leaves R_tt = E^(3/2)
Conn[1][2][1] = sqrt(E)	-- R_xx = -E, changes R_tx and R_tt
Conn[1][1][2] = sqrt(E)	-- with C^t_xt = sqrt(E) this eliminates R_tx and the only difference is R_tt = E - E^(3/2) x
Conn[1][3][3] = sqrt(E)
Conn[1][4][4] = sqrt(E)
--]]

--[[ 
-- C^x_tt = E x
-- C^t_tt = -C^t_xx = C^t_yy = C^t_zz = sqrt(E) 
-- => R_tt = -R_xx = R_yy = R_zz = E, R_tx = R_xt = E^(3/2) x
Conn[2][1][1] = E * x
Conn[1][1][1] = sqrt(E)
Conn[1][2][2] = -sqrt(E)
Conn[1][3][3] = sqrt(E)
Conn[1][4][4] = sqrt(E)
-- R_tx is influenced by R^t_ttx, R^y_tyx, R^z_tzx
-- R_xt is influenced by R^x_xxt, R^y_xyt, R^z_xzt
--Conn[2][2][2] = E	-- adds E to R_tt
--Conn[2][1][2] = E	-- scales R_jj by 1 + sqrt(E), adds something to R_tt
--Conn[2][2][1] = E	-- adds 2 E^(3/2) to R_xx
--Conn[2][3][1] = E	-- adds E^(3/2) to R_xy and R_yx
--Conn[2][1][3] = E	-- nothing
--Conn[3][1][2] = E	-- nothing
--Conn[1][1][2] = E	-- changes R_tt and R_tx 
--Conn[1][2][1] = E	-- changes R_tt and R_tx and R_xx
--Conn[1][3][2] = E	-- changes R_ty, R_xy, R_yt
--]]

--[[ 
-- C^y_tt = E y
-- C^t_tt = -C^t_xx = C^t_yy = C^t_zz = sqrt(E) 
-- => R_tt = -R_xx = R_yy = R_zz = E, R_ty = R_yt = E^(3/2) y
Conn[3][1][1] = E * y
Conn[1][1][1] = sqrt(E)
Conn[1][2][2] = -sqrt(E)
Conn[1][3][3] = sqrt(E)
Conn[1][4][4] = sqrt(E)
--]]

--[[ 
-- C^x_tt = E x
-- C^t_tt = -C^t_xx = C^t_yy = C^t_zz = sqrt(E) 
-- => R_tt = -R_xx = R_yy = R_zz = E, R_tx = R_xt = E^(3/2) x
Conn[2][1][1] = E * x
Conn[1][1][1] = sqrt(E)
Conn[1][2][2] = -sqrt(E)
Conn[1][3][3] = sqrt(E)
Conn[1][4][4] = sqrt(E)
--]]

--[[ C^t_tt = -C^t_xx = C^t_yy = C^t_zz = sqrt(E) => -R_xx = R_yy = R_zz = E
Conn[1][1][1] = sqrt(E)
Conn[1][2][2] = -sqrt(E)
Conn[1][3][3] = sqrt(E)
Conn[1][4][4] = sqrt(E)
--]]

--[[ C^j_tt = E x_j => R_tt = E 
Conn[2][1][1] = E * x
--Conn[3][1][1] = E * y
--Conn[4][1][1] = E * z
--]]

--[[ C^t_jt = +-sqrt(E) => R_jj = -E
Conn[1][2][1] = -sqrt(E)
--Conn[1][3][1] = -sqrt(E)
--Conn[1][4][1] = -sqrt(E)
--]]

--[[ C^t_tt = +-C^t_jj = sqrt(E) => R_jj = +-E
-- jj's linearly combine
Conn[1][1][1] = sqrt(E)
Conn[1][2][2] = -sqrt(E)
--Conn[1][3][3] = sqrt(E)
--Conn[1][4][4] = sqrt(E)
--]]

--[[ C^t_ty = -C^t_yt = sqrt(E) => R_yy = -E
Conn[1][1][3] = sqrt(E)
Conn[1][3][1] = -sqrt(E)
--]]


--[[ C^x_xy = -C^x_yx = sqrt(E) => R_yy = -E
Conn[2][2][3] = sqrt(E)
Conn[2][3][2] = -sqrt(E)
--]]

-- C^t_ty = -C^t_yt = sqrt(E) and C^x_xy = -C^x_yx = sqrt(E) linearly combine



local s = table()
for index,value in Conn:iter() do
	local a,b,c = table.unpack(index)
	if value ~= symmath.Constant(0) then
		s:insert(tostring(var('\\Gamma^{'..coords[a].name..'}'..'_{'..coords[b].name..coords[c].name..'}'):eq(value))) 
	end
end
printbr(s:concat',')

-- why am I getting asymmetric Ricci curvature for symmetric connections? 
local RiemannExpr = Conn'^a_bd,c' - Conn'^a_bc,d' 
	+ Conn'^a_ec' * Conn'^e_bd' - Conn'^a_ed' * Conn'^e_bc'
	- Conn'^a_be' * (Conn'^e_dc' - Conn'^e_cd')
--[[
printbr(var'R''^a_bcd':eq(RiemannExpr:replace(Conn, var'\\Gamma')))
printbr(var'R''_ab':eq(RiemannExpr
	:replace(Conn, var'\\Gamma')
	:replace(TensorIndex{lower=false, symbol='a'}, TensorIndex{lower=false, symbol='c'})
	:replace(TensorIndex{lower=true, symbol='b'}, TensorIndex{lower=true, symbol='a'})
	:replace(TensorIndex{lower=true, symbol='d'}, TensorIndex{lower=true, symbol='b'})
	:replace(TensorIndex{lower=true, symbol='d', derivative='partial'}, TensorIndex{lower=true, symbol='b', derivative='partial'})
))
--]]

local Riemann = Tensor'^a_bcd'
Riemann['^a_bcd'] = RiemannExpr()
--printbr(var'R''^a_bcd':eq(Riemann))

local Ricci = Riemann'^c_acb'()
print(var'R''_ab':eq(Ricci))

print('vs desired')
printbr(var'R''_ab':eq(Ricci_EM'_ab'()))
