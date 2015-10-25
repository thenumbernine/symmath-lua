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

local function printbr(...)
	print(...)
	print'<br>'
end

--this is a halfway step between pure symmath code and symmath+tensor code

local x, y, z, r, phi, theta = symmath.vars('x', 'y', 'z', 'r', '\\phi', '\\theta')

local flatCoords = {x,y,z}
local curvedCoords = {theta, phi}

local curvedSpace = {variables=flatCoords, symbols='IJKLMN' }
local flatSpace = {variables=curvedCoords}

Tensor.coords{flatSpace, curvedSpace}

local eta = Tensor('_IJ', {1,0,0},{0,1,0},{0,0,1})
Tensor.metric(eta, eta, 'I')

printbr'flat metric:'
printbr('\\(\\eta_{IJ} = '..eta'_IJ'..'\\)')
printbr()

local u = Tensor('^I', 
	r * symmath.sin(theta) * symmath.cos(phi),
	r * symmath.sin(theta) * symmath.sin(phi),
	r * symmath.cos(theta))
printbr'coordinate chart:'
printbr('\\(u^I = '..u'^I'..'\\)')
printbr()

printbr('\\({{u^I}_{,u}} = '..u'^I_,u'..'\\)')

local e = Tensor'_u^I'
e['_u^I'] = u'^I_,u':simplify()
printbr'vielbein:'
printbr('\\({e_u}^I = '..e'_u^I'..'\\)')
printbr()

local g = (e'_u^I' * e'_v^J' * eta'_IJ'):simplify()
printbr'coordinate metric:'
printbr('\\(g_{uv} = '..g'_uv'..'\\)')
printbr()

-- TODO factoring functions and trig identities
Tensor.metric(g)
printbr'coordinate metric inverse:'
printbr('\\(g^{uv} = '..g'^uv'..'\\)')

local dg = g'_uv,w':simplify()
printbr('\\(\\partial_w g_{uv} = '..dg'_uvw'..'\\)')
printbr()

local Gamma = ((dg'_uvw' + dg'_uwv' - dg'_vwu')/2):simplify()
printbr'connection coefficients:'
printbr('\\(\\Gamma_{uvw} = '..Gamma'_uvw'..'\\)')
printbr()

Gamma = Gamma'^u_vw'
printbr('\\({\\Gamma^u}_{vw} = '..Gamma'^u_vw'..'\\)')
printbr()

-- now comes the geodesic equation: d^2[x^i]/dt^2 = -conn^i_jk dx^j_dt dx^k/dt
local dx = Tensor('^u', function(u) return symmath.var('\\dot{'..curvedCoords[u].name..'}') end)
local d2x = Tensor('^u', function(u) return symmath.var('\\ddot{'..curvedCoords[u].name..'}') end)
printbr'geodesic:'
-- TODO unravel equaliy, or print individual assignments
printbr('\\('..((d2x'^u' + Gamma'^u_vw' * dx'^v' * dx'^w'):equals(Tensor('^u',0,0))):simplify()..'\\)')
printbr()

print(MathJax.footer)
