#!/usr/bin/env luajit
-- schwarzschild in spherical form: (-A dt^2 + B dr^2 + r^2 dtheta^2 + r^2 sin(theta)^2 dphi^2
require 'ext'
require 'symmath'.setup{MathJax={title='Schwarzschild - spherical - derivation', useCommaDerivative=true}}

-- coordinates
local t,r,theta,phi = vars('t','r','\\theta','\\phi')

local coords = {t,r,theta,phi}
Tensor.coords{{variables = coords}}

-- schwarzschild metric in cartesian coordinates
local A = var('A', {r})
local B = var('B', {r})
local g = Tensor('_uv', function(u,v) return u == v and ({-A, B, r^2, r^2 * symmath.sin(theta)^2})[u] or 0 end) 

local Props = class(require 'symmath.physics.diffgeom')
Props.verbose = true
local props = Props(g)

printbr'vaccuum constraint:'
printbr(var'R''^u_v':eq(0))

local R_tt_minus_R_rr = (props.Ricci[1][1] - props.Ricci[2][2])()
printbr((var'R''^t_t' - var'R''^r_r'):eq( R_tt_minus_R_rr ) )
printbr(R_tt_minus_R_rr:eq(0))
printbr(R_tt_minus_R_rr[1]:eq(0))
printbr((A * B)'_,r':eq(0))
local K = var'K'
printbr((A * B):eq(K))

local B_def = B:eq(K / A)
printbr("now substitute "..B_def)
g = g:subst(B_def)
local props = Props(g)

print(require 'symmath.tostring.MathJax'.footer)
