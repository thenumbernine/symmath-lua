#!/usr/bin/env luajit
--[[

    File: linearized_euler_hydrodyanamic_equations.lua

    Copyright (C) 2013-2015 Christopher Moore (christopher.e.moore@gmail.com)
	  
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
local factorLinearSystem = require 'symmath.factorLinearSystem'
local vars = symmath.vars
local var = symmath.var
local add = symmath.addOp	-- why the 'Op' suffix anyways?
local Matrix = symmath.Matrix

local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
MathJax.usePartialLHSForDerivative = true

print(MathJax.header)

local function printbr(...)
	print(...)
	print('<br>')
end

-- dimension variables
local t, x, y, z = vars('t', 'x', 'y', 'z')

-- primitive variables
local rho = var('\\rho', {t,x,y,z})	-- density

local ux = var('u_x', {t,x,y,z})	-- velocity
local uy = var('u_y', {t,x,y,z})
local uz = var('u_z', {t,x,y,z})

local e = var('e', {t,x,y,z})		-- total specific energy 

-- dimension related
for dim=1,3 do
	print('<h3>'..dim..'D case:</h3>')
	
	local us = table{ux, uy, uz} 
	us = us:sub(1,dim)
	local xs = table{x,y,z}
	xs = xs:sub(1,dim)
	local uSq = dim == 1 and ux^2 or add(us:map(function(u) return u^2 end):unpack())

	-- state variable
	local qs = range(dim+2):map(function(i) return var('q_'..i, {t,x,y,z}) end)
	local q1, q2, q3, q4, q5 = table.unpack(qs)

	-- other variables
	local gamma = var('\\gamma')
	local ek = uSq/2					-- specific kinetic energy
	local ei = e - ek					-- specific internal energy
	local P = (gamma - 1) * rho * ei	-- pressure
	local E = rho * e					-- total energy

	-- equations 
	printbr('original equations:')

	local continuityEqn = (rho:diff(t) + 
		add(range(dim):map(function(j)
			return (rho * us[j]):diff(xs[j])
		end):unpack())):equals(0)

	local momentumEqns = range(dim):map(function(i)
		return ((rho * us[i]):diff(t) + add(range(dim):map(function(j)
			return (rho * us[i] * us[j] + (i==j and P or 0)):diff(xs[j])
		end):unpack())):equals(0)
	end)

	local energyEqn = ((rho * e):diff(t) +
		add(range(dim):map(function(j)
			return ((E + P) * us[j]):diff(xs[j])
		end):unpack())):equals(0)

	local eqns = table{continuityEqn}:append(momentumEqns):append{energyEqn}

	eqns:map(function(eqn) printbr(eqn) end)

	printbr('substituting state variables:')
	eqns = eqns:map(function(eqn)
		local i = 1
		eqn = eqn:replace(rho, qs[i]) i=i+1
		for j=1,dim do
			eqn = eqn:replace(us[j], qs[i] / qs[1]) i=i+1
		end
		assert(qs[i], "failed to find state var for "..i)
		eqn = eqn:replace(e, qs[i] / qs[1])
		
		return eqn
	end)
	eqns:map(function(eqn) printbr(eqn) end)

	printbr'distribute'

	eqns = eqns:map(function(eqn) return eqn:distributeDivision() end)
	eqns:map(function(eqn) printbr(eqn) end)

	printbr'factor matrix'

	local remainingTerms = Matrix(eqns:map(function(eqn)
		return {eqn:lhs()}
	end):unpack())

	local matrixLHS

	local dFk_dqs = table()
	for j=1,dim do
		local dq_dxk = qs:map(function(q) return q:diff(xs[j]) end)

		local dFk_dq
		dFk_dq, remainingTerms = factorLinearSystem(
			table.map(remainingTerms, function(row) return row[1] end), dq_dxk)
		dFk_dqs:insert(dFk_dq)

		local dq_dxk = Matrix(dq_dxk:map(function(dq_dx)
			return {dq_dx}
		end):unpack())

		local dFk_dxk = dFk_dq * dq_dxk
		matrixLHS = matrixLHS and (matrixLHS + dFk_dxk) or dFk_dxk
	end

	local matrixRHS = -remainingTerms

	-- convert from table to matrix
	local dq_dts = Matrix(qs:map(function(q)
		return {q:diff(t)}
	end):unpack())

	-- remove the dq_dts from the source term (and add them to the right-hand side)
	matrixLHS = dq_dts + matrixLHS
	matrixRHS = dq_dts + matrixRHS

	matrixRHS = matrixRHS:simplify() 	-- simplify the rhs only -- keep the dts and dxs separate
	printbr(matrixLHS:equals(matrixRHS))

	printbr('eigenvalues of ${{\\partial F_x}\\over{\\partial q}}$')
	local lambda = var'\\lambda'
	local det = (dFk_dqs[1] - Matrix.identity(#qs) * lambda):determinant():equals(0)
	printbr(det)
	printbr(det:solve(lambda))
end

print(MathJax.footer)
