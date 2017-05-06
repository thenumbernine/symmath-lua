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
local exp = symmath.exp
local div = symmath.op.div
local Constant = symmath.Constant

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
local Ev = Tensor('_i', function(i) return var('E_'..spatialCoords[i].name) end)
local Ex, Ey, Ez = table.unpack(Ev)
local B = var'B'
local Bv = Tensor('_i', function(i) return var('B_'..spatialCoords[i].name) end)
local Bx, By, Bz = table.unpack(Bv)
local S = var'S'
local Sv = Tensor('_i', function(i) return var('S_'..spatialCoords[i].name) end)
local Sx, Sy, Sz = table.unpack(Sv)

--[[
here's a thought on this:
finding g->C and C->R means finding the space by which E changes when transformed, and therefore R changes
so the problem is circular.
we want to measure the one thing that is independent of the problem.
wouldn't that be E^i rather than E_i ?
if so, don't I need to factor g's into my calculations of R?
--]]
local g = Tensor'_ab'

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

-- [[ ok now to find the metric that gives rise to the conn ...
-- C^t_tt = E = g^tt C_ttt + g^tk C_ktt = 1/2 g^tt g_tt,t + g^tk g_tk,t - 1/2 g^tk g_tt,k
-- C^t_yy = E = g^tt C_tyy + g^tk C_kyy = g^tt g_ty,y - 1/2 g^tt g_yy,t + g^tk g_ky,y - 1/2 g^tk g_yy,k
-- C^x_tt = -E = g^xt C_ttt + g^xk C_ktt = 1/2 g^xt g_tt,t + g^xk g_kt,t - 1/2 g^xk g_tt,k
-- C^t_tx = E = g^tt C_ttx + g^tk C_ktx = 1/2 (g^tt g_tt,x + g^tx g_xx,t + g^ty (g_xy,t + g_ty,x - g_tx,y) + 1/2 g^tz (g_xz,t + g_tz,x - g_tx,z))
-- and all those terms are constant.
g[1][1] = var('a', {})
g[2][2] = var('b', {})
g[3][3] = var('c', {})
g[4][4] = var('d', {})

g[1][2] = var('e', {}) g[2][1] = g[1][2]
g[1][3] = var('f', {}) g[3][1] = g[1][3]
g[1][4] = var('g', {}) g[4][1] = g[1][4]

g[2][3] = var('h', {}) g[3][2] = g[2][3]
g[2][4] = var('j', {}) g[4][2] = g[2][4]
g[3][4] = var('k', {}) g[4][3] = g[3][4]
--]]

local gU = Tensor('^ab', table.unpack(( Matrix.inverse(g) )))

--g:printElem'g' printbr() 
g:print'g'
--gU:printElem'g' printbr() 
gU:print'g'

local ConnFromMetric = Tensor'_abc'
ConnFromMetric['_abc'] = (div(1,2) * (g'_ab,c' + g'_ac,b' - g'_bc,a'))()	-- ... plus commutation? in this case I have a symmetric Conn so I don't need comm

printbr'...produces...'
--ConnFromMetric:printElem'\\Gamma' printbr()
ConnFromMetric = (gU'^ad' * ConnFromMetric'_dbc')()

--ConnFromMetric:printElem'\\Gamma' printbr()
ConnFromMetric:print'\\Gamma'

print'vs desired'

local Conn = Tensor'^a_bc'

-- THIS WORKS:
-- [[ this gives rise to the stress-energy tensor for EM with E in the x dir and B = 0
-- to account for other E's and B's, just boost and rotate your coordinate system
-- don't forget, when transforming Conn, to use its magic transformation eqn, since it's not a real tensor
Conn[1][1][1] = E
Conn[2][1][1] = -E
Conn[1][2][1] = E
Conn[1][1][2] = E
Conn[1][3][3] = E
Conn[1][4][4] = E
--]]

--Conn:printElem'\\Gamma' printbr()
Conn:print'\\Gamma'
--printbr(var'c''_cb^a':eq(var'\\Gamma''^a_bc' - var'\\Gamma''^a_cb'):eq((Conn'^a_bc' - Conn'^a_cb')()))

printbr()

local RiemannExpr = Conn'^a_bd,c' - Conn'^a_bc,d' 
	+ Conn'^a_ec' * Conn'^e_bd' - Conn'^a_ed' * Conn'^e_bc'
	- Conn'^a_be' * (Conn'^e_dc' - Conn'^e_cd')


local Riemann = Tensor'^a_bcd'
Riemann['^a_bcd'] = RiemannExpr()
--Riemann:print'R'

local Ricci = Riemann'^c_acb'()
Ricci:print'R'

-- 8 pi T_ab = G_ab = R_ab - 1/2 R g_ab
-- and R = 0 for electrovac T_ab
-- so 8 pi T_ab = R_ab
print'vs desired'
local ESqBSq = Ex^2 + Ey^2 + Ez^2 + Bx^2 + By^2 + Bz^2
local Ricci_EM = Tensor('_ab', function(a,b)
	if a==1 and b==1 then
		return ESqBSq
	elseif a==1 then
		return -2 * Sv[b-1]
	elseif b==1 then
		return -2 * Sv[a-1]
	elseif a==b then
		return ESqBSq - 2 * (Ev[a-1] * Ev[b-1] + Bv[a-1] * Bv[b-1])
	else
		return -2 * (Ev[a-1] * Ev[b-1] + Bv[a-1] * Bv[b-1])
	end
end)
Ricci_EM = Ricci_EM
	:replace(Sx, Ey*Bz-Ez*By)
	:replace(Sy, Ez*Bx-Ex*Bz)
	:replace(Sz, Ex*By-Ey*Bx)
-- E in Ex direction 
	:replace(Ex, E)
	:replace(Ey, 0)
	:replace(Ez, 0)
-- zero b-field
	:replace(Bx, 0)
	:replace(By, 0)
	:replace(Bz, 0)
	:simplify()
printbr(Ricci_EM:print'R')

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
printbr(var'R''^a_bcd':eq(RiemannExpr:replace(Conn, var'\\Gamma')))
printbr(var'R''_ab':eq(RiemannExpr:replace(Conn, var'\\Gamma'):reindex{cacbd='abcde'}))
