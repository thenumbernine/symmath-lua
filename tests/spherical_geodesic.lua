--[[

    File: polar_geodesic.lua 

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



local tensor = require 'symmath.tensor'

--this is a halfway step between pure symmath code and symmath+tensor code

x = symmath.Variable('x')
y = symmath.Variable('y')
r = symmath.Variable('r')
phi = symmath.Variable('phi')
theta = symmath.Variable('theta')
srcCoords = {x, y, z}
coords = {theta, phi}

tensor.coords{coords, abcdefg=srcCoords}

-- TODO make this symbolic so that it can be properly evaluated
function cond(expr, ontrue, onfalse)
	if expr then return ontrue end
	return onfalse
end

metric_x = r * symmath.sin(theta) * symmath.cos(phi)
metric_y = r * symmath.sin(theta) * symmath.sin(phi)
metric_z = r * symmath.cos(theta)
print('metric_x =',metric_x)
print('metric_y =',metric_y)
print('metric_z =',metric_z)

eLU_theta_x = symmath.simplify(symmath.diff(metric_x, theta))
eLU_theta_y = symmath.simplify(symmath.diff(metric_y, theta))
eLU_theta_z = symmath.simplify(symmath.diff(metric_z, theta))
eLU_phi_x = symmath.simplify(symmath.diff(metric_x, phi))
eLU_phi_y = symmath.simplify(symmath.diff(metric_y, phi))
eLU_phi_z = symmath.simplify(symmath.diff(metric_z, phi))
print('eLU_theta_x =',eLU_theta_x)
print('eLU_theta_y =',eLU_theta_y)
print('eLU_theta_z =',eLU_theta_z)
print('eLU_phi_x =',eLU_phi_x)
print('eLU_phi_y =',eLU_phi_y)
print('eLU_phi_z =',eLU_phi_z)

-- next issue with simplification: factoring terms out of some but not all of the addition expressions
gLL_theta_theta = symmath.simplify(eLU_theta_x * eLU_theta_x + eLU_theta_y * eLU_theta_y + eLU_theta_z * eLU_theta_z)
gLL_theta_phi = symmath.simplify(eLU_theta_x * eLU_phi_x + eLU_theta_y * eLU_phi_y + eLU_theta_z * eLU_phi_z)
gLL_phi_theta = symmath.simplify(eLU_phi_x * eLU_theta_x + eLU_phi_y * eLU_theta_y + eLU_phi_z * eLU_theta_z)
gLL_phi_phi = symmath.simplify(eLU_phi_x * eLU_phi_x + eLU_phi_y * eLU_phi_y + eLU_phi_z * eLU_phi_z)
print('gLL_theta_theta =',gLL_theta_theta)
print('gLL_theta_phi =',gLL_theta_phi)
print('gLL_phi_theta =',gLL_phi_theta)
print('gLL_phi_phi =',gLL_phi_phi)

-- assume diagonal 
-- TODO factoring functions and trig identities
tensor.assign[[gUU_$u_$v = symmath.simplify(cond($u==$v, 1/gLL_$u_$v, symmath.Constant(0)))]]
tensor.assign[[gLLL_$u_$v_$w = symmath.simplify(symmath.diff(gLL_$u_$v, $w))]]
tensor.assign[[connectionLLL_$u_$v_$w = symmath.simplify((1/2) * (gLLL_$u_$v_$w + gLLL_$u_$w_$v - gLLL_$v_$w_$u))]]
tensor.assign[[connectionULL_$u_$v_$w = gUU_$u_$r * connectionLLL_$r_$v_$w]]

-- now comes the geodesic equation: d^2[x^i]/dt^2 = -conn^i_jk dx^j_dt dx^k/dt
tensor.assign[[diffxU_$u = symmath.Variable('diffxU_$u', nil, true)]]
tensor.assign[[diff2xU_$u = -connectionULL_$u_$v_$w * diffxU_$u * diffxU_$v]]

print(symmath.evaluate(diff2xU_r, {r=1, phi=0, diffxU_r=0, diffxU_phi=1}))
print(symmath.evaluate(diff2xU_phi, {r=1, phi=0, diffxU_r=0, diffxU_phi=1}))

