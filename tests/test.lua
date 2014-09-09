--[[

    File: test.lua

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
require 'symmath.notebook'

-- verify that simplification works

function assertexpreq(a,b)
	asserteq(symmath.prune(symmath.expand(a)), symmath.prune(symmath.expand(b)))
end

notebook[[
x = symmath.Variable'x'
y = symmath.Variable'y'

-- commutativity
=assertexpreq(x+y, y+x)
=assertexpreq(x*y, y*x)

-- factoring out a sum
=assertexpreq(x-x^2, x*(1-x))
=assertexpreq(x^2-x^3, x^2*(1-x))

-- adding two constant-scalars
=assertexpreq(2*x+3*x, 5*x)

-- adding two variable scalars
=assertexpreq(2*y*x+3*y, y*(2*x+3))

-- factoring out powers
=assertexpreq(x^2*y+x*y^2, x*y*(x+y))

-- division of terms
=assertexpreq(x/x^2, 1/x)
=assertexpreq(1/x, 1/x)

-- division / factoring out polynomials
=assertexpreq((x-x^2)/(x^2-x^3), 1/x)
=assertexpreq((x*(1-x))/(x^2*(1-x)), 1/x)

]]
