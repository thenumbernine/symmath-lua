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

symmath = require 'symmath'
require 'symmath.notebook'
Constant = require 'symmath.Constant'
simplify = require 'symmath.simplify'

--symmath.toStringMethod = require 'symmath.tostring.Verbose'
symmath.toStringMethod = require 'symmath.tostring.SingleLine'

notebook[[
=asserteq(Constant(1), simplify(Constant(1)*Constant(1)))
=asserteq(Constant(1), simplify(Constant(1)/Constant(1)))
=asserteq(Constant(-1), simplify(-Constant(1)/Constant(1)))
=asserteq(Constant(1), simplify(Constant(1)/(Constant(1)*Constant(1))))

x = symmath.Variable('x', nil, true)
y = symmath.Variable('y', nil, true)
t = symmath.Variable('t', nil, true)

-- commutativity
=asserteq(x+y, y+x)
=asserteq(x*y, y*x)

-- simplify rationals
=asserteq(symmath.simplify(x/x), Constant(1))

-- differentiation
expr = simplify(-1 - 2 * x * y^2)
=expr
=symmath.diff(expr, t)
=symmath.simplify(symmath.diff(expr, t))
]]
