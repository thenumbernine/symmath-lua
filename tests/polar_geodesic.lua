#!/usr/bin/env luajit
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

local symmath = require 'symmath'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
print(MathJax.header)

local function printbr(...) print(...) print'<br>' end

local Tensor = symmath.Tensor
local var = symmath.var
local vars = symmath.vars

local x,y,r,phi = vars('x','y','r','\\phi')
Tensor.coords{
	{variables = {r,phi}},
	{variables = {x,y}, symbols = 'IJKLMN', metric = {{1,0},{0,1}} }
}

local eta = Tensor('_IJ', {1,0}, {0,1})
printbr'flat metric:'
printbr(var'\\eta''_IJ':eq(eta'_IJ'()))
printbr()

local u = Tensor('^I', r * symmath.cos(phi), r * symmath.sin(phi))
printbr'coordinate chart:'
printbr(var'u''^I':eq(u'^I'()))
printbr()

local e = Tensor'_u^I'
e['_u^I'] = u'^I_,u'()
printbr'vielbein:'
printbr(var'e''_u^I':eq(var'u''^I_,u'):eq(u'^I_,u'()):eq(e'_u^I'()))
printbr()

local g = (e'_u^I' * e'_v^J' * eta'_IJ')()
g = g:replace(symmath.cos(phi)^2, 1-symmath.sin(phi)^2)()		-- TODO somehow automatically do this ...
printbr'coordinate metric:'
printbr(var'g''_uv':eq(var'e''_u^I' * var'e''_v^J' * var'\\eta''_IJ'):eq(g'_uv'()))
printbr()
Tensor.metric(g)

local Gamma = ((g'_ab,c' + g'_ac,b' - g'_bc,a') / 2)()
printbr'connection:'
printbr(var'\\Gamma''_abc':eq(Gamma'_abc'()))
printbr(var'\\Gamma''^a_bc':eq(Gamma'^a_bc'()))
printbr()

local dx = Tensor('^u', var'\\dot{r}', var'\\dot{\\phi}')
local d2x = Tensor('^u', var'\\ddot{r}', var'\\ddot{\\phi}')
printbr'geodesic:'
-- TODO unravel equaliy, or print individual assignments
printbr(((d2x'^a' + Gamma'^a_bc' * dx'^b' * dx'^c'):eq(Tensor('^u',0,0)))())
printbr()

print(MathJax.footer)
