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

symmath.toStringMethod = 'singleLine'

function exec(expr, args)
	if args then
		for k,v in pairs(args) do
			expr = expr:gsub('$'..k, v)
		end
	end
	assert(loadstring(expr))()
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
	if args then
		for k,v in pairs(args) do
			expr = expr:gsub('$'..k, v)
		end
	end
	exec("if "..expr.." ~= symmath.Constant(0) then print('"..expr.." = '.."..expr..") end")
end

--[[
schwarzschild in spherical form: (-(1-2m/r)) dt^2 + 1/(1-2m/r) dr^2 + r^2 dtheta^2 + r^2 sin(theta)^2 dphi^2

my guess of how this fits with cartesian:
--]]


-- coordinates
t = symmath.Variable('t', nil, true)
x = symmath.Variable('x', nil, true)
y = symmath.Variable('y', nil, true)
z = symmath.Variable('z', nil, true)
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
		exec('gLL_$u_$v = symmath.Constant(0)', {u=u, v=v})
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
			exec('gUU_$u_$v = 1 / gLL_$u_$v', {u=u, v=v})
		else
			exec('gUU_$u_$v = symmath.Constant(0)', {u=u, v=v})
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

--[[
partial metric: g_ab,c
--]]
print()
for _,u in ipairs(coords) do
	for _,v in ipairs(coords) do
		for _,w in ipairs(coords) do
			exec('gLLL_$u_$v_$w = symmath.diff(gLL_$u_$v, $w)', {u=u, v=v, w=w})
			exec('gLLL_$u_$v_$w = symmath.simplify(gLLL_$u_$v_$w)', {u=u, v=v, w=w})
			
			-- replace symmath.diff(r,t) with 0
			exec('gLLL_$u_$v_$w = symmath.replace(gLLL_$u_$v_$w, symmath.Derivative(r, t), symmath.Constant(0))', {u=u, v=v, w=w})
			
			exec('gLLL_$u_$v_$w = symmath.simplify(gLLL_$u_$v_$w)', {u=u, v=v, w=w})
			
			printNonZero('gLLL_$u_$v_$w', {u=u,v=v,w=w})
		end
	end
end

--[[
Christoffel: G_abc = 1/2 (g_ab,c + g_ac,b - g_bc,a) 
--]]
print()
for _,u in ipairs(coords) do
	for _,v in ipairs(coords) do
		for _,w in ipairs(coords) do
			exec('christoffelLLL_$u_$v_$w = symmath.simplify((1/2) * (gLLL_$u_$v_$w + gLLL_$u_$w_$v - gLLL_$v_$w_$u))', {u=u, v=v, w=w})
			printNonZero('christoffelLLL_$u_$v_$w', {u=u,v=v,w=w})
		end
	end
end

--[[
Christoffel: G^a_bc = g^ae G_ebc
--]]
print()
for _,u in ipairs(coords) do
	for _,v in ipairs(coords) do
		for _,w in ipairs(coords) do
			exec('christoffelULL_$u_$v_$w = 0', {u=u, v=v, w=w})
			for _,r in ipairs(coords) do
				exec('christoffelULL_$u_$v_$w = christoffelULL_$u_$v_$w + christoffelLLL_$r_$v_$w * gUU_$r_$u', {r=r, u=u, v=v, w=w})
			end
			exec('christoffelULL_$u_$v_$w = symmath.simplify(christoffelULL_$u_$v_$w)', {u=u, v=v, w=w})
			printNonZero('christoffelULL_$u_$v_$w',{u=u,v=v,w=w})
		end
	end
end

--[[
Geodesic:
x''^u = -G^u_vw x'^v x'^w
--]]
print()
for _,u in ipairs(coords) do
	exec([[diffxU_$u = symmath.Variable('diffxU_$u',nil,true)]], {u=u})
end
for _,u in ipairs(coords) do
	exec('diff2xU_$u = 0', {u=u})
	for _,v in ipairs(coords) do
		for _,w in ipairs(coords) do
			exec('diff2xU_$u = diff2xU_$u - christoffelULL_$u_$v_$w * diffxU_$v * diffxU_$w', {u=u,v=v,w=w})
		end
	end
	exec('diff2xU_$u = symmath.simplify(diff2xU_$u)', {u=u})
	printNonZero('diff2xU_$u',{u=u})
end

--[[
Christoffel partial:
G^a_bc,d
--]]
print()
for _,a in ipairs(coords) do
	for _,b in ipairs(coords) do
		for _,c in ipairs(coords) do
			for _,d in ipairs(coords) do
				exec('christoffelULLL_$a_$b_$c_$d = symmath.diff(christoffelULL_$a_$b_$c, $d)', {a=a,b=b,c=c,d=d})
				exec('christoffelULLL_$a_$b_$c_$d = symmath.simplify(christoffelULLL_$a_$b_$c_$d)', {a=a,b=b,c=c,d=d})
				printNonZero('christoffelULLL_$a_$b_$c_$d', {a=a,b=b,c=c,d=d})
			end
		end
	end
end

--[[
Riemann:
R^a_bcd = G^a_bd,c - G^a_bc,d + G^a_uc G^u_bd - G^a_ud G^u_bc
--]]
print()
for _,a in ipairs(coords) do
	for _,b in ipairs(coords) do
		for _,c in ipairs(coords) do
			for _,d in ipairs(coords) do
				exec('riemannULLL_$a_$b_$c_$d = christoffelULLL_$a_$b_$d_$c - christoffelULLL_$a_$b_$c_$d', {a=a,b=b,c=c,d=d})
				for _,u in ipairs(coords) do
					exec('riemannULLL_$a_$b_$c_$d = riemannULLL_$a_$b_$c_$d + christoffelULL_$a_$u_$c * christoffelULL_$u_$b_$d', {a=a,b=b,c=c,d=d,u=u})
					exec('riemannULLL_$a_$b_$c_$d = riemannULLL_$a_$b_$c_$d - christoffelULL_$a_$u_$d * christoffelULL_$u_$b_$c', {a=a,b=b,c=c,d=d,u=u})
				end
				exec('riemannULLL_$a_$b_$c_$d = symmath.simplify(riemannULLL_$a_$b_$c_$d)', {a=a,b=b,c=c,d=d})
				printNonZero('riemannULLL_$a_$b_$c_$d', {a=a,b=b,c=c,d=d})
			end
		end
	end
end

--[[
Ricci:
R_ab = R^u_aub
--]]
print()
for _,a in ipairs(coords) do
	for _,b in ipairs(coords) do
		exec('ricciLL_$a_$b = 0', {a=a,b=b})
		for _,u in ipairs(coords) do
			exec('ricciLL_$a_$b = ricciLL_$a_$b + riemannULLL_$u_$a_$u_$b', {a=a,b=b,u=u})
		end
		exec('ricciLL_$a_$b = symmath.simplify(ricciLL_$a_$b)', {a=a,b=b})
		printNonZero('ricciLL_$a_$b', {a=a,b=b})
	end
end

