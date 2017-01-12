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
local print_ = print
local function print(...) print_(...) print_'<br>' end
print_(MathJax.header)

require 'symmath.tostring.LaTeX'.usePartialLHSForDerivative = true

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
print()
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
print()
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
print()
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
print()
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
local ijk = var'ijk'	-- not sure about this ...
local spatialCoords = {x,y,z}
local coords = {t,x,y,z}
local spacetimeIndexes = {variables=coords}
local spatialIndexes = {symbols='ijklmn', variables=spatialCoords}
local groupedSpatialIndexes = {symbols='IJKLMN', variables={ijk}}
local groupedIndexes = {symbols='UVW', variables={t,ijk}}	-- maybe 'group' to specify that a split will happen?  but that restricts to a certain form
Tensor.coords{
	spacetimeIndexes,
	spatialIndexes,
	groupedIndexes,
}
local alpha = var'\\alpha'
local beta = var'\\beta'
local gamma = var'\\gamma'
local g = var'g'

print(alpha)
print(beta'^i')
print(gamma'_ij')
print(gamma'^ij')

-- metric
--[[
how to handle subtensors ... 
how to we declare the indexes of a tensor to use subindexes?
if we say Tensor'_uv' for defaults uv on coords t,x,y,z then the ctor will span 4 variables ...
if we create a new set of indexes for groups of indexes ... we'd have to specify the layout beforehand (to be compatible with the current system)
if we use matrices ...
... then how will we access them in the future?
--]]
local gLLDef = g'_uv':eq(Tensor('_UV', 
	{
		-alpha^2 + beta'^k' * beta'_k',
		beta'_j',
	}, {
		beta'_i',
		gamma'_ij',
	}
))
print(gLLDef)

local gUUDef = g'^uv':eq(Tensor('^UV',
	{
		-1/alpha^2,
		beta'^j'/alpha^2,
	}, {
		beta'^i'/alpha^2,
		gamma'^ij' - beta'^i' * beta'^j' / alpha^2,
	}
))
print(gUUDef)

--[[
now if 'group' was used in the index definitions ... (TODO rename Tensor.coords to Tensor.indexes)
I wouldn't need 'group' if I just had separate index information for grouped and non-grouped tensors
... so gamma and beta would be defined on indexes where ijk span xyz
... but g would be defined on indexes where ijk reprsent a single coordinate (which can be later expanded)

... then we could do something like this:
g = Tensor('_UV', {alpha, beta'_i'}, {beta'_j', gamma'_ij'}) 
... and then ...
print(g'_ij'()) to show gamma_ij
--]]
--print(gLLDef:rhs()'_IJ')	-- this would work if the code were in place for the notion of g'_tt' to return a scalar ... same principle

local Gamma = var'\\Gamma'
print(Gamma'_abc':eq((g'_ab,c' + g'_ac,b' - g'_bc,a') / 2))

os.exit()
print(var'\\Gamma''_abc':eq(Gamma'_abc'()))
Gamma = Gamma'^a_bc'()
print(var'\\Gamma''^a_bc':eq(Gamma'^a_bc'()))

local Riemann = Tensor'^a_bcd'
Riemann['^a_bcd'] = (Gamma'^a_bd,c' - Gamma'^a_bc,d' + Gamma'^a_ec' * Gamma'^e_bd' - Gamma'^a_ed' * Gamma'^e_bc')()
print('${R^a}_{bcd} = $'..Riemann'^a_bcd')

print_(MathJax.footer)
