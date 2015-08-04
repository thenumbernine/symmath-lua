#!/usr/bin/env luajit
--[[

    File: gravitation_16_1.lua

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

-- MTW's Gravitation ch. 16 problem 1

symmath = require 'symmath'
local Tensor = require 'symmath.Tensor'
symmath.tostring = require 'symmath.tostring.LaTeX'
print(require 'symmath.tostring.MathJax'.header)

local t, x, y, z = symmath.vars('t', 'x', 'y', 'z')
local coords = {t, x, y, z}
Tensor.coords{
	{
		variables = coords,
	},
}

local Phi = symmath.var('\\Phi', coords)
local rho = symmath.var('\\rho', coords)
local P = symmath.var('P', coords)

local delta = Tensor('_uv', {1,0,0,0}, {0,1,0,0}, {0,0,1,0}, {0,0,0,1})
print('\\(\\delta_{uv} = '..delta'_uv'..'\\)<br>')

local eta = Tensor('_uv', {-1,0,0,0}, {0,1,0,0}, {0,0,1,0}, {0,0,0,1})
print('\\(\\eta_{uv} = '..eta'_uv'..'\\)<br>')

local g = (eta'_uv' - 2 * Phi * delta'_uv'):simplify()
print('\\(g_{uv} = '..g'_uv'..'\\)<br>')
Tensor.metric(g)
print('\\(g^{uv} = '..g'^uv'..'\\)<br>')

local Gamma = ((g'_ab,c' + g'_ac,b' - g'_bc,a') / 2):simplify()
print('\\(\\Gamma_{abc} = '..Gamma'_abc'..'\\)<br>')
Gamma = Gamma'^a_bc'
print('\\({\\Gamma^a}_{bc} = '..Gamma'^a_bc'..'\\)<br>')

-- assume diagonal matrix
print[[let \(\Phi\) ~ 0, but keep \(d\Phi\)<br>]]

Gamma = symmath.replace(Gamma, Phi, symmath.Constant(0), function(v) return v:isa(symmath.Derivative) end)
print('\\({\\Gamma^a}_{bc} = '..Gamma'^a_bc'..'\\)<br>')

local u = Tensor('^a',
	symmath.var('u^t', coords),
	symmath.var('u^x', coords),
	symmath.var('u^y', coords),
	symmath.var('u^z', coords))
print('\\(u^a = '..u'^a'..'\\)<br>')

local T = ((rho * P) * u'^a' * u'^b'):simplify()
print'matter stress-energy tensor<br>'
print('\\(T^{ab} = '..T'^ab'..'\\)<br>')

print'low velocity relativistic approximation<br>'
local v = Tensor('^a',
	1,
	symmath.var('v^x', coords),
	symmath.var('v^y', coords),
	symmath.var('v^z', coords))
print('\\(v^a = '..v'^a'..'\\)<br>')
T = ((rho * P) * v'_a' * v'_b'):simplify()
print('\\(T^{ab} = '..T'^ab'..'\\)<br>')

print'matter constraint<br>'

local C = (T'^uv_,v' + Gamma'^u_av' * T'^av' + Gamma'^v_av' * T'^ua'):simplify()
print('\\(C^u = '..C'^u'..'\\)<br>')

print(require 'symmath.tostring.MathJax'.footer)
