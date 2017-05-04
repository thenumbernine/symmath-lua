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

local makeLeviCivita = require 'symmath.tensor.LeviCivita'
--local LeviCivita4 = makeLeviCivita()
--printbr(var'\\epsilon''_abcd':eq(LeviCivita4'_abcd'()))
local LeviCivita3 = makeLeviCivita('i')
--printbr(var'\\epsilon''_ijk':eq(LeviCivita3'_ijk'()))

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

-- [[
-- all I need now is R_rr = C^c_rr,c - C^c_rc,r + C^c_dc C^d_rr - C^c_dr C^d_rc - C^c_rd (C^d_rc - C^d_cr)
Conn[2][1][1] = -frac(4,3) * (I^2 / r^3) - 4 * lambda^2 / r
Conn[2][1][4] = 4 * I * lambda / r^2 
Conn[2][4][1] = 4 * I * lambda / r^2 

Conn[1][1][1] = 2 * I
--Conn[1][2][2] = 2 * I / r^4
Conn[1][3][3] = -2 * I / r^2
Conn[1][4][4] = 2 * I / r^4

Conn[2][3][3] = 4 * lambda^2 * r
Conn[2][4][4] = -4 * lambda^2 / r
--]]

--[[ produces R_tt, R_tz, R_zt, R_pp, Rzz
Conn[2][1][1] = -frac(4,3) * I^2 / r^3 - 4 * lambda^2 / r
Conn[2][1][4] = 4 * I * lambda / r^2 
Conn[2][4][1] = 4 * I * lambda / r^2 

Conn[1][1][1] = 2 * I
--Conn[1][2][2] = 2 * I / r^4
Conn[1][3][3] = -2 * I / r^2
Conn[1][4][4] = 2 * I / r^4

Conn[2][3][3] = 4 * lambda^2 * r
Conn[2][4][4] = -4 * lambda^2 / r
--]]

--[[ produces R_tt, R_tz, R_zt, and I component of R_pp, R_zz
Conn[2][1][1] = -frac(4,3) * I^2 / r^3 - 4 * lambda^2 / r
Conn[2][1][4] = 4 * I * lambda / r^2 
Conn[2][4][1] = 4 * I * lambda / r^2 

Conn[1][1][1] = 2 * I
--Conn[1][2][2] = 2 * I / r^4
Conn[1][3][3] = -2 * I / r^2
Conn[1][4][4] = 2 * I / r^4
--Conn[2][3][3] = lambda
--Conn[2][4][4] = lambda / r^2
--]]

--[[ C^r_tt = -4/3 I^2 / r^3 - 4 lambda^2 / r, C^r_tz = C^r_zt = 4 I lambda / r^2 
-- => R_tt = 4 (I^2 + lamda^2 r^2) / r^4, R_tz = R_zt = -8 I lambda / r^3
Conn[2][1][1] = (-frac(4,3) * I^2 / r^3 - 4 * lambda^2 / r)()
--Conn[1][1][4] = -8 * I * lambda * t / r^3
--Conn[1][4][1] = -8 * I * lambda * t / r^3		-- can't set C^t_zt = C^t_tz or it contributes to R_zr
Conn[2][1][4] = 4 * I * lambda / r^2 
Conn[2][4][1] = 4 * I * lambda / r^2 
--Conn[3][1][4] = -8 * I * lambda * phi / r^3
-- ...
-- R_pp = C^c_dc C^d_pp - C^c_dp C^d_pc
Conn[1][1][1] = 2 * I / r
--Conn[1][2][2] = -var'q'	-- this messes up the R_tr and R_rt variables
Conn[1][3][3] = -2 * I / r
Conn[1][4][4] = 2 * I / r
-- ...
-- I either need to make the R_pp and R_zz a complex difference-of-squares (which is tempting)
-- or I need to put the separate terms in separate traces of the Conn (which I'm doing here)
--- but when using the 'r' component, it incorporates influence from C^r_tt which is used for R_tt ...
Conn[2][1][2] = 2 / r
Conn[2][3][3] = -2 * lambda / r
Conn[2][4][4] = 2 * lambda / r
--]]

--[[ trying to produce R_tt by torsion: -C^c_td (C^d_tc - C^d_ct) ... but nowhere near finished
do
	local d = 2
	Conn[2][1][d] = 1
	Conn[d][1][2] = 2 * (I^2 / r^4)
	Conn[d][2][1] = -Conn[d][1][2]
end
--]]

--[[ producing R_tt by C^z_tt,z
Conn[4][1][1] = 4 * (I^2 / r^4 + lambda^2 / r^2) * z
Conn[2][1][4] = 4 * I * lambda / r^2 
Conn[2][4][1] = 4 * I * lambda / r^2 
--]]

--[[ producing R_tt by separating terms and producing them individually with C^r_tt,r (I^2) and C^p_tt,p (lambda^2)
-- C^r_tt = -4/3 I^2 / r^3, C^p_tt = 4 lambda^2 phi r^2, C^r_tz = C^r_zt = 4 I lambda / r^2
-- => R_tt = 4 (I^2 + lamda^2 r^2) / r^4, R_tz = R_zt = -8 I lambda / r^3
Conn[2][1][1] = -frac(4,3) * I^2 / r^3
Conn[3][1][1] = 4 * lambda^2 * phi / r^2
Conn[2][1][4] = 4 * I * lambda / r^2 
Conn[2][4][1] = 4 * I * lambda / r^2 
--]]

-- here I'm producing the R_tt, R_tz, R_zt terms, just by integrating the Conn^r_tt,r
--[[ C^r_tt = -4/3 I^2 / r^3 - 4 lambda^2 / r, C^r_tz = C^r_zt = 4 I lambda / r^2 
-- => R_tt = 4 (I^2 + lamda^2 r^2) / r^4, R_tz = R_zt = -8 I lambda / r^3
Conn[2][1][1] = (-frac(4,3) * I^2 / r^3 - 4 * lambda^2 / r)()
--Conn[1][1][4] = -8 * I * lambda * t / r^3
--Conn[1][4][1] = -8 * I * lambda * t / r^3		-- can't set C^t_zt = C^t_tz or it contributes to R_zr
Conn[2][1][4] = 4 * I * lambda / r^2 
Conn[2][4][1] = 4 * I * lambda / r^2 
--Conn[3][1][4] = -8 * I * lambda * phi / r^3
--]]

-- R_tz = Conn^u_tz,u - Conn^u_tu,z + Conn^c_dc Conn^d_ab
-- to make R_tz = f, set Conn^u_tz,u = f or Conn^u_tu,z = f
--[[ Conn^t_tz,t = f t or Conn^j_tz,j = f x_j => R_tz = f
Conn[1][1][4] = -8 * I * lambda * t / r^3
--Conn[2][1][4] = 4 * I * lambda / r^2 
--Conn[3][1][4] = -8 * I * lambda * phi / r^3
--Conn[4][1][4] = -2 * I * lambda / r^2		-- but antisym makes R_tz = 0.  This instead contributes to R_tt, R_tr
--]]

--[[ C^r_tt = -4/3 I^2 r^3 - 4 lambda / r => R_tt = C^r_tt,r = 4 (I^2 / r^4 + lambda^2 / r^2)
Conn[2][1][1] = -4/3 * I^2 / r^3 - 4 * lambda^2 / r
--]]

--[[  Conn^r_rr = a, Conn^r_tz = b => R_tz = a b (1 - 2 r)	<- hmm, where does the -2r come from 
Conn[2][2][2] = I / r^2
Conn[2][1][4] = lambda / r^2
--Conn[2][4][1] = lambda / r^2
--]]

-- the rest are from the cartesian constant-field-everywhere solution:

--[[ 
-- C^x_tt = I x
-- C^t_tt = C^t_yy = C^t_zz = sqrt(I) 
-- => R_tt = R_yy = R_zz = I
Conn[1][1][1] = sqrt(I)
Conn[2][1][1] = -sqrt(I)-- with C^t_xt = C^t_tx = sqrt(I) this leaves R_tt = I^(3/2)
Conn[1][2][1] = sqrt(I)	-- R_xx = -I, changes R_tx and R_tt
Conn[1][1][2] = sqrt(I)	-- with C^t_xt = sqrt(I) this eliminates R_tx and the only difference is R_tt = I - I^(3/2) x
Conn[1][3][3] = sqrt(I)
Conn[1][4][4] = sqrt(I)
--]]

--[[ 
-- C^x_tt = I x
-- C^t_tt = -C^t_xx = C^t_yy = C^t_zz = sqrt(I) 
-- => R_tt = -R_xx = R_yy = R_zz = I, R_tx = R_xt = I^(3/2) x
Conn[2][1][1] = I * x
Conn[1][1][1] = sqrt(I)
Conn[1][2][2] = -sqrt(I)
Conn[1][3][3] = sqrt(I)
Conn[1][4][4] = sqrt(I)
-- R_tx is influenced by R^t_ttx, R^y_tyx, R^z_tzx
-- R_xt is influenced by R^x_xxt, R^y_xyt, R^z_xzt
--Conn[2][2][2] = I	-- adds I to R_tt
--Conn[2][1][2] = I	-- scales R_jj by 1 + sqrt(I), adds something to R_tt
--Conn[2][2][1] = I	-- adds 2 I^(3/2) to R_xx
--Conn[2][3][1] = I	-- adds I^(3/2) to R_xy and R_yx
--Conn[2][1][3] = I	-- nothing
--Conn[3][1][2] = I	-- nothing
--Conn[1][1][2] = I	-- changes R_tt and R_tx 
--Conn[1][2][1] = I	-- changes R_tt and R_tx and R_xx
--Conn[1][3][2] = I	-- changes R_ty, R_xy, R_yt
--]]

--[[ 
-- C^y_tt = I y
-- C^t_tt = -C^t_xx = C^t_yy = C^t_zz = sqrt(I) 
-- => R_tt = -R_xx = R_yy = R_zz = I, R_ty = R_yt = I^(3/2) y
Conn[3][1][1] = I * y
Conn[1][1][1] = sqrt(I)
Conn[1][2][2] = -sqrt(I)
Conn[1][3][3] = sqrt(I)
Conn[1][4][4] = sqrt(I)
--]]

--[[ 
-- C^x_tt = I x
-- C^t_tt = -C^t_xx = C^t_yy = C^t_zz = sqrt(I) 
-- => R_tt = -R_xx = R_yy = R_zz = I, R_tx = R_xt = I^(3/2) x
Conn[2][1][1] = I * x
Conn[1][1][1] = sqrt(I)
Conn[1][2][2] = -sqrt(I)
Conn[1][3][3] = sqrt(I)
Conn[1][4][4] = sqrt(I)
--]]

--[[ C^t_tt = -C^t_xx = C^t_yy = C^t_zz = sqrt(I) => -R_xx = R_yy = R_zz = I
Conn[1][1][1] = sqrt(I)
Conn[1][2][2] = -sqrt(I)
Conn[1][3][3] = sqrt(I)
Conn[1][4][4] = sqrt(I)
--]]

--[[ C^j_tt = I x_j => R_tt = I 
Conn[2][1][1] = I * x
--Conn[3][1][1] = I * y
--Conn[4][1][1] = I * z
--]]

--[[ C^t_jt = +-sqrt(I) => R_jj = -I
Conn[1][2][1] = -sqrt(I)
--Conn[1][3][1] = -sqrt(I)
--Conn[1][4][1] = -sqrt(I)
--]]

--[[ C^t_tt = +-C^t_jj = sqrt(I) => R_jj = +-I
-- jj's linearly combine
Conn[1][1][1] = sqrt(I)
Conn[1][2][2] = -sqrt(I)
--Conn[1][3][3] = sqrt(I)
--Conn[1][4][4] = sqrt(I)
--]]

--[[ C^t_ty = -C^t_yt = sqrt(I) => R_yy = -I
Conn[1][1][3] = sqrt(I)
Conn[1][3][1] = -sqrt(I)
--]]


--[[ C^x_xy = -C^x_yx = sqrt(I) => R_yy = -I
Conn[2][2][3] = sqrt(I)
Conn[2][3][2] = -sqrt(I)
--]]

-- C^t_ty = -C^t_yt = sqrt(I) and C^x_xy = -C^x_yx = sqrt(I) linearly combine



local s = table()
for index,value in Conn:iter() do
	local a,b,c = table.unpack(index)
	if value ~= symmath.Constant(0) then
		s:insert(tostring(var('\\Gamma^{'..coords[a].name..'}'..'_{'..coords[b].name..' '..coords[c].name..'}'):eq(value))) 
	end
end
printbr(s:concat'; ')

-- R^a_bcd = Conn^a_bd,c - Conn^a_bc,d + Conn^a_ec Conn^e_bd - Conn^a_ed Conn^e_bc - Conn^a_be (Conn^e_dc - Conn^e_cd)
local RiemannExpr = Conn'^a_bd,c' - Conn'^a_bc,d' 
	+ Conn'^a_ec' * Conn'^e_bd' - Conn'^a_ed' * Conn'^e_bc'
	- Conn'^a_be' * (Conn'^e_dc' - Conn'^e_cd')
-- [[
printbr(var'R''^a_bcd':eq(RiemannExpr:replace(Conn, var'\\Gamma')))
printbr(var'R''_ab':eq(RiemannExpr:replace(Conn, var'\\Gamma'):reindex{cacbd='abcde'}))
--]]

local Riemann = Tensor'^a_bcd'
Riemann['^a_bcd'] = RiemannExpr()
--printbr(var'R''^a_bcd':eq(Riemann))

-- R_ab = R^c_acb = Conn^c_ab,c - Conn^c_ac,b + Conn^c_dc Conn^d_ab - Conn^c_db Conn^d_ac - Conn^c_ad (Conn^d_bc - Conn^d_cb)
local Ricci = Riemann'^c_acb'()
print(var'R''_ab':eq(Ricci))

print('vs desired')
printbr(var'R''_ab':eq(Ricci_EM))
