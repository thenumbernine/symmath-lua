#!/usr/bin/env luajit
--[[

    File: metric.lua

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
local MathJax = require 'symmath.tostring.MathJax'
--symmath.tostring = MathJax

function printbr(...)
	print(...)
	print('<br>')
end

print(MathJax.header)

--[[
g_ab =	[ g_uv + phi^2 A_u A_v	phi^2 A^u	 ]
		[	phi^2 A_v			phi^2		 ]
g^ab =	[ 	g^uv				-A^u		 ]
		[	-A^v				A^2 + phi^-2 ]
--]]

t = symmath.Variable('t')
x = symmath.Variable('x')
y = symmath.Variable('y')
z = symmath.Variable('z')
w = symmath.Variable('w')	-- x^5, or the A^mu vector combined with the phi^2 ...
phi = symmath.Variable('\\phi', {t,x,y,z,w})

-- symmath.tensor isn't set up to handle _5 ... since it uses tostring() for concat'ing variable names 
-- ... yet also uses tostring() for referencing the variable itself ...
tensor.coords{{t,x,y,z}, abcdef={t,x,y,z,w}}

-- 4D metric tensor
-- keeping it 4D at the moment
-- if one were so inclined they might insert the adm 3+1 metric here ...
printbr('4D metric tensor')
tensor.assign[[gLL_$u_$v = symmath.Variable('g_{{$u}{$v}}', {t,x,y,z,w})]]
printbr('4D metric tensor inverse')
tensor.assign[[gUU_$u_$v = symmath.Variable('g^{{$u}{$v}}', {t,x,y,z,w})]]

-- EM potential 4-vector
printbr('EM potential vector')
tensor.assign[[AL_$u = symmath.Variable('A_{$u}', {t,x,y,z,w})]]
tensor.assign[[AU_$u = symmath.Variable('A^{$u}', {t,x,y,z,w})]]
A = symmath.Variable('A', {t,x,y,z,w})	-- helper for representing A^2 = A^u A_u

-- 5D metric tensor
printbr('5D metric tensor')
tensor.assign[[g5LL_$u_$v = gLL_$u_$v + phi^2 * AL_$u * AL_$v]]
tensor.assign[[g5LL_$u_w = phi^2 * AL_$u]]
tensor.assign[[g5LL_w_$v = phi^2 * AL_$v]]
tensor.assign[[g5LL_w_w = phi^2]]

printbr('5D metric tensor inverse')
tensor.assign[[g5UU_$u_$v = gUU_$u_$v]]
tensor.assign[[g5UU_$u_w = -AU_$u]]
tensor.assign[[g5UU_w_$v = -AU_$v]]
tensor.assign[[g5UU_w_w = A^2 + phi^-2]]

--[=[ keep track of the equality
printbr('5D metric partial derivatives')
tensor.assign[[g5LLL_$a_$b_$c = g5LL_$a_$b:diff($c)]]
printbr('cylindrical constraint')
tensor.assign[[g5cylilnderLL_$a_$b = g5LLL_$a_$b_w:equals(0)]]
--]=]
-- [=[  just zero (no chance of substituting out like expressions for zero later on)
printbr('5D metric partial derivatives')
tensor.assign[[g5LLL_$a_$b_$u = g5LL_$a_$b:diff($c)]]
tensor.assign[[g5LLL_$a_$b_w = symmath.Constant(0)]]
--]=]

-- 1st kind connection coefficients
tensor.assign[[Gamma5LLL_$u_$v_$w = symmath.simplify((1/2) * (g5LLL_$u_$v_$w + g5LLL_$u_$w_$v - g5LLL_$v_$w_$u))]]

-- 2nd kind
tensor.assign[[Gamma5ULL_$u_$v_$w = g5UU_$u_$r * Gamma5LLL_$r_$v_$w]]

