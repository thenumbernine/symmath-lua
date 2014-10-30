#!/usr/bin/env luajit
--[[

    File: schwarzschild_spherical.lua

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
schwarzschild in spherical form: (-(1-2m/r)) dt^2 + 1/(1-2m/r) dr^2 + r^2 dtheta^2 + r^2 sin(theta)^2 dphi^2
--]]

symmath = require 'symmath'
symmath.toStringMethod = require 'symmath.tostring.LaTeX'
local MathJax = require 'symmath.tostring.MathJax'

print(MathJax.header)

-- coordinates
t = symmath.Variable('t')
r = symmath.Variable('r')
theta = symmath.Variable('\\theta')
phi = symmath.Variable('\\phi')
M = symmath.Variable('M')	-- schwarzschild radius = 2*M

spatialCoords = {'r', 'theta', 'phi'}
coords = {'t', 'r', 'theta', 'phi'}

-- TODO make this symbolic so that it can be properly evaluated
function cond(expr, ontrue, onfalse)
	if expr then return ontrue end
	return onfalse
end

local function printbr(...)
	print(...)
	print('<br>')
end

-- schwarzschild metric in cartesian coordinates

-- start with zero
for _,u in ipairs(coords) do
	for _,v in ipairs(coords) do
		_G['gLL_'..u..'_'..v] = symmath.Constant(0)
	end
end
	
-- assign diagonals
printbr('metric')
gLL_t_t =  (-(1-2*M/r)):simplify()
gLL_r_r = (1/(1-2*M/r)):simplify()
gLL_theta_theta = (r^2):simplify()
gLL_phi_phi = (r^2 * symmath.sin(theta)^2):simplify()
for _,u in ipairs(coords) do
	printbr('\\(g_{'.._G[u]..' '.._G[u]..'} = '.._G['gLL_'..u..'_'..u]..'\\)')
end
printbr()

-- metric inverse, assume diagonal
printbr('metric inverse')
for _,u in ipairs(coords) do
	for _,v in ipairs(coords) do
		_G['gUU_'..u..'_'..v] = symmath.Constant(0)
	end
end
for _,u in ipairs(coords) do
	_G['gUU_'..u..'_'..u] = (1/_G['gLL_'..u..'_'..u]):simplify()
	printbr('\\(g^{'.._G[u]..' '.._G[u]..'} = '.._G['gUU_'..u..'_'..u]..'\\)')
end
printbr()

-- metric partial
printbr('metric partial')
for _,u in ipairs(coords) do
	for _,v in ipairs(coords) do
		for _,w in ipairs(coords) do
			local x = _G['gLL_'..u..'_'..v]:diff(_G[w]):simplify()
			_G['diffgLLL_'..u..'_'..v..'_'..w] = x
			if x ~= symmath.Constant(0) then
				printbr('\\(g_{'.._G[u]..' '.._G[v]..','.._G[w]..'} = '..x..'\\)')
			end
		end
	end
end
printbr()

-- Christoffel: G_abc = 1/2 (g_ab,c + g_ac,b - g_bc,a) 
printbr('1st kind Christoffel')
for _,u in ipairs(coords) do
	for _,v in ipairs(coords) do
		for _,w in ipairs(coords) do
			local x = (symmath.Constant(1)/symmath.Constant(2)*(
				_G['diffgLLL_'..u..'_'..v..'_'..w]
				+ _G['diffgLLL_'..u..'_'..w..'_'..v]
				- _G['diffgLLL_'..v..'_'..w..'_'..u])):simplify()
			_G['GammaLLL_'..u..'_'..v..'_'..w] = x
			if x ~= symmath.Constant(0) then
				printbr('\\(\\Gamma_{'.._G[u]..' '.._G[v]..' '.._G[w]..'} = '..x..'\\)')
			end
		end
	end
end
printbr()

-- Christoffel: G^a_bc = g^ae G_ebc
printbr('2nd kind Christoffel')
for _,u in ipairs(coords) do
	for _,v in ipairs(coords) do
		for _,w in ipairs(coords) do
			-- Gamma^u_vw = g^up Gamma_pvw
			local sum = symmath.Constant(0)
			for _,p in ipairs(coords) do
				sum = sum + _G['gUU_'..u..'_'..p] * _G['GammaLLL_'..p..'_'..v..'_'..w]
			end
			sum = sum:simplify()
			_G['GammaULL_'..u..'_'..v..'_'..w] = sum
			if sum ~= symmath.Constant(0) then
				printbr('\\({\\Gamma^'.._G[u]..'}_{'.._G[v]..' '.._G[w]..'} = '..sum..'\\)')
			end
		end
	end
end
printbr()

-- Geodesic: x''^u = -G^u_vw x'^v x'^w
--tensor.assign[[diffxU_$u = symmath.Variable('{dx^$u}\\over{d\\tau}', nil, true)]]
for _,u in ipairs(coords) do
	_G['diffxU_'..u] = symmath.Variable('{{\\dot x}^'.._G[u]..'}', nil, true)
end
printbr('geodesic equation')
--tensor.assign[[diff2xU_$u = -GammaULL_$u_$v_$w * diffxU_$u * diffxU_$v]]
for _,u in ipairs(coords) do
	local sum = symmath.Constant(0)
	for _,v in ipairs(coords) do
		for _,w in ipairs(coords) do
			sum = sum - _G['GammaULL_'..u..'_'..v..'_'..w] * _G['diffxU_'..v] * _G['diffxU_'..w]
		end
	end
	sum = sum:simplify()
	_G['diff2xU_'..u] = sum
	if sum ~= symmath.Constant(0) then
		printbr('\\({{\\ddot x}^'.._G[u]..'} = '..sum..'\\)')
	end
end
printbr()

-- Christoffel partial: G^a_bc,d
printbr('2nd kind Christoffel partial')
for _,u in ipairs(coords) do
	for _,v in ipairs(coords) do
		for _,w in ipairs(coords) do
			for _,p in ipairs(coords) do
				local x = _G['GammaULL_'..u..'_'..v..'_'..w]:diff(_G[p]):simplify()
				_G['diffGammaULLL_'..u..'_'..v..'_'..w..'_'..p] = x
				if x ~= symmath.Constant(0) then
					printbr('\\({\\Gamma^'.._G[u]..'}_{'.._G[v]..' '.._G[w]..','.._G[p]..'} = '..x..'\\)')
				end
			end
		end
	end
end
printbr()

--Riemann: R^a_bcd = G^a_bd,c - G^a_bc,d + G^a_uc G^u_bd - G^a_ud G^u_bc
--tensor.assign'RULLL_$a_$b_$c_$d = GammaULLL_$a_$b_$d_$c - GammaULLL_$a_$b_$c_$d + GammaULL_$a_$u_$c * GammaULL_$u_$b_$d - GammaULL_$a_$u_$d * GammaULL_$u_$b_$c'
printbr('Riemann curvature tensor')
for _,a in ipairs(coords) do
	for _,b in ipairs(coords) do
		for _,c in ipairs(coords) do
			for _,d in ipairs(coords) do
				local sum = symmath.Constant(0)
				for _,u in ipairs(coords) do
					sum = sum + _G['GammaULL_'..a..'_'..u..'_'..c] * _G['GammaULL_'..u..'_'..b..'_'..d] 
						- _G['GammaULL_'..a..'_'..u..'_'..d] * _G['GammaULL_'..u..'_'..b..'_'..c] 
				end
				local x = _G['diffGammaULLL_'..a..'_'..b..'_'..d..'_'..c]
					- _G['diffGammaULLL_'..a..'_'..b..'_'..c..'_'..d] + sum
				x = x:simplify()
				_G['RULLL_'..a..'_'..b..'_'..c..'_'..d] = x
				if x ~= symmath.Constant(0) then
					printbr('\\({R^'.._G[a]..'}_{'.._G[b]..' '.._G[c]..' '.._G[d]..'} = '..x..'\\)')
				end
			end
		end
	end
end
printbr()

-- Ricci: R_ab = R^u_aub
--tensor.assign'RLL_$a_$b = RULLL_$u_$a_$u_$b'
printbr('Ricci curvature tensor')
for _,a in ipairs(coords) do
	for _,b in ipairs(coords) do
		local sum = symmath.Constant(0)
		for _,u in ipairs(coords) do
			sum = sum + _G['RULLL_'..u..'_'..a..'_'..u..'_'..b]
		end
		sum = sum:simplify()
		_G['RLL_'..a..'_'..b] = sum
		if sum ~= symmath.Constant(0) then
			printbr('\\(R_{'.._G[a]..' '.._G[b]..'} = '..sum..'\\)')
		end
	end
end
printbr()

-- Gaussian curvature: R = g^ab R_ab
printbr('Gaussian curvature')
--tensor.assign'R = gUU_$a_$b * RLL_$a_$b'
local R = symmath.Constant(0)
for _,a in ipairs(coords) do
	for _,b in ipairs(coords) do
		R = R + _G['gUU_'..a..'_'..b] * _G['RLL_'..a..'_'..b]
	end
end
R = R:simplify()
printbr('\\(R = '..R..'\\)')
printbr()


print(MathJax.footer)

