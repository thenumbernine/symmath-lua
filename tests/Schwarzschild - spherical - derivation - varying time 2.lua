#!/usr/bin/env luajit
-- spherical form: (-A dt^2 + B dr^2 + r^2 dtheta^2 + r^2 sin(theta)^2 dphi^2
-- just like schwarzschild except A = A(t,r), B = B(t,r)
require 'ext'
require 'symmath'.setup{MathJax={title='Schwarzschild - spherical - derivation - varying time', useCommaDerivative=true}}

-- coordinates
local t,r,theta,phi = vars('t','r','\\theta','\\phi')

local coords = {t,r,theta,phi}
Tensor.coords{{variables = coords}}

--[[ schwarzschild metric in cartesian coordinates

what does a coordinate rotation look like?
ds^2 = -A dt^2 + 1/A dr^2
dt = cos psi dt' - sin psi dr'
dr = sin psi dt' + cos psi dr'
dt^2 = (cos psi dt' - sin psi dr')^2
	= (cos psi)^2 dt'^2 - 2 sin psi cos psi dt' dr' + (sin psi)^2 dr'^2
dr^2 = (sin psi dt' + cos psi dr')^2
	= (sin psi)^2 dt'^2 + 2 sin psi cos psi dt' dr' + (cos psi)^2 dr'^2
ds^2 = -A ((cos psi)^2 dt'^2 - 2 sin psi cos psi dt' dr' + (sin psi)^2 dr'^2)
	+ 1/A ((sin psi)^2 dt'^2 + 2 sin psi cos psi dt' dr' + (cos psi)^2 dr'^2)
ds^2 = 
	(-A (cos psi)^2 + 1/A (sin psi)^2) dt'^2 
	+ 2 (A + 1/A) sin psi cos psi dt' dr' 
	+ (-A (sin psi)^2 + 1/A (cos psi)^2) dr'^2
A = 1 - Rs/r

try again

dt = (cos psi t') dt' - (sin psi t') dr'
dt^2 = (cos psi t')^2 dt' - (sin psi t') dr'

dr = (sin psi t') dt' + (cos psi t') dr'
--]]
local R_s = var'R_s'
local psi = var'\\psi'
local A = var('A', {r})
local g = Tensor'_uv' 
g[1][1] = -A * cos(psi)^2 + 1/A * sin(psi)^2
g[1][2] = (A + 1/A) * sin(psi) * cos(psi)
g[2][1] = g[1][2]
g[2][2] = -A * sin(psi)^2 + 1/A * cos(psi)^2
g[3][3] = r^2
g[4][4] = r^2 * sin(psi)^2

local Props = class(require 'symmath.physics.diffgeom')
Props.verbose = true
Props.fields = Props.fields:filter(function(f) return f.name ~= 'Riemann' and f.name ~= 'Ricci' and f.name ~= 'Gaussian' and f.name ~= 'Einstein' end)
Props.fields:insert{
	name = 'Ricci',
	symbol = 'R',
	title = 'Ricci curvature, $\\flat\\flat$',
	calc = function(self) return self.RiemannULLL'^c_acb'() end,
	display = function(self) return var'R''_ab':eq(self.Ricci'_ab'()) end,
}
local props = Props(g, gU)


printbr("looking at vacuum solutions", var'R''_uv':eq(0))
printbr("comparing", var'R''_tt', "with", var'R''_rr')

local R_tt_minus_R_rr = (props.Ricci[1][1] - props.Ricci[2][2])()
printbr((var'R''_tt' - var'R''_rr'):eq( R_tt_minus_R_rr ) )

print(require 'symmath.tostring.MathJax'.footer)
