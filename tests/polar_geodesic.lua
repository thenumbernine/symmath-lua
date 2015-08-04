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


symmath = require 'symmath'
local Tensor = require 'symmath.Tensor'
local tensorhelp = require 'symmath.tensorhelp'

x, y, r, phi = symmath.vars('x', 'y', 'r', '\\phi')
Tensor.coords{
	{
		variables = {r, phi},
	},
	{
		symbols = 'IJKLMN',
		variables = {x, y},
		metric = {{1,0}, {0,1}},
	}
}

tensorhelp.coords{{r, phi}, abcdefg={x, y}}

-- TODO make this symbolic so that it can be properly evaluated
function cond(expr, ontrue, onfalse)
	if expr then return ontrue end
	return onfalse
end

local function printbr(...)
	print(...)
	print'<br>'
end

local function printmath(...)
	print([[\(]] .. table{...}:map(tostring):concat'\t' .. [[\)<br>]])
end

local eta = Tensor('_IJ', {1,0}, {0,1})
printbr'eta:'
printmath([[\eta_{IJ} = ]]..eta'_IJ')
printbr()

local u = Tensor('^I', r * symmath.cos(phi), r * symmath.sin(phi))
printbr'coordinate chart:'
printmath('u^I = '..u'^I')
printbr()

local e = Tensor('_u^I')
e['_u^I'] = u'^I_,u':simplify()		-- use assignment to correctly arrange indexes. TODO have a ctor to do this?
printbr'vielbein:'
printmath([[{e_u}^I = \partial_u u^I = ]]..u'^I_,u'..' = '..e'_u^I')
printbr()

local g = (e'_u^I' * e'_v^J' * eta'_IJ'):simplify()
printbr'metric:'
printmath([[g_{uv} = {e_u}^I {e_v}^J \eta_{IJ} = ]]..g'_uv')
printbr()
Tensor.metric(g)

local Gamma = ((g'_ab,c' + g'_ac,b' - g'_bc,a') / 2):simplify()
printbr'connection:'
printmath([[\Gamma_{abc} = ]]..Gamma)
printmath([[{\Gamma^a}_{bc} = ]]..Gamma'^a_bc')
printbr()

local dx = Tensor('^u', symmath.var'\\dot{x}^r', symmath.var'\\dot{x}^\\phi')
local d2x = Tensor('^u', symmath.var'\\ddot{x}^r', symmath.var'\\ddot{x}^\\phi')
printbr'geodesic:'
-- TODO unravel equaliy, or print individual assignments
printmath(((d2x'^a' + Gamma'^a_bc' * dx'^b' * dx'^c'):equals(Tensor('^u',0,0))):simplify())
printbr()
