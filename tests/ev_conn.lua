#! /usr/bin/env luajit
require 'ext'
local symmath = require 'symmath'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
print(MathJax.header)
local printbr = MathJax.print
MathJax.usePartialLHSForDerivative = true

local Tensor = symmath.Tensor
local TensorIndex = require 'symmath.tensor.TensorIndex'
local var = symmath.var
local vars = symmath.vars
local sqrt = symmath.sqrt

local t,x,y,z = vars('t', 'x', 'y', 'z')
local r = var('r', {x,y,z})

local spatialCoords = {x,y,z}
local coords = table{t}:append(spatialCoords)

Tensor.coords{
	{variables=coords},
	{symbols='ijklmn', variables=spatialCoords},
	{symbols='t', variables={t}},
	{symbols='x', variables={x}},
	{symbols='y', variables={y}},
	{symbols='z', variables={z}},
}

local E = var'E'

local Conn = Tensor'^a_bc'

-- [[ 
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

--printbr(var'\\Gamma''^a_bc':eq(Conn))
--printbr(var'c''_cb^a':eq(var'\\Gamma''^a_bc' - var'\\Gamma''^a_cb'):eq((Conn'^a_bc' - Conn'^a_cb')()))

local RiemannExpr = Conn'^a_bd,c' - Conn'^a_bc,d' 
	+ Conn'^a_ec' * Conn'^e_bd' - Conn'^a_ed' * Conn'^e_bc'
	- Conn'^a_be' * (Conn'^e_dc' - Conn'^e_cd')
printbr(var'R''^a_bcd':eq(RiemannExpr:replace(Conn, var'\\Gamma')))
printbr(var'R''_ab':eq(RiemannExpr
	:replace(Conn, var'\\Gamma')
	:replace(TensorIndex{lower=false, symbol='a'}, TensorIndex{lower=false, symbol='c'})
	:replace(TensorIndex{lower=true, symbol='b'}, TensorIndex{lower=true, symbol='a'})
	:replace(TensorIndex{lower=true, symbol='d'}, TensorIndex{lower=true, symbol='b'})
	:replace(TensorIndex{lower=true, symbol='d', derivative='partial'}, TensorIndex{lower=true, symbol='b', derivative='partial'})
))

local Riemann = Tensor'^a_bcd'
Riemann['^a_bcd'] = RiemannExpr()
--printbr(var'R''^a_bcd':eq(Riemann))

local Ricci = Riemann'^c_acb'()
print(var'R''_ab':eq(Ricci))

-- 8 pi T_ab = G_ab = R_ab - 1/2 R g_ab
-- and R = 0 for electrovac T_ab
-- so 8 pi T_ab = R_ab
print('vs desired')
local R = Tensor('_ab',
	{E, 0, 0, 0},
	{0, -E, 0, 0},
	{0, 0, E, 0},
	{0, 0, 0, E})
printbr(var'R''_ab':eq(R))
