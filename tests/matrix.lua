#!/usr/bin/env luajit
--[[

    File: matrix.lua

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
symmath = require 'symmath'
require 'symmath.notebook'
Matrix = require 'symmath.Matrix'
Tensor = require 'symmath.Tensor'

-- test

function printbr(...)
	print(...)
	print('<br>')
end

notebook[[

-- vectors
=Tensor(1,2,3)

=Tensor(1,2) + Tensor(3,4)
=(Tensor(1,2) + Tensor(3,4)):simplify()

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
mInv = mInv:replace(symmath.sin(theta)^2, 1-symmath.cos(theta)^2):simplify()	-- almost there ... still have to trig simplify this ...

=m + mInv
=(m + mInv):simplify()
=m * mInv
=(m * mInv):simplify()
=m*m
=(m*m):simplify()

m1 = symmath.Matrix({1,a},{0,1})
m2 = symmath.Matrix({1,0},{b,1})
=(m1)
=(m2)
=(m1*m2):equals((m1*m2):simplify())
=(m2*m1):equals((m2*m1):simplify())
=m1:equals(m2)
=m1==m2
=(m1*m2):equals(m2*m1)
=m1*m2==m2*m1
=(m1*m2):equals(m1*m2)
=m1*m2==m1*m2
=(m1*m2):equals(m2*m1):simplify()
=(m1*m2):simplify()==(m2*m1):simplify()

t = var't'
=(Matrix({a},{b}) + Matrix({c},{d})) / t
=((Matrix({a},{b}) + Matrix({c},{d})) / t):simplify()

-- linear system solver

=Matrix({1,2},{3,4}):inverse(Matrix({5},{6}))
=(Matrix({1,2},{3,4})*Matrix({1,2},{3,4}):inverse(Matrix({5},{6}))):simplify()
]]

