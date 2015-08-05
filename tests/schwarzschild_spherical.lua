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

print(MathJax.header)

-- coordinates
local t, r, theta, phi, M = symmath.vars('t', 'r', '\\theta', '\\phi', 'M')

local coords = {t, r, theta, phi}
Tensor.coords{
	{variables = coords},
}
local function printbr(...)
	print(...)
	print('<br>')
end

-- schwarzschild metric in cartesian coordinates
local g = Tensor('_uv', function(u,v) return u == v and ({-(1-2*M/r), 1/(1-2*M/r), r^2, r^2 * symmath.sin(theta)^2})[u] or 0 end) 
printbr('metric')
printbr('\\(g_{uv} = \\)'..g'_uv')
printbr()

Tensor.metric(g)

-- metric inverse, assume diagonal
printbr('metric inverse')
printbr('\\(g^{uv} = \\)'..g'^uv')
printbr()

-- Christoffel: G_abc = 1/2 (g_ab,c + g_ac,b - g_bc,a) 
local Gamma = ((g'_ab,c' + g'_ac,b' - g'_bc,a')/2):simplify()
printbr('1st kind Christoffel')
printbr('\\(\\Gamma_{abc} = \\)'..Gamma'_abc')
printbr()

Gamma = Gamma'^a_bc':simplify()	-- change form stored in Gamma from 1st to 2nd kind

-- Christoffel: G^a_bc = g^ae G_ebc
printbr('2nd kind Christoffel')
printbr('\\({\\Gamma^a}_{bc} = \\)'..Gamma'^a_bc')
printbr()

-- Geodesic: x''^u = -G^u_vw x'^v x'^w
local diffx = Tensor('^u', function(u) return symmath.var('{d x^'..u..'}\\over{d\\tau}', coords) end)
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
