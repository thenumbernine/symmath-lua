--[[

    File: schwarzschild.lua

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

require 'symmath'

function exec(cmd)
	assert(loadstring(cmd))()
end

function assign(cmd)
	local var, expr = cmd:match('^(.-)=(.-)$')
	assert(var, "couldn't pick apart "..cmd)
	var = var:trim()
	expr = expr:trim()
	exec(var .. '=' .. expr)
	print(var .. ' = ' .. tostring(_G[var]))
end

function printNonZero(expr, args)
	for k,v in pairs(args) do
		expr = expr:gsub('$'..k, v)
	end
	exec("if "..expr.." ~= symmath.Constant(0) then print('"..expr.." = '.."..expr..") end")
end

--[[
schwarzschild in spherical form: (-(1-2m/r)) dt^2 + 1/(1-2m/r) dr^2 + r^2 dtheta^2 + r^2 sin(theta)^2 dphi^2

my guess of how this fits with cartesian:
--]]


-- coordinates
t = symmath.Variable('t')
x = symmath.Variable('x')
y = symmath.Variable('y')
z = symmath.Variable('z')
M = symmath.Variable('M')
coords = {'t', 'x', 'y', 'z'}
-- algebraic
--r = (x^2 + y^2 + z^2)^.5
-- deferred:
r = symmath.Variable('r', nil, true)

-- schwarzschild metric in cartesian coordinates

	-- start with zero
for _,u in ipairs(coords) do
	for _,v in ipairs(coords) do
		exec(('gLL_$u_$v = symmath.Constant(0)'):gsub('$u',u):gsub('$v',v))
	end
end
	
	-- assign diagonals
assign('gLL_t_t =  -(1-2*M/r)')
assign('gLL_x_x = 1/(1-2*M/r)')
assign('gLL_y_y = 1/(1-2*M/r)')
assign('gLL_z_z = 1/(1-2*M/r)')

-- metric inverse
for _,u in ipairs(coords) do
	for _,v in ipairs(coords) do
		if u == v then
			exec(('gUU_$u_$v = 1 / gLL_$u_$v'):gsub('$u',u):gsub('$v',v))
		else
			exec(('gUU_$u_$v = symmath.Constant(0)'):gsub('$u',u):gsub('$v',v))
		end
		printNonZero('gUU_$u_$v',{u=u,v=v})
	end
end


print('metric')
for _,u in ipairs(coords) do
	for _,v in ipairs(coords) do
		printNonZero('gLL_$u_$v', {u=u,v=v})
	end
end

print('inverse')
for _,u in ipairs(coords) do
	for _,v in ipairs(coords) do
		printNonZero('gUU_$u_$v', {u=u,v=v})
	end
end

print()
for _,u in ipairs(coords) do
	for _,v in ipairs(coords) do
		for _,w in ipairs(coords) do
			exec(('gLLL_$u_$v_$w = symmath.diff(gLL_$u_$v, $w)'):gsub('$u',u):gsub('$v',v):gsub('$w',w))
			exec(('gLLL_$u_$v_$w = symmath.simplify(gLLL_$u_$v_$w)'):gsub('$u',u):gsub('$v',v):gsub('$w',w))
			
			-- replace symmath.diff(r,t) with 0
			exec(('gLLL_$u_$v_$w = symmath.replace(gLLL_$u_$v_$w, symmath.Derivative(r, t), symmath.Constant(0))'):gsub('$u',u):gsub('$v',v):gsub('$w',w))
			
			exec(('gLLL_$u_$v_$w = symmath.simplify(gLLL_$u_$v_$w)'):gsub('$u',u):gsub('$v',v):gsub('$w',w))
			
			printNonZero('gLLL_$u_$v_$w', {u=u,v=v,w=w})
		end
	end
end

print()
for _,u in ipairs(coords) do
	for _,v in ipairs(coords) do
		for _,w in ipairs(coords) do
			exec(('christoffelLLL_$u_$v_$w = symmath.simplify((1/2) * (gLLL_$u_$v_$w + gLLL_$u_$w_$v - gLLL_$v_$w_$u))'):gsub('$u',u):gsub('$v',v):gsub('$w',w))
			printNonZero('christoffelLLL_$u_$v_$w', {u=u,v=v,w=w})
		end
	end
end

print()
for _,u in ipairs(coords) do
	for _,v in ipairs(coords) do
		for _,w in ipairs(coords) do
			exec(('christoffelULL_$u_$v_$w = 0'):gsub('$u',u):gsub('$v',v):gsub('$w',w))
			for _,r in ipairs(coords) do
				exec(('christoffelULL_$u_$v_$w = christoffelULL_$u_$v_$w + christoffelLLL_$r_$v_$w * gUU_$r_$u'):gsub('$u',u):gsub('$v',v):gsub('$w',w):gsub('$r',r))
			end
			exec(('christoffelULL_$u_$v_$w = symmath.simplify(christoffelULL_$u_$v_$w)'):gsub('$u',u):gsub('$v',v):gsub('$w',w))
			printNonZero('christoffelULL_$u_$v_$w',{u=u,v=v,w=w})
		end
	end
end


