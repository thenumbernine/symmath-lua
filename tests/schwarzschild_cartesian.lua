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
print(MathJax.header)

-- coordinates
local t, x, y, z = symmath.vars('t', 'x', 'y', 'z')

local dim = 2	-- 2, 3, or 4

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
print'metric:<br>'
print('\\(g_{uv} = \\)'..g..'<br>')
g = g:simplify()
print'simplified:<br>'
print('\\(g_{uv} = \\)'..g..'<br>')

Tensor.metric(g)
print('\\(g^{uv} = \\)'..Tensor.metric().metricInverse..'<br>')

-- metric partial
-- assume dr/dt is zero
local dg = g'_uv,w':simplify()
print'metric partial derivatives:<br>'
print('\\(\\partial_w g_{uv} = \\)'..dg'_uvw'..'<br>')

print'let \\({{\\partial r}\\over{\\partial t}} = 0\\)<br>'
dg = dg:replace(r:diff(t), 0):simplify()
print('\\(\\partial_w g_{uv} = \\)'..dg'_uvw'..'<br>')

-- Christoffel: G_abc = 1/2 (g_ab,c + g_ac,b - g_bc,a) 
local Gamma = ((dg'_uvw' + dg'_uwv' - dg'_vwu')/2):simplify()
print'1st kind Christoffel:<br>'
print('\\(\\Gamma_{uvw} = \\)'..Gamma'_uvw'..'<br>')

-- Christoffel: G^a_bc = g^ae G_ebc
Gamma = Gamma'^u_vw'	-- change underlying storage (not necessary, but saves future calculations)
print'2nd kind Christoffel:<br>'
print('\\({\\Gamma^u}_{vw} = \\)'..Gamma'^u_vw'..'<br>')
do return end

-- Geodesic: x''^u = -G^u_vw x'^v x'^w
tensor.assign[[diffxU_$u = symmath.Variable('diffxU_$u', {t,x,y,z})]]
tensor.assign[[diff2xU_$u = -GammaULL_$u_$v_$w * diffxU_$u * diffxU_$v]]

-- Christoffel partial: G^a_bc,d
tensor.assign'GammaULLL_$a_$b_$c_$d = symmath.diff(GammaULL_$a_$b_$c, $d)'

--Riemann: R^a_bcd = G^a_bd,c - G^a_bc,d + G^a_uc G^u_bd - G^a_ud G^u_bc
tensor.assign'RULLL_$a_$b_$c_$d = GammaULLL_$a_$b_$d_$c - GammaULLL_$a_$b_$c_$d + GammaULL_$a_$u_$c * GammaULL_$u_$b_$d - GammaULL_$a_$u_$d * GammaULL_$u_$b_$c'

-- Ricci: R_ab = R^u_aub
tensor.assign'RLL_$a_$b = RULLL_$u_$a_$u_$b'

-- Gaussian curvature: R = g^ab R_ab
tensor.assign'R = gUU_$a_$b * RLL_$a_$b'

print(MathJax.footer)
