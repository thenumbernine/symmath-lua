#! /usr/bin/env luajit
--[[
this is the same as em_conn_uniform_field.lua, 
except in cylindrical coordinates, 
which I've verified tensor transformations of via em_verify_cyl_xform.lua 
I did this out of suspicion spacetime would twist around the uniform field
(when specifying the manual metric)
but if it is uniform then of course it's not going to...
--]]
require 'ext'
require 'symmath'.setup{implicitVars=true, MathJax={title='uniform field - cylindrical', usePartialLHSForDerivative=true, pathToTryToFindMathJax='..'}}

local t, r, phi, z = vars('t', 'r', '\\phi', 'z')
local E = var'E'
local coords = {t,r,phi,z}

Tensor.coords{
	{variables=coords},
	{symbols='t', variables={t}},
	{symbols='r', variables={r}},
	{symbols='phi', variables={phi}},
	{symbols='z', variables={z}},
}

--[==[
local CylEmbedding = Tensor('^I', t, r * cos(phi), r * sin(phi), z)
CylEmbedding:print'u_{cyl}'
printbr()

local CylJacobian = Tensor'^I_a'
CylJacobian['^I_a'] = CylEmbedding'^I_,a'()
printbr(var'e_{cyl}''_a^I':eq(var'u_{cyl}''^I_,a'):eq(CylJacobian))

local CylJacobianInv = Tensor('_I^a', table.unpack((Matrix.inverse(CylJacobian))))
printbr(var'e_{cyl}''^a_I':eq(CylJacobianInv))

local MinkowskiMetric = Tensor('_IJ', function(I,J) return I ~= J and 0 or I == 1 and -1 or 1 end)
local CylMetric = (CylJacobian'^I_a' * CylJacobian'^J_b' * MinkowskiMetric'_IJ')()
CylMetric:print'g_{cyl}' 
printbr()

local CylMetricInv = Tensor('^ab', table.unpack((Matrix.inverse(CylMetric))))

local FaradayCyl = require 'symmath.physics.Faraday'{
	g = CylMetric, 
	gU = CylMetricInv, 
	E = Tensor('_a', 0, 0, 0, E),
	B = Tensor'_a',
}
printbr'Faraday:'
FaradayCyl:print'F'
printbr()

local StressEnergyCyl = Tensor'_ab'
StressEnergyCyl['_ab'] = (frac(1, 4 * pi) * (
	FaradayCyl'_ac' * FaradayCyl'_bd' * CylMetricInv'^cd'
	- frac(1, 4) * CylMetric'_ab' * FaradayCyl'_ce' * FaradayCyl'_df' * CylMetricInv'^cd' * CylMetricInv'^ef'
))()
local RicciDesired = (8 * pi * StressEnergyCyl'_ab')()
printbr(R'_ab':eq(8 * pi * var'T''_ab'):eq(RicciDesired))
printbr()
--]==]
-- [==[
local RicciDesired = Tensor('_ab', table.unpack(Matrix.diagonal(E^2, E^2, r^2 * E^2, -E^2)))
--]==]

--[[
here's a thought on this:
finding g->C and C->R means finding the space by which E changes when transformed, and therefore R changes
so the problem is circular.
we want to measure the one thing that is independent of the problem.
wouldn't that be E^i rather than E_i ?
if so, don't I need to factor g's into my calculations of R?
--]]
local g = Tensor'_ab'

-- [[ reproduces R_tt, R_rr, R_pp, but sets R_zz = 0
g[1][1] = -exp(E * z)
g[2][2] = -exp(E * z)
g[3][3] = -r^2 * exp(E * z)
g[4][4] = exp(E * z) / 2
--]]

--[[
g[1][1] = Constant(-1)
g[2][2] = Constant(1)
g[3][3] = r^2
g[4][4] = Constant(1)
g[1][3] = B * (cos(phi) - sin(phi))
g[3][1] = g[1][3]
--]]

--[[ cylindrical, with time scaled and r and z squashed similar to Schwarzschild
g[1][1] = var('a',{r})
g[2][2] = var('b',{r})
g[3][3] = r^2
g[4][4] = var('c',{r})
--]]

--[[ reproduces R_zz, but the others are scaled wrong
g[1][1] = -e^(sqrt(2) * E * z)
g[2][2] = -e^(sqrt(2) * E * z)
g[3][3] = -r^2 * e^(sqrt(2) * E * z)
g[4][4] = e^(sqrt(2) * E * z / 3)
--]]

--[[ reproduces R_tt, R_rr, R_pp, but sets R_zz = 0
g[1][1] = -exp(E * z)
g[2][2] = -exp(E * z)
g[3][3] = -r^2 * exp(E * z)
g[4][4] = exp(E * z) / 2
--]]

--[[
-- same as below, but messing with signs, 
-- got it to reproduce R_tt, R_rr, R_pp, but sets R_zz = 0
g[1][1] = -exp(sqrt(2) * E * z)
g[2][2] = -exp(sqrt(2) * E * z)
g[3][3] = -r^2 * exp(sqrt(2) * E * z)
g[4][4] = exp(sqrt(2) * E * z)
--]]

--[[ 
-- reproduces all of C^a_bc, with additional C^r_zr = C^r_rz = C^p_pz = C^p_zp = C^z_zz = E
-- produces R_tt = -2 E^2, R_xx = 2 E^2, R_pp = 2 E^2 r^2, R_zz = 0
-- note: replace exp(2 E z) with exp(sqrt(2) E z) to rescale the R_ab
-- start with this
--g[1][1] = var('a',{r,phi,z})
--g[2][2] = var('b',{r,phi,z})
--g[3][3] = var('c',{r,phi,z})
--g[4][4] = var('d',{r,phi,z})
-- and solve:
-- C^t_zt: a,z / 2a = E =>  da/a = 2 E z dz =>a = exp(2 E z)
g[1][1] = exp(2 * E * z)
-- C^z_tt: -E exp(2 E z) / d = -E => d = exp(-2 E z)
g[4][4] = exp(2 * E * z)
-- C^z_rr: -b,z / (2 exp(2 E z)) = E => b,z = -2 E exp(2 E z) => b = -exp(2 E z)
g[2][2] = -exp(2 * E * z)
-- C^r_pp: c,r / (2 exp(2 E z)) = -r => c,r = -2 r exp(2 E z) => c = -r^2 exp(2 E z)
g[3][3] = -r^2 * exp(2 * E * z)
--]]

--[[
g[1][1] = exp(2 * E * z)
g[2][2] = Constant(1)
g[3][3] = Constant(1)
g[1][3] = exp(2 * E * z)
g[3][1] = exp(2 * E * z)
g[4][4] = Constant(1)
-- E_r = A_t,r - A_r,t
--]]

--[[ 
-- this produces almost all nonzero conns, except C^t_tz = C^t_zt = 1/(2*z) instead of e
-- it produces some extra nonzero conns as well
-- it also produces a ricci that is scaled by 1/(2z), except for r_zz = 3 / (4 * z^2) but should be -e^2 
g[1][1] = -1 + 2 * E * z
g[2][2] = 1 - 2 * E * z
g[3][3] = 1 - 2 * E * z * r^2	-- influences C^p_pr = C^p_rp = 1/r
g[4][4] = Constant(1)
--]]

--[[ 
-- this produces almost all nonzero conns, except C^t_tz = C^t_zt = 1/(2*z) instead of e
-- it produces some extra nonzero conns as well
-- it also produces a ricci that is scaled by 1/(2z), except for r_zz = 3 / (4 * z^2) but should be -e^2 
g[1][1] = 2 * E * z
g[2][2] = -2 * E * z
g[3][3] = -2 * E * z * r^2	-- influences C^p_pr = C^p_rp = 1/r
g[4][4] = Constant(1)
--]]

local gU = Tensor('^ab', table.unpack(( Matrix.inverse(g) )))

--g:printElem'g' printbr() 
g:print'g'
--gU:printElem'g' printbr() 
gU:print'g'

local ConnFromMetric = Tensor'_abc'
ConnFromMetric['_abc'] = (frac(1,2) * (g'_ab,c' + g'_ac,b' - g'_bc,a'))()	-- ... plus commutation? in this case I have a symmetric Conn so I don't need comm

printbr'...produces...'
--ConnFromMetric:printElem'\\Gamma' printbr()
ConnFromMetric = (gU'^ad' * ConnFromMetric'_dbc')()

local ConnManual = Tensor'^a_bc'

--[[ transform the connection for x-direction field from cartesian to cylindrical
-- I think my cylindrical jacobian and inv are mixed up 
local ConnManualCartesian = Tensor'^a_bc'
ConnManualCartesian[2][1][1] = -E	-- only scales R_tt
ConnManualCartesian[1][2][1] = E	-- scales R_xx and affects terms of R_tt
ConnManualCartesian[1][1][2] = E	-- affects terms of R_tt
ConnManualCartesian[2][3][3] = E	-- scales R_yy
ConnManualCartesian[2][4][4] = E	-- scales R_zz

ConnManual['^a_bc'] = 
	(CylJacobianInv'_I^a' * (
		CylJacobian'^J_b'
		* CylJacobian'^K_c'
		* ConnManualCartesian'^I_JK'
		+ CylJacobian'^I_b,c')())()
printbr'cartesian conn'
ConnManualCartesian:print'\\Gamma'

printbr'cylindrical conn'
ConnManual:print'\\Gamma'
--]]

-- [[ THIS WORKS
-- ConnManual[1][1][1] = E	-- is optional, and I don't like it (it implies perpetual acceleration through time
-- I don't like the z in there, I would rather it be r ...
ConnManual[4][1][1] = -E
ConnManual[1][4][1] = E
ConnManual[1][1][4] = E

ConnManual[4][2][2] = E
ConnManual[4][3][3] = E * r^2

ConnManual[2][3][3] = -r
ConnManual[3][2][3] = 1/r
ConnManual[3][3][2] = 1/r
--]]

printbr'conn from manual metric'
ConnFromMetric:print'\\Gamma'

print'vs manual conn'
ConnManual:print'\\Gamma'
--printbr(var'c''_cb^a':eq(var'\\Gamma''^a_bc' - var'\\Gamma''^a_cb'):eq((ConnManual'^a_bc' - ConnManual'^a_cb')()))
printbr()

local RiemannExpr = var'\\Gamma''^a_bd,c' - var'\\Gamma''^a_bc,d' 
	+ var'\\Gamma''^a_ec' * var'\\Gamma''^e_bd' - var'\\Gamma''^a_ed' * var'\\Gamma''^e_bc'
	- var'\\Gamma''^a_be' * (var'\\Gamma''^e_dc' - var'\\Gamma''^e_cd')

local RiemannFromManualMetric = Tensor'^a_bcd'
RiemannFromManualMetric['^a_bcd'] = RiemannExpr:replace(var'\\Gamma', ConnFromMetric)()
--printbr'Riemann from manual metric'
--RiemannFromManualConn:print'R'

local RicciFromManualMetric = Tensor'_ab'
RicciFromManualMetric['_ab'] = RiemannFromManualMetric'^c_acb'()
printbr'Ricci from manual metric'
RicciFromManualMetric:print'R'
printbr()

local RiemannFromManualConn = Tensor'^a_bcd'
RiemannFromManualConn['^a_bcd'] = RiemannExpr:replace(var'\\Gamma', ConnManual)()
--printbr'Riemann from manual connection'
--RiemannFromManualConn:print'R'

local RicciFromManualConn = RiemannFromManualConn'^c_acb'()
printbr'Ricci from manual conn'
RicciFromManualConn:print'R'
printbr()

-- 8 pi T_ab = G_ab = R_ab - 1/2 R g_ab
-- and R = 0 for electrovac T_ab
-- so 8 pi T_ab = R_ab
printbr'desired Ricci'
RicciDesired:print'R'
printbr()
printbr()

-- manual Gaussian curvature.  verify this is zero.

if RicciFromManualMetric then
	local GaussianFromMetric = (gU'^ab' * RicciFromManualMetric'_ab')()
	printbr'manual metric Gaussian -- equal to zero according to EM stress-energy trace:'
	printbr(Constant(0):eq(GaussianFromMetric))
	local iszero = GaussianFromMetric
	if symmath.op.div.is(iszero) then iszero = iszero[1] end
	if symmath.op.unm.is(iszero) then iszero = iszero[1] end
	printbr(iszero:eq(0))
	printbr()
end

-- reminders:
printbr(var'R''^a_bcd':eq(RiemannExpr))
printbr(var'R''_ab':eq(RiemannExpr:reindex{abcde='cacbd'}))
