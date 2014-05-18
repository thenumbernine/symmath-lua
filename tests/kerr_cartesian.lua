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

local tensor = require 'symmath.tensor'

-- coordinates
t = symmath.Variable('t', nil, true)
x = symmath.Variable('x', nil, true)
y = symmath.Variable('y', nil, true)
z = symmath.Variable('z', nil, true)

a = symmath.Variable('a')
r = symmath.Variable('r', nil, true)
M = symmath.Variable('M')
Q = symmath.Variable('Q')

spatialCoords = {x, y, z}
coords = {t, x, y, z}
tensor.coords{coords, ijk=spatialCoords}

-- TODO make this symbolic so that it can be properly evaluated
function cond(expr, ontrue, onfalse)
	if expr then return ontrue end
	return onfalse
end

--[[
H = (r * M - Q^2 / 2) / (r^2 + a^2 * z^2 / r^2)
--]]
-- [[
H = symmath.Variable('H', nil, true)
--]]

--[[
lL_t = 1
lL_x = (r*x + a*y) / (r^2 + a^2)
lL_y = (r*y - a*x) / (r^2 + a^2)
lL_z = z / r
lStarU_t = -lL_t
lStarU_x = lL_x
lStarU_y = lL_y
lStarU_z = lL_z
--]]
-- [=[
tensor.assign[[lL_$u = symmath.Variable('lL_$u', nil, true)]]
tensor.assign[[lStarU_$u = symmath.Variable('lStarU_$u', nil, true)]]
--]=]

-- Minkowski metric
tensor.assign'etaLL_$u_$v = symmath.Constant(0)'
etaLL_t_t = -1
etaLL_x_x = 1
etaLL_y_y = 1
etaLL_z_z = 1
tensor.assign'etaUU_$u_$v = etaLL_$u_$v'

-- Kerr metric in cartesian coordinates
tensor.assign'gLL_$u_$v = etaLL_$u_$v - 2 * H * lL_$u * lL_$v'

-- metric inverse, assume diagonal
tensor.assign'gUU_$u_$v = etaUU_$u_$v - 2 * H * lStarU_$u * lStarU_$v'

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

do return end

-- Christoffel partial: G^a_bc,d
tensor.assign'connectionULLL_$a_$b_$c_$d = symmath.diff(connectionULL_$a_$b_$c, $d)'

--Riemann: R^a_bcd = G^a_bd,c - G^a_bc,d + G^a_uc G^u_bd - G^a_ud G^u_bc
tensor.assign'riemannULLL_$a_$b_$c_$d = connectionULLL_$a_$b_$d_$c - connectionULLL_$a_$b_$c_$d + connectionULL_$a_$u_$c * connectionULL_$u_$b_$d - connectionULL_$a_$u_$d * connectionULL_$u_$b_$c'

-- Ricci: R_ab = R^u_aub
tensor.assign'ricciLL_$a_$b = riemannULLL_$u_$a_$u_$b'

-- Gaussian curvature: R = g^ab R_ab
tensor.assign'gaussianCurvature = gUU_$a_$b * ricciLL_$a_$b'

