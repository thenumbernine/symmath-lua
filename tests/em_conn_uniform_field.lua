#! /usr/bin/env luajit
require 'ext'
require 'symmath'.setup{implicitVars=true, env=_ENV or getfenv()}
require 'symmath.tostring.MathJax'.setup{usePartialLHSForDerivative=true}

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
local Gamma = var'\\Gamma'

local ConnFromMetric 
-- finding the metric
--[==[

-- ONCE YOU FIND THE METRIC, FIND THE FARADAY TRANFORMED UNDER THE METRIC, THEN FIND THE STRESS-ENERGY FROM THE FARADAY, and see if it is the same or not ...

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
g[1][1] = -exp(E * x)
g[2][2] = exp(E * x) / 2
g[3][3] = -exp(E * x)
g[4][4] = -exp(E * x)
--]]

--[[ if you don't mind /x^2 terms ... and E is still missing from R_xx 
local e = var'e'
g[1][1] = -E/x
g[2][2] = 1/(E*x)
g[3][3] = -E/x
g[4][4] = -E/x
--]]

--[[ well, I got that R_xx = -E^2, but the others are now wrong
g[1][1] = -exp(sqrt(2) * E * x)
g[2][2] = exp(sqrt(2) * E * x / 3)
g[3][3] = -exp(sqrt(2) * E * x)
g[4][4] = -exp(sqrt(2) * E * x)
--]]

--[[
g[1][1] = var('a', {x})
g[2][2] = var('b', {x})
g[3][3] = var('a', {x})
g[4][4] = var('a', {x})
-- this gives:
-- 2 a'' a b -   a' b' a +   a'^2 b + 4 a b^2 E^2 = 0
-- 6 a'' a b - 3 a' b' a - 3 a'^2 b - 4 a^2 b E^2 = 0
-- good luck
--]]

--[[
g[1][1] = var('a', {x})
g[2][2] = var('a', {x})
g[3][3] = var('a', {x})
g[4][4] = var('a', {x})
-- this gives:
-- a,xx + 2 E^2 a = 0
-- 3 a,xx a - 3 a,x^2 - 2 a^2 E^2 = 0
-- two equations means we need two variables
--]]

--[[ this gives R_tt = R_yy = R_zz = E^2, but has R_xx = 0 instead of -E^2
g[1][1] = -exp(E * x)
g[2][2] = exp(E * x) / 2
g[3][3] = -exp(E * x)
g[4][4] = -exp(E * x)
--]]

--[[ 
-- this forgets C^t_tt, C^t_yy, C^t_zz, and misrepresents C^x_tt
-- but leaves one nonzero values that should be zeros, 

-- solving for g_tt = -1 + a(x), g_xx = 1 + b (is const), g_yy = g_zz = 1
-- I get everything except the C^t_tt constraint (which I'm now thinking maybe I should avoid, since Schwarzschild avoids it)
--	...and the C^t_yy and C^t_zz constraints ...
-- C^t_tx = C^t_xt = -a,x / (2(1-a)) = E
-- C^x_tt = -a,x / (2(1+b)) = -E
-- 
-- solving for a(x):
-- da/dx = 2 E a
-- da/a = 2 E dx
-- ln a = 2 E x
-- a = exp(2 E x) + C
-- a = exp(2 E x) + 1
-- da/dx = 2 E exp(2 E x)
-- -da/dx + 2 E a = -2 E exp(2 E x) + 2 E (exp(2 E x) + 1) = 2 E, viola
-- 
-- -2 E exp(2 E x) / (2 (1 + b)) = -E
-- b = -exp(2 E x) - 1
-- ...and now I'm in trouble, because 'b' was supposed to be constant (otherwise more C^a_bc terms would show up)
-- maybe I should let b depend on x, and solve this as a linear dynamic system?
-- 
-- here's another swing:
-- a = E exp(E x)
-- da/dx = E^2 exp(E x)
-- da/dx / a = ...
g[1][1] = var('a', {x})
g[2][2] = 1 + var'b'
g[3][3] = Constant(1)
g[4][4] = Constant(1)

g[1][1] = exp(2 * E * x)
g[2][2] = -1 - exp(2 * E * x)
--]]

--[[ 
-- This solves the C^t_ab constraints, but leaves a lot of values where there should be zeroes
-- da/dt / 2a = E => da/a = 2 E dt => a = exp(2 E t)
-- da/dx / 2a = E => a = exp(2 E x)
-- da/dx / 2 = E => a = 2 E x	<- I don't expect this one to fit with da/dx / 2a = E
-- -dc/dt / 2a = E => dc/dt = -2 a E => dc/dt = -2 E exp(2 E (x + t)) => c = -exp(2 E (x + t)) ... but c wasn't supposed to depend on x ...
-- -dd/dt / 2a = E =>
g[1][1] = exp(2 * E * (x + t))
g[3][3] = -exp(2 * E * (x + t))
g[4][4] = -exp(2 * E * (x + t))
--]]

--[[
-- g_tx = e(t), g_xy = h(y), g_xz = j(z)
-- gives C^t_tt, C^t_yy, C^t_zz, and zeros everywhere else
-- it misses C^t_xt = C^t_tx = -C^x_tt = E
-- de/dt / e = E => de/e = E dt => e = exp(E t)
-- dh/dy / e = E
-- dj/dz / e = E
g[1][2] = exp(E * t) g[2][1] = g[1][2]
g[2][3] = E * y * exp(E * t) g[3][2] = g[2][3]	-- this requires h to be a function of t as well, and therefore creates extra terms
g[2][4] = E * z * exp(E * t) g[4][2] = g[2][4]
--]]

--[[ ok now to find the metric that gives rise to the conn ...
-- C^t_tt = E = g^tt C_ttt + g^tk C_ktt = 1/2 g^tt g_tt,t + g^tk g_tk,t - 1/2 g^tk g_tt,k
-- C^t_yy = E = g^tt C_tyy + g^tk C_kyy = g^tt g_ty,y - 1/2 g^tt g_yy,t + g^tk g_ky,y - 1/2 g^tk g_yy,k
-- C^x_tt = -E = g^xt C_ttt + g^xk C_ktt = 1/2 g^xt g_tt,t + g^xk g_kt,t - 1/2 g^xk g_tt,k
-- C^t_tx = E = g^tt C_ttx + g^tk C_ktx = 1/2 (g^tt g_tt,x + g^tx g_xx,t + g^ty (g_xy,t + g_ty,x - g_tx,y) + 1/2 g^tz (g_xz,t + g_tz,x - g_tx,z))
-- and all those terms are constant.
g[1][1] = var('a', {t,x,y,z})
g[2][2] = var('b', {t,x,y,z})
g[3][3] = var('c', {t,x,y,z})
g[4][4] = var('d', {t,x,y,z})

g[1][2] = var('e', {t,x,y,z}) g[2][1] = g[1][2]
--g[1][3] = var('f', {}) g[3][1] = g[1][3]
--g[1][4] = var('g', {}) g[4][1] = g[1][4]

--g[2][3] = var('h', {}) g[3][2] = g[2][3]
--g[2][4] = var('j', {}) g[4][2] = g[2][4]
--g[3][4] = var('k', {}) g[4][3] = g[3][4]
--]]

local gU = Tensor('^ab', table.unpack(( Matrix.inverse(g) )))

--g:printElem'g' printbr() 
g:print'g'
--gU:printElem'g' printbr() 
gU:print'g'
printbr()

ConnFromMetric = Tensor'_abc'
ConnFromMetric['_abc'] = (frac(1,2) * (g'_ab,c' + g'_ac,b' - g'_bc,a'))()	-- ... plus commutation? in this case I have a symmetric Conn so I don't need comm
print'conn from manual metric:'
--ConnFromMetric:printElem'\\Gamma' printbr()
ConnFromMetric = (gU'^ad' * ConnFromMetric'_dbc')()

--ConnFromMetric:printElem'\\Gamma' printbr()
ConnFromMetric:print'\\Gamma'

print'vs'
--]==]

local Conn = Tensor'^a_bc'

-- THIS WORKS
-- [[ same as below, but I want to avoid C^t_tt ...
Conn[2][1][1] = -E	-- only scales R_tt
Conn[1][2][1] = E	-- scales R_xx and affects terms of R_tt
Conn[1][1][2] = E	-- affects terms of R_tt
Conn[2][3][3] = E	-- scales R_yy
Conn[2][4][4] = E	-- scales R_zz
--]]

-- THIS WORKS:
--[[ this gives rise to the stress-energy tensor for EM with E in the x dir and B = 0
-- to account for other E's and B's, just boost and rotate your coordinate system
-- don't forget, when transforming Conn, to use its magic transformation eqn, since it's not a real tensor
Conn[1][1][1] = E
Conn[2][1][1] = -E
Conn[1][2][1] = E
Conn[1][1][2] = E
Conn[1][3][3] = E
Conn[1][4][4] = E
--]]

print'manual conn:'
Conn:print'\\Gamma'
printbr()
--printbr(var'c''_cb^a':eq(Gamma'^a_bc' - Gamma'^a_cb'):eq((Conn'^a_bc' - Conn'^a_cb')()))

local RiemannExpr = Gamma'^a_bd,c' - Gamma'^a_bc,d' 
	+ Gamma'^a_ec' * Gamma'^e_bd' - Gamma'^a_ed' * Gamma'^e_bc'
	- Gamma'^a_be' * (Gamma'^e_dc' - Gamma'^e_cd')

if ConnFromMetric then
	local RiemannFromManualMetric = Tensor'^a_bcd'
	RiemannFromManualMetric['^a_bcd'] = RiemannExpr:replace(Gamma, ConnFromMetric)()
	--printbr'Riemann from manual metric'
	--RiemannFromManualConn:print'R'

	local RicciFromManualMetric = Tensor'_ab'
	RicciFromManualMetric['_ab'] = RiemannFromManualMetric'^c_acb'()
	printbr'Ricci from manual metric'
	RicciFromManualMetric:print'R'
	printbr()
	print'vs'
end

local RiemannFromManualConn = Tensor'^a_bcd'
RiemannFromManualConn['^a_bcd'] = RiemannExpr:replace(Gamma, Conn)()
--printbr'riemann from manual conn'
--RiemannFromManualConn:print'R'

local RicciFromManualConn = RiemannFromManualConn'^c_acb'()
printbr'Ricci from manual conn'
RicciFromManualConn:print'R'
printbr()

-- 8 pi T_ab = G_ab = R_ab - 1/2 R g_ab
-- and R = 0 for electrovac T_ab
-- so 8 pi T_ab = R_ab
printbr'vs desired Ricci'
local RicciDesired = Tensor('_ab', table.unpack(Matrix.diagonal(E^2, -E^2, E^2, E^2))) 
RicciDesired:print'R'
printbr()

--[[
let's create a magnetic field in the Y direction (to compliment our electric field in the X direction)

Lorentz boost of EM fields:

E||' = E||
B||' = B||
E_P' = gamma (E_P + v x B)
B_P' = gamma (B_P - v x E / c^2)

so if our B = 0 and we want to make a new one out of nothing ...
boost at a right-angle to the desired B field: 
E||' = E||
E_P' = gamma E_P
... let v = -E x B' / (E^2) ... gamma in the denominator, eh?
B' = gamma (-v x E) = gamma (-(-E x B' / E^2) x E) = gamma (E x (B' x E)) / E^2
	vector triple product ... a x (b x c) = b (a.c) - c (a.b)
B' = gamma (B' (E . E) - E (E . B')) / E^2
... assume B' is picked to be orthogonal to E ...
B' = gamma B' ... tada!
... for gamma = (1-v^2)^(-1/2)

likewise if we wanted to make B = 0 ...
... we would have to boost perpendicular to B, so B|| = 0
... then solve:
0 = gamma (B_P - v x E)
0 = B_P - v x E
v x E = B_P
v = E x B_P / E.E
v x E = (E x B_P / E.E) x E = -E x (E x B_P) / E.E = (-E(E.B_P) + B_P(E.E)) / E.E = B_P

--]]
-- technically this should have a separate set for its upper index
-- shouldn't the boost be perpendicular to E and B?
local LorentzBoost = Tensor('^a_b', 
	{gamma, 0, 0, -beta * gamma},
	{0, 1, 0, 0},
	{0, 0, 1, 0},
	{-beta * gamma, 0, 0, gamma})

printbr'Lorentz boost'
LorentzBoost:print'\\Lambda'
printbr()

LorentzBoost = LorentzBoost 
--	:replace(gamma, 1/sqrt(1 - beta^2))
--	:replace(beta, -B / E)
	:simplify()
printbr'Lorentz boost to reconstruct a magnetic field in the Y direction (I hope)'
LorentzBoost:print'\\Lambda'
printbr()

local RicciDesiredBoosted = (RicciDesired'_cd' * LorentzBoost'^c_a' * LorentzBoost'^d_b')
	:replace(gamma^2, 1 / (1 - beta^2))
	:simplify()
printbr'EM Ricci, boosted'
RicciDesiredBoosted:print'R'
printbr()

local Faraday = Tensor('_ab', 
	{0, -E, 0, 0},
	{E, 0, 0, 0},
	{0, 0, 0, 0},
	{0, 0, 0, 0})
printbr'Faraday of Electric field in X direction:'
Faraday:print'F'
printbr()
printbr'Faraday, boosted:'
local FaradayBoosted = (Faraday'_cd' * LorentzBoost'^c_a' * LorentzBoost'^d_b')()
FaradayBoosted:print'F'
printbr()

-- but we don't have a metric ...
printbr'Ricci from stress-energy from boosted Faraday (assuming near-linear metric):'
local etaL4 = Tensor('_ab', table.unpack(Matrix.diagonal(-1, 1, 1, 1)))
local etaU4 = Tensor('^ab', table.unpack(Matrix.diagonal(-1, 1, 1, 1)))
local RicciFromBoostedFaraday = (2 * (FaradayBoosted'_ac' * FaradayBoosted'_bd' * etaU4'^cd' - frac(1,4) * etaL4'_ab' * etaU4'^ce' * etaU4'^df' * FaradayBoosted'_cd' * FaradayBoosted'_ef'))()
RicciFromBoostedFaraday:print'R'
printbr()

--[[ Bianchi identities
-- This is zero, but it's a bit slow to compute.
-- It's probably zero because I derived the Riemann values from the connections.
-- This will be a 4^5 = 1024, but it only needs to show 20 * 4 = 80, though because it's R^a_bcd, we can't use the R_abcd = R_cdab symmetry, so maybe double that to 160.
-- TODO covariant derivative function?
-- NOTICE this matches em_conn_infwire.lua, so fix both of these
local diffRiemann = Tensor'^a_bcde'
diffRiemann['^a_bcde'] = (Riemann'^a_bcd,e' + Conn'^a_fe' * Riemann'^f_bcd' - Conn'^f_be' * Riemann'^a_fcd' - Conn'^f_ce' * Riemann'^a_bfd' - Conn'^f_de' * Riemann'^a_bcf')()
local Bianchi = Tensor'^a_bcde'
Bianchi['^a_bcde'] = (diffRiemann'^a_bcde' + diffRiemann'^a_becd' +  diffRiemann'^a_bdec')()
print'Bianchi:'
local sep = ''
for index,value in Bianchi:iter() do
	local abcde = table.map(index, function(i) return coords[i].name end)
	local a,b,c,d,e = abcde:unpack()
	local bcde = table{b,c,d,e}
	if value ~= Constant(0) then
		if sep == '' then printbr() end
		print(sep, (
				var('{R^'..a..'}_{'..b..' '..c..' '..d..';'..e..'}')
				+ var('{R^'..a..'}_{'..b..' '..e..' '..c..';'..d..'}')
				+ var('{R^'..a..'}_{'..b..' '..d..' '..e..';'..c..'}')
			):eq(value))
		sep = ';'
	end
end
if sep=='' then print(0) end
printbr()
--]]

-- reminders:
printbr()
printbr(var'R''^a_bcd':eq(RiemannExpr))
printbr(var'R''_ab':eq(RiemannExpr:reindex{cacbd='abcde'}))

printbr([[ 
Gravitation acting on an object at rest is given as ${\Gamma^j}_{tt}$.

For a uniform field in the x direction,
for the connections that give rise to this stress-energy,
gravitation is ${\Gamma^x}_{tt} = -E$.
]])

local units = require 'symmath.naturalUnits'()

local volts = frac(3,2) * units.V
local dist = 1e-2 * units.m
local Emag = E:eq(volts / dist)():factorDivision()
printbr('Applying',volts,'between conductors',dist,'apart produces a uniform electric field of',Emag,'.')
Emag = Emag:subst(units.V_in_m)():factorDivision()
local Emag_in_ms2 =E:eq((Emag:rhs():subst(units.m_in_s) * (m / m:subst(units.m_in_s)))():factorDivision())
printbr('converting to meters gives',Emag:eq(Emag_in_ms2:rhs()))	-- 1/m ...

--[[
acceleration is m/s = unitless ...
so does that mean our E, in 1/m^3, is per-volume?
and what units are the Schwarzschild connection in?
units of metric tensor: g_tt = m^2/s^2, g_ti = m/s, g_ij = 1
N = kg m / s^2
g_ab is unitless
C^a_bc is in units 1/m
R^c_acb and R_ab is units 1/m^2
T_ab is units N / m^2 = kg / (m s^2)
G is units N m^2 / kg^2 = m^3 / (kg s^2)
8 pi G / c^4 T_ab is units (m^3 / (kg s^2)) / (m/s)^4 (kg / (m s^2))
= 1 / (m^2)
and my stress-energy tensor is E^2 in units of 1/m^2, good 
--]]
