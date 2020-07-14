#!/usr/bin/env lua
require 'ext'
require 'symmath'.setup{implicitVars=true, MathJax={title='Divergence Theorem in Curvilinear Coordinates'}}
theta = var'\\theta'
phi = var'\\phi'
Gamma = var'\\Gamma'

rHat = r
thetaHat = var('\\hat{theta}')
function thetaHat:applyDiff(x) return x:diff(theta) / r end
phiHat = var('\\hat{phi}')
function phiHat:applyDiff(x) return x:diff(phi) / (r * sin(theta)) end
Tensor.coords{{variables={rHat, thetaHat, phiHat}, metric=Matrix.identity(3)}}
-- TODO automatically compute this from the tangent space basis operator "variables"
c = Tensor'_ij^k'
c[1][2][2] = -1/r
c[1][3][3] = -1/r
c[2][1][2] = 1/r
c[2][3][3] = -cos(theta)/(r*sin(theta))
c[3][1][3] = 1/r
c[3][2][3] = cos(theta)/(r*sin(theta))
printbr(var'c':eq(c))

g = Tensor('_ij', function(i,j) return i==j and 1 or 0 end)
gU = Tensor('^ij', function(i,j) return i==j and 1 or 0 end)
coords = table{rHat, thetaHat, phiHat}
Tensor.coords{{variables=coords, metric=g, metricInverse=gU}}
geom = require 'symmath.physics.diffgeom'(g, gU, c)
GammaVal = geom.Gamma
printbr(GammaVal)
F = Tensor('^i', theta/r, phi/r, 0)
divF = (F'^i_,i' + GammaVal'^i_ij' * F'^j')()
printbr(divF)
V = r^2 * sin(theta)
printbr((divF * V)())
printbr((F'^i' * Tensor('_i', 1, 0, 0)):integrate(theta, 0, pi/2):integrate(phi, 0, pi/2)())
-- this is along the r surface normal, and r=rHat, so no renormalization is needed
printbr((F'^i' * Tensor('_i', 1, 0, 0)):replace(r, 1):integrate(theta, 0, pi/2):integrate(phi, 0, pi/2)())
printbr((F'^i' * Tensor('_i', -1, 0, 0)):replace(r, frac(1,2)):integrate(theta, 0, pi/2):integrate(phi, 0, pi/2)())
printbr((F'^i' * Tensor('_i', 0, 1, 0) * 1/r):replace(theta, 0):integrate(r, frac(1,2), 1):integrate(phi, 0, pi/2)())
printbr((F'^i' * Tensor('_i', 0, -1, 0) * 1/r):replace(theta, 0):integrate(r, frac(1,2), 1):integrate(phi, 0, pi/2)())
printbr((F'^i' * Tensor('_i', 0, 1, 0) * 1/r):replace(theta, pi/2):integrate(r, frac(1,2), 1):integrate(phi, 0, pi/2)())
printbr((F'^i' * Tensor('_i', 0, 0, 1) * 1/(r*sin(theta)) ):replace(phi, pi/2):integrate(r, frac(1,2), 1):integrate(theta, 0, pi/2)())
printbr((F'^i' * Tensor('_i', 0, 0, -1) * 1/(r*sin(theta)) ):replace(phi, 0):integrate(r, frac(1,2), 1):integrate(theta, 0, pi/2)())
printbr((pi^3/16 - pi^3/8 + pi^2/8 - pi^2/8)())
printbr((divF * V)():integrate(r, frac(1,2), 1):integrate(theta, 0, pi/2):integrate(phi, 0, pi/2)())

local eRLen = 1
local eThetaLen = r
local ePhiLen = r * sin(theta)

r1, r2 = frac(1,2), 1
theta1, theta2 = 0, pi/2
phi1, phi2 = 0, pi/2

printbr((F'^i' * Tensor('_i', 1, 0, 0) * 1/eRLen * V):replace(r, r2):integrate(theta, theta1, theta2):integrate(phi, phi1, phi2)())
printbr((F'^i' * Tensor('_i', -1, 0, 0) * 1/eRLen * V):replace(r, r1):integrate(theta, theta1, theta2):integrate(phi, phi1, phi2)())
printbr((F'^i' * Tensor('_i', 0, 1, 0) * 1/eThetaLen * V):replace(theta, theta2):integrate(r, r1, r2):integrate(phi, phi1, phi2)())
printbr((F'^i' * Tensor('_i', 0, -1, 0) * 1/eThetaLen * V):replace(theta, theta1):integrate(r, r1, r2):integrate(phi, phi1, phi2)())
printbr((F'^i' * Tensor('_i', 0, 0, 1) * 1/ePhiLen * V):replace(phi, phi2):integrate(r, r1, r2):integrate(theta, theta1, theta2)())
printbr((F'^i' * Tensor('_i', 0, 0, -1) * 1/ePhiLen * V):replace(phi, phi1):integrate(r, r1, r2):integrate(theta, theta1, theta2)())
printbr((pi/2 + pi/2 + pi^2/16)())

function calcIntFromDivExpr()
	return (var'F'' ^{\\hat{i}} _,{\\hat{i}}' * var'V')
		:integrate(r, var'r1', var'r2')
		:integrate(theta, var'theta1', var'theta2')
		:integrate(phi, var'phi1', var'phi2')
end
function calcIntFromDiv(F) 
	return ((F'^i_,i' + GammaVal'^i_ij' * F'^j') * V):integrate(r, r1, r2):integrate(theta, theta1, theta2):integrate(phi, phi1, phi2)() 
end
printbr(calcIntFromDivExpr():eq(calcIntFromDiv(F)))

function calcIntFromNExpr()
	return
		  (var'F'' ^{\\hat{i}}' * var'e'' _{\\hat{i}} ^i' * var'V' * var'nr+''_i'):replace(r, var'r2'):integrate(theta, var'theta1', var'theta2'):integrate(phi, var'phi1', var'phi2')
		+ (var'F'' ^{\\hat{i}}' * var'e'' _{\\hat{i}} ^i' * var'V' * var'nr-''_1'):replace(r, var'r1'):integrate(var'theta1', var'theta2'):integrate(phi, var'phi1', var'phi2')
		+ (var'F'' ^{\\hat{i}}' * var'e'' _{\\hat{i}} ^i' * var'V' * var'ntheta+''_i'):replace(theta, var'theta2'):integrate(r, var'r1', var'r2'):integrate(phi, var'phi1', var'phi2')
		+ (var'F'' ^{\\hat{i}}' * var'e'' _{\\hat{i}} ^i' * var'V' * var'ntheta-''_i'):replace(theta, var'theta1'):integrate(r, var'r1', var'r2'):integrate(phi, var'phi1', var'phi2')
		+ (var'F'' ^{\\hat{i}}' * var'e'' _{\\hat{i}} ^i' * var'V' * var'nphi+''_i'):replace(phi, var'phi2'):integrate(r, var'r1', var'r2'):integrate(theta, var'theta1', var'theta2')
		+ (var'F'' ^{\\hat{i}}' * var'e'' _{\\hat{i}} ^i' * var'V' * var'nphi-''_i'):replace(phi, var'phi1'):integrate(r, var'r1', var'r2'):integrate(theta, var'theta1', var'theta2')
end

function calcIntFromN(F) 
	return (
		(F'^i' * Tensor('_i', 1, 0, 0) * V):replace(r, r2):integrate(theta, theta1, theta2):integrate(phi, phi1, phi2)() 
		+ (F'^i' * Tensor('_i', -1, 0, 0) * V):replace(r, r1):integrate(theta1, theta2):integrate(phi, phi1, phi2)() 
		+ (F'^i' * Tensor('_i', 0, 1, 0) * V/r):replace(theta, theta2):integrate(r, r1, r2):integrate(phi, phi1, phi2)() 
		+ (F'^i' * Tensor('_i', 0, -1, 0) * V/r):replace(theta, theta1):integrate(r, r1, r2):integrate(phi, phi1, phi2)() 
		+ (F'^i' * Tensor('_i', 0, 0, 1) * V/(r*sin(theta))):replace(phi, phi2):integrate(r, r1, r2):integrate(theta, theta1, theta2)() 
		+ (F'^i' * Tensor('_i', 0, 0, -1) * V/(r*sin(theta))):replace(phi, phi1):integrate(r, r1, r2):integrate(theta, theta1, theta2)() 
	)() 
end
printbr(calcIntFromNExpr():eq(calcIntFromN(F)))
