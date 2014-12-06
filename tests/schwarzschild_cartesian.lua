#!/usr/bin/env luajit
--[[

    File: schwarzschild_cartesian.lua

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

my incorrect guess of how this converts to Cartesian.

TODO: The correct substitution method is:
	dr = (x dx + y dy + z dy) / r
	dtheta = (xz dx + yz dy - (x^2 + y^2) dz) / (r^2 sqrt(x^2 + y^2))
	dphi = (-y dx + x dy) / (x^2 + y^2)
--]]

symmath = require 'symmath'
local tensor = require 'symmath.tensorhelp'

-- coordinates
t = symmath.Variable('t')
x = symmath.Variable('x')
y = symmath.Variable('y')
z = symmath.Variable('z')
M = symmath.Variable('M')

-- algebraic
--r = (x^2 + y^2 + z^2)^.5
-- deferred:
r = symmath.Variable('r', {t,x,y,z})

spatialCoords = {x, y, z}
coords = {t, x, y, z}
tensor.coords{coords, ijk=spatialCoords}

-- TODO make this symbolic so that it can be properly evaluated
function cond(expr, ontrue, onfalse)
	if expr then return ontrue end
	return onfalse
end

-- schwarzschild metric in cartesian coordinates

	-- start with zero
tensor.assign'gLL_$u_$v = symmath.Constant(0)'
	
-- assign diagonals
-- atm canonical form isnt so good, so dont simplify metric and inverse
gLL_t_t =  -(1-2*M/r)
gLL_x_x = 1/(1-2*M/r)
gLL_y_y = 1/(1-2*M/r)
gLL_z_z = 1/(1-2*M/r)

-- metric inverse, assume diagonal
tensor.assign'gUU_$u_$v = symmath.Constant(0)'
gUU_t_t =  -1/(1-2*M/r)
gUU_x_x = 1-2*M/r
gUU_y_y = 1-2*M/r
gUU_z_z = 1-2*M/r

-- metric partial
-- assume dr/dt is zero
tensor.assign[[gLLL_$u_$v_$w = symmath.simplify(symmath.diff(gLL_$u_$v, $w))]]
tensor.assign[[gLLL_$u_$v_$w = symmath.replace(gLLL_$u_$v_$w, symmath.Derivative(r, t), symmath.Constant(0))]]

-- Christoffel: G_abc = 1/2 (g_ab,c + g_ac,b - g_bc,a) 
tensor.assign[[GammaLLL_$u_$v_$w = symmath.simplify((1/2) * (gLLL_$u_$v_$w + gLLL_$u_$w_$v - gLLL_$v_$w_$u))]]

-- Christoffel: G^a_bc = g^ae G_ebc
tensor.assign[[GammaULL_$u_$v_$w = gUU_$u_$r * GammaLLL_$r_$v_$w]]

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

