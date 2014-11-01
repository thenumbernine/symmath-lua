#!/usr/bin/env luajit
--[[

    File: alcubierre.lua

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

--[[

ideal code:
	
	-- provide default, provide specific indexes.
	-- for assignment strings are fine,
	-- but for differentiation the variables have to be referenced.
	-- strings values is fine if the variables are globals
	--tensor.coords{'txyz', ijk = 'xyz'}
	-- but if they're not then you'll have to to use a table
	tensor.coords{{t,x,y,z}, ijk={x,y,z}}
	-- and then there's the t=0/t=4 issue.
	-- will the fact that non-i's x is the 2nd and i's x is the 1st element make a difference?
	-- align coords by associated variables. let the user reference by g'_tt' rather than g[1][1] or g[4][4] or whichever implementation is used.
	-- ... either use the vars as fields themselves or use the provided list as order index, so 'txyz' would either provide g.t.t, g.t.x, etc or g[1][1] as g_tt, g[1][2] as g_tx, etc

	alpha = 1

	-- "dont differentiate / not a constant" is the default?
	v = var()
	f = var()
	
	-- use tensor's ctor to specify the default contra/co-variance and which indexes to allocate for
	-- use the coords def to infer rank from these indexes
	beta = tensor'^i'

	-- for tensor assignment I'd like to use __call with implicit string parameter 
	-- but the returned object would be assigned with Lua's un-overloadable assignment operation 
	--beta'^0' = -v*f	-- (ideal but not possible as a setter)
	-- to work around this __newindex could be overloaded
	beta['^0'] = -v*f

	gamma = tensor'_ij'
	gamma['_ij'] = tensor.delta'_ij'
	
	g = tensor'_ab'

	-- how should lowering work?  one way is to use separate variables for betaU and betaL
	-- lowering/raising with no metric set should throw an error ... or use a default
	-- circumventing this, explicit lowering should work fine, so long as variables provided are in their defined contra/co-variance:
	g['_tt'] = -alpha^2 + beta'^i' * beta'^j' * gamma'_ij'
	g['_it'] = beta'^i' / alpha^2
	g['_ij'] = gamma'^ij' - beta'^i' * beta'^j' / alpha^2

	tensor.print{['g_ab'] = g}
	tensor.print{['g^ab'] = g}

	-- stores g as the metric and calculates tensor.metricInv = matrixInverse(g) ... or gauss seidel or whatever 
	tensor.metric(g)

	dg = g'_ab,c'
	tensor.print(['g_ab,c'] = dg)
	
	conn = 1/2 * (dg'_abc' + dg'_acb' - dg'_bca')
	tensor.print{['\\Gamma_abc'] = conn}
	tensor.print{['\\Gamma^a_bc'] = conn}

	-- or combined:
	-- conn = 1/2 * (g'_ab,c' + g'_ac,b' - g'_bc,a')

what has to be done to get there?
- tensor library needs to allow storage in either contra- or co-variant form
	(right now it only does one and converts to the other immediately)
- tensor library needs to use __newindex for its assignments, then look at variations between contra- and co- indices to see what to convert 
	(right now it uses call implicit string params to convert '_ij' to a 'indexed tensor' object, then another '' to collapse it back to a tensor ...
- tensor needs to use an inverse algorithm (gauss-jordan? somethign that works for symmath as well) for calculating the metric inverse
- tensor needs to allow indicies to be associated with lists of variables.  to boot, allow index groups to be associated with unique metrics as well.
--]]

symmath = require 'symmath'
local MathJax = require 'symmath.tostring.MathJax'
symmath.toStringMethod = MathJax

function exec(cmd)
	assert(loadstring(cmd))()
end

function printbr(...)
	print(...)
	print('<br>')
end

function printNonZero(title, expr, args)
	for k,v in pairs(args) do
		expr = expr:gsub('$'..k, v)
		title = title:gsub('$'..k, v)
	end
	exec([[if ]]..expr..[[ ~= symmath.Constant(0) then printbr('\\(]]..title..[[\\) = '..]]..expr..[[) end]])
end

print(MathJax.header)

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
coords = table{'t', 'x', 'y', 'z'}
spatialCoords = table{'x', 'y', 'z'}

-- schwarzschild metric in cartesian coordinates

	-- spatial
alpha = symmath.Constant(1)
v = symmath.Variable('v', coords:map(function(v) return _G[v] end))
f = symmath.Variable('f', coords:map(function(v) return _G[v] end))
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
exec('gLL_t_t = symmath.simplify(-alpha * alpha + betaSq)')
for _,u in ipairs(spatialCoords) do
	exec(('gLL_$u_t = symmath.simplify(betaL_$u)'):gsub('$u',u))
	exec(('gLL_t_$u = symmath.simplify(betaL_$u)'):gsub('$u',u))
	for _,v in ipairs(spatialCoords) do
		exec(('gLL_$u_$v = symmath.simplify(gammaLL_$u_$v)'):gsub('$u',u):gsub('$v',v))
	end
end
	
-- metric inverse
exec('gUU_t_t = symmath.simplify(-1/(alpha * alpha))')
for _,u in ipairs(spatialCoords) do
	exec(('gUU_$u_t = symmath.simplify(betaU_$u / (alpha * alpha))'):gsub('$u',u))
	exec(('gUU_t_$u = symmath.simplify(betaU_$u / (alpha * alpha))'):gsub('$u',u))
	for _,v in ipairs(spatialCoords) do
		exec(('gUU_$u_$v = symmath.simplify(gammaUU_$u_$v - betaU_$u * betaU_$v / (alpha * alpha))'):gsub('$u',u):gsub('$v',v))
	end
end

printbr('metric')
for _,u in ipairs(coords) do
	for _,v in ipairs(coords) do
		printNonZero('g_{$u$v}', 'gLL_$u_$v', {u=u,v=v})
	end
end

printbr()
printbr('inverse')
for _,u in ipairs(coords) do
	for _,v in ipairs(coords) do
		printNonZero('g^{$u$v}', 'gUU_$u_$v', {u=u,v=v})
	end
end

printbr()
for _,u in ipairs(coords) do
	for _,v in ipairs(coords) do
		for _,w in ipairs(coords) do
			exec(('gLLL_$u_$v_$w = symmath.diff(gLL_$u_$v, $w)'):gsub('$u',u):gsub('$v',v):gsub('$w',w))
			exec(('gLLL_$u_$v_$w = symmath.simplify(gLLL_$u_$v_$w)'):gsub('$u',u):gsub('$v',v):gsub('$w',w))
			-- replace symmath.diff(r,t) with 0
			--exec(('gLLL_$u_$v_$w = symmath.replace(gLLL_$u_$v_$w, symmath.Derivative(r, t), symmath.Constant(0))'):gsub('$u',u):gsub('$v',v):gsub('$w',w))
			
			exec(('gLLL_$u_$v_$w = symmath.simplify(gLLL_$u_$v_$w)'):gsub('$u',u):gsub('$v',v):gsub('$w',w))
			
			printNonZero('g_{$u$v,$w}', 'gLLL_$u_$v_$w', {u=u,v=v,w=w})
		end
	end
end

printbr()
for _,u in ipairs(coords) do
	for _,v in ipairs(coords) do
		for _,w in ipairs(coords) do
			exec(('christoffelLLL_$u_$v_$w = symmath.simplify((symmath.Constant(1)/2) * (gLLL_$u_$v_$w + gLLL_$u_$w_$v - gLLL_$v_$w_$u))'):gsub('$u',u):gsub('$v',v):gsub('$w',w))
			printNonZero([[\\Gamma_{$u$v$w}]], 'christoffelLLL_$u_$v_$w', {u=u,v=v,w=w})
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
			printNonZero([[{\\Gamma^$u}_{$v$w}]], 'christoffelULL_$u_$v_$w',{u=u,v=v,w=w})
		end
	end
end

printbr()
printbr('geodesic')
--[[
x''^u = -G^u_vw x'^v x'^w
--]]
for _,u in ipairs(coords) do
	exec(([[diffxU_$u = symmath.Variable('{d x^$u}\\over {d\\tau}')]]):gsub('$u',u))
end
for _,u in ipairs(coords) do
	exec(('diff2xU_$u = 0'):gsub('$u',u))
	for _,v in ipairs(coords) do
		for _,w in ipairs(coords) do
			exec(('diff2xU_$u = diff2xU_$u + christoffelULL_$u_$v_$w * diffxU_$v * diffxU_$w'):gsub('$u',u):gsub('$v',v):gsub('$w',w))
		end
	end
	exec(([[diff2xU_$u = symmath.simplify(diff2xU_$u)]]):gsub('$u',u))
	printNonZero([[{d^2 x^$u} \\over {d\\tau^2}]], 'diff2xU_$u',{u=u})
end

print(MathJax.footer)

