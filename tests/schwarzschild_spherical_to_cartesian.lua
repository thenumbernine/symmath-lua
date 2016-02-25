#!/usr/bin/env luajit

local table = require 'ext.table'
local symmath = require 'symmath'
local Tensor = require 'symmath.Tensor'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax

local function printbr(...)
	print(...)
	print('<br>')
end

print(MathJax.header)

-- coordinates
local t, x, y, z = symmath.vars('t', 'x', 'y', 'z')
local theta, phi = symmath.vars('r', 'theta', 'phi')

-- differentials
local dt, dx, dy, dz = symmath.vars('dt', 'dx', 'dy', 'dz')
local dr, dtheta, dphi = symmath.vars('dr', 'd\\theta', 'd\\phi')

-- Constants
local R = symmath.var('R')

Tensor.coords{
	{variables = {t, r, theta, phi}},
}

-- algebraic
--r = (x^2 + y^2 + z^2)^.5
-- deferred:
local r = symmath.Variable('r', spatialCoords)
--]=]

--schwarzschild in spherical form: (-(1-2m/r)) dt^2 + 1/(1-2m/r) dr^2 + r^2 dtheta^2 + r^2 sin(theta)^2 dphi^2
local dsSq = (-(1-R/r))*dt^2 + 1/(1-R/r)*dr^2 + r^2*dtheta^2 + r^2*symmath.sin(theta)^2*dphi^2
printbr('Spherical representation:')
printbr('$ds^2 = $'..dsSq)
dsSq = dsSq
	:replace(dr, (x*dx + y*dy + z*dy) / r)
	:replace(dtheta, (x*z*dx + y*z*dy - (x^2 + y^2)*dz) / (r^2*symmath.sqrt(x^2 + y^2)))
	:replace(dphi, (-y*dx + x*dy) / (x^2 + y^2))
	-- I should really call this 'expandDivision' because it doesn't factor ...
	:factorDivision()
local function rapply(expr)
	if expr:isa(symmath.divOp) then return expr end
	if expr:isa(symmath.powOp) then return expr:expand() end
	if #expr == 0 then return expr end
	expr = expr:clone()
	for i=1,#expr do
		expr[i] = rapply(expr[i])
	end
	return expr
end
dsSq = rapply(dsSq):simplify():factorDivision()
printbr('Cartesian representation:')
printbr('$ds^2 = $'..dsSq)

--[[
convert to pseudo-Cartesian via:
	r = sqrt(x^2 + y^2 + z^2)
	dr = (x dx + y dy + z dy) / r
	dtheta = (xz dx + yz dy - (x^2 + y^2) dz) / (r^2 sqrt(x^2 + y^2))
	dphi = (-y dx + x dy) / (x^2 + y^2)
...and verify the results are the same
--]]
local factorLinearSystem = require 'symmath.factorLinearSystem'
local results = factorLinearSystem({dsSq}, table{dt^2, dx^2, dy^2, dz^2, dx*dy, dx*dz, dy*dz})
printbr('factoring...')
printbr(results)

print(MathJax.footer)
