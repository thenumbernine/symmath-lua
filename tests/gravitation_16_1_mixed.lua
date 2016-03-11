#!/usr/bin/env luajit
--[[

    File: gravitation_16_1_mixed.lua

    Copyright (C) 2016 Christopher Moore (christopher.e.moore@gmail.com)
	  
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
local range = require 'ext.range'
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
local xyz = var'xyz'	-- index range placeholder
Tensor.coords{
	{variables = coords},
	{variables = {x,y,z}, symbols = 'ijklmn'},
	{variables = {t, xyz}, symbols = range(0,26):map(function(i)
		return string.char(('A'):byte()+i)
	end):concat()},
}

local Phi = var('\\Phi', coords)
local rho = var('\\rho', coords)
local P = var('P', coords)

local delta = var'\\delta'
local delta4LLDef = delta'_uv':eq(Tensor('_UV', {1, 0}, {0, delta'_ij'}))
printbr(delta4LLDef)
--[[
delta'_uv'() tries to transform the 2x2 mixed into a 4x4
(according to the uv coordinates) which fails... 
TODO how to handle this?
--]]
--printbr(var'\\delta''_uv':eq(delta'_uv'()))

local eta = var'\\eta'
local eta4LLDef = eta'_uv':eq(Tensor('_UV', {-1, 0}, {0, delta'_ij'}))
printbr(eta4LLDef)
--printbr(var'\\eta''_uv':eq(eta'_uv'()))

local g = var'g'
local g4LLDef = g'_uv':eq(eta'_uv' - 2*Phi*delta'_uv')
printbr(g4LLDef)
--local g = (eta'_uv' - 2 * Phi * delta'_uv')()

--[[
now for the mixed-definition metric inverse...
two ways to go about providing this:
(1) do our mixed expansion to get the full 4x4 representation of g_uv, then use the matrix inverse algorithm on that.
(2) explicitly provide a mixed representation
(3) some algebraic combination of (1) and (2) to automatically find the mixed inverse
for now I'll explicitly provide the mixed representation...
--]]
local g4UUDef = g'^uv':eq(Tensor('^UV', {-1/(1+2*Phi), 0}, {0, delta'^ij'/(1-2*Phi)}))
printbr(g4UUDef)
Tensor.metric(g, g)

local Gamma = var'\\Gamma'
local Gamma4LLLDef = Gamma'_abc':eq((g'_ab,c' + g'_ac,b' - g'_bc,a') / 2)
printbr(Gamma4LLLDef)
--[[
TODO here, expand Gamma4LLLDef, particularly the g's within it
i.e. replace all g'_ab's with mixed tensors ... that's a tough problem.
This requires knowledge of the mixed tensor nestings ...

how do we substitute g'_uv' (implicit 4x4 lower) with its def (of eta'_uv' - 2*Phi*delta'_uv') in mixed notation?
...which is Tensor('_UV', {-1,0}, {0,delta'_ij'}) - 2*Phi*Tensor('_UV', {1,0}, {0,delta'_ij'}) ?
what has to be done?
(1) gather all used indexes in the original equation: u, v
(2) create mapped group indexes.  In this case: U, V
(3) create mapped subindexes.  In this case: i,j 
(4) substitute 
Things get trickier if there are full-indexed and mixed-indexed tensors, like: g'_uv' + Tensor('_UV', {1,0}, {0,delta'_ij'})
In this case, there has to be a pre-existing association between the uv <-> UV <-> ij
If such an association must exist, it'll have to be present in the constructed mixed-rank tensor.
If that's the case, there might not be a need for group indexes.  Just so long as the subindexes add up to the full rank.
So the above statement could be replaced with: g'_uv' + Tensor('_uv', {1,0}, {0,delta'_ij'})
...where upon construction, Tensor('_uv', ...) would verify that its contents are the full rank.  it'd get 1x1 for the first col/row, and 3x3 for the delta'_ij', and add up to 4x4.
(Somewhere in there is implicit 0 -> {0,0,0} expansion as well, which might be a pain to work around.
 In fact, always doing implicit rank-2 expansion will cause ambiguities when defining Tensor('_uv',{1,0},{0,1})
 because you don't know if it's a 1+3, 2+2, or 3+1 representation.)
In the mean time ...
--]]
printbr(g'_uv,w':eq(
	-- here's another gotcha.  the substitution would have to split out the comma derivatives. 
	-- this means also incorporating comma derivative distribution in tensor representations of variables.
	g'_uv''_,w'
	-- here I'm substituting all the _uv vars for _UV dense tensors
	:subst(g4LLDef)
	:subst(eta4LLDef)
	:subst(delta4LLDef)
	-- here's where a normal simplify() should go, but it will try to simplify the indexed vars as well. 	
	:map(function(expr)
		-- map processes children first
		-- so only do this on the last node
		-- dirty hack, I know
		if require 'symmath.subOp'.is(expr) then
			return expr 
				:simplify()
				-- so I hide them, simplify, and un-hide them
				:replace(delta'_ij', var'tmp')
				:simplify()
				:replace(var'tmp', delta'_ij')
		end
	end)
))

local Gamma4ULLDef = Gamma'^a_bc':eq(g'^ad' * Gamma'_dbc')
printbr(Gamma4ULLDef)
os.exit()

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
