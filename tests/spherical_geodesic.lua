#!/usr/bin/env luajit
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



local symmath = require 'symmath'
local Tensor = require 'symmath.Tensor'
symmath.tostring = require 'symmath.tostring.LaTeX'

local MathJax = require 'symmath.tostring.MathJax'
print(MathJax.header)

--this is a halfway step between pure symmath code and symmath+tensor code

local x, y, z, r, phi, theta = symmath.vars('x', 'y', 'z', 'r', '\\phi', '\\theta')

Tensor.coords{
	{variables={theta, phi}},
	{variables={x, y, z}, symbols='IJKLMN' },
}

local eta = Tensor('_IJ', {1,0,0},{0,1,0},{0,0,1})
Tensor.metric(eta, eta, 'I')
print'flat metric:<br>'
print('\\(\\eta_{IJ} = '..eta'_IJ'..'\\)<br>')
print'<br>'

local u = Tensor('^I', 
	r * symmath.sin(theta) * symmath.cos(phi),
	r * symmath.sin(theta) * symmath.sin(phi),
	r * symmath.cos(theta))
print'coordinate chart:<br>'
print('\\(u^I = '..u'^I'..'\\)<br>')
print'<br>'

print('\\({{u^I}_{,u}} = '..u'^I_,u'..'\\)<br>')

local e = Tensor'_u^I'
e['_u^I'] = u'^I_,u':simplify()
print'vielbein:<br>'
print('\\({e_u}^I = '..e'_u^I'..'\\)<br>')
print'<br>'

local g = (e'_u^I' * e'_v^J' * eta'_IJ'):simplify()
print'coordinate metric:<br>'
print('\\(g_{uv} = '..g'_iu'..'\\)<br>')
print'<br>'

-- TODO factoring functions and trig identities
Tensor.metric(g)
print'coordinate metric inverse:<br>'
print('\\(g^{uv} = '..g'^uv'..'\\)<br>')

local dg = g'_uv,w':simplify()
print('\\(\\partial_w g_{uv} = '..dg'_uvw'..'\\)<br>')
print'<br>'

local Gamma = ((dg'_uvw' + dg'_uwv' - dg'_vwu')/2):simplify()
print'connection coefficients:<br>'
print('\\(\\Gamma_{uvw} = '..Gamma'_uvw'..'\\)<br>')
print'<br>'

Gamma = Gamma'^u_vw'
print('\\({\\Gamma^u}_{vw} = '..Gamma'^u_vw'..'\\)<br>')
print'<br>'

-- now comes the geodesic equation: d^2[x^i]/dt^2 = -conn^i_jk dx^j_dt dx^k/dt
local dx = Tensor('^u', symmath.var'\\dot{x}^t', symmath.var'\\dot{x}^x')
local d2x = Tensor('^u', symmath.var'\\ddot{x}^t', symmath.var'\\ddot{x}^x')
print'geodesic:<br>'
-- TODO unravel equaliy, or print individual assignments
print('\\('..((d2x'^u' + Gamma'^u_vw' * dx'^v' * dx'^w'):equals(Tensor('^u',0,0))):simplify()..'\\)<br>')
print'<br>'



--printbr(diff2xU_theta:eval{r=1, [phi.name]=0, [theta.name]=0, [diffxU_theta.name]=0, [diffxU_phi.name]=1})
--printbr(diff2xU_phi:eval{r=1, [phi.name]=0, [theta.name]=0, [diffxU_theta.name]=0, [diffxU_phi.name]=1})

print(MathJax.footer)
