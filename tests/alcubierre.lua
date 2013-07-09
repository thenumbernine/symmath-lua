--[[

    File: alcubierre.lua

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
ADM:
g_uv = -alpha^2 + beta^2	beta_j
			beta_i			gamma_ij
Alcubierre:
alpha = 1
beta_x = -v f
f = f(rs)
rs = length(x - xs)
--]]


-- coordinates
t = symmath.Variable('t')
x = symmath.Variable('x')
y = symmath.Variable('y')
z = symmath.Variable('z')
coords = {'t', 'x', 'y', 'z'}
spatialCoords = {'x', 'y', 'z'}

-- schwarzschild metric in cartesian coordinates

	-- spatial
alpha = symmath.Constant(1)
v = symmath.Variable('v',nil,true)
f = symmath.Variable('f',nil,true)
betaL_x = -v * f
betaU_x = -v * f
betaL_y = symmath.Constant(0)
betaU_y = symmath.Constant(0)
betaL_z = symmath.Constant(0)
betaU_z = symmath.Constant(0)
for _,u in ipairs(coords) do
	for _,v in ipairs(coords) do
		if u == v then
			exec(([[gammaLL_$u_$v = symmath.Constant(1)]]):gsub('$u',u):gsub('$v',v))
			exec(([[gammaUU_$u_$v = symmath.Constant(1)]]):gsub('$u',u):gsub('$v',v))
		else
			exec(([[gammaLL_$u_$v = symmath.Constant(0)]]):gsub('$u',u):gsub('$v',v))
			exec(([[gammaUU_$u_$v = symmath.Constant(0)]]):gsub('$u',u):gsub('$v',v))
		end
	end
end

betaSq = symmath.Constant(0)
for _,u in ipairs(spatialCoords) do
	exec(([[betaSq = betaSq + betaL_$u * betaU_$u]]):gsub('$u',u))
end

	-- start with zero
assign('gLL_t_t = symmath.simplify(-alpha * alpha + betaSq)')
for _,u in ipairs(spatialCoords) do
	exec(('gLL_$u_t = symmath.simplify(betaL_$u)'):gsub('$u',u))
	exec(('gLL_t_$u = symmath.simplify(betaL_$u)'):gsub('$u',u))
	for _,v in ipairs(spatialCoords) do
		exec(('gLL_$u_$v = symmath.simplify(gammaLL_$u_$v)'):gsub('$u',u):gsub('$v',v))
	end
end
	
-- metric inverse
assign('gUU_t_t = symmath.simplify(-1/(alpha * alpha))')
for _,u in ipairs(spatialCoords) do
	exec(('gUU_$u_t = symmath.simplify(betaU_$u / (alpha * alpha))'):gsub('$u',u))
	exec(('gUU_t_$u = symmath.simplify(betaU_$u / (alpha * alpha))'):gsub('$u',u))
	for _,v in ipairs(spatialCoords) do
		exec(('gUU_$u_$v = symmath.simplify(gammaUU_$u_$v - betaU_$u * betaU_$v / (alpha * alpha))'):gsub('$u',u):gsub('$v',v))
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
			--exec(('gLLL_$u_$v_$w = symmath.replace(gLLL_$u_$v_$w, symmath.Derivative(r, t), symmath.Constant(0))'):gsub('$u',u):gsub('$v',v):gsub('$w',w))
			
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


