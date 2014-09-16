--[[

    File: polar_geodesic.lua 

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


symmath = require 'symmath'
local tensor = require 'symmath.tensor'

--this is a halfway step between pure symmath code and symmath+tensor code

x = symmath.Variable('x')
y = symmath.Variable('y')
r = symmath.Variable('r')
phi = symmath.Variable('\\phi')
srcCoords = {x, y}
coords = {r, phi}

tensor.coords{coords, abcdefg=srcCoords}

-- TODO make this symbolic so that it can be properly evaluated
function cond(expr, ontrue, onfalse)
	if expr then return ontrue end
	return onfalse
end

tensor.assign[[metric_x = r * symmath.cos(phi)]]
tensor.assign[[metric_y = r * symmath.sin(phi)]]
tensor.assign[[eLU_$u_$a = symmath.simplify(symmath.diff(metric_$a, $u))]]
tensor.assign[[gLL_$u_$v = eLU_$u_$a * eLU_$v_$a]]
-- assume diagonal 
-- TODO factoring functions and trig identities
tensor.assign[[gUU_$u_$v = symmath.simplify(cond($u==$v, 1/gLL_$u_$v, symmath.Constant(0)))]]
tensor.assign[[gLLL_$u_$v_$w = symmath.simplify(symmath.diff(gLL_$u_$v, $w))]]
tensor.assign[[GammaLLL_$u_$v_$w = symmath.simplify((1/2) * (gLLL_$u_$v_$w + gLLL_$u_$w_$v - gLLL_$v_$w_$u))]]
tensor.assign[[GammaULL_$u_$v_$w = gUU_$u_$r * GammaLLL_$r_$v_$w]]

-- now comes the geodesic equation: d^2[x^i]/dt^2 = -conn^i_jk dx^j_dt dx^k/dt
tensor.assign[[diffxU_$u = symmath.Variable('{dx^{$u}}\\over{d\\tau}', nil, true)]]
tensor.assign[[diff2xU_$u = -GammaULL_$u_$v_$w * diffxU_$u * diffxU_$v]]

printbr(symmath.evaluate(diff2xU_r, {r=1, [phi.name]=0, [diffxU_r.name]=0, [diffxU_phi.name]=1}))
printbr(symmath.evaluate(diff2xU_phi, {r=1, [phi.name]=0, [diffxU_r.name]=0, [diffxU_phi.name]=1}))

