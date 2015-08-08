#!/usr/bin/env luajit
--[[

    File: flrw.lua

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
flrw in spherical form: -dt^2 + a^2 (dr^2 / (1 - k r^2) + r^2 (dtheta^2 + sin(theta)^2 dphi^2)
--]]

symmath = require 'symmath'
symmath.tostring = require 'symmath.tostring.LaTeX'
local MathJax = require 'symmath.tostring.MathJax'
local Tensor = require 'symmath.Tensor'

print(MathJax.header)

-- coordinates
local t, r, theta, phi = symmath.vars('t', 'r', '\\theta', '\\phi')

Tensor.coords{
	{
		variables = {t, r, theta, phi},
	}
}

-- metric variables
local a = symmath.var('a', {t})		-- radius of curvature
local k = symmath.var'k'			-- constant: +1, 0, -1

-- EFE variables
local rho = symmath.var'\\rho'
local p = symmath.var'p'
local Lambda = symmath.var'\\Lambda'

-- constants
local pi = symmath.var'\\pi'

local function printbr(...)
	print(...)
	print('<br>')
end
local function printmath(...)
	print'\\('
	printbr(...)
	print'\\)<br>'
end

-- schwarzschild metric in cartesian coordinates

-- start with zero
local g = Tensor('_uv', unpack(symmath.Matrix.diagonal(
	-1, a^2 / (1 - k * r^2), a^2 * r^2, a^2 * r^2 * symmath.sin(theta)^2
)))
printbr('metric:')
printmath([[g_{uv} = ]]..g'_uv')

Tensor.metric(g)

-- metric inverse, assume diagonal
printbr'metric inverse:'
printmath([[g^{uv} = ]]..g'^uv')

-- connections of 1st kind
local Gamma = ((g'_ab,c' + g'_ac,b' - g'_bc,a') / 2):simplify()
printbr'1st kind Christoffel:'
printmath([[\Gamma_{abc} = ]]..Gamma'_abc')
printbr()

-- connections of 2nd kind
printbr'2nd kind Christoffel:'
printmath([[{\Gamma^a}_{bc} = ]]..Gamma'^a_bc')
printbr()

local dx = Tensor('^a',
	symmath.var'\\dot{x}^t',
	symmath.var'\\dot{x}^x',
	symmath.var'\\dot{x}^y',
	symmath.var'\\dot{x}^z')
local d2x = Tensor('^a',
	symmath.var'\\ddot{x}^t',
	symmath.var'\\ddot{x}^x',
	symmath.var'\\ddot{x}^y',
	symmath.var'\\ddot{x}^z')
printbr'geodesic:'
-- TODO unravel equaliy, or print individual assignments
printmath(((d2x'^a' + Gamma'^a_bc' * dx'^b' * dx'^c'):equals(Tensor('^a',0,0,0,0))):simplify())
printbr()

local Riemann = (Gamma'^a_bd,c' - Gamma'^a_bc,d' + Gamma'^a_uc' * Gamma'^u_bd' - Gamma'^a_ud' * Gamma'^u_bc'):simplify()
printbr'Riemann curvature tensor:'
-- TODO trig simplification
Riemann = symmath.map(Riemann, function(x)
	if x == symmath.cos(theta)^2 then return 1 - symmath.sin(theta)^2 end
end):simplify()
-- also TODO the other thing that doesn't appear to work is factoring out negatives of the denominator for simplification 
printmath([[{R^a}_{bcd} = ]]..Riemann'^a_bcd')

local Ricci = Riemann'^c_acd':simplify()
printbr'Ricci curvature tensor:'
printmath([[R_{ab} = ]]..Ricci'_ab')

printbr('Gaussian curvature')
local Gaussian = Ricci'^a_a':simplify()
printmath([[R = ]]..Gaussian)
printbr()

-- matter stress-energy tensor
printbr'matter stress-energy tensor:'
local u = Tensor('^a', 1,0,0,0)
printmath([[u^a = ]]..u)

local T = (g'_ab' * p + u'_a' * u'_b' * (rho + p)):simplify()
printmath([[T_{ab} = ]]..T'_ab')
printbr()

-- Einstein field equations
printbr('Einstein field equations')
-- G_uv + Lambda g_uv = 8 pi T_mu
-- R_uv + g_uv (Lambda - 1/2 R) = 8 pi T_uv
--[[
T_uv = (rho + p) u_u u_v + p g_uv
u is normalized <> u_u u_v g^uv = -1
g^uv = diag(-1, 1, 1/r^2 1/(r^2 sin(theta)^2) )

let u be purely timelike: u_u = [1,0,0,0]
u_t^2 g^tt = -1 <=> -u_t^2 = -1 <=> u_t = 1

T_uv = 
[rho + p 0 0 0 ]     [-1  0     0             0           ]
[      0 0 0 0 ]     [ 0 a^2    0             0           ]
[      0 0 0 0 ] + p [ 0  0  a^2 r^2          0           ]
[      0 0 0 0 ]     [ 0  0     0    a^2 r^2 sin(theta)^2 ]
=
[rho  0       0             0             ]
[ 0  p a^2    0             0             ]
[ 0  0   p a^2 r^2          0             ]
[ 0  0       0     p a^2 r^2 sin(theta)^2 ]
--]]
local lhs = (Ricci'_ab' + g'_ab' * Gaussian / 2):simplify()
local rhs = (8 * pi * T'_ab'):simplify()
for i=1,4 do
	for j=1,4 do
		local lhs_ij = lhs{i,j}
		local rhs_ij = rhs{i,j}
		local Constant = require 'symmath.Constant'
		if lhs_ij ~= Constant(0)
		or rhs_ij ~= Constant(0)
		then
			printmath(lhs_ij..' = '..rhs_ij)
		end
	end
end

print(MathJax.footer)
