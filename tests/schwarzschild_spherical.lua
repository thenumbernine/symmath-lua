#!/usr/bin/env luajit
--[[

    File: schwarzschild_spherical.lua

    Copyright (C) 2000-2014 Christopher Moore (christopher.e.moore@gmail.com)
	  
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
local t, r, theta, phi, M = symmath.vars('t', 'r', '\\theta', '\\phi', 'M')

local coords = {t, r, theta, phi}
Tensor.coords{
	{variables = coords},
}

-- schwarzschild metric in cartesian coordinates
local gVar = symmath.var('g')
local g = Tensor('_uv', function(u,v) return u == v and ({-(1-2*M/r), 1/(1-2*M/r), r^2, r^2 * symmath.sin(theta)^2})[u] or 0 end) 
printbr('metric')
printbr(gVar'_uv':eq(g'_uv'()))
printbr()

Tensor.metric(g)

-- metric inverse, assume diagonal
printbr('metric inverse')
printbr(gVar'^uv':eq(g'^uv'()))
printbr()

-- Christoffel: G_abc = 1/2 (g_ab,c + g_ac,b - g_bc,a) 
local GammaVar = symmath.var('\\Gamma')
local Gamma = ((g'_ab,c' + g'_ac,b' - g'_bc,a')/2)()
printbr('1st kind Christoffel')
printbr(GammaVar'_abc':eq(Gamma'_abc'()))
printbr()

Gamma = Gamma'^a_bc'()	-- change form stored in Gamma from 1st to 2nd kind

-- Christoffel: G^a_bc = g^ae G_ebc
printbr('2nd kind Christoffel')
printbr(GammaVar'^a_bc':eq(Gamma'^a_bc'()))
printbr()

-- Geodesic: x''^u = -G^u_vw x'^v x'^w
local diffx = Tensor('^u', function(u) return symmath.var('\\dot{x}^'..coords[u].name, coords) end)
local diffx2Var = symmath.var('\\ddot{x}', coords)
local diffx2 = (-Gamma'^u_vw' * diffx'^v' * diffx'^w')()
printbr('geodesic equation')
printbr(diffx2Var'^a':eq(diffx2'^a'()))

-- Christoffel partial: G^a_bc,d
local dGamma = Gamma'^a_bc,d'()
dGamma = dGamma:replace(symmath.cos(theta)^2, 1-symmath.sin(theta)^2)
dGamma = dGamma()	-- this isn't removing the 1-sin^2+sin^2's...
printbr('2nd kind Christoffel partial')
printbr(GammaVar'^a_bc,d':eq(dGamma'^a_bcd'()))
printbr()

--Riemann: R^a_bcd = G^a_bd,c - G^a_bc,d + G^a_uc G^u_bd - G^a_ud G^u_bc
local RVar = symmath.var('R')
local Riemann = (dGamma'^a_bdc' - dGamma'^a_bcd' + Gamma'^a_uc' * Gamma'^u_bd' - Gamma'^a_ud' * Gamma'^u_bc')()
Riemann = Riemann:replace(symmath.cos(theta)^2, 1-symmath.sin(theta)^2)()
printbr('Riemann curvature tensor')
printbr(RVar'^a_bcd':eq(Riemann'^a_bcd'()))
printbr()

-- Ricci: R_ab = R^u_aub
local Ricci = Riemann'^u_aub'()
printbr('Ricci curvature tensor')
printbr(RVar'_ab':eq(Ricci'_ab'()))
printbr()

-- Gaussian curvature: R = g^ab R_ab
local Gaussian = Ricci'^a_a'()
printbr('Gaussian curvature')
printbr(RVar:eq(Gaussian))
printbr()

print(MathJax.footer)
