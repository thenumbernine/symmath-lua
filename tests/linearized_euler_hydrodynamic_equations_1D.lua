#!/usr/bin/env luajit
--[[

    File: linearized_euler_hydrodyanamic_equations.lua

    Copyright (C) 2013-2014 Christopher Moore (christopher.e.moore@gmail.com)
	  
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
MathJax.usePartialLHSForDerivative = true

local function printbr(...)
	print(...)
	print('<br>')
end

-- dimension variables
local t, x = symmath.vars('t', 'x')

-- primitive variables
local rho = symmath.var('\\rho', {t,x})	-- density
local u = symmath.var('u', {t,x})		-- velocity
local e = symmath.var('e', {t,x})		-- total specific energy 

-- state variable
local qs = range(3):map(function(i) return symmath.var('q_'..i, {t,x}) end)
local q1, q2, q3 = table.unpack(qs)

local gamma = symmath.var('\\gamma')
local ek = (u * u)/2					-- kinetic specific energy
local ei = e - ek						-- internal specific energy
local P = (gamma - 1) * rho * ei		-- pressure
local E = rho * e						-- total energy

print(MathJax.header)

-- ...equal zero
printbr('original equations:')
local diff = symmath.diff
local eqns = table{
	(diff(rho    , t) + diff(rho * u        , x)):equals(0),
	(diff(rho * u, t) + diff(rho * u * u + P, x)):equals(0),
	(diff(rho * e, t) + diff((E + P) * u    , x)):equals(0),
}
eqns:map(function(eqn) printbr(eqn) end)

printbr('substituting state variables:')
eqns = eqns:map(function(eqn)
	eqn = eqn:replace(rho, q1)
		:replace(u, q2 / q1)
		:replace(e, q3 / q1)
	return eqn
end)
eqns:map(function(eqn) printbr(eqn) end)

printbr'factor matrix'

local dq_dxs = qs:map(function(q) return q:diff(x) end)

local A, S = require 'symmath.factorLinearSystem'(
	eqns:map(function(eqn) return eqn:lhs() end), dq_dxs)

-- convert from table to matrix
local dq_dts = symmath.Matrix(qs:map(function(q)
	return {q:diff(t)}
end):unpack())

local dq_dxs = symmath.Matrix(dq_dxs:map(function(dq_dx)
	return {dq_dx}
end):unpack())

local matrixEqn = (A * dq_dxs):equals(-S)
matrixEqn = dq_dts + matrixEqn
matrixEqn[2] = matrixEqn[2]:simplify() 	-- simplify the rhs only -- keep the dts and dxs separate
printbr(matrixEqn)

print(MathJax.footer)
