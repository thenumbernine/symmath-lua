#!/usr/bin/env luajit
-- schwarzschild in spherical form: (-(1-2m/r)) dt^2 + 1/(1-2m/r) dr^2 + r^2 dtheta^2 + r^2 sin(theta)^2 dphi^2
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{
	env=env,
	--implicitVars=true, 
	MathJax={title='Schwarzschild - spherical - mass varying with time', usePartialLHSForDerivative=true}
}

-- coordinates
local t,r,theta,phi = vars('t','r','\\theta','\\phi')

local coords = {t,r,theta,phi}
local chart = Tensor.Chart{coords=coords}

-- mass
local R = var('R', coords)

-- schwarzschild metric in cartesian coordinates
local g = Tensor('_uv', function(u,v) return u == v and ({-(1-R/r), 1/(1-R/r), r^2, r^2 * symmath.sin(theta)^2})[u] or 0 end) 

local Props = require 'symmath.physics.diffgeom':subclass()
Props.verbose = true
local props = Props(g)
local Gamma = props.Gamma

local A = Tensor('^i', function(i) return var('A^{'..coords[i].name..'}', coords) end)
local divVarExpr = var'A''^i_,i' + var'\\Gamma''^i_ji' * var'A''^j'
local divExpr = divVarExpr:replace(var'A', A):replace(var'\\Gamma', Gamma)
-- TODO only simplify TensorRef, so the indexes are fixed
printbr('divergence:', divVarExpr:eq(divExpr():factorDivision())) 

printbr'geodesic:'
local dx = Tensor('^u', function(u)
	return var('\\dot{' .. coords[u].name .. '}')
end)
local d2x = Tensor('^u', function(u)
	return var('\\ddot{' .. coords[u].name .. '}')
end)
-- TODO unravel equaliy, or print individual assignments
printbr(d2x'^a':eq(-Gamma'^a_bc' * dx'^b' * dx'^c')())
printbr()

print(symmath.export.MathJax.footer)
