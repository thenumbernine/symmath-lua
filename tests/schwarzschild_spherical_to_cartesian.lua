#!/usr/bin/env luajit

local table = require 'ext.table'
local symmath = require 'symmath'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
print(MathJax.header)

local function printbr(...) print(...) print'<br>' end

local Tensor = symmath.Tensor
local var = symmath.var
local vars = symmath.vars

-- coordinates
local t,x,y,z = vars('t','x','y','z')
local spatialCoords = table{t,x,y,z}
local theta= var('\\theta', spatialCoords)
local phi = var('\\phi', spatialCoords)

-- differentials
local dt,dx,dy,dz = vars('dt','dx','dy','dz')
local dr,dtheta,dphi = vars('dr','d\\theta','d\\phi')

-- Constants
local R = symmath.var('R')

Tensor.coords{
	{variables = {t,r,theta,phi}},
}

-- algebraic
--r = (x^2 + y^2 + z^2)^.5
-- deferred:
local r = var('r', spatialCoords)
--]=]

--schwarzschild in spherical form: (-(1-2m/r)) dt^2 + 1/(1-2m/r) dr^2 + r^2 dtheta^2 + r^2 sin(theta)^2 dphi^2
local dsSq = (-(1-R/r))*dt^2 + 1/(1-R/r)*dr^2 + r^2*dtheta^2 + r^2*symmath.sin(theta)^2*dphi^2
printbr'Spherical representation:'
printbr((var'ds'^2):eq(dsSq))
dsSq = dsSq
	:replace(dr, (x*dx + y*dy + z*dz) / r)
	:replace(dtheta, (x*z*dx + y*z*dy - (x^2 + y^2)*dz) / (r^2*symmath.sqrt(x^2 + y^2)))
	:replace(dphi, (-y*dx + x*dy) / (x^2 + y^2))
	
	:replace(symmath.sin(theta), symmath.sqrt(x^2 + y^2)/r)
	:replace(y^2, r^2 - x^2 - z^2)
	:replace(z^2, r^2 - x^2 - y^2)
	
	-- I should really call this 'expandDivision' because it doesn't factor ...
	:factorDivision()
local function rapply(expr)
	if symmath.divOp.is(expr) then return expr end
	if symmath.powOp.is(expr) then return expr:expand() end
	if #expr == 0 then return expr end
	expr = expr:clone()
	for i=1,#expr do
		expr[i] = rapply(expr[i])
	end
	return expr
end
dsSq = rapply(dsSq)():factorDivision()
printbr'Cartesian representation:'
printbr((var'ds'^2):eq(dsSq))

--[[
convert to pseudo-Cartesian via:
	r = sqrt(x^2 + y^2 + z^2)
	dr = (x dx + y dy + z dy) / r
	dtheta = (xz dx + yz dy - (x^2 + y^2) dz) / (r^2 sqrt(x^2 + y^2))
	dphi = (-y dx + x dy) / (x^2 + y^2)
...and verify the results are the same
--]]
local factorLinearSystem = require 'symmath.factorLinearSystem'
local terms = table{dt^2, dx^2, dy^2, dz^2, dx*dy, dx*dz, dy*dz}
local results, source = factorLinearSystem({dsSq}, terms)
printbr'factoring...'
--there's MathJax error somewhere in this output...
--printbr(results)
for i,term in ipairs(terms) do
	print(term)
	print(':')
	printbr(results[1][i])
end
printbr('rest:',source[1][1])
print(MathJax.footer)
