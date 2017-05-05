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
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
MathJax.usePartialLHSForDerivative = true
print(MathJax.header)
local printbr = MathJax.print

local Tensor = symmath.Tensor
local vars = symmath.vars
local var = symmath.var

-- coordinates
local t,r,theta,phi = vars('t','r','\\theta','\\phi')

-- mass
local R_of_r = false
-- dependent on r or not?  most derivations treat R as constant, but for stellar models R varies inside of the star
-- TODO to match up with MTW, use 'R' for the planet radius and 'M' for the total mass, so 2 M for the Schwarzschild radius
local R = var('R', R_of_r and {r} or nil)	

local coords = {t,r,theta,phi}
Tensor.coords{
	{variables = coords},
}

-- schwarzschild metric in cartesian coordinates
local g = Tensor('_uv', function(u,v) return u == v and ({-(1-R/r), 1/(1-R/r), r^2, r^2 * symmath.sin(theta)^2})[u] or 0 end) 
printbr'metric' g:print'g' printbr() printbr()

local props = require 'symmath.diffgeom'(g)

Tensor.metric(g)

-- metric inverse, assume diagonal
printbr'metric inverse' g'^uv'():print'g' printbr() printbr()

-- Christoffel: G_abc = 1/2 (g_ab,c + g_ac,b - g_bc,a) 
local Gamma = Tensor'_abc'
Gamma['_abc'] = ((g'_ab,c' + g'_ac,b' - g'_bc,a')/2)()
printbr'1st kind Christoffel'
Gamma:print'\\Gamma' printbr() printbr()

Gamma = Gamma'^a_bc'()	-- change form stored in Gamma from 1st to 2nd kind

-- Christoffel: G^a_bc = g^ae G_ebc
printbr'2nd kind Christoffel'
Gamma'^a_bc'():print'\\Gamma' printbr() printbr()

-- Geodesic: x''^u = -G^u_vw x'^v x'^w
local diffx = Tensor('^u', function(u) return var('\\dot{x}^'..coords[u].name, coords) end)
local diffx2 = (-Gamma'^u_vw' * diffx'^v' * diffx'^w')()
printbr'geodesic equation' printbr(var'\\ddot{x}''^a':eq(diffx2'^a'()))

-- Christoffel partial: G^a_bc,d
local dGamma = Tensor'^a_bcd'
dGamma['^a_bcd'] = Gamma'^a_bc,d'()
-- hack:
dGamma = dGamma:replace(symmath.cos(theta)^2, 1-symmath.sin(theta)^2)() -- this isn't removing the 1-sin^2+sin^2's...
printbr'2nd kind Christoffel partial'
printbr(var'\\Gamma''^a_bc,d':eq(dGamma'^a_bcd'()))
printbr()

--Riemann: R^a_bcd = G^a_bd,c - G^a_bc,d + G^a_uc G^u_bd - G^a_ud G^u_bc
local Riemann = Tensor'^a_bcd'
Riemann['^a_bcd'] = (dGamma'^a_bdc' - dGamma'^a_bcd' + Gamma'^a_uc' * Gamma'^u_bd' - Gamma'^a_ud' * Gamma'^u_bc')()
-- hack:
Riemann = Riemann:replace(symmath.cos(theta)^2, 1-symmath.sin(theta)^2)()
printbr'Riemann curvature tensor'
Riemann:print'R' printbr() printbr()

-- Ricci: R_ab = R^u_aub
local Ricci = Riemann'^u_aub'()
printbr'Ricci curvature tensor'
Ricci:print'R' printbr() printbr()

-- Gaussian curvature: R = g^ab R_ab
local Gaussian = Ricci'^a_a'()
printbr'Gaussian curvature'
printbr(var'R':eq(Gaussian))
printbr()

-- Einstein tensor: G_ab = R_ab - 1/2 g_ab R
local Einstein = (Ricci'_ab' - g'_ab' * Gaussian / 2)()
printbr'Einstein tensor'
Einstein:print'G' printbr() printbr()

print(MathJax.footer)
