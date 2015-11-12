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


--[[
schwarzschild in spherical form: (-(1-2m/r)) dt^2 + 1/(1-2m/r) dr^2 + r^2 dtheta^2 + r^2 sin(theta)^2 dphi^2

convert to pseudo-Cartesian via:
	dr = (x dx + y dy + z dy) / r
	dtheta = (xz dx + yz dy - (x^2 + y^2) dz) / (r^2 sqrt(x^2 + y^2))
	dphi = (-y dx + x dy) / (x^2 + y^2)
--]]

local table = require 'ext.table'
local symmath = require 'symmath'
local Tensor = require 'symmath.Tensor'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax

local function printbr(...)
	print(...)
	print('<br>')
end

print(MathJax.header)

-- coordinates
local t, x, y, z = symmath.vars('t', 'x', 'y', 'z')

local dim = 4	-- 2, 3, or 4

local allCoords = table{t, x, y, z}
local coords = allCoords:sub(1,dim)
local spatialCoords = allCoords:sub(2,dim)

-- algebraic
--r = (x^2 + y^2 + z^2)^.5
-- deferred:
local r = symmath.Variable('r', spatialCoords)
-- mass is constant
local R = symmath.var('R')

Tensor.coords{
	{variables = coords},
	{variables = spatialCoords, symbols = 'ijklmn'},
}

-- scale factor
local mu = symmath.var('\\mu')
local mu_def = mu:equals(R / (r^2 * (r - R)))

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
end):simplify()

printbr'spatial metric:'
printbr('$\\gamma_{ij} = $'..gamma)

local rSq_def = dim == 2 and x^2 or symmath.addOp(spatialCoords:map(function(xi) return xi^2 end):unpack())
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
end):simplify()

--local gammaInv = Tensor{indexes='^ij', values=symmath.Matrix.inverse(gamma)}
printbr'spatial metric inverse:'
printbr('$\\gamma^{ij} = $'..gammaInv)

local delta3 = (gamma'_ik' * gammaInv'^kj')
	:replace(r^2, rSq_def)
	:replace(r^3, r*rSq_def)
	:simplify()
printbr('$\\gamma_{ik} \\gamma^{kj} = $'..delta3)

-- schwarzschild metric in cartesian coordinates
local g = Tensor('_uv', function(u,v)
	if u == 1 and v == 1 then
		return -1 + R/r
	elseif u > 1 and v > 1 then
		return gamma[{u-1,v-1}]
	else
		return 0
	end
end)

printbr'metric:'
printbr('$g_{uv} = $'..g)

local gInv = Tensor('^uv', function(u,v)
	if u == 1 and v == 1 then
		return 1/g[{1,1}]
	elseif u > 1 and v > 1 then
		return gammaInv[{u-1,v-1}]
	else
		return 0
	end
end)

printbr'metric inverse:'
printbr('$g^{uv} = $'..gInv)

local delta4 = (g'_ua' * gInv'^av')
	:replace(r^2, rSq_def)
	:replace(r^3, r * rSq_def)
	:simplify()
printbr('$g_{ua} g^{av} = $'..delta4)

Tensor.metric(g, gInv)

-- metric partial
-- assume dr/dt is zero
local dg = g'_uv,w':simplify()
for _,xi in ipairs(spatialCoords) do
	dg = dg:replace(r:diff(xi), xi/r)
end
dg = dg:simplify()
printbr'metric partial derivatives:'
printbr('$\\partial_w g_{uv} = $'..dg'_uvw')

-- Christoffel: G_abc = 1/2 (g_ab,c + g_ac,b - g_bc,a) 
local Gamma = ((dg'_abc' + dg'_acb' - dg'_bca') / 2):simplify()
printbr'1st kind Christoffel:'
printbr('$\\Gamma_{uvw} = $'..Gamma'_uvw')

-- Christoffel: G^a_bc = g^ae G_ebc
Gamma = Gamma'^u_vw'	-- change underlying storage (not necessary, but saves future calculations)
	--:replace(x^2, r^2-y^2-z^2):simplify()
	--:replace(y^2, r^2-x^2-z^2):simplify()
	--:replace(z^2, r^2-x^2-y^2):simplify()
printbr'2nd kind Christoffel:'
printbr('${\\Gamma^u}_{vw} = $'..Gamma'^u_vw')

do return end

-- Geodesic: x''^u = -G^u_vw x'^v x'^w
local diffx = Tensor('^u', function(u) return symmath.var('\\dot{x}^'..coords[u].name, coords) end)
local diffx2 = (-Gamma'^u_vw' * diffx'^v' * diffx'^w'):simplify()
printbr('geodesic equation')
printbr('$\\ddot{x}^a = $'..diffx2)

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

print(MathJax.footer)
