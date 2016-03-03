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

local table = require 'ext.table'
local range = require 'ext.range'
local symmath = require 'symmath'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
print(MathJax.header)

local function printbr(...) print(...) print'<br>' end

local var = symmath.var
local vars = symmath.vars

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

local x,y,z,t = vars('x','y','z','t')
local rho = var'\\rho'
local vx,vy,vz = vars('v_x','v_y','v_z')
local p,P,Z,E = vars('p','P','Z','E')
local Bx,By,Bz = vars('B_x','B_y','B_z')
local gamma,mu = vars('\\gamma','\\mu')
local c,cs,cf,ca = vars('c','cs','cf','ca')
for _,v in ipairs{rho,vx,vy,vz,p,P,Z,E,Bx,By,Bz,c,cs,cf,ca} do
	v:depends(x,y,z,t)
end

local vs = table{vx, vy, vz}
local Bs = table{Bx, By, Bz}
local xs = table{x,y,z}

local vDotB = sum(function(i) return vs[i] * Bs[i] end, 1, 3)
local divB = sum(function(i) return symmath.diff(Bs[i], xs[i]) end, 1, 3)
local BSq = sum(function(i) return Bs[i]^2 end, 1, 3)
local vSq = sum(function(i) return vs[i]^2 end, 1, 3)

-- relations

printbr'relations'

local Z_from_E_B_rho_mu = Z:eq(E + 1 / (2 * rho * mu) * BSq)
printbr(Z_from_E_B_rho_mu)

local P_from_p_B_mu = P:eq(p + 1 / (2 * mu) * BSq)
printbr(P_from_p_B_mu)

local p_from_E_rho_v_gamma = p:eq((gamma - 1) * rho * (E - 1/symmath.Constant(2) * vSq))
printbr(p_from_E_rho_v_gamma)

local cSq_from_p_rho_gamma = (c^2):eq(gamma * p / rho)
printbr(cSq_from_p_rho_gamma)

-- equations

local continuityEqn = (symmath.diff(rho, t) + sum(function(j) 
	return (rho*vs[j]):diff(xs[j])
end,1,3)):eq(0)

printbr()
printbr'continuity'
printbr(continuityEqn)

local momentumEqns = range(3):map(function(i)
	return ((rho * vs[i]):diff(t) + sum(function(j)
				return (rho * vs[i] * vs[j] - 1/mu * Bs[i] * Bs[j]):diff(xs[j])
			end, 1,3)
			+ P:diff(xs[i])
		):eq(
			-1/mu * Bs[i] * divB)
end)

printbr()
printbr'momentum'
momentumEqns:map(function(eqn) printbr(eqn) end)

local magneticFieldEqns = range(3):map(function(i)
	return (symmath.diff(Bs[i], t) + sum(function(j)
				return symmath.diff(vs[j] * Bs[i] - vs[i] * Bs[j], xs[j])
			end, 1,3)
		):eq(-vs[i] * divB)
end)

printbr()
printbr'magnetic field'
magneticFieldEqns:map(function(eqn) printbr(eqn) end)

local energyTotalEqn = 
	(symmath.diff(rho * Z, t) + sum(function(j)
		return (rho * Z + p) * vs[j] - 1/mu * vDotB * Bs[j]
	end, 1, 3)
	):eq(-1/mu * vDotB * divB)

printbr()
printbr'energy total'
printbr(energyTotalEqn)

-- expand system
continuityEqn = continuityEqn()


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
allEqns[1] = allEqns[1]()
allEqns[2] = allEqns[2]()
allEqns[3] = allEqns[3]()
allEqns[4] = allEqns[4]()
allEqns[5] = allEqns[5]()
allEqns[6] = allEqns[6]()
allEqns[7] = allEqns[7]()
allEqns[8] = allEqns[8]()

printbr()
printbr'all'
allEqns:map(function(eqn) printbr(eqn) end)

-- conservative variables

--[[
-- Eigenvectors from Trangenstein J. A. "A Numerical Solution of Hyperbolic Partial Differential Equations"

local bx = var'bx'
local by = var'by'
local bz = var'bz'
local sigma = var'sigma'
local rho = var'rho'
local cf = var'cf'
local c = var'c'
local cs = var'cs'

local bSq = bx^2 + by^2 + bz^2

local m = tensor.Array(8, 8, {
	{
		(rho * cf^2 - bSq) / c^2,
		0,
		(rho * cs^2 - bSq) / c^2,
		1,
		0,
		(rho * cs^2 - bSq) / c^2,
		0,
		(rho * cf^2 - bSq) / c^2
	},
	{
		-cf + bx^2 / (rho * cf),
		0,
		-cs + bx^2 / (rho * cs),
		0,
		0,
		cs - bx^2 / (rho * cs),
		0,
		cf - bx^2 / (rho * cf),
	},
	{
		bx * by / (rho * cf),
		bz * sigma,
		bx * by / (rho * cs),
		0,
		0,
		-bx * by / (rho * cs),
		-bz * sigma,
		-bx * by / (rho * cf),
	},
	{
		bx * bz / (rho * cf),
		-by * sigma,
		bx * bz / (rho * cs),
		0,
		0,
		-bx * bz / (rho * cs),
		by * sigma,
		-bx * bz / (rho * cf),
	},
	{
		0,
		0,
		0,
		0,
		1,
		0,
		0,
		0,
	},
	{
		by,
		bz * symmath.sqrt(rho),
		by,
		0,
		0,
		by,
		bz * symmath.sqrt(rho),
		by,
	},
	{
		bz,
		-by * symmath.sqrt(rho),
		bz,
		0,
		0,
		bz,
		-by * symmath.sqrt(rho),
		bz,
	},
	{
		rho * cf^2 - bSq,
		0,
		rho * cs^2 - bSq,
		0,
		0,
		rho * cs^2 - bSq,
		0,
		rho * cf^2 - bSq,
	}
})
print(m)
print(inverse(m))
--]]

print(MathJax.footer)
