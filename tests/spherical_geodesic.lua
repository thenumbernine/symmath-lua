#!/usr/bin/env luajit
--[[

    File: polar_geodesic.lua 

    Copyright (C) 2000-2016 Christopher Moore (christopher.e.moore@gmail.com)
	  
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
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax 
print(MathJax.header)

local function printbr(...) print(...) print'<br>' end

local Tensor = symmath.Tensor
local vars = symmath.vars
local var = symmath.var

--this is a halfway step between pure symmath code and symmath+tensor code

local x,y,z,r,phi,theta = vars('x','y','z','r','\\phi','\\theta')

local flatCoords = {x,y,z}
local curvedCoords = {theta, phi}

local curvedSpace = {variables=flatCoords, symbols='IJKLMN' }
local flatSpace = {variables=curvedCoords}

Tensor.coords{flatSpace, curvedSpace}

local eta = Tensor('_IJ', {1,0,0},{0,1,0},{0,0,1})
Tensor.metric(eta, eta, 'I')

printbr'flat metric:'
printbr(var'\\eta''_IJ':eq(eta'_IJ'()))
printbr()

local u = Tensor('^I', 
	r * symmath.sin(theta) * symmath.cos(phi),
	r * symmath.sin(theta) * symmath.sin(phi),
	r * symmath.cos(theta))
printbr'coordinate chart:'
printbr(var'u''^I':eq(u'^I'()))
printbr()

printbr(var'u''^I_,u':eq(u'^I_,u'()))

local e = Tensor'_u^I'
e['_u^I'] = u'^I_,u'()
printbr'vielbein:'
printbr(var'e''_u^I':eq(e'_u^I'()))
printbr()

local g = (e'_u^I' * e'_v^J' * eta'_IJ')()
printbr'coordinate metric:'
g = g:replace(symmath.cos(phi)^2, 1-symmath.sin(phi)^2)()
g = g:replace(symmath.cos(theta)^2, 1-symmath.sin(theta)^2)()
printbr(var'g''_uv':eq(g'_uv'()))
printbr()

-- TODO factoring functions and trig identities
Tensor.metric(g)
printbr'coordinate metric inverse:'
printbr(var'g''^uv':eq(g'^uv'()))

local dg = g'_uv,w'()
printbr(var'g''_uv,w':eq(dg'_uvw'()))
printbr()

local Gamma = ((dg'_uvw' + dg'_uwv' - dg'_vwu')/2)()
printbr'connection coefficients:'
printbr(var'\\Gamma''_uvw':eq(Gamma'_uvw'()))
printbr()

Gamma = Gamma'^u_vw'()
printbr(var'\\Gamma''^u_vw':eq(Gamma'^u_vw'()))
printbr()

-- now comes the geodesic equation: d^2[x^i]/dt^2 = -conn^i_jk dx^j_dt dx^k/dt
local dx = Tensor('^u', function(u) return var('\\dot{'..curvedCoords[u].name..'}') end)
local d2x = Tensor('^u', function(u) return var('\\ddot{'..curvedCoords[u].name..'}') end)
printbr'geodesic:'
-- TODO unravel equaliy, or print individual assignments
printbr(((d2x'^u' + Gamma'^u_vw' * dx'^v' * dx'^w'):eq(Tensor('^u',0,0)))())
printbr()

print(MathJax.footer)
