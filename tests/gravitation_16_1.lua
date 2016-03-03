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

local function printbr(...) print(...) print'<br>' end

local t, x, y, z = vars('t', 'x', 'y', 'z')
local coords = table{t, x, y, z}
Tensor.coords{
	{variables = coords},
	{variables = {x,y,z}, symbols = 'ijklmn'},
}

local Phi = var('\\Phi', coords)
local rho = var('\\rho', coords)
local P = var('P', coords)

local delta = Tensor('_uv', {1,0,0,0}, {0,1,0,0}, {0,0,1,0}, {0,0,0,1})
printbr(var'\\delta''_uv':eq(delta'_uv'()))

local eta = Tensor('_uv', {-1,0,0,0}, {0,1,0,0}, {0,0,1,0}, {0,0,0,1})
printbr(var'\\eta''_uv':eq(eta'_uv'()))

local g = (eta'_uv' - 2 * Phi * delta'_uv')()
Tensor.metric(g)

printbr(var'g''_uv':eq(g'_uv'()))
printbr(var'g''^uv':eq(g'^uv'()))

local Gamma = ((g'_ab,c' + g'_ac,b' - g'_bc,a') / 2)()
printbr(var'\\Gamma''_abc':eq(Gamma'_abc'()))
Gamma = Gamma'^a_bc'()
printbr(var'\\Gamma''^a_bc':eq(Gamma'^a_bc'()))

-- assume diagonal matrix
printbr()
printbr[[let $\Phi$ ~ 0, but keep $d\Phi$]]

Gamma = Gamma:replace(Phi, 0, symmath.Derivative.is)()
printbr(var'\\Gamma''^a_bc':eq(Gamma'^a_bc'()))

g = g:replace(Phi, 0, symmath.Derivative.is)()
Tensor.metric(g)
printbr(var'g''_uv':eq(g'_uv'()))
printbr(var'g''^uv':eq(g'^uv'()))

local dPhi_dt_eq_0 = Phi:diff(t):eq(0)
printbr()
printbr('let '..dPhi_dt_eq_0)
Gamma = Gamma:subst(dPhi_dt_eq_0)()

printbr(var'\\Gamma''^a_bc':eq(Gamma'^a_bc'()))

local u = Tensor('^u', function(u) return var('u^'..coords[u].name, coords) end)
printbr(var'u''^a':eq(u'^a'()))

printbr()
printbr'matter stress-energy tensor:'
local T = ((rho + P) * u'^a' * u'^b' + P * g'^ab')()
printbr(var'T''^ab':eq(T'^ab'()))

local div_T = (T'^ab_,b' + Gamma'^a_cb' * T'^cb' + Gamma'^b_cb' * T'^ac')()
printbr()
printbr'$\\nabla \\cdot T = 0$'
for _,eqn in ipairs(div_T) do
	printbr(eqn:eq(0))
end

printbr()
printbr'low velocity relativistic approximations:'
local ut_eq_1 = u[1]:eq(1)
printbr(ut_eq_1)
div_T = div_T:subst(ut_eq_1)()

printbr()
printbr'$\\nabla \\cdot T = 0$ becomes:'
for _,eqn in ipairs(div_T) do
	printbr(eqn:eq(0))
end

local Pu = (P * u'^i')()	
local div_Pu = Pu'^i_,i'()
printbr(div_Pu:eq(0))
div_T[1] = (div_T[1] - div_Pu)()

printbr()
printbr('first equation in terms of $\\partial_t \\rho$')
local drho_dt_def = div_T[1]:eq(0):solve(rho:diff(t))
printbr(drho_dt_def)

printbr()
printbr'spatial equations neglect $P_{,t}$, $(P u^j)_{,j}$, $P$, and $\\Phi_{,i} u_j$ and substitutes the definition of $\\partial_t \\rho$'
for i=2,4 do
	-- remove time derivative of pressure
	div_T[i] = div_T[i]:replace(P:diff(t), 0)()
	
	-- this one's tough: neglect P,j u^j u^i ... but keep P,j
	div_T[i] = (div_T[i] - div_Pu * u[i])()

	-- this one too ... get rid of the P that's just floating out there.  but leave its gradients.
	div_T[i] = div_T[i]:replace(P, 0, symmath.Derivative.is)()

	-- substitute drho/dt definition to cancel some terms out
	div_T[i] = div_T[i]:subst(drho_dt_def)()

	-- get rid of any Phi,j times u,k of any kind ... hmm ...
	div_T[i] = div_T[i]:map(function(expr)
		if not symmath.mulOp.is(expr) then return end
		local dPhi = Phi'_,i'()
		local foundDPhi
		local foundU
		expr:map(function(node)
			foundDPhi = foundDPhi or table.find(dPhi, node)
			foundU = foundU or table.find(u, node)
		end)
		if foundDPhi and foundU then return 0 end
	end)()
end

printbr()
printbr'$\\nabla \\cdot T = 0$ becomes:'
for _,eqn in ipairs(div_T) do
	printbr(eqn:eq(0))
end

print(MathJax.footer)
