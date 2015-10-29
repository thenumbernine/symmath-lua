#!/usr/bin/env luajit
--[[

    File: gravitation_16_1.lua

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

-- MTW's Gravitation ch. 16 problem 1

local table = require 'ext.table'
local symmath = require 'symmath'
local Tensor = require 'symmath.Tensor'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax 
print(MathJax.header)

local function printbr(...) print(...) print'<br>' end

local t, x, y, z = symmath.vars('t', 'x', 'y', 'z')
local coords = table{t, x, y, z}
Tensor.coords{
	{
		variables = coords,
	},
	{
		variables = {x,y,z},
		symbols = 'ijklmn',
	}
}

local Phi = symmath.var('\\Phi', coords)
local rho = symmath.var('\\rho', coords)
local P = symmath.var('P', coords)

local delta = Tensor('_uv', {1,0,0,0}, {0,1,0,0}, {0,0,1,0}, {0,0,0,1})
printbr('$\\delta_{uv} = $'..delta'_uv')

local eta = Tensor('_uv', {-1,0,0,0}, {0,1,0,0}, {0,0,1,0}, {0,0,0,1})
printbr('$\\eta_{uv} = $'..eta'_uv')

local g = (eta'_uv' - 2 * Phi * delta'_uv'):simplify()
printbr('$g_{uv} = $'..g'_uv')
Tensor.metric(g)
printbr('$g^{uv} = $'..g'^uv')

local Gamma = ((g'_ab,c' + g'_ac,b' - g'_bc,a') / 2):simplify()
printbr('$\\Gamma_{abc} = $'..Gamma'_abc')
Gamma = Gamma'^a_bc'
printbr('${\\Gamma^a}_{bc} = $'..Gamma'^a_bc')

-- assume diagonal matrix
printbr[[let $\Phi$ ~ 0, but keep $d\Phi$]]

Gamma = Gamma:replace(Phi, 0, function(v) return symmath.Derivative.is(v) end):simplify()
printbr('${\\Gamma^a}_{bc} = $'..Gamma'^a_bc')

g = g:replace(Phi, 0, function(v) return symmath.Derivative.is(v) end):simplify()
Tensor.metric(g)
printbr('$g_{uv} = $'..g'_uv')
printbr('$g^{uv} = $'..g'^uv')

local dPhi_dt_equals_0 = Phi:diff(t):equals(0)
printbr(dPhi_dt_equals_0)
Gamma = Gamma:subst(dPhi_dt_equals_0):simplify()

printbr('${\\Gamma^a}_{bc} = $'..Gamma'^a_bc')

local u = Tensor('^a', coords:map(function(x) return symmath.var('u^'..x.name, coords) end):unpack())
printbr('$u^a = $'..u'^a')

printbr'matter stress-energy tensor'
local T = ((rho + P) * u'^a' * u'^b' + P * g'^ab'):simplify()
printbr('$T^{ab} = $'..T'^ab')

local div_T = (T'^ab_,b' + Gamma'^a_cb' * T'^cb' + Gamma'^b_cb' * T'^ac'):simplify()
printbr'constraint equation of $\\nabla \\cdot T = 0$'
for _,eqn in ipairs(div_T) do
	printbr(eqn:equals(0))
end

printbr'low velocity relativistic approximations:'
local ut_equals_1 = u[1]:equals(1)
printbr(ut_equals_1)
div_T = div_T:subst(ut_equals_1):simplify()

printbr'constraint equation of $\\nabla \\cdot T = 0$'
for _,eqn in ipairs(div_T) do
	printbr(eqn:equals(0))
end

-- hmm without the simplify the tensor derivative doesn't work ...
-- between this and the idea of producing scalar gradients, I might have to overload *all* nodes with tensor syntax handling 
local Pu = (P * u'^i'):simplify()	
local div_Pu = Pu'^i_,i'
printbr(div_Pu:equals(0))
div_T[1] = (div_T[1] - div_Pu):simplify()

printbr('in terms of $\\partial_t \\rho$')
local drho_dt_def = div_T[1]:equals(0):solve(rho:diff(t))
printbr(drho_dt_def)

printbr'space equation neglects'
for i=2,4 do
	-- remove time derivative of pressure
	div_T[i] = div_T[i]:replace(P:diff(t), 0):simplify()
	
	-- this one's tough: neglect P,j u^j u^i ... but keep P,j
	div_T[i] = (div_T[i] - div_Pu * u[i]):simplify()

	-- this one too ... get rid of the P that's just floating out there.  but leave its gradients.
	div_T[i] = div_T[i]:replace(P, 0, function(v) return symmath.Derivative.is(v) end):simplify()

	-- substitute drho/dt definition to cancel some terms out
	div_T[i] = div_T[i]:subst(drho_dt_def):simplify()

	-- get rid of any Phi,j times u,k of any kind ... hmm ...
	div_T[i] = div_T[i]:map(function(expr)
		if not expr:isa(symmath.mulOp) then return end
		local dPhi = {Phi:diff(x), Phi:diff(y), Phi:diff(z)}
		local foundDPhi
		local foundU
		expr:map(function(node)
			foundDPhi = foundDPhi or table.find(dPhi, node)
			foundU = foundU or table.find(u, node)
		end)
		if foundDPhi and foundU then return 0 end
	end):simplify()
end

printbr'constraint equation of $\\nabla \\cdot T = 0$'
for _,eqn in ipairs(div_T) do
	printbr(eqn:equals(0))
end

print(MathJax.footer)
