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

local function println(...)
	print(...)
	print('<br>')
end

-- primitive variables
local rho = symmath.Variable('\\rho', nil, true)	-- density
local u = symmath.Variable('u', nil, true)		-- velocity
local v = symmath.Variable('v', nil, true)
local w = symmath.Variable('w', nil, true)
local e = symmath.Variable('e', nil, true)		-- total specific energy 

-- state variable
local q1 = symmath.Variable('q1', nil, true)
local q2 = symmath.Variable('q2', nil, true)
local q3 = symmath.Variable('q3', nil, true)
local q4 = symmath.Variable('q4', nil, true)
local q5 = symmath.Variable('q5', nil, true)

-- dimension variables
local t = symmath.Variable('t', nil, true)
local x = symmath.Variable('x', nil, true)
local y = symmath.Variable('y', nil, true)
local z = symmath.Variable('z', nil, true)

local gamma = symmath.Variable('\\gamma')
local ek = .5 * (u * u + v * v + w * w)			-- kinetic specific energy
local ei = e - .5 * ek							-- internal specific energy
local P = (gamma - 1) * rho * ei				-- pressure
local E = rho * e								-- total energy

print(MathJax.header)

-- ...equal zero
println('original equations:')
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
eqns:map(function(eqn) println(eqn) end)

println('substituting state variables:')
eqns = eqns:map(function(eqn)
	eqn = symmath.replace(eqn, rho, q1)
	eqn = symmath.replace(eqn, u, q2 / q1)
	eqn = symmath.replace(eqn, v, q3 / q1)
	eqn = symmath.replace(eqn, w, q4 / q1)
	eqn = symmath.replace(eqn, e, q5 / q1)
	--eqn = symmath.simplify(eqn)
	return eqn
end)
eqns:map(function(eqn) println(eqn) end)

println('simplify & expand')
eqns = eqns:map(symmath.simplify)
eqns:map(function(eqn) println(eqn) end)

println('factor derivatives')
eqns = symmath.factor(eqns, function(eqn)
	return symmath.factor(eqn, {symmath.diff(q1, x), symmath.diff(q2, x), symmath.diff(q3, x)})
end)

print(MathJax.footer)

-- ... factor?  provide a list of expressions to factor by ... to get our matrix?

