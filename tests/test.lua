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


notebook[[
-- constant simplificaiton
=asserteq(1, (Constant(1)*Constant(1)):simplify())
=asserteq(1, (Constant(1)/Constant(1)):simplify())
=asserteq(-1, (-Constant(1)/Constant(1)):simplify())	-- without the first 'simplify' we don't get the same canonical form with the unary - on the outside
=asserteq(1, (Constant(1)/(Constant(1)*Constant(1))):simplify())

x = symmath.Variable('x')
y = symmath.Variable('y')
t = symmath.Variable('t')

-- commutativity
=asserteq(x+y, y+x)
=asserteq(x*y, y*x)

-- pruning operations
=asserteq(x, (1*x):simplify())
=asserteq(0, (Constant(0)*x):simplify())
=asserteq(x, (1*x):simplify())
=asserteq((x/x):simplify(), 1)

=asserteq(x^2, (x*x):simplify())

-- simplify(): div add mul
=asserteq(((x+1)*y):simplify(), (x*y + y):simplify())
=asserteq(((x+1)*(y+1)):simplify(), (x*y + x + y + 1):simplify())
=asserteq((2/(2*x*y)):simplify(), (1/(x*y)):simplify())
=asserteq((1-(1-x)):simplify(), x)
=asserteq(((1-(1-x))/x):simplify(), 1)
	
-- factoring integers
=asserteq((Constant(2)/Constant(2)):simplify(), Constant(1))
=asserteq((Constant(2)/Constant(4)):simplify(), (Constant(1)/Constant(2)):simplify())

=asserteq(((2*x + 2*y)/2):simplify(), (x+y):simplify())
=asserteq(((-2*x + 2*y)/2):simplify(), (-x+y):simplify())

print((-1-x):simplify())
print(-(1+x):simplify())
=asserteq(-1-x, -(1+x))

=asserteq((-x)/x, -1)
=asserteq((x/(-x)), -1)
=asserteq((-x-1)/(x+1), -1) 
=asserteq((x-1)/(1-x), -1)

os.exit()

-- expand(): add div mul

-- factor(): mul add div

-- trigonometry
=asserteq((symmath.sin(x)^2+symmath.cos(x)^2):simplify(), 1)
=asserteq((y*symmath.sin(x)^2+y*symmath.cos(x)^2):simplify(), y)
=asserteq((y+y*symmath.sin(x)^2+y*symmath.cos(x)^2):simplify(), 2*y)	-- works when combining y + y * trig ident
=asserteq((1+y*symmath.sin(x)^2+y*symmath.cos(x)^2):simplify(), 1+y)	-- ... but not when combining 1 + y * trig ident (look in factor.lua)
]]
