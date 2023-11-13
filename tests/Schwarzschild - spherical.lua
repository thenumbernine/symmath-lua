#!/usr/bin/env luajit
-- schwarzschild in spherical form: (-(1-2m/r)) dt^2 + 1/(1-2m/r) dr^2 + r^2 dtheta^2 + r^2 sin(theta)^2 dphi^2
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{
	env=env,
	--implicitVars=true, 
	MathJax={title='Schwarzschild - spherical', usePartialLHSForDerivative=true}
}

-- coordinates
local t,theta,phi = vars('t','\\theta','\\phi')
local r = set.nonNegativeReal:var'r'

-- mass
local R_of_r = false
-- dependent on r or not?  most derivations treat R as constant, but for stellar models R varies inside of the star
-- TODO to match up with MTW, use 'R' for the planet radius and 'M' for the total mass, so 2 M for the Schwarzschild radius
local R = set.nonNegativeReal:var('R', R_of_r and {r} or nil)	

local coords = {t,r,theta,phi}
Tensor.Chart{coords=coords}
Tensor.Chart{coords={t}, symbols='t'}
Tensor.Chart{coords={r,theta,phi}, symbols='ijklmn'}

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

printbr'ADM variables:'
local gVar = var'g'
local alpha, beta, gamma = vars('\\alpha', '\\beta', '\\gamma')
local alphaDef = alpha:eq(sqrt(-gVar'^tt'))
local betaDef = beta'_i':eq(gVar'_ti')
local gammaDef = gamma'_ij':eq(gVar'_ij')
printbr(alphaDef)
printbr(betaDef)
printbr(gammaDef)
printbr()

local gU = props.gU

local alphaVal = (1/sqrt(-gU'^tt'))()
printbr(alpha:eq(alphaVal))

local gammaVal = g'_ij'()
printbr(gamma'_ij':eq(gammaVal))
local gammaUVal = Tensor('^ij', gammaVal:inverse():unpack())
printbr(gamma'^ij':eq(gammaUVal))

local betaLVal = g'_ti'()
printbr(beta'_i':eq(betaLVal))
local betaVal = (gammaUVal'^ij' * betaLVal'_j')()
printbr(beta'^i':eq(betaVal))

local n = var'n'
local nVal = Tensor('_a', -alphaVal, 0, 0, 0)
printbr(n'_a':eq(nVal))
printbr(n'^a':eq((gU'^ab' * nVal'_b')()))

printbr((n'_a' * n'^a'):eq(nVal'_a' * nVal'^a')())
printbr((n'_a' * n'_b' * gVar'^ab'):eq(nVal'_a' * nVal'_b' * gU'^ab')())

local deltaVal = Tensor('_a^b', function(a,b) return a==b and 1 or 0 end)
local gammaULVal = (deltaVal'_a^b' + nVal'_a' * nVal'^b')()
printbr(gamma'_a^b':eq(gammaULVal))

local K = var'K'
local KVal = (gammaULVal'_a^c' * gammaULVal'_b^d' * (nVal'_d,c' - Gamma'^e_cd' * nVal'_e'))()
printbr(K'_ab':eq(KVal))

print(symmath.export.MathJax.footer)
