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
local q1, q2, q3 = unpack(qs)

local gamma = symmath.var('\\gamma')
local ek = .5 * (u * u)					-- kinetic specific energy
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
-- TODO don't simplify differentiation
eqns = eqns:map(function(eqn) 
	return symmath.simplify(eqn)--, {exclude={symmath.Derivative}}) 
end)
eqns:map(function(eqn) printbr(eqn) end)

printbr('substituting state variables:')
eqns = eqns:map(function(eqn)
	eqn = symmath.replace(eqn, rho, q1)
	eqn = symmath.replace(eqn, u, q2 / q1)
	eqn = symmath.replace(eqn, e, q3 / q1)
	--eqn = symmath.simplify(eqn)
	return eqn
end)
eqns:map(function(eqn) printbr(eqn) end)

printbr('simplify & expand')
eqns = eqns:map(symmath.simplify)
eqns:map(function(eqn) printbr(eqn) end)

-- [[
local dq_dxs = qs:map(function(q) return q:diff(x) end)
printbr('factor derivatives')
eqns = eqns:map(function(eqn)
	-- [[ get rid of negative signs that might block the div(mul(diff,...)) tree that the next map looks for
	eqn = eqn:map(function(expr)
		if expr:isa(symmath.divOp)
		and expr[1]:isa(symmath.unmOp)
		and expr[1][1]:isa(symmath.mulOp)
		then
			return (-1) * (expr[1][1] / expr[2])
		end
	end)
	--]]
	-- pull out any div(mul(diff,...)) s to mul(diff,div(...)
	eqn = eqn:map(function(expr)
		if expr:isa(symmath.divOp)
		and expr[1]:isa(symmath.mulOp)
		then
			local prods = table()
			local mul = expr[1]
			for i=#mul,1,-1 do
				local expr = mul[i]
				if expr:isa(symmath.Derivative) then
					prods:insert(table.remove(mul, i))
				end
			end
			if #prods > 0 then
				return mulOp(expr, table.unpack(prods))
			end
		end
	end)
	-- factor out partials from the base addOp ...
	-- TODO matrix factor
	assert(eqn[1]:isa(symmath.addOp))
	return eqn
end)
eqns = eqns:map(function(eqn)
	return symmath.factor(eqn, dq_dxs)
end)
eqns:map(function(eqn) printbr(eqn) end)
--]]

print(MathJax.footer)

-- ... factor?  provide a list of expressions to factor by ... to get our matrix?

