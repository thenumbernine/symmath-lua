#! /usr/bin/env luajit
require 'ext'
local _ENV = _ENV or getfenv()
require 'symmath'.setup{env=_ENV, implicitVars=true, MathJax={title='infinite wire no charge', usePartialLHSForDerivative=true, pathToTryToFindMathJax='..'}}

local RiemannExpr = Gamma'^a_bd,c' - Gamma'^a_bc,d' 
	+ Gamma'^a_ec' * Gamma'^e_bd' - Gamma'^a_ed' * Gamma'^e_bc'
	- Gamma'^a_be' * (Gamma'^e_dc' - Gamma'^e_cd')
printbr(R'^a_bcd':eq(RiemannExpr))

--[[ how to get g_ab,c from Gamma_abc?
do
	local ConnDef = var'\\Gamma''_abc':eq(frac(1,2) * (var'g''_ab,c' + var'g''_ac,b' - var'g''_bc,a'))
	local eqns = table{
		ConnDef,
		ConnDef:reindex{abc='bca'}:replace(g'_ba,c', g'_ab,c'):replace(g'_ca,b', g'_ac,b'),	-- TODO define symmetric g_ab = g_ba
		ConnDef:reindex{abc='cab'}:replace(g'_ca,b', g'_ac,b'):replace(g'_cb,a', g'_bc,a'),
	}
	-- y = A x + b
	local ylhs = eqns:map(function(eqn) return eqn:lhs() end)
	local yrhs = eqns:map(function(eqn) return eqn:rhs() end)
	local ylhsm = Matrix(ylhs):T()
	local yrhsm = Matrix(yrhs):T()
	printbr(ylhsm:eq(yrhsm))

	local dgs = table{g'_ab,c', g'_ac,b', g'_bc,a'}
	local A, b = factorLinearSystem(yrhs, dgs)
	assert(b == Matrix{0,0,0}:T())
	dgm = Matrix(dgs):T()
	printbr(ylhsm:eq(A * dgm))
	local AInv = A:inv()
	printbr(dgm:eq(AInv * ylhsm))
end
-- ... tells us g_ab,c = 2 Gamma_(ab)c
os.exit()
--]]

local chart_t_r_phi_z = Tensor.Chart{coords={t,r,phi,z}}
local chart_r_phi_z = Tensor.Chart{symbols='ijklmn', coords={r,phi,z}}
local chart_t = Tensor.Chart{symbols='t', coords={t}}
local chart_r = Tensor.Chart{symbols='r', coords={r}}
local chart_phi = Tensor.Chart{symbols='phi', coords={phi}}
local chart_z = Tensor.Chart{symbols='z', coords={z}}

printbr'manual metric:'
local g = Tensor('_ab', table.unpack((Matrix.diagonal(-1, 1, 1, 1))))

-- [[ meh close
g[1][1] = -I / r
g[2][2] = 1 / (I * r)
g[3][3] = r^2
g[4][4] = 1 / r
--]]

--[[ this... 
local a = var('a', {r})
g = Tensor('_ab', table.unpack((Matrix.diagonal(a,-a,r^2,-a))))
--]] 
--[[ ... produces ...
-- for g = diag(a, -a, r^2, -a) we find from R_phi_phi = a,r r / (2 a^2) = -4 I^2
-- da/dr = -8 I^2 a^2 / r
-- da / a^2 = -8 I^2 dr / r
-- -1/a = -8 I^2 ln r - C
-- a = 1 / (8 I^2 ln r + C)
local a = 1 / (8 * I^2 * log(r) + C)
printbr(var'a':eq(a))
printbr(var'a':diff(r):eq(a:diff(r)()))
printbr((var'a':diff(r) * r / (2 * var'a'^2)):eq(-4 * I^2))
printbr((a:diff(r) * r / (2 * a^2)):eq(-4 * I^2)())
g = Tensor('_ab', table.unpack((Matrix.diagonal(a,-a,r^2,-a))))
--]]

--[[
--g[1][1] = var'g_{tt}'
--g[2][2] = var'g_{rr}'
g[3][3] = r^2	-- var'g_{\\phi\\phi}'
--g[4][4] = var'g_{zz}'
g[1][3] = var'g_{t\\phi}'
g[1][4] = var'g_{tz}'
g[3][1] = g[1][3]
g[4][1] = g[1][4]
--]]

--[[
g = Tensor'_ab'
g[1][1] = -(a + b / r)
g[2][2] = 1 / (a + b / r)
g[3][3] = r^2
g[4][4] = 1 / (a + b / r)
--]]

local gU = Tensor('^ab', table.unpack(
	(Matrix(table.unpack(g)):T():inv())
))

printbr(g:print'g')
printbr(gU:print'g')

local ConnFromManualMetric = Tensor'_abc'
ConnFromManualMetric['_abc'] = ((g'_ab,c' + g'_ac,b' - g'_bc,a') / 2)() 
printbr(ConnFromManualMetric:printElem'\\Gamma')
ConnFromManualMetric = (gU'^ad' * ConnFromManualMetric'_dbc')()
printbr(ConnFromManualMetric:printElem'\\Gamma')

local ConnManual = Tensor'^a_bc'

-- [[ WORKS
ConnManual[3][1][1] = -2 * I / r^2
ConnManual[1][3][1] = 2 * I
ConnManual[1][1][3] = 2 * I
ConnManual[3][2][2] = 2 * I / r^2
ConnManual[3][4][4] = 2 * I / r^2
--]]

printbr'connection from manual metric:'
printbr(ConnFromManualMetric:printElem'\\Gamma')

printbr'manual connection:'
printbr(ConnManual:printElem'\\Gamma')

local RiemannFromManualMetric = Tensor'^a_bcd'
RiemannFromManualMetric['^a_bcd'] = RiemannExpr:replace(Gamma, ConnFromManualMetric)()
local RicciFromManualMetric = RiemannFromManualMetric'^c_acb'()
printbr'Ricci from manual metric:'
printbr(RicciFromManualMetric:print'R')

printbr'Gaussian from manual metric:'
local GaussianFromManualMetric = (gU'^ab' * RicciFromManualMetric'_ab')()
printbr(R:eq(GaussianFromManualMetric):eq(0))
do
	local expr = GaussianFromManualMetric
	if symmath.op.div:isa(expr) then expr = expr[1] end
	if symmath.op.unm:isa(expr) then expr = expr[1] end
	printbr(expr:eq(0))

	printbr'$R_{tt} - R_{rr}$:'
	printbr((RicciFromManualMetric[1][1] - RicciFromManualMetric[2][2])():eq(0))
	printbr'$R_{rr} - R_{zz}$:'
	printbr((RicciFromManualMetric[2][2] - RicciFromManualMetric[4][4])():eq(0))
	printbr'$r^{-2} R_{\\phi\\phi} + R_{tt}$:'
	printbr((RicciFromManualMetric[1][1] + RicciFromManualMetric[3][3] / r^2)():eq(0))
end

local RiemannFromManualConn = Tensor'^a_bcd'
RiemannFromManualConn['^a_bcd'] = RiemannExpr:replace(Gamma, ConnManual)()
local RicciFromManualConn = RiemannFromManualConn'^c_acb'()
printbr'Ricci from manual connection:'
printbr(RicciFromManualConn:print'R')

-- stress energy of EM field around an infinite wire
-- looking at the case where there is no charge in the wire (lambda = 0), but there is a current (I != 0)
-- taken from em_conn_infwire.lua
local RicciDesired = (Tensor('_ab', table.unpack(Matrix.diagonal(1, 1, -r^2, 1))) * 4 * I^2 / r^2)()
print'vs $8 \\pi \\times$ EM stress-energy tensor = Ricci tensor'
RicciDesired:print'R' 
printbr()




printbr'now the same thing for no-current only-charge'




local Conn = Tensor'^a_bc'

-- [[ works, but looks ugly, but works
--Conn[2][1][1] = -a / r
--Conn[1][2][1] = b / r
--Conn[1][1][2] = b / r
--Conn[2][3][3] = c * r
--Conn[2][4][4] = d / r
-- b (1 - b) = -4 lambda^2
-- b - b^2 = -4 lambda^2
-- b^2 - b - 4 lambda^2 = 0
-- b = (1 +- sqrt(1 + 16 lambda^2)) / 2
local b = ((1 + sqrt(1 + 16 * lambda^2)) / 2)()
-- a (1 + b) = 4 lambda^2
local a = (4 * lambda^2 / (1 + b))()
-- c (1 + b) = 4 * lambda^2
local c = a
-- d (b - 1) = 4 * lambda^2
local d = (4 * lambda^2 / (b - 1))()
Conn[2][1][1] = -a / r
Conn[1][2][1] = b / r
Conn[1][1][2] = b / r
Conn[2][3][3] = c * r
Conn[2][4][4] = d / r
Conn = Conn()
--]]

--[[ works but I don't like the C^t_tt term
Conn[2][1][1] = - 4 * lambda^2 / r		-- R_tt
Conn[1][1][1] = Constant(1)										-- R_pp, R_zz
Conn[1][3][3] = 4 * lambda^2					-- R_pp
Conn[1][4][4] = 4 * lambda^2 / r^2				-- R_zz
Conn[3][2][2] = -4 * phi * lambda^2 / r^2			-- R_rr
--]]

printbr'manual connection:'
printbr(Conn:printElem'\\Gamma')

local RiemannForConn = Tensor'^a_bcd'
RiemannForConn['^a_bcd'] = RiemannExpr:replace(Gamma, Conn)()
local RicciForConn = RiemannForConn'^c_acb'()
printbr'Ricci from connection:'
RicciForConn:print'R'
printbr()

-- stress energy of EM field around an infinite wire
-- looking at the case where there is no current in the wire (I = 0), but there is a chage (lambda != 0)
-- taken from em_conn_infwire.lua
local RicciEM = (Tensor('_ab', table.unpack(Matrix.diagonal(1, -1, r^2, 1))) * 4 * lambda^2 / r^2)()
print'vs $8 \\pi \\times$ EM stress-energy tensor = Ricci tensor'
RicciEM:print'R' 
printbr()
