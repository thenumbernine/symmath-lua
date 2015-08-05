#!/usr/bin/env luajit
--[[

    File: kerr_cartesian.lua

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

local symmath = require 'symmath'
local Tensor = require 'symmath.Tensor'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
print(MathJax.header)

-- coordinates
local t, x, y, x = symmath.vars('t', 'x', 'y', 'z')
local spatialCoords = {x, y, z}
local coords = {t, x, y, z}

-- TODO store tensor names like we store variables ... though I no longer store variable values (as tensor values are stored)
function printTensor(name, t)
	local s = name
	local lastLower = 'asdf'
	if t.variance then
		for _,index in ipairs(t.variance) do
			if index.lower then
				s = '{'..s..'}_'..index.symbol
			else
				s = '{'..s..'}^'..index.symbol
			end
		end
	end
	print('\\('..s..' = \\)'..t..'<br>')
	io.stdout:flush()
end

local a = symmath.var('a', coords)
local r = symmath.var('r', coords)
local M = symmath.var('M')
local Q = symmath.var('Q')

Tensor.coords{
	{variables=coords},
	{symbols='ijk', variables=spatialCoords}
}

--[[
H = (r * M - Q^2 / 2) / (r^2 + a^2 * z^2 / r^2)
--]]
-- [[
local H = symmath.var('H', coords)
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
local l = Tensor('_u', function(u) return symmath.var('l_'..u, coords) end)
printTensor('l', l)
local m = Tensor('^u', function(u) return symmath.var('m^'..u, coords) end)
printTensor('m', m)
--]=]

-- Minkowski metric
local eta = Tensor('_uv', function(u,v) return u == v and (u == 1 and -1 or 1) or 0 end)
printTensor('\\eta', eta)

-- Kerr metric in cartesian coordinates
local g = (eta'_uv' - 2 * H * l'_u' * l'_v'):simplify()
Tensor.metric(g)
printTensor('g', g)

-- metric partial
-- assume dr/dt is zero
local dg = g'_uv,w'
dg = dg:replace(r:diff(t), symmath.Constant(0)):simplify()
printTensor('\\partial g', dg)

-- Christoffel: G_abc = 1/2 (g_ab,c + g_ac,b - g_bc,a) 
local Gamma = ((dg'_uvw' + dg'_uwv' - dg'_vwu') / 2):simplify()
printTensor('\\Gamma', Gamma)

-- Christoffel: G^a_bc = g^ae G_ebc
Gamma = Gamma'^a_bc':simplify()
printTensor('\\Gamma', Gamma)

-- Geodesic: x''^u = -G^u_vw x'^v x'^w
local diffx = Tensor('^u', function(u) return symmath.var('{d x^'..u..'}\\over{d\\tau}', coords) end)
local diffx2 = (-Gamma'^u_vw' * diffx'^v' * diffx'^w'):simplify()
printTensor('\\ddot{x}', diffx2)

-- Christoffel partial: G^a_bc,d
local dGamma = Gamma'^a_bc,d':simplify()
printTensor('\\partial \\Gamma', dGamma)

--Riemann: R^a_bcd = G^a_bd,c - G^a_bc,d + G^a_uc G^u_bd - G^a_ud G^u_bc
local Riemann = (dGamma'^a_bdc' - dGamma'^a_bcd' + Gamma'^a_uc' * Gamma'^u_bd' - Gamma'^a_ud' * Gamma'^u_bc'):simplify()
printTensor('R', Riemann)

-- Ricci: R_ab = R^u_aub
local Ricci = Riemann'^u_aub':simplify()
printTensor('R', Ricci)

-- Gaussian curvature: R = g^ab R_ab
local Gaussian = Ricci'^a_a':simplify()
printTensor('R', Gaussian)

print(MathJax.footer)
