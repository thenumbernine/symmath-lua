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

local symmath = require 'symmath'

local print_ = print
local print = function(...) print_(...) print_'<br>' end

local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax 
print_(MathJax.header)

local Constant = symmath.Constant

local function asserteq(a,b)
	local sa = symmath.simplify(a)
	local ta = symmath.simplify.stack
	local sb = symmath.simplify(b)
	local tb = symmath.simplify.stack
	if sa ~= sb then
		print('expected '..tostring(a)..' to equal '..tostring(b))
		print('instead found '..tostring(sa)..' vs '..tostring(sb))
		print('lhs stack')
		for _,x in ipairs(ta) do print(x) end
		print('rhs stack')
		for _,x in ipairs(tb) do print(x) end
	end
end

-- constant simplificaiton
asserteq(1, (Constant(1)*Constant(1))())
asserteq(1, (Constant(1)/Constant(1))())
asserteq(-1, (-Constant(1)/Constant(1))())	-- without the first 'simplify' we don't get the same canonical form with the unary - on the outside
asserteq(1, (Constant(1)/(Constant(1)*Constant(1)))())

x = symmath.Variable('x')
y = symmath.Variable('y')
t = symmath.Variable('t')

-- commutativity
asserteq(x+y, y+x)
asserteq(x*y, y*x)

-- pruning operations
asserteq(x, (1*x)())
asserteq(0, (Constant(0)*x)())
asserteq(x, (1*x)())
asserteq((x/x)(), 1)

asserteq(x^2, (x*x)())

-- simplify(): div add mul
asserteq(((x+1)*y)(), (x*y + y)())
asserteq(((x+1)*(y+1))(), (x*y + x + y + 1)())
asserteq((2/(2*x*y))(), (1/(x*y))())
asserteq((1-(1-x))(), x)
asserteq(((1-(1-x))/x)(), 1)
	
-- factoring integers
asserteq((Constant(2)/Constant(2))(), Constant(1))
asserteq((Constant(2)/Constant(4))(), (Constant(1)/Constant(2))())

asserteq(((2*x + 2*y)/2)(), (x+y)())
asserteq(((-2*x + 2*y)/2)(), (-x+y)())

asserteq(-1-x, -(1+x))

asserteq((-x)/x, -1)
asserteq((x/(-x)), -1)
asserteq((-x-1)/(x+1), -1) 
asserteq((x-1)/(1-x), -1)

-- expand(): add div mul

-- factor(): mul add div

--[[ trigonometry
asserteq((symmath.sin(x)^2+symmath.cos(x)^2)(), 1)
asserteq((y*symmath.sin(x)^2+y*symmath.cos(x)^2)(), y)
asserteq((y+y*symmath.sin(x)^2+y*symmath.cos(x)^2)(), 2*y)	-- works when combining y + y * trig ident
asserteq((1+y*symmath.sin(x)^2+y*symmath.cos(x)^2)(), 1+y)	-- ... but not when combining 1 + y * trig ident (look in factor.lua)
--]]

-- these fail with the extra "factor() if trig found" condition is set in the prune() function
asserteq(1+symmath.cos(x)^2+symmath.cos(x)^2, 1+2*symmath.cos(x)^2)
asserteq(-1+symmath.cos(x)^2+symmath.cos(x)^2, -1+2*symmath.cos(x)^2)

asserteq((y-x)/(x-y), -1)
asserteq((x+y)/(x+y)^2, 1/(x+y))
asserteq((-x+y)/(-x+y)^2, 1/(-x+y))

print_(MathJax.footer)
