#!/usr/bin/env luajit
--[[

    File: metric.lua

    Copyright (C) 2000-2016 Christopher Moore (christopher.e.moore@gmail.com)
	  
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
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
print(MathJax.header)

require 'symmath.tostring.LaTeX'.usePartialLHSForDerivative = true

local function printbr(...) print(...) print'<br>' end

local Tensor = symmath.Tensor
local var = symmath.var
local vars = symmath.vars

--[[ polar
r = var('r')
phi = var('phi')
srcCoords = {'x', 'y'}
coords = {'r', 'phi'}
assign('metric_x = r * symmath.cos(phi)')
assign('metric_y = r * symmath.sin(phi)')
--]]

--[[ spherical
r = var('r')
theta = var('theta')
phi = var('phi')
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
t = var('t')
x = var('x')
y = var('y')
z = var('z')
coords = {'t', 'x', 'y', 'z'}
Phi = var('Phi', {t,x,y,z})
--]]

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
		printNonZero('g_{$u$v}', 'gLL_$u_$v',{u=u,v=v})
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
		printNonZero('g_{$u$v}', 'gUU_$u_$v',{u=u,v=v})
	end
end
--]]

-- [[ ADM
local t,x,y,z = vars('t','x','y','z')
local spatialCoords = {x,y,z}
local coords = {t,x,y,z}
Tensor.coords{
	{variables = coords},
	{variables = spatialCoords, symbols='ijklmn'},
}
local alpha = var('\\alpha', coords)
local beta = Tensor('^i', function(i) return var('\\beta^'..spatialCoords[i].name, coords) end)
local gamma = Tensor('_ij', function(i,j) return var('\\gamma_{'..spatialCoords[i].name..spatialCoords[j].name..'}', coords) end)
local gammaUU = Tensor('^ij', function(i,j) return var('\\gamma^{'..spatialCoords[i].name..spatialCoords[j].name..'}', coords) end)

--local betaL = Tensor('_i', function(i) return var('\\beta_'..spatialCoords[i].name, coords) end)
--local betaL_def = Tensor('_i', function(i) return betaL[i]:equals(
local betaSq = var'\\beta^2'
--local betaSq_def = betaSq:equals(beta'^i' * betaL'_i')

Tensor.metric(gamma, gammaUU, 'i')
--local gammaUU = Tensor.metric(gamma, nil, 'i').metricInverse

printbr(alpha)
printbr(var'\\beta''^i':eq(beta'^i'()))
printbr(var'\\gamma''_ij':eq(gamma'_ij'()))
printbr(var'\\gamma''^ij':eq(gammaUU'^ij'()))

-- metric
-- TODO subtensor expansion.  useful here and in the ADM flux ... and a lot of other places
local g = Tensor('_uv', function(u,v)
	if u == 1 then
		if v == 1 then
			return (-alpha^2 + betaSq)
		else
			return beta'_i'()[v-1]
		end
	else
		if v == 1 then
			return beta'_i'()[u-1]
		else
			return gamma'_ij'()[u-1][v-1]
		end
	end
end)
local gUU = Tensor('^uv', function(u,v)
	if u == 1 then
		if v == 1 then
			return -1/alpha^2
		else
			return beta[v-1] / alpha^2
		end
	else
		if v == 1 then
			return beta[u-1] / alpha^2
		else
			return gammaUU[u-1][v-1] - beta[u-1] * beta[v-1] / alpha^2
		end
	end
end)
Tensor.metric(g, gUU)

printbr(var'g''_uv':eq(g'_uv'()))
printbr(var'g''^uv':eq(gUU'^uv'()))

local Gamma = Tensor'_abc'
Gamma['_abc'] = ((g'_ab,c' + g'_ac,b' - g'_bc,a') / 2)()
printbr(var'\\Gamma''_abc':eq(Gamma'_abc'()))
Gamma = Gamma'^a_bc'()
printbr(var'\\Gamma''^a_bc':eq(Gamma'^a_bc'()))

local Riemann = Tensor'^a_bcd'
Riemann['^a_bcd'] = (Gamma'^a_bd,c' - Gamma'^a_bc,d' + Gamma'^a_ec' * Gamma'^e_bd' - Gamma'^a_ed' * Gamma'^e_bc')()
printbr('${R^a}_{bcd} = $'..Riemann'^a_bcd')

print(MathJax.footer)
