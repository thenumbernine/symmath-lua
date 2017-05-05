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


local g = Tensor'_ab'

--[[ 
solving for g_tt = -1 + a(x), g_xx = 1 + b (is const), g_yy = g_zz = 1
I get everything except the C^t_tt constraint (which I'm now thinking maybe I should avoid, since Schwarzschild avoids it)
C^t_tx = C^t_xt = -a,x / (2(1-a)) = E
C^x_tt = -a,x / (2(1+b)) = -E

solving for a(x):
da/dx = 2 E a
da/a = 2 E dx
ln a = 2 E x
a = exp(2 E x) + C
a = exp(2 E x) + 1
da/dx = 2 E exp(2 E x)
-da/dx + 2 E a = -2 E exp(2 E x) + 2 E (exp(2 E x) + 1) = 2 E, viola...
...however, a = 1 + exp(2 E x) means g_tt = -1 + a = -1 + 1 + exp(2 E x)
... means I'm cancelling out my Minkowski component of the metric ...

-2 E exp(2 E x) / (2 (1 + b)) = -E
b = -exp(2 E x) - 1
...and now I'm in trouble, because 'b' was supposed to be constant (otherwise more C^a_bc terms would show up)
maybe I should let b depend on x, and solve this as a linear dynamic system?
--]]

-- [[ ok now to find the metric that gives rise to the conn ...
g[1][1] = -1 + var('a',{x})
g[2][2] = 1 + var('b')
--g[3][3] = var('c',{x,y,z})
--g[4][4] = var('d',{x,y,z})
--g[2][3] = var('h', {x,y,z}) g[3][2] = g[2][3]
--g[2][4] = var('j', {x,y,z}) g[4][2] = g[2][4]
--g[3][4] = var('k', {x,y,z}) g[4][3] = g[3][4]

-- still need: 
-- C^t_tt = g^tt C_ttt + g^tk C_ktt = 1/2 (g^tt g_tt,t + g^tk (2 g_kt,t - g_tt,k))
--g[1][2] = var('e', {x}) g[2][1] = g[1][2]
--g[1][3] = var('f', {y,z}) g[3][1] = g[1][3]
--g[1][4] = var('g', {x,y,z}) g[4][1] = g[1][4]
-- C^t_jj = g^tt C_tjj + g^tk C_kjj

g[3][3] = Constant(1)
g[4][4] = Constant(1)
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
local diffRiemann = (Riemann'^a_bcd,e' + Conn'^a_fe' * Riemann'^f_bcd' - Conn'^f_be' * Riemann'^a_fcd' - Conn'^f_ce' * Riemann'^a_bfd' - Conn'^f_de' * Riemann'^a_bcf')()
local Bianchi = Tensor'^a_bcde'
Bianchi['^a_bcde'] = (diffRiemann + diffRiemann:reindex{abecd='abcde'} +  diffRiemann:reindex{abdec='abcde'})()
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
