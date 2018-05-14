#!/usr/bin/env luajit
-- spherical form: (-A dt^2 + B dr^2 + r^2 dtheta^2 + r^2 sin(theta)^2 dphi^2
-- just like schwarzschild except A = A(t,r), B = B(t,r)
require 'ext'
require 'symmath'.setup{MathJax={title='Schwarzschild - spherical - derivation - varying time', useCommaDerivative=true}}

-- coordinates
local t,r,theta,phi = vars('t','r','\\theta','\\phi')

local coords = {t,r,theta,phi}
Tensor.coords{{variables = coords}}

-- schwarzschild metric in cartesian coordinates
local A = var('A', {t,r})
local B = var('B', {t,r})
local g = Tensor('_uv', function(u,v) return u == v and ({-A, B, r^2, r^2 * symmath.sin(theta)^2})[u] or 0 end) 
local Props = class(require 'symmath.physics.diffgeom')
Props.verbose = true
local props = Props(g)

printbr("looking at vacuum solutions", var'R''_uv':eq(0))
printbr("from ", var'R''_tr':eq(0), "we know that", var'B''_,t':eq(0), ", therefore $B = B(r)$ alone")
printbr("comparing", var'R''^t_t', "with", var'R''^r_r')

local R_tt_minus_R_rr = (props.Ricci[1][1] - props.Ricci[2][2])()
printbr((var'R''^t_t' - var'R''^r_r'):eq( R_tt_minus_R_rr ) )
printbr("therefore, once again, $(AB)_{,r} = 0$")
-- d(AB)/dr = 0 <-> int d(AB) = int 0 dr = C
printbr("but now that A and B are functions of t, we instead conclude that $A \\cdot B$ is a function of t alone")
printbr("except $B_{,t} = 0$ by the vacuum equations")
printbr("which is fine.  $A = A(r,t)$ and $B = B(r)$ means $(A \\cdot B) = (A \\cdot B)(r,t)$")
printbr("in fact, let $A = C(t) \\cdot D(r)$")
printbr("then $(AB)_{,r} = (CDB)_{,r} = C (DB)_{,r}$")
printbr("then $DB = k$ for constant $k$")
printbr("then $A = k C / B$")

local B = var('B', {r})
local k = var'k'
local C = var('C', {t})
local A_def = A:eq(k * C / B)
g = g:subst(A_def):replace(B, B)

props = Props(g)

printbr("now we get", props.Ricci[2][2][1]:eq(0))
local s = var's'
local B_def = B:eq(1 + 1 / (s * r))
printbr("which has the solution", B_def)
g = g:subst(B_def)
printbr("keeping with tradition, $k = -1, s = -R_s$")
local R_s = var'R_s'

--g = g:replace(k, -1):replace(s, -R_s)
g = Tensor('_uv', table.unpack(Matrix.diagonal( -(1 - R_s / r) * C, 1 / (1 - R_s / r), r^2, r^2 * sin(theta)^2)))
props = Props(g)

print(require 'symmath.tostring.MathJax'.footer)
