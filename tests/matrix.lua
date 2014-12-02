#!/usr/bin/env luajit
--[[

    File: matrix_inverse.lua

    Copyright (C) 2014 Christopher Moore (christopher.e.moore@gmail.com)
	  
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


require 'ext'
local symmath = require 'symmath'
local Matrix = require 'symmath.Matrix'
local RowVector = require 'symmath.RowVector'
local var = symmath.var
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax

-- test

print(MathJax.header)

local function printbr(...)
	print(...)
	print('<br>')
end


printbr('vectors')
local v = RowVector(1,2,3)
printbr(v)

printbr(RowVector(1,2) + RowVector(3,4))
printbr((RowVector(1,2) + RowVector(3,4)):simplify())

printbr('numeric example:')

local m = Matrix({1,2},{3,4})
printbr('\\(m =\\) '..m)
printbr('\\( m^{-1} = \\)'..symmath.inverse(m))

local a = var'a'
local b = var'b'
local c = var'c'
local d = var'd'
local m = Matrix({a,b},{c,d})

printbr('2D variable example:')

printbr('\\(m =\\) '..m)
--printbr('m[1,2] = '..m[1][2])
printbr('\\( m^{-1} = \\) '..symmath.inverse(m):simplify())

printbr('4D translation matrix:')

local m = Matrix(
{1,0,0,var't_x'},
{0,1,0,var't_y'},
{0,0,1,var't_z'},
{0,0,0,1})
printbr('\\(m =\\) '..m)
printbr('\\( m^{-1} = \\) '..symmath.inverse(m))

printbr('2D rotation matrix:')
local theta = var'\\theta'
local m = Matrix({symmath.cos(theta), -symmath.sin(theta)}, {symmath.sin(theta), symmath.cos(theta)})
printbr('\\(m =\\) '..m)
local mInv = symmath.inverse(m)
mInv = mInv:replace(symmath.sin(theta)^2, 1-symmath.cos(theta)^2):simplify()	-- almost there ... still have to trig simplify this ...
printbr('\\(m^{-1} = \\)'..mInv)

printbr(m + mInv)
printbr((m + mInv):simplify())
printbr(m * mInv)
printbr((m * mInv):simplify())

print(MathJax.footer)

