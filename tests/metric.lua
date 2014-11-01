#!/usr/bin/env luajit
--[[

    File: metric.lua

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
local MathJax = require 'symmath.tostring.MathJax'
symmath.toStringMethod = MathJax

-- test

function exec(cmd)
	assert(loadstring(cmd))()
end

function printbr(...)
	print(...)
	print('<br>')
end

function assign(cmd)
	local var, expr = cmd:match('^(.-)=(.-)$')
	assert(var, "couldn't pick apart "..cmd)
	var = var:trim()
	expr = expr:trim()
	exec(var .. '=' .. expr)
	printbr(var .. ' = ' .. tostring(_G[var]))
end

print(MathJax.header)

--[[ polar
r = symmath.Variable('r')
phi = symmath.Variable('phi')
srcCoords = {'x', 'y'}
coords = {'r', 'phi'}
assign('metric_x = r * symmath.cos(phi)')
assign('metric_y = r * symmath.sin(phi)')
--]]

--[[ spherical
r = symmath.Variable('r')
theta = symmath.Variable('theta')
phi = symmath.Variable('phi')
srcCoords = {'x', 'y', 'z'}
coords = {'r', 'theta', 'phi'}
assign('metric_x = r * symmath.cos(phi) * symmath.sin(theta)')
assign('metric_y = r * symmath.sin(phi) * symmath.sin(theta)')
assign('metric_z = r * symmath.cos(theta)')
--]]

--[[
printbr()
-- coordinate basis
for _,u in ipairs(coords) do
	for _,v in ipairs(srcCoords) do
		assign(('e_$u_$v = symmath.diff(metric_$v, $u)'):gsub('$u',u):gsub('$v',v))
	end
end
--]]

--[[ non-coordinate basis
-- this typically means orthonormalizing the basis ... I'm just going to normalize it.
for _,u in ipairs(coords) do
	assign(('e_$u = 0'):gsub('$u',u)
	for _,v in ipairs(srcCoords) do
		assign(('e_$u = e_$u + e_$u_$v * e_$u_$v'):gsub('$u',u):gsub('$v',v))
	end
	assign(('e_$u = e_$u^(symmath.Constant(1)/2)'):gsub('$u',u))
end
--]]

--[[
printbr()
for _,u in ipairs(coords) do
	for _,v in ipairs(coords) do
		exec(('gLL_$u_$v = 0'):gsub('$u',u):gsub('$v',v))
		for _,w in ipairs(srcCoords) do
			exec(('gLL_$u_$v = gLL_$u_$v + e_$u_$w * e_$v_$w'):gsub('$u',u):gsub('$v',v):gsub('$w',w))
		end
		assign(('gLL_$u_$v = gLL_$u_$v'):gsub('$u',u):gsub('$v',v))
	end
end
--]]

--[[ explicitly provided metric
t = symmath.Variable('t')
x = symmath.Variable('x')
y = symmath.Variable('y')
z = symmath.Variable('z')
coords = {'t', 'x', 'y', 'z'}
Phi = symmath.Variable('Phi', {t,x,y,z})
--]]

function printNonZero(expr, args)
	for k,v in pairs(args) do
		expr = expr:gsub('$'..k, v)
	end
	exec("if "..expr.." ~= symmath.Constant(0) then printbr('"..expr.." = '.."..expr..") end")
end

--[[
printbr()
for _,u in ipairs(coords) do
	for _,v in ipairs(coords) do
		if u == v then
			if _G[u] == t then
				exec(('gLL_$u_$v = -1-2*Phi'):gsub('$u',u):gsub('$v',v))
			else
				exec(('gLL_$u_$v = 1-2*Phi'):gsub('$u',u):gsub('$v',v))
			end
		else
			exec(('gLL_$u_$v = symmath.Constant(0)'):gsub('$u',u):gsub('$v',v))
		end
		printNonZero('gLL_$u_$v',{u=u,v=v})
	end
end
--]]

--[[ calc inverse of diagonal matrix
printbr()
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
--]]

-- [[ ADM
t = symmath.Variable('t')
x = symmath.Variable('x')
y = symmath.Variable('y')
z = symmath.Variable('z')
alpha = symmath.Variable('\\alpha', {t,x,y,z})
spatial = {'x','y','z'}
coords = {'t', 'x', 'y', 'z'}
for _,u in ipairs(spatial) do
	exec(([[betaU_$u = symmath.Variable('\\beta^$u', {t,x,y,z})]]):gsub('$u', u))
	exec(([[betaL_$u = symmath.Variable('\\beta_$u', {t,x,y,z})]]):gsub('$u', u))
end
for _,u in ipairs(spatial) do
	for _,v in ipairs(spatial) do
		exec(([[gammaLL_$u_$v = symmath.Variable('\\gamma_{$u$v}', {t,x,y,z})]]):gsub('$u', u):gsub('$v', v))
		exec(([[gammaUU_$u_$v = symmath.Variable('\\gamma^{$u$v}', {t,x,y,z})]]):gsub('$u', u):gsub('$v', v))
	end
end
--[=[
for _,u in ipairs(spatial) do
	exec(('betaL_$u = 0'):gsub('$u',u))
	for _,v in ipairs(spatial) do
		exec(('betaL_$u = beta_L_$u + gammaLL_$u_$v * betaU_$v'):gsub('$u',u):gsub('$v',v))
	end
end
--]=]
-- metric
exec('gLL_t_t = alpha * alpha')
for _,u in ipairs(spatial) do
	exec(('gLL_t_t = gLL_t_t - betaU_$u * betaL_$u'):gsub('$u', u))
end
for _,u in ipairs(spatial) do
	exec(('gLL_$u_t = betaL_$u'):gsub('$u', u))
	exec(('gLL_t_$u = betaL_$u'):gsub('$u', u))
end
for _,u in ipairs(spatial) do
	for _,v in ipairs(spatial) do
		exec(('gLL_$u_$v = gammaLL_$u_$v'):gsub('$u', u):gsub('$v', v))
	end
end
-- inverse
exec('gUU_t_t =-alpha^-2')
for _,u in ipairs(spatial) do
	exec(('gUU_$u_t = betaU_$u / alpha^2'):gsub('$u', u))
	exec(('gUU_t_$u = betaU_$u / alpha^2'):gsub('$u', u))
end
for _,u in ipairs(spatial) do
	for _,v in ipairs(spatial) do
		exec(('gUU_$u_$v = gammaUU_$u_$v - betaU_$u * betaU_$v / alpha^2'):gsub('$u', u):gsub('$v', v)) 
	end
end
--]]

printbr()
for _,u in ipairs(coords) do
	for _,v in ipairs(coords) do
		for _,w in ipairs(coords) do
			exec(('gLLL_$u_$v_$w = symmath.simplify(symmath.diff(gLL_$u_$v, $w))'):gsub('$u',u):gsub('$v',v):gsub('$w',w))
			printNonZero('gLLL_$u_$v_$w', {u=u,v=v,w=w})
		end
	end
end

printbr()
for _,u in ipairs(coords) do
	for _,v in ipairs(coords) do
		for _,w in ipairs(coords) do
			exec(('christoffelLLL_$u_$v_$w = symmath.simplify((symmath.Constant(1)/2) * (gLLL_$u_$v_$w + gLLL_$u_$w_$v - gLLL_$v_$w_$u))'):gsub('$u',u):gsub('$v',v):gsub('$w',w))
			printNonZero('christoffelLLL_$u_$v_$w', {u=u,v=v,w=w})
		end
	end
end

printbr()
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


printbr('Phi ~ -1')
for _,u in ipairs(coords) do
	for _,v in ipairs(coords) do
		for _,w in ipairs(coords) do
			exec(('christoffelULL_$u_$v_$w = symmath.replace(christoffelULL_$u_$v_$w, Phi, symmath.Constant(-1), function(v) return not v:isa(symmath.Derivative) end)'):gsub('$u',u):gsub('$v',v):gsub('$w',w))
			printNonZero('christoffelULL_$u_$v_$w',{u=u,v=v,w=w})
		end
	end
end

print(MathJax.footer)

