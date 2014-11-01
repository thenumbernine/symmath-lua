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

require 'ext'

local symmath = require 'symmath'
local MathJax = require 'symmath.tostring.MathJax'
symmath.toStringMethod = MathJax
symmath.simplifyConstantPowers  = true

local function printbr(...)
	print(...)
	print('<br>')
end

-- dimension variables
local t = symmath.Variable('t', nil, true)
local x = symmath.Variable('x', nil, true)
local y = symmath.Variable('y', nil, true)
local z = symmath.Variable('z', nil, true)

-- primitive variables
local rho = symmath.Variable('\\rho', {t,x,y,z})	-- density
local u = symmath.Variable('u', {t,x,y,z})		-- velocity
local v = symmath.Variable('v', {t,x,y,z})
local w = symmath.Variable('w', {t,x,y,z})
local e = symmath.Variable('e', {t,x,y,z})		-- total specific energy 

-- state variable
local q1 = symmath.Variable('q1', {t,x,y,z})
local q2 = symmath.Variable('q2', {t,x,y,z})
local q3 = symmath.Variable('q3', {t,x,y,z})
local q4 = symmath.Variable('q4', {t,x,y,z})
local q5 = symmath.Variable('q5', {t,x,y,z})

local gamma = symmath.Variable('\\gamma')
local ek = symmath.Constant(1)/symmath.Constant(2) * (u * u + v * v + w * w)			-- kinetic specific energy
local ei = e - symmath.Constant(1)/symmath.Constant(2) * ek							-- internal specific energy
local P = (gamma - 1) * rho * ei				-- pressure
local E = rho * e								-- total energy

print(MathJax.header)

-- ...equal zero
printbr('original equations:')
local diff = symmath.diff
local eqns = table{
	symmath.equals(diff(rho    , t) + diff(rho * u        , x) + diff(rho * v        , y) + diff(rho * w        , z), 0),
	symmath.equals(diff(rho * u, t) + diff(rho * u * u + P, x) + diff(rho * u * v    , y) + diff(rho * u * w    , z), 0),
	symmath.equals(diff(rho * v, t) + diff(rho * v * u    , x) + diff(rho * v * v + P, y) + diff(rho * v * w    , z), 0),
	symmath.equals(diff(rho * w, t) + diff(rho * w * u    , x) + diff(rho * w * v    , y) + diff(rho * w * w + P, z), 0),
	symmath.equals(diff(rho * e, t) + diff((E + P) * u    , x) + diff((E + P) * v    , y) + diff((E + P) * w    , z), 0),
}
-- TODO don't simplify differentiation
eqns = eqns:map(function(eqn) 
	return symmath.simplify(eqn)--, {exclude={symmath.Derivative}}) 
end)
eqns:map(function(eqn) printbr(eqn) end)

printbr('substituting state variables:')
eqns = eqns:map(function(eqn)
	eqn = symmath.replace(eqn, rho, q1)
	eqn = symmath.replace(eqn, u, q2 / q1)
	eqn = symmath.replace(eqn, v, q3 / q1)
	eqn = symmath.replace(eqn, w, q4 / q1)
	eqn = symmath.replace(eqn, e, q5 / q1)
	--eqn = symmath.simplify(eqn)
	return eqn
end)
eqns:map(function(eqn) printbr(eqn) end)

printbr('simplify & expand')
eqns = eqns:map(symmath.simplify)
eqns:map(function(eqn) printbr(eqn) end)

--[[
printbr('factor derivatives')
eqns = symmath.factor(eqns, function(eqn)
	return symmath.factor(eqn, {symmath.diff(q1, x), symmath.diff(q2, x), symmath.diff(q3, x)})
end)
--]]

print(MathJax.footer)

-- ... factor?  provide a list of expressions to factor by ... to get our matrix?

