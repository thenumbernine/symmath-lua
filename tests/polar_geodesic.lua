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
local Tensor = require 'symmath.Tensor'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax

print(MathJax.header)

local x, y, r, phi = symmath.vars('x', 'y', 'r', '\\phi')
Tensor.coords{
	{ variables = {r, phi} },
	{ variables = {x, y}, symbols = 'IJKLMN', metric = {{1,0}, {0,1}} }
}

local function printbr(...)
	print(...)
	print'<br>'
end

local eta = Tensor('_IJ', {1,0}, {0,1})
printbr'flat metric:'
printbr([[$\eta_{IJ} = $]]..eta'_IJ')
printbr()

local u = Tensor('^I', r * symmath.cos(phi), r * symmath.sin(phi))
printbr'coordinate chart:'
printbr([[$u^I = $]]..u'^I')
printbr()

local e = Tensor'_u^I'
e['_u^I'] = u'^I_,u':simplify()		-- use assignment to correctly arrange indexes. TODO have a ctor to do this?
printbr'vielbein:'
printbr([[${e_u}^I = \partial_u u^I = $]]..u'^I_,u'..[[$ = $]]..e'_u^I')
printbr()

local g = (e'_u^I' * e'_v^J' * eta'_IJ'):simplify()
printbr'coordinate metric:'
printbr([[$g_{uv} = {e_u}^I {e_v}^J \eta_{IJ} = $]]..g'_uv')
printbr()
Tensor.metric(g)

local Gamma = ((g'_ab,c' + g'_ac,b' - g'_bc,a') / 2):simplify()
printbr'connection:'
printbr([[$\Gamma_{abc} = $]]..Gamma)
printbr([[${\Gamma^a}_{bc} = $]]..Gamma'^a_bc')
printbr()

local dx = Tensor('^u', symmath.var'\\dot{r}', symmath.var'\\dot{\\phi}')
local d2x = Tensor('^u', symmath.var'\\ddot{r}', symmath.var'\\ddot{\\phi}')
printbr'geodesic:'
-- TODO unravel equaliy, or print individual assignments
printbr(((d2x'^a' + Gamma'^a_bc' * dx'^b' * dx'^c'):equals(Tensor('^u',0,0))):simplify())
printbr()

print(MathJax.footer)
