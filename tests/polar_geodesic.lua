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

local t,x,y = vars('t','x','y')
local r,phi = vars('r','\\phi')

for _,info in ipairs{
	{
		title = 'Polar',
		coords = {r,phi},
		basis = {x,y},
		flatMetric = {{1,0},{0,1}},
		chart = function() 
			return Tensor('^I', r * symmath.cos(phi), r * symmath.sin(phi))
		end,
	},
	{
		title = 'Spiral',
		coords = {r,phi},
		basis = {x,y},
		flatMetric = {{1,0},{0,1}},
		chart = function()
			return Tensor('^I',
				r * symmath.cos(phi + symmath.log(r)),
				r * symmath.sin(phi + symmath.log(r))
			)
		end,
	},
	{
		title = 'Cylindrical Spiral',
		coords = {t,r,phi},
		basis = {t,x,y},
		flatMetric = {{1,0,0},{0,1,0},{0,0,1}},
		chart = function()
			return Tensor('^I', 
				t,
				r * symmath.cos(phi + t),
				r * symmath.sin(phi + t)
			)
		end,
	},
} do
	print('<h3>'..info.title..'</h3>')

	Tensor.coords{
		{variables = info.coords},
		{variables = info.basis, symbols = 'IJKLMN', metric = info.flatMetric }
	}

	local eta = Tensor('_IJ', unpack(info.flatMetric))
	printbr'flat metric:'
	printbr(var'\\eta''_IJ':eq(eta'_IJ'()))
	printbr()

	local u = info.chart()
	printbr'coordinate chart:'
	printbr(var'u''^I':eq(u'^I'()))
	printbr()

	local e = Tensor'_u^I'
	e['_u^I'] = u'^I_,u'()
	printbr'basis:'
	printbr(var'e''_u^I':eq(var'u''^I_,u'):eq(u'^I_,u'()):eq(e'_u^I'()))
	printbr()

	local g = (e'_u^I' * e'_v^J' * eta'_IJ')()
	-- TODO automatically do this ...
	g = g:replace(symmath.cos(phi)^2, 1-symmath.sin(phi)^2)()		
	g = g:replace(symmath.cos(symmath.log(r) + phi)^2, 1-symmath.sin(symmath.log(r) + phi)^2)()		
	g = g:replace(symmath.cos(phi + t)^2, 1-symmath.sin(phi + t)^2)()		

	local props = require 'symmath.diffgeom'(g)
	printbr(var'g''_uv':eq(var'e''_u^I' * var'e''_v^J' * var'\\eta''_IJ'))
	printbr(var'\\Gamma''_abc':eq(symmath.divOp(1,2)*(var'g''_ab,c' + var'g''_ac,b' - var'g''_bc,a')))
	props:print(printbr)
	local Gamma = props.Gamma

	local dx = Tensor('^u', function(u)
		return var('\\dot{' .. info.coords[u].name .. '}')
	end)
	local d2x = Tensor('^u', function(u)
		return var('\\ddot{' .. info.coords[u].name .. '}')
	end)
	printbr'geodesic:'
	-- TODO unravel equaliy, or print individual assignments
	printbr(((d2x'^a' + Gamma'^a_bc' * dx'^b' * dx'^c'):eq(Tensor'^u'))())
	printbr()
end

print(MathJax.footer)
