#!/usr/bin/env luajit
--[[

    File: matrix.lua

    Copyright (C) 2014-2016 Christopher Moore (christopher.e.moore@gmail.com)
	  
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
require 'symmath.notebook'	-- THIS IS THE LAST FILE THAT USES NOTEBOOK
Matrix = require 'symmath.Matrix'
Array = require 'symmath.Array'

-- test

function printbr(...)
	print(...)
	print('<br>')
end

notebook[[

-- vectors
=Array(1,2,3)

=Array(1,2) + Array(3,4)
=(Array(1,2) + Array(3,4))()

-- numeric example

=Matrix({1,2},{3,4})
=Matrix({1,2},{3,4}):inverse()

-- 2D variable example

var = symmath.var
vars = symmath.vars
a, b, c, d = vars('a','b','c','d')
=Matrix({a,b},{c,d})
=Matrix({a,b},{c,d}):inverse()

-- 4D translation matrix

=Matrix({1,0,0,var't_x'},{0,1,0,var't_y'},{0,0,1,var't_z'},{0,0,0,1})
=Matrix({1,0,0,var't_x'},{0,1,0,var't_y'},{0,0,1,var't_z'},{0,0,0,1}):inverse()

-- 2D rotation matrix

theta = var'\\theta'
m = Matrix({symmath.cos(theta), -symmath.sin(theta)}, {symmath.sin(theta), symmath.cos(theta)})
mInv = m:inverse()
mInv = mInv:replace(symmath.sin(theta)^2, 1-symmath.cos(theta)^2)()	-- almost there ... still have to trig simplify this ...

=m + mInv
=(m + mInv)()
=m * mInv
=(m * mInv)()
=m*m
=(m*m)()

m1 = symmath.Matrix({1,a},{0,1})
m2 = symmath.Matrix({1,0},{b,1})
=(m1)
=(m2)
=(m1*m2):eq((m1*m2)())
=(m2*m1):eq((m2*m1)())
=m1:eq(m2)
=m1==m2
=(m1*m2):eq(m2*m1)
=m1*m2==m2*m1
=(m1*m2):eq(m1*m2)
=m1*m2==m1*m2
=(m1*m2):eq(m2*m1)()
=(m1*m2)()==(m2*m1)()

t = var't'
=(Matrix({a},{b}) + Matrix({c},{d})) / t
=((Matrix({a},{b}) + Matrix({c},{d})) / t)()

-- linear system solver

=Matrix({1,2},{3,4}):inverse(Matrix({5},{6}))
=(Matrix({1,2},{3,4})*Matrix({1,2},{3,4}):inverse(Matrix({5},{6})))()
]]

