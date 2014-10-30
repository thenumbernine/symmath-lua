#!/usr/bin/env luajit
--[[

    File: test.lua

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
require 'symmath.notebook'
Constant = require 'symmath.Constant'

symmath.toStringMethod = require 'symmath.tostring.MathJax'

notebook[[
-- constant simplificaiton
=asserteq(Constant(1), (Constant(1)*Constant(1)):simplify())
=asserteq(Constant(1), (Constant(1)/Constant(1)):simplify())
=asserteq(Constant(-1):simplify(), (-Constant(1)/Constant(1)):simplify())	-- without the first 'simplify' we don't get the same canonical form with the unary - on the outside
=asserteq(Constant(1), (Constant(1)/(Constant(1)*Constant(1))):simplify())

x = symmath.Variable('x', nil, true)
y = symmath.Variable('y', nil, true)
t = symmath.Variable('t', nil, true)

-- commutativity
=asserteq(x+y, y+x)
=asserteq(x*y, y*x)

-- pruning operations
=asserteq(x, (Constant(1)*x):simplify())
=asserteq(Constant(0), (Constant(0)*x):simplify())
=asserteq(x, (Constant(1)*x):simplify())
=asserteq((x/x):simplify(), Constant(1))

=asserteq(x^2, (x*x):simplify())

-- simplify(): div add mul
=asserteq(((x+1)*y):simplify(), x*y + y)
=asserteq(((x+1)*(y+1)):simplify(), (x*y + x + y + 1):simplify())

-- expand(): add div mul

-- factor(): mul add div


]]
