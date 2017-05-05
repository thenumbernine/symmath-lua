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

local Conn = Tensor'^a_bc'

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

--printbr(var'\\Gamma''^a_bc':eq(Conn))
--printbr(var'c''_cb^a':eq(var'\\Gamma''^a_bc' - var'\\Gamma''^a_cb'):eq((Conn'^a_bc' - Conn'^a_cb')()))

local RiemannExpr = Conn'^a_bd,c' - Conn'^a_bc,d' 
	+ Conn'^a_ec' * Conn'^e_bd' - Conn'^a_ed' * Conn'^e_bc'
	- Conn'^a_be' * (Conn'^e_dc' - Conn'^e_cd')
printbr(var'R''^a_bcd':eq(RiemannExpr:replace(Conn, var'\\Gamma')))
printbr(var'R''_ab':eq(RiemannExpr:replace(Conn, var'\\Gamma'):reindex{cacbd='abcde'}))

for index,value in Conn:iter() do
	local a,b,c = table.unpack(index)
	if value ~= Constant(0) then
		print(
			var'\\Gamma'(
				'^'..coords[a].name
				..'_'..coords[b].name
				..coords[c].name
			):eq(value),',') 
	end
end
printbr()

local Riemann = Tensor'^a_bcd'
Riemann['^a_bcd'] = RiemannExpr()
--printbr(var'R''^a_bcd':eq(Riemann))

local Ricci = Riemann'^c_acb'()
print(var'R''_ab':eq(Ricci))

-- 8 pi T_ab = G_ab = R_ab - 1/2 R g_ab
-- and R = 0 for electrovac T_ab
-- so 8 pi T_ab = R_ab
print('vs desired')
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
printbr(var'R''_ab':eq(Ricci_EM))

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
