#!/usr/bin/env luajit
--[[

    File: mhd_symmetrization.lua

    Copyright (C) 2014 Christopher Moore (christopher.e.moore@gmail.com)
	  
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

local function printbr(...)
	print(...)
	print('<br>')
end

-- header 

print(MathJax.header)

-- functions

function sum(f,first,last,step)
	step = step or 1
	local total
	for i=first,last,step do
		if not total then 
			total = f(i)
		else
			total = total + f(i)
		end
	end
	return total
end

-- variables

do
	local isGreek = ('rho gamma mu'):split('%s+'):map(function(v) return true,v end)
	local varNames = 'x y z t rho vx vy vz p P Z E Bx By Bz gamma mu c cs cf ca'
	printbr('variables:', varNames)
	for _,var in ipairs(varNames:split('%s+')) do
		local varname = var
		-- LaTeX greek symbols
		if isGreek[varname] then varname = '\\' .. varname end
		-- subscript
		if #varname > 1 and varname:match('[xyz]$') then varname = varname:sub(1,-2)..'_'..varname:sub(-1) end
		_G[var] = symmath.Variable(varname)
	end
	for _,var in ipairs(varNames:split('%s+')) do
		if not ({x=1,y=1,z=1,t=1})[var] then
			_G[var]:depends(x,y,z,t)
		end
	end
end

local vs = table{vx, vy, vz}
local Bs = table{Bx, By, Bz}
local xs = table{x,y,z}

local vDotB = sum(function(i) return vs[i] * Bs[i] end, 1, 3)
local divB = sum(function(i) return symmath.diff(Bs[i], xs[i]) end, 1, 3)
local BSq = sum(function(i) return Bs[i]^2 end, 1, 3)
local vSq = sum(function(i) return vs[i]^2 end, 1, 3)

-- relations

printbr('relations')

local Z_from_E_B_rho_mu = Z:equals(E + 1 / (2 * rho * mu) * BSq)
printbr(Z_from_E_B_rho_mu)

local P_from_p_B_mu = P:equals(p + 1 / (2 * mu) * BSq)
printbr(P_from_p_B_mu)

local p_from_E_rho_v_gamma = p:equals((gamma - 1) * rho * (E - 1/symmath.Constant(2) * vSq))
printbr(p_from_E_rho_v_gamma)

local cSq_from_p_rho_gamma = (c^2):equals(gamma * p / rho)
printbr(cSq_from_p_rho_gamma)

-- equations

local continuityEqn = (symmath.diff(rho, t) + sum(function(j) 
	return symmath.diff(rho*vs[j], xs[j])
end,1,3)):equals(0)

printbr()
printbr('continuity')
printbr(continuityEqn)

local momentumEqns = range(3):map(function(i)
	return (symmath.diff(rho * vs[i], t) + sum(function(j)
				return symmath.diff(rho * vs[i] * vs[j] - 1/mu * Bs[i] * Bs[j], xs[j])
			end, 1,3)
			+ symmath.diff(P, xs[i])
		):equals(
			-1/mu * Bs[i] * divB)
end)

printbr()
printbr('momentum')
momentumEqns:map(function(eqn) printbr(eqn) end)

local magneticFieldEqns = range(3):map(function(i)
	return (symmath.diff(Bs[i], t) + sum(function(j)
				return symmath.diff(vs[j] * Bs[i] - vs[i] * Bs[j], xs[j])
			end, 1,3)
		):equals(-vs[i] * divB)
end)

printbr()
printbr('magnetic field')
magneticFieldEqns:map(function(eqn) printbr(eqn) end)

local energyTotalEqn = 
	(symmath.diff(rho * Z, t) + sum(function(j)
		return (rho * Z + p) * vs[j] - 1/mu * vDotB * Bs[j]
	end, 1, 3)
	):equals(-1/mu * vDotB * divB)

printbr()
printbr('energy total')
printbr(energyTotalEqn)

-- expand system
continuityEqn:simplify()


local allEqns = table{
	continuityEqn,
	momentumEqns[1],
	momentumEqns[2],
	momentumEqns[3],
	magneticFieldEqns[1],
	magneticFieldEqns[2],
	magneticFieldEqns[3],
	energyTotalEqn
}
allEqns[1] = allEqns[1]:simplify()
allEqns[2] = allEqns[2]:simplify()
allEqns[3] = allEqns[3]:simplify()
allEqns[4] = allEqns[4]:simplify()
allEqns[5] = allEqns[5]:simplify()
allEqns[6] = allEqns[6]:simplify()
allEqns[7] = allEqns[7]:simplify()
allEqns[8] = allEqns[8]:simplify()

printbr()
printbr('all')
allEqns:map(function(eqn) printbr(eqn) end)

-- conservative variables

print(MathJax.footer)

