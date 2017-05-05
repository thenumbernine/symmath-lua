#!/usr/bin/env luajit
--[[

    File: schwarzschild_cartesian.lua

    Copyright (C) 2000-2015 Christopher Moore (christopher.e.moore@gmail.com)
	  
    This software is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
  
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
  
    You should have received a copy of the GNU General Public License along
    with this program; if not, write the Free Software Foundation, Inc., 51
    Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

--]]

local table = require 'ext.table'
local symmath = require 'symmath'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
print(MathJax.header)
local printbr = MathJax.print

local Tensor = symmath.Tensor
local vars = symmath.vars
local var = symmath.var
local add = symmath.op.add

-- coordinates
local t,x,y,z = vars('t','x','y','z')

local dim = 4	-- 2, 3, or 4

local allCoords = table{t, x, y, z}
local coords = allCoords:sub(1,dim)
local spatialCoords = allCoords:sub(2,dim)

Tensor.coords{
	{variables = coords},
	{variables = spatialCoords, symbols = 'ijklmn'},
}


local r = var('r', spatialCoords) 	-- r = (x^2 + y^2 + z^2)^.5

-- mass is constant
local R = var'R'

-- algebraic
--r = (x^2 + y^2 + z^2)^.5
-- deferred:
local r = var('r', spatialCoords)
--]=]

-- scale factor
local mu = var'\\mu'
local mu_def = mu:eq(R / (r^2 * (r - R)))

-- spatial metric

local gamma = Tensor('_ij', function(i,j)
	local xi = spatialCoords[i]
	local xj = spatialCoords[j]
	if i == j then
		result = 1 + mu_def:rhs() * xi^2
	else
		result = mu_def:rhs() * xi * xj
	end
	return result
end)()

printbr'spatial metric:'
printbr(var'\\gamma''_ij':eq(gamma'_ij'()))

local rSq_def = dim == 2 and x^2 or add(spatialCoords:map(function(xi) return xi^2 end):unpack())
local gammaInv = Tensor('^ij', function(i,j)
	local xi = spatialCoords[i]
	local xj = spatialCoords[j]
	local result
	if i == j then
		result = 1 + mu_def:rhs() * (r^2 - xi^2)
	else
		result = -mu_def:rhs() * xi * xj
	end
	return result / (1 + mu_def:rhs() * r^2)
end)()

--local gammaInv = Tensor{indexes='^ij', values=symmath.Matrix.inverse(gamma)}
printbr'spatial metric inverse:'
printbr(var'\\gamma''^ij':eq(gammaInv'^ij'()))

local delta3 = (gamma'_ik' * gammaInv'^kj')
	:replace(r^2, rSq_def)
	:replace(r^3, r*rSq_def)
	:simplify()
printbr((var'\\gamma''_ik' * var'\\gamma''^kj'):eq(delta3'_i^j'()))

-- schwarzschild metric in cartesian coordinates
local g = Tensor('_uv', function(u,v)
	if u == 1 and v == 1 then
		return -1 + R/r
	elseif u > 1 and v > 1 then
		return gamma[u-1][v-1]
	else
		return 0
	end
end)

printbr'metric:'
printbr(var'g''_uv':eq(g'_uv'()))

local gInv = Tensor('^uv', function(u,v)
	if u == 1 and v == 1 then
		return 1/g[1][1]
	elseif u > 1 and v > 1 then
		return gammaInv[u-1][v-1]
	else
		return 0
	end
end)

printbr'metric inverse:'
printbr(var'g''^uv':eq(gInv'^uv'()))

local delta4 = (g'_ua' * gInv'^av')
	:replace(r^2, rSq_def)
	:replace(r^3, r * rSq_def)
	:simplify()
printbr((var'g''_ua'*var'g''^av'):eq(delta4'_u^v'()))

Tensor.metric(g, gInv)

-- metric partial
-- assume dr/dt is zero
local dg = Tensor'_uvw'
dg['_uvw'] = g'_uv,w'()
for _,xi in ipairs(spatialCoords) do
	dg = dg:replace(r:diff(xi), xi/r)
end
dg = dg()
printbr'metric partial derivatives:'
printbr(var'g''_uv,w':eq(dg'_uvw'()))

-- Christoffel: G_abc = 1/2 (g_ab,c + g_ac,b - g_bc,a) 
local Gamma = ((dg'_abc' + dg'_acb' - dg'_bca') / 2)()
printbr'1st kind Christoffel:'
printbr(var'\\Gamma''_uvw':eq(Gamma'_uvw'()))

-- Christoffel: G^a_bc = g^ae G_ebc
Gamma = Gamma'^u_vw'()	-- change underlying storage (not necessary, but saves future calculations)
	:replace(x^4, x^2*x^2)
	:replace(y^4, y^2*y^2)
	:replace(z^4, z^2*z^2)
	:replace(x^2, r^2-y^2-z^2)()
	:replace(y^2, r^2-x^2-z^2)()
	:replace(z^2, r^2-x^2-y^2)()
--	:replace(r^2, x^2+y^2+z^2)()
printbr'2nd kind Christoffel:'
printbr(var'\\Gamma''^u_vw':eq(Gamma'^u_vw'()))

--[[
-1/alpha^2 = g^tt
alpha = sqrt(-1/g^tt)
--]]
local alpha = symmath.sqrt(-1/gInv[1][1])
local n = Tensor('_u', function(u)
	return u == 1 and alpha or 0
end)
printbr(var'n''_u':eq(n'_u'()))	--'_u')

-- P is really just the 4D extension of gamma ...
-- it'd be great if I could just define gamma in 4D then just reference the 3D components of it when it needed to be treated like a 3D tensor ...
local P = (g'_uv' + n'_u' * n'_v')()
printbr(var'P''_uv':eq(P'_uv'()))

local dn = Tensor'_uv'
-- simplification loop?
--dn = (dn'_uv' - Gamma'^w_vu' * n'_w'):simplify()
-- looks like chaining arithmetic operators between tensor +- and * causes problems ... 
-- ... probably because we're trying to derefernce an uevaluated multiplication ... so it has no internal structure yet ...
-- ... so should (a) tensor algebra be immediately simplified, or
--				(b) dereferences require simplification?
dn['_uv'] = (n'_v,u' - (Gamma'^w_vu' * n'_w')()'_uv')()
for _,xi in ipairs(spatialCoords) do
	dn = dn:replace(r:diff(xi), xi/r)()
end
printbr(var'dn':eq(dn))
printbr((var'\\nabla n''_uv'):eq(dn'_uv'()))

-- TODO add support for (ab) and [ab] indexes
local K = (P'^a_u' * P'^b_v' * ((dn'_ab' + dn'_ba')/2))() 
printbr(var'K''_uv':eq(K'_uv'()))

-- Geodesic: x''^u = -G^u_vw x'^v x'^w
local diffx = Tensor('^u', function(u) return symmath.var('\\dot{x}^'..coords[u].name, coords) end)
local diffx2 = (-Gamma'^u_vw' * diffx'^v' * diffx'^w'):simplify()
printbr('geodesic equation')
printbr('$\\ddot{x}^a = $'..diffx2)

--[[
-- Christoffel partial: G^a_bc,d
local dGamma = Gamma'^a_bc,d':simplify()
printbr('2nd kind Christoffel partial')
printbr('${\\Gamma^a}_{bc,d} = $'..dGamma)
printbr()

--Riemann: R^a_bcd = G^a_bd,c - G^a_bc,d + G^a_uc G^u_bd - G^a_ud G^u_bc
local Riemann = (dGamma'^a_bdc' - dGamma'^a_bcd' + Gamma'^a_uc' * Gamma'^u_bd' - Gamma'^a_ud' * Gamma'^u_bc'):simplify()
printbr('Riemann curvature tensor')
printbr('${R^a}_{bcd} = $'..Riemann)
printbr()

-- Ricci: R_ab = R^u_aub
local Ricci = Riemann'^u_aub':simplify()
printbr('Ricci curvature tensor')
printbr('$R_{ab} = $'..Ricci)
printbr()

-- Gaussian curvature: R = g^ab R_ab
local Gaussian = Ricci'^a_a':simplify()
printbr('Gaussian curvature')
printbr('$R = $'..Gaussian)
printbr()
--]]

print(MathJax.footer)
