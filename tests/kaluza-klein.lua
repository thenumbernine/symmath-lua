#!/usr/bin/env luajit
--[[

    File: kaluza-klein.lua

    Copyright (C) 2013-2016 Christopher Moore (christopher.e.moore@gmail.com)
	  
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
local printbr = MathJax.print

local Tensor = symmath.Tensor
local var = symmath.var
local vars = symmath.vars

--[[
g_ab =	[ g_uv + phi^2 A_u A_v	phi^2 A^u	 ]
		[	phi^2 A_v			phi^2		 ]
g^ab =	[ 	g^uv				-A^u		 ]
		[	-A^v				A^2 + phi^-2 ]
--]]

local t, x, y, z, w = vars('t', 'x', 'y', 'z', 'w')
local coords = {t, x, y, z, w}
-- w = x^5, or the A^mu vector combined with the phi^2 ...
local phi = var('\\phi', {t,x,y,z,w})

Tensor.coords{
	{variables={t,x,y,z}},
	{variables={t,x,y,z,w}, symbols='abcdef'},
}

-- 4D metric tensor
-- keeping it 4D at the moment
-- if one were so inclined they might insert the adm 3+1 metric here ...
local gLL = Tensor('_uv', function(u,v) return var('g_{'..u..v..'}', coords) end)
printbr'4D metric tensor:'
printbr(var'g''_uv':eq(gLL'_uv'()))

local gUU = Tensor('^uv', function(u,v) return var('g^{'..u..v..'}', coords) end)
printbr('4D metric tensor inverse')
printbr(var'g''^uv':eq(gUU'^uv'()))

Tensor.metric(gLL, gUU)

-- EM potential 4-vector
printbr'EM potential vector:'
local AL = Tensor('_u', function(u) return var('A_'..u, coords) end)
printbr(var'A''_u':eq(AL'_u'()))
local AU = Tensor('^u', function(u) return var('A^'..u, coords) end)
printbr(var'A''^u':eq(AU'^u'()))
local ASq = var('A^2', coords)	-- helper for representing A^2 = A^u A_u
printbr(ASq:eq(AU'^u' * AL'_u')())

-- 5D metric tensor
printbr'5D metric tensor:'
local g5LL = Tensor('_ab', function(a,b)
	if a < 5 and b < 5 then
		return gLL[a][b] + phi^2 * AL[a] * AL[b]
	elseif a < 5 then
		return phi^2 * AL[a]
	elseif b < 5 then
		return phi^2 * AL[b]
	else
		return phi^2
	end
end)
printbr(var'\\tilde{g}''_ab':eq(g5LL'_ab'()))
--[[ TODO
g5LL['_uv'] = gLL'_uv' + phi^2 * AL'_u' * AL'_v'
g5LL['_uw'] = phi^2 * AL'_u'
g5LL['_wv'] = phi^2 * AL'_v'
g5LL['_ww'] = phi^2
--]]

printbr'5D metric tensor inverse:'
local g5UU = Tensor('^ab', function(a,b)
	if a < 5 and b < 5 then
		return gUU[a][b]
	elseif a < 5 then
		return -AU[a]
	elseif b < 5 then
		return -AU[b]
	else
		return ASq + phi^-2
	end
end)
--[[ TODO
g5UU['^uv'] = gUU'_uv'
g5UU['^uw'] = -AU'^u'
g5UU['^wv'] = -AU'^v'
g5UU['^ww'] = ASq + phi^-2
--]]
printbr(var'\\tilde{g}''^ab':eq(g5UU'^ab'))

Tensor.metric(g5LL, g5UU, 'a')	-- TODO think up better arguments for this

printbr'cylindrical constraint:'
local g5cylinderLL = g5LL'_ab':diff(w):eq(Tensor'_ab')()	-- TODO allow g5LL'_ab,w' or g5LL'_ab,5'
printbr(g5cylinderLL)
-- TODO extract unique equations from tensor/tensor equality

-- now comes the manual assumption that g5_ab,c = 0 ...
local dg5 = g5LL'_ab,c'()
local Gamma5 = ((dg5'_abc' + dg5'_acb' - dg5'_bca') / 2)()
printbr'1st kind Christoffel:'
printbr(var'\\Gamma''_abc':eq(Gamma5'_abc'()))

-- 2nd kind
printbr'2nd kind Christoffel:'
Gamma5 = Gamma5'^a_bc'()	-- should raise with the metric of 'a' ... which is the g5-metric
printbr(var'\\Gamma''^a_bc':eq(Gamma5'^a_bc'()))

print(MathJax.footer)
