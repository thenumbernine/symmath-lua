#! /usr/bin/env luajit
--[[
this is the same as em_conn_uniform_field.lua, except in cylindrical coordinates, which I've verified tensor transformations of via em_verify_cyl_xform.lua 
--]]
require 'ext'
local symmath = require 'symmath'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
print(MathJax.header)
local printbr = MathJax.print
MathJax.usePartialLHSForDerivative = true

for k,v in pairs(symmath) do
	if k ~= 'tostring' then _G[k] = v end
end
local frac = symmath.op.div

local t, r, phi, z = vars('t', 'r', '\\phi', 'z')
local E = var'E'

local coords = table{t, r, phi, z}

Tensor.coords{
	{variables=coords},
	{symbols='t', variables={t}},
	{symbols='x', variables={x}},
	{symbols='y', variables={y}},
	{symbols='z', variables={z}},
}


--[[
here's a thought on this:
finding g->C and C->R means finding the space by which E changes when transformed, and therefore R changes
so the problem is circular.
we want to measure the one thing that is independent of the problem.
wouldn't that be E^i rather than E_i ?
if so, don't I need to factor g's into my calculations of R?
--]]
local g = Tensor'_ab'

-- [[ 
-- this produces almost all nonzero conns, except c^t_tz = c^t_zt = 1/(2*z) instead of e
-- it produces some extra nonzero conns as well
-- it also produces a ricci that is scaled by 1/(2z), except for r_zz = 3 / (4 * z^2) but should be -e^2 
g[1][1] = 2 * E * z / r
g[2][2] = -2 * E * z / r
g[3][3] = -2 * E * z * r	-- influences c^p_pr = c^p_rp = 1/r
g[4][4] = constant(1)
--]]

--[[ 
-- this produces almost all nonzero conns, except c^t_tz = c^t_zt = 1/(2*z) instead of e
-- it produces some extra nonzero conns as well
-- it also produces a ricci that is scaled by 1/(2z), except for r_zz = 3 / (4 * z^2) but should be -e^2 
g[1][1] = 2 * E * z
g[2][2] = -2 * E * z
g[3][3] = -2 * E * z * r^2	-- influences c^p_pr = c^p_rp = 1/r
g[4][4] = constant(1)
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

-- THIS WORKS
-- [[ same as below, but I want to avoid C^t_tt ...
ConnManual[4][1][1] = -E
ConnManual[1][4][1] = E
ConnManual[1][1][4] = E

ConnManual[4][2][2] = E
ConnManual[4][3][3] = E * r^2

ConnManual[2][3][3] = -r
ConnManual[3][3][2] = 1/r
ConnManual[3][2][3] = 1/r
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
local RicciDesired = Tensor('_ab', table.unpack(Matrix.diagonal(E^2, E^2, E^2 * r^2, -E^2))) 
printbr'desired Ricci'
RicciDesired:print'R'
printbr()

-- reminders:
printbr()
printbr(var'R''^a_bcd':eq(RiemannExpr))
printbr(var'R''_ab':eq(RiemannExpr:reindex{cacbd='abcde'}))
