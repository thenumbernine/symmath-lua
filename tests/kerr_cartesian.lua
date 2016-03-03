#!/usr/bin/env luajit
--[[

    File: kerr_cartesian.lua

    Copyright (C) 2013-2016 Christopher Moore (christopher.e.moore@gmail.com)
	  
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
kerr in cartesian form: 

Alcubierre p. 56, Baumgarte & Shapiro p. 52
ds^2 = (eta_uv + 2 H l_u l_v)
	for eta_uv = diag(-1,1,1,1)
		H = (r M - Q^2 / 2) / (r^2 + a^2 z^2 / r^2)
		l_u = (1, (rx + ay) / (r^2 + a^2), (ry - ax) / (r^2 + a^2), z / r)
		r is defined as (x^2 + y^2) / (r^2 + a^2) + z^2 / r^2 = 1

solving for r ...
(x^2 + y^2) / (r^2 + a^2) + z^2 / r^2 = 1
r^2 (x^2 + y^2) + (r^2 + a^2) z^2 = r^2 (r^2 + a^2)
r^2 x^2 + r^2 y^2 + r^2 z^2 + a^2 z^2 = r^4 + a^2 r^2
-r^4 + r^2 x^2 + r^2 y^2 + r^2 z^2 + r^2 a^2 + a^2 z^2 = 0
-r^4 + r^2 (x^2 + y^2 + z^2 + a^2) + a^2 z^2 = 0
...has roots
	r^2 = 1/2 ((x^2 + y^2 + z^2 + a^2) +- sqrt((x^2 + y^2 + z^2 + a^2)^2 + 4 a^2 z^2))
--]]

-- TODO inverting the metric goes really slow...

local symmath = require 'symmath'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
print(MathJax.header)

local function printbr(...) print(...) print'<br>' end

local Tensor = symmath.Tensor
local var = symmath.var
local vars = symmath.vars

-- coordinates
local t, x, y, z = vars('t', 'x', 'y', 'z')
local coords = {t, x, y, z}

local a = var('a', coords)
local r = var('r', coords)
local M = var'M'
local Q = var'Q'

Tensor.coords{
	{variables=coords},
}

--[[
H = (r * M - Q^2 / 2) / (r^2 + a^2 * z^2 / r^2)
--]]
-- [[
local H = var('H', coords)
--]]

--[[
lL_t = 1
lL_x = (r*x + a*y) / (r^2 + a^2)
lL_y = (r*y - a*x) / (r^2 + a^2)
lL_z = z / r
mU_t = -lL_t
mU_x = lL_x
mU_y = lL_y
mU_z = lL_z
--]]
-- [=[
local l = Tensor('_u', function(u) return var('l_'..u, coords) end)
printbr(var'l''_u':eq(l'_u'()))
local m = Tensor('^u', function(u) return var('m^'..u, coords) end)
printbr(var'm''^u':eq(m'^u'()))
--]=]

-- Minkowski metric
local eta = Tensor('_uv', function(u,v) return u == v and (u == 1 and -1 or 1) or 0 end)
printbr(var'\\eta''_uv':eq(eta'_uv'()))

-- Kerr metric in cartesian coordinates
local g = (eta'_uv' - 2 * H * l'_u' * l'_v')()
printbr(var'g''_uv':eq(g'_uv'()))

error"current matrix inverse is too slow for n=4"
Tensor.metric(g)

local gInv = Tensor.metric().metricInverse
printbr(var'g''^uv':eq(gInv'^uv'()))

-- metric partial
-- assume dr/dt is zero
local dg = g'_uv,w'()
dg = dg:replace(r:diff(t), 0)()
printbr(var'g''_uv,w':eq(dg'_uvw'()))

-- Christoffel: G_abc = 1/2 (g_ab,c + g_ac,b - g_bc,a) 
local Gamma = ((dg'_uvw' + dg'_uwv' - dg'_vwu') / 2)()
printbr(var'\\Gamma''_abc':eq(Gamma'_abc'()))

-- Christoffel: G^a_bc = g^ae G_ebc
Gamma = Gamma'^a_bc'()
printbr(var'\\Gamma''^a_bc':eq(Gamma'^a_bc'()))

-- Geodesic: x''^u = -G^u_vw x'^v x'^w
local diffx = Tensor('^u', function(u) return var('{d x^'..u..'}\\over{d\\tau}', coords) end)
local diffx2 = (-Gamma'^u_vw' * diffx'^v' * diffx'^w')()
printbr(var'\\ddot{x}':eq(diffx2))

-- Christoffel partial: G^a_bc,d
local dGamma = Gamma'^a_bc,d'()
printbr(var'\\Gamma''^a_bc,d':eq(dGamma'^a_bcd'()))

--Riemann: R^a_bcd = G^a_bd,c - G^a_bc,d + G^a_uc G^u_bd - G^a_ud G^u_bc
local Riemann = (dGamma'^a_bdc' - dGamma'^a_bcd' + Gamma'^a_uc' * Gamma'^u_bd' - Gamma'^a_ud' * Gamma'^u_bc')()
printbr(var'R''^a_bcd':eq(Riemann'^a_bcd'()))

-- Ricci: R_ab = R^u_aub
local Ricci = Riemann'^u_aub'()
printbr(var'R''_ab':eq(Ricci'_ab'))

-- Gaussian curvature: R = g^ab R_ab
local Gaussian = Ricci'^a_a'()
printbr(var'R':eq(Gaussian))

print(MathJax.footer)
