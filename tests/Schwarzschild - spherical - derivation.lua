#!/usr/bin/env luajit
-- schwarzschild in spherical form: (-A dt^2 + B dr^2 + r^2 dtheta^2 + r^2 sin(theta)^2 dphi^2
-- following https://en.wikipedia.org/wiki/Deriving_the_Schwarzschild_solution except my A and B is swapped
-- also maybe I started from the MTW "Gravitation" chapter on the topic
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='Schwarzschild - spherical - derivation', useCommaDerivative=true}}

-- coordinates
local t,r,theta,phi = vars('t','r','\\theta','\\phi')

local coords = {t,r,theta,phi}
local chart = Tensor.Chart{coords=coords}

-- schwarzschild metric in cartesian coordinates
local A = var('A', {r})
local B = var('B', {r})
local g = Tensor('_uv', function(u,v) return u == v and ({-A, B, r^2, r^2 * symmath.sin(theta)^2})[u] or 0 end) 

local Props = class(require 'symmath.physics.diffgeom')
Props.verbose = true
local props = Props(g)

printbr'vaccuum constraint:'
printbr(var'R''^u_v':eq(0))
for a=1,4 do
	for b=1,4 do
		if props.Ricci[a][b] ~= Constant(0) then
			printbr(var'R'(' ^'..coords[a].name..' _'..coords[a].name):eq(props.Ricci[a][b]):eq(0))
		end
	end
end

local R_tt_minus_R_rr = (props.Ricci[1][1] - props.Ricci[2][2])()
printbr((var'R''^t_t' - var'R''^r_r'):eq( R_tt_minus_R_rr ) )
printbr(R_tt_minus_R_rr:eq(0))
printbr(R_tt_minus_R_rr[1]:eq(0))
printbr((A * B)'_,r':eq(0))
local K = var'K'
local AB_def = (A * B):eq(K)
printbr(AB_def)
printbr(AB_def:diff(r)())
local A_from_B = AB_def:solve(A)
printbr("substitute into "..var'R'' ^\\theta _\\theta':eq(0))
local c3 = props.Ricci[3][3]:eq(0):subst(A_from_B)()
c3 = (c3 * c3[1][2])()
printbr(c3)
-- which has the solution ...
local S = var'S'
local A_def = A:eq((1 - 1/(S*r))())
local B_def = B:eq(1 / (1 - 1/(S*r)))()
printbr(A_def)
printbr(B_def)
local R = var'R'
local A_def = A:eq((1 - R/r)())
local B_def = B:eq(1 / (1 - R/r))()
printbr(A_def)
printbr(B_def)

printbr("now substitute to find:")
g = g:subst(A_def, B_def)
local props = Props(g)

print(symmath.export.MathJax.footer)
