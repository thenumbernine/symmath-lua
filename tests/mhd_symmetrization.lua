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
symmath.simplifyDivisionByPower = true

local oldPrint = print
local function print(...)
	oldPrint(...)
	oldPrint('<br>')
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
	print('variables:', varNames)
	for _,var in ipairs(varNames:split('%s+')) do
		local varname = var
		-- LaTeX greek symbols
		if isGreek[varname] then varname = '\\' .. varname end
		-- subscript
		if #varname > 1 and varname:match('[xyz]$') then varname = varname:sub(1,-2)..'_'..varname:sub(-1) end
		_G[var] = symmath.Variable(varname, nil, true)
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

print('relations')

local Z_from_E_B_rho_mu = Z:equals(E + 1 / (2 * rho * mu) * BSq)
print(Z_from_E_B_rho_mu)

local P_from_p_B_mu = P:equals(p + 1 / (2 * mu) * BSq)
print(P_from_p_B_mu)

local p_from_E_rho_v_gamma = p:equals((gamma - 1) * rho * (E - 1/symmath.Constant(2) * vSq))
print(p_from_E_rho_v_gamma)

local cSq_from_p_rho_gamma = (c^2):equals(gamma * p / rho)
print(cSq_from_p_rho_gamma)

-- equations

local continuityEqn = (symmath.diff(rho, t) + sum(function(j) 
	return symmath.diff(rho*vs[j], xs[j])
end,1,3):equals(0)

print()
print('continuity')
print(continuityEqn)

local momentumEqns = range(3):map(function(i)
	return (symmath.diff(rho * vs[i], t) + sum(function(j)
				return symmath.diff(rho * vs[i] * vs[j] - 1/mu * Bs[i] * Bs[j], xs[j])
			end, 1,3)
			+ symmath.diff(P, xs[i])
		):equals(
			-1/mu * Bs[i] * divB)
end)

print()
print('momentum')
momentumEqns:map(function(eqn) print(eqn) end)

local magneticFieldEqns = range(3):map(function(i)
	return (symmath.diff(Bs[i], t) + sum(function(j)
				return symmath.diff(vs[j] * Bs[i] - vs[i] * Bs[j], xs[j])
			end, 1,3)
		):equals(-vs[i] * divB)
end)

print()
print('magnetic field')
magneticFieldEqns:map(function(eqn) print(eqn) end)

local energyTotalEqn = 
	(symmath.diff(rho * Z, t) + sum(function(j)
		return (rho * Z + p) * vs[j] - 1/mu * vDotB * Bs[j]
	end, 1, 3)
	):equals(-1/mu * vDotB * divB)

print()
print('energy total')
print(energyTotalEqn)

-- expand system

local allEqns = table()
	:append{continuityEqn}
	:append(momentumEqns)
	:append(magneticFieldEqns)
	:append{energyTotalEqn}
	:map(function(eqn)
		return symmath.simplify(eqn)
	end)

print()
print('all')
allEqns:map(function(eqn) print(eqn) end)

-- conservative variables

print(MathJax.footer)

