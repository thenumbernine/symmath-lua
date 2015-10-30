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
--[[ TODO don't simplify differentiation
eqns = eqns:map(function(eqn) 
	return symmath.simplify(eqn)--, {exclude={symmath.Derivative}}) 
end)
--]]
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
-- TODO make an operation out of this: 'distribute division'
do
	local found
	eqns = eqns:map(function(eqn)
		eqn = eqn:simplify()
		eqn = eqn:prune()	-- undo the last 'tidy'
		local lhs, rhs = eqn:lhs(), eqn:rhs()
		-- distribute division
		if lhs:isa(symmath.divOp) then
			local num, denom = lhs[1], lhs[2]
			if num:isa(symmath.addOp)
			or num:isa(symmath.subOp)
			then
				found = true
				lhs = getmetatable(num)(
					table.map(num, function(term,k)
						if type(k) == 'number' then
							return (term / denom):simplify()
						end
					end):unpack()
				)
			end
		end
		return lhs:equals(rhs)
	end)
end
eqns:map(function(eqn) printbr(eqn) end)

-- [[
local dq_dxs = qs:map(function(q) return q:diff(x) end)
printbr('factor derivatives')
eqns = eqns:map(function(eqn)
	-- [[ -a => a
	if eqn[1]:isa(symmath.addOp) then
		for i=#eqn[1],1,-1 do
			local expr = eqn[1][i]
			if expr:isa(symmath.unmOp) then
				if expr[1]:isa(symmath.mulOp) then
					eqn[1][i] = symmath.mulOp(symmath.Constant(-1), table.unpack(expr[1]))
				else
					eqn[1][i] = symmath.mulOp(symmath.Constant(-1), expr)
				end
			end
		end
	end
	--]]
	
	-- [[ (-(a*b*c))/d => (-1) * ((a*b*c)/d)
	eqn = eqn:map(function(expr)
		if expr:isa(symmath.divOp)
		and expr[1]:isa(symmath.unmOp)
		and expr[1][1]:isa(symmath.mulOp)
		then
			return symmath.mulOp(symmath.Constant(-1), table.unpack(expr[1][1])) / expr[2]
		end
	end)
	--]]
	-- pull out any div(mul(diff,...)) s to mul(diff,div(...)
	-- (a * b * dc/dx) / d => dc/dx * (a * b) / d
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
				return symmath.mulOp(expr, table.unpack(prods))
			end
		end
	end)
	-- factor out partials from the base addOp ...
	-- TODO matrix factor
	assert(eqn[1]:isa(symmath.addOp))
	return eqn
end)

--[=[ TODO not yet working
eqns = eqns:map(function(eqn)
	return symmath.factor(eqn, dq_dxs)
end)
--]=]
eqns:map(function(eqn) printbr(eqn) end)
--]]
printbr'factor matrix'
-- ... factor?  provide a list of expressions to factor by ... to get our matrix?
local dq_dt = symmath.Matrix({qs[1]:diff(t)}, {qs[2]:diff(t)}, {qs[3]:diff(t)})
local A = symmath.Matrix({0,0,0}, {0,0,0}, {0,0,0})
local dq_dx = symmath.Matrix({qs[1]:diff(x)}, {qs[2]:diff(x)}, {qs[3]:diff(x)})
eqns = eqns:map(function(eqn,i)
	local lhs, rhs = eqn:lhs(), eqn:rhs()
	assert(lhs:isa(symmath.addOp))
	-- find dts
	local dtIndex = table.find(lhs, nil, function(expr) return expr == qs[i]:diff(t) end)
	assert(dtIndex)
	table.remove(lhs, dtIndex)	-- destroy the lhs
	-- find dx(qj)
	for k=#lhs,1,-1 do
		
		if lhs[k]:isa(symmath.unmOp) then
			if lhs[k][1]:isa(symmath.mulOp) then
				table.insert(lhs[k][1], 1, symmath.Constant(-1))
			else
				lhs[k] = symmath.Constant(-1) * lhs[k][1]
			end
		end
		
		local found = false
		for j=1,3 do
			if lhs[k] == qs[j]:diff(x) then
				assert(not found)
				A[i][j] = (A[i][j] + 1):simplify()
				table.remove(lhs,k)
				found = true
			elseif lhs[k]:isa(symmath.mulOp) then
				for l=1,#lhs[k] do
					if lhs[k][l]:isa(symmath.mulOp) then error"needs flattening" end
					if lhs[k][l] == qs[j]:diff(x) then
						assert(not found)
						table.remove(lhs[k],l)
						A[i][j] = (A[i][j] + lhs[k]):simplify()
						found = true
					end
				end
				if found then
					table.remove(lhs,k)
				end
			end
			if found then break end
		end
	end
	-- TODO if there is anything left then put it in the rhs side
	assert(#lhs == 0)
	return lhs:equals(rhs)
end)
print((dq_dt + A * dq_dx):equals(symmath.Matrix({0},{0},{0})))

print(MathJax.footer)
