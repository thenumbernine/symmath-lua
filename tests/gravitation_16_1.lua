#!/usr/bin/env luajit
--[[

    File: gravitation_16_1.lua

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

-- MTW's Gravitation ch. 16 problem 1

local table = require 'ext.table'
local symmath = require 'symmath'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax 
print(MathJax.header)

local Tensor = symmath.Tensor
local var = symmath.var
local vars = symmath.vars
local div = symmath.div
local mul = symmath.mul

local function print(...)
	_G.print(...)
	_G.print'<br>'
end

local t, x, y, z = vars('t', 'x', 'y', 'z')
local coords = table{t, x, y, z}
Tensor.coords{
	{variables = coords},
	{variables = {x,y,z}, symbols = 'ijklmn'},
}

local Phi = var('\\Phi', coords)
local rho = var('\\rho', coords)
local P = var('P', coords)

local delta = var'\\delta'
local deltaDef = delta'_uv':eq(Tensor('_uv', {1,0,0,0}, {0,1,0,0}, {0,0,1,0}, {0,0,0,1}))
print(deltaDef)

local eta = var'\\eta'
local etaDef = eta'_uv':eq(Tensor('_uv', {-1,0,0,0}, {0,1,0,0}, {0,0,1,0}, {0,0,0,1}))
print(etaDef)
 
local g = var'g'
local gDef = g'_uv':eq( eta'_uv' - 2 * Phi * delta'_uv' )
print(gDef)

local gVal = gDef:rhs():subst(deltaDef, etaDef)()	-- turn the index expression into a dense tensor ...
Tensor.metric(gVal)
local gValDef = g'_uv':eq(gVal'_uv'())
print(gValDef)
local gUValDef = g'^uv':eq(gVal'^uv'())
print(gUValDef)
print()

local Gamma = var'\\Gamma'
-- TODO:
-- *) automatically separate out comma derivatives into separate TensorRef's, for easier substitution
-- *) automatically reindex subst's where applicable
-- *) make dense Tensor reindexing work just like expression reindexing
local GammaLDef = Gamma'_abc':eq(div(1,2) * (g'_ab''_,c' + g'_ac''_,b' - g'_bc''_,a'))
print(GammaLDef)
print()

local GammaLDef_wrt_eta_delta = GammaLDef:subst(
	gDef:reindex{ab='uv'},
	gDef:reindex{ac='uv'},
	gDef:reindex{bc='uv'})
print(GammaLDef_wrt_eta_delta)
print()

-- [[ can't substitute g's for eta's, then reindex, then subtitute
--	because the comma derivatives ...
-- TODO if subst gets a tensorRef on the lhs then try substituting all permutations of its indexes into the rhs
local GammaLVal = GammaLDef_wrt_eta_delta:rhs():subst(
	etaDef:reindex{ab='uv'},
	etaDef:reindex{ac='uv'},
	etaDef:reindex{bc='uv'},
	deltaDef:reindex{ab='uv'},
	deltaDef:reindex{ac='uv'},
	deltaDef:reindex{bc='uv'})
print(Gamma'_abc':eq(GammaLVal))
print()
--]]
-- [[ so instead you have to substitute the dense tensor values first

-- here's an ambiguity issue:
-- x'_uv' if x is a tensor reindex gVal
-- but x'_,c', if x is a scalar, should give the gradient of x
-- so stop using __call to reindex dense tensors -- only use :reindex 
-- but then dense tensor expressions would become ugly...
-- Gamma['_abc'] = (g:reindex{ab='uv'}'_,c' + g:reindex{ac='uv'}'_,b' + g:reindex{bc='uv'}'_,a')/2
local dgVal = gVal'_ab,c'()	-- dgVal is indexed by abc
local dgValDef = g'_ab''_,c':eq(dgVal)
local GammaLVal = GammaLDef:rhs():subst(
	dgValDef:reindex{abc='abc'},
	dgValDef:reindex{acb='abc'},
	dgValDef:reindex{bca='abc'})
--]]
print(Gamma'_abc':eq(GammaLVal))
print()

GammaLVal = GammaLVal()	-- simplify
print(Gamma'_abc':eq(GammaLVal))
print()

local GammaUVal = GammaLVal'^a_bc'()	-- here's where __call is used for reindexing
print(Gamma'^a_bc':eq(g'^ad' * Gamma'_dbc'))
print()

print(Gamma'^a_bc':eq(GammaUVal))
print()

-- assume diagonal matrix
print()
print'let $\\Phi$ ~ 0, but keep $\\partial\\Phi$ to find:'

GammaUVal = GammaUVal:replace(Phi, 0, symmath.Derivative.is)()
print(Gamma'^a_bc':eq(GammaUVal'^a_bc'()))

gVal = gVal:replace(Phi, 0, symmath.Derivative.is)()
Tensor.metric(gVal)
local gVal = gVal'_uv'()
local gValDef = g'_uv':eq(gVal)
print(gValDef)
local gUVal = gVal'^uv'()
local gUValDef = g'^uv':eq(gUVal)
print(gUValDef)
print()

local dPhi_dt_eq_0 = Phi:diff(t):eq(0)
print('let '..dPhi_dt_eq_0..' to find:')
GammaUVal = GammaUVal:subst(dPhi_dt_eq_0)()

print(Gamma'^a_bc':eq(GammaUVal'^a_bc'()))
print()

print('let')
local u = var'u'
local uVal = Tensor('^u', function(u)
	return var('u^'..coords[u].name, coords)
end)
local uDef = u'^a':eq(uVal'^a'())
print(uDef)
print()

print'matter stress-energy tensor:'
local T = var'T'
local TDef = T'^ab':eq( (rho + P) * u'^a' * u'^b' + P * g'^ab' )
print(TDef)
print()

local TVal = TDef:rhs():subst(
	u'^a':eq( uVal'^a'() ),
	u'^b':eq( uVal'^b'() ),
	g'^ab':eq(gUVal'^ab'() )
)
print(T'^ab':eq(TVal))

TVal = TVal()
print(T'^ab':eq(TVal))
print()

-- YOU ARE HERE

local divT = var'\\nabla \\cdot T'
local divT_eq_0 = divT:eq(0)
local divTVal = (TVal'^ab_,b' + GammaUVal'^a_cb' * TVal'^cb' + GammaUVal'^b_cb' * TVal'^ac')()
print()
print(divT_eq_0)
for _,eqn in ipairs(divTVal) do
	print(eqn:eq(0))
end

print()
print'low velocity relativistic approximations:'
local ut_eq_1 = uVal[1]:eq(1)
print(ut_eq_1)
divTVal = divTVal:subst(ut_eq_1)()

print()
print(divT_eq_0..' becomes:')
for _,eqn in ipairs(divTVal) do
	print(eqn:eq(0))
end

local Pu = (P * uVal'^i')()	
local div_Pu = Pu'^i_,i'()
print(div_Pu:eq(0))
divTVal[1] = (divTVal[1] - div_Pu)()

print()
print('first equation in terms of $\\partial_t \\rho$')
local drho_dt_def = divTVal[1]:eq(0):solve(rho:diff(t))
print(drho_dt_def)

print()
print'spatial equations neglect $P_{,t}$, $(P u^j)_{,j}$, $P$, and $\\Phi_{,i} u_j$ and substitutes the definition of $\\partial_t \\rho$'
for i=2,4 do
	-- remove time derivative of pressure
	divTVal[i] = divTVal[i]:replace(P:diff(t), 0)()
	
	-- this one's tough: neglect P,j u^j u^i ... but keep P,j
	divTVal[i] = (divTVal[i] - div_Pu * uVal[i])()

	-- this one too ... get rid of the P that's just floating out there.  but leave its gradients.
	divTVal[i] = divTVal[i]:replace(P, 0, symmath.Derivative.is)()

	-- substitute drho/dt definition to cancel some terms out
	divTVal[i] = divTVal[i]:subst(drho_dt_def)()

	-- get rid of any Phi,j times u,k of any kind ... hmm ...
	divTVal[i] = divTVal[i]:map(function(expr)
		if not mul.is(expr) then return end
		local dPhi = Phi'_,i'()
		local foundDPhi
		local foundU
		expr:map(function(node)
			foundDPhi = foundDPhi or table.find(dPhi, node)
			foundU = foundU or table.find(uVal, node)
		end)
		if foundDPhi and foundU then return 0 end
	end)()
end

print()
print(divT_eq_0..' becomes:')
for _,eqn in ipairs(divTVal) do
	print(eqn:eq(0))
end

_G.print(MathJax.footer)
