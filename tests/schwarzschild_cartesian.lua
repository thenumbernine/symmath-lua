--[[

    File: schwarzschild_cartesian.lua

    Copyright (C) 2000-2013 Christopher Moore (christopher.e.moore@gmail.com)
	  
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

my guess of how this fits with cartesian:
--]]

local tensor = require 'symmath.tensor'

-- coordinates
t = symmath.Variable('t', nil, true)
x = symmath.Variable('x', nil, true)
y = symmath.Variable('y', nil, true)
z = symmath.Variable('z', nil, true)
M = symmath.Variable('M')

-- algebraic
--r = (x^2 + y^2 + z^2)^.5
-- deferred:
r = symmath.Variable('r', nil, true)

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
tensor.assign[[connectionLLL_$u_$v_$w = symmath.simplify((1/2) * (gLLL_$u_$v_$w + gLLL_$u_$w_$v - gLLL_$v_$w_$u))]]

-- Christoffel: G^a_bc = g^ae G_ebc
tensor.assign[[connectionULL_$u_$v_$w = gUU_$u_$r * connectionLLL_$r_$v_$w]]

-- Geodesic: x''^u = -G^u_vw x'^v x'^w
tensor.assign[[diffxU_$u = symmath.Variable('diffxU_$u', nil, true)]]
tensor.assign[[diff2xU_$u = -connectionULL_$u_$v_$w * diffxU_$u * diffxU_$v]]

-- Christoffel partial: G^a_bc,d
tensor.assign'connectionULLL_$a_$b_$c_$d = symmath.diff(connectionULL_$a_$b_$c, $d)'

--Riemann: R^a_bcd = G^a_bd,c - G^a_bc,d + G^a_uc G^u_bd - G^a_ud G^u_bc
tensor.assign'riemannULLL_$a_$b_$c_$d = connectionULLL_$a_$b_$d_$c - connectionULLL_$a_$b_$c_$d + connectionULL_$a_$u_$c * connectionULL_$u_$b_$d - connectionULL_$a_$u_$d * connectionULL_$u_$b_$c'

-- Ricci: R_ab = R^u_aub
tensor.assign'ricciLL_$a_$b = riemannULLL_$u_$a_$u_$b'

-- Gaussian curvature: R = g^ab R_ab
tensor.assign'gaussianCurvature = gUU_$a_$b * ricciLL_$a_$b'

