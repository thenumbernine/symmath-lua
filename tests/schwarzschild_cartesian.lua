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

local dim = 3	-- 2, 3, or 4

local allCoords = {t, x, y, z}
local coords = {table.unpack(allCoords, 1, dim)}
local spatialCoords = {table.unpack(allCoords, 2, dim)}

-- algebraic
--r = (x^2 + y^2 + z^2)^.5
-- deferred:
local r = symmath.Variable('r', coords)
-- mass is constant
local M = symmath.var('M')

Tensor.coords{
	{variables = coords},
	{variables = spatialCoords, symbols = 'ijklmn'},
}

-- schwarzschild metric in cartesian coordinates

--[[ 4D
local g = Tensor('_uv', 
	{-(1-2*M/r), 0, 0, 0},
	{0, (x^2/(1-2*M/r) + y^2 + z^2)/r^2, x*y*2*M/(r^2*(r-2*M)), x*z*2*M/(r^2*(r-2*M))},
	{0, x*y*2*M/(r^2*(r-2*M)), (x^2 + y^2/(1-2*M/r) + z^2)/r^2, y*z*2*M/(r^2*(r-2*M))},
	{0, x*z*2*M/(r^2*(r-2*M)), y*z*2*M/(r^2*(r-2*M)), (x^2 + y^2 + z^2/(1-2*M/r))/r^2})
--]]
-- [[ n-D
local g = Tensor'_uv'
g[{1,1}] = -(1-2*M/r)
for i=1,dim-1 do
	local xi = spatialCoords[i]
	for j=1,dim-1 do
		local xj = spatialCoords[j]
		if i == j then
			local sum
			for k=1,dim-1 do
				local xk = spatialCoords[k]
				local term = k == i and (xk^2 / (1 - 2 * M / r)) or (xk^2)
				sum = sum and sum + term or term
			end
			sum = sum / r^2
			g[{i+1,j+1}] = sum
		else
			g[{i+1,j+1}] = 2 * M * xi * xj / (r^2 * (r - 2 * M))
		end
	end
end
--]]
printbr'metric:'
printbr('\\(g_{uv} = \\)'..g)
g = g:simplify()
printbr'simplified:'
printbr('\\(g_{uv} = \\)'..g)

Tensor.metric(g)
printbr('\\(g^{uv} = \\)'..Tensor.metric().metricInverse)

-- metric inverse, assume diagonal
printbr('metric inverse')
printbr('\\(g^{uv} = \\)'..g'^uv')
printbr()

-- metric partial
-- assume dr/dt is zero
local dg = g'_uv,w':simplify()
printbr'metric partial derivatives:'
printbr('\\(\\partial_w g_{uv} = \\)'..dg'_uvw')

printbr'let \\({{\\partial r}\\over{\\partial t}} = 0\\)'
dg = dg:replace(r:diff(t), 0):simplify()
printbr('\\(\\partial_w g_{uv} = \\)'..dg'_uvw')

-- Christoffel: G_abc = 1/2 (g_ab,c + g_ac,b - g_bc,a) 
local Gamma = ((dg'_abc' + dg'_acb' - dg'_bca') / 2):simplify()
printbr'1st kind Christoffel:'
printbr('\\(\\Gamma_{uvw} = \\)'..Gamma'_uvw')

-- Christoffel: G^a_bc = g^ae G_ebc
Gamma = Gamma'^u_vw'	-- change underlying storage (not necessary, but saves future calculations)
printbr'2nd kind Christoffel:'
printbr('\\({\\Gamma^u}_{vw} = \\)'..Gamma'^u_vw')

-- Geodesic: x''^u = -G^u_vw x'^v x'^w
local diffx = Tensor('^u', function(u) return symmath.var('\\dot{x}^'..coords[u].name, coords) end)
local diffx2 = (-Gamma'^u_vw' * diffx'^v' * diffx'^w'):simplify()
printbr('geodesic equation')
printbr('\\(\\ddot{x}^a = \\)'..diffx2)

-- Christoffel partial: G^a_bc,d
local dGamma = Gamma'^a_bc,d':simplify()
printbr('2nd kind Christoffel partial')
printbr('\\({\\Gamma^a}_{bc,d} = \\)'..dGamma)
printbr()

--Riemann: R^a_bcd = G^a_bd,c - G^a_bc,d + G^a_uc G^u_bd - G^a_ud G^u_bc
local Riemann = (dGamma'^a_bdc' - dGamma'^a_bcd' + Gamma'^a_uc' * Gamma'^u_bd' - Gamma'^a_ud' * Gamma'^u_bc'):simplify()
printbr('Riemann curvature tensor')
printbr('\\({R^a}_{bcd} = \\)'..Riemann)
printbr()

-- Ricci: R_ab = R^u_aub
local Ricci = Riemann'^u_aub':simplify()
printbr('Ricci curvature tensor')
printbr('\\(R_{ab} = \\)'..Ricci)
printbr()

-- Gaussian curvature: R = g^ab R_ab
local Gaussian = Ricci'^a_a':simplify()
printbr('Gaussian curvature')
printbr('\\(R = \\)'..Gaussian)
printbr()

print(MathJax.footer)
