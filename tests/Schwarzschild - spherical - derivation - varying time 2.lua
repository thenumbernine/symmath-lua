#!/usr/bin/env luajit
-- spherical form: (-A dt^2 + B dr^2 + r^2 dtheta^2 + r^2 sin(theta)^2 dphi^2
-- just like schwarzschild except A = A(t,r), B = B(t,r)
require 'ext'
require 'symmath'.setup{MathJax={title='Schwarzschild - spherical - derivation - varying time', useCommaDerivative=true}}


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


-- coordinates
local t,r,theta,phi = vars('t','r','\\theta','\\phi')

local coords = {t,r,theta,phi}
Tensor.coords{{variables = coords}}

-- [[
local A = var('A', {r,t})
local B = var('B', {r,t})
local C = var('C', {r,t})
local g = Tensor'_uv' 
g[1][1] = -A
g[1][2] = C
g[2][1] = g[1][2]
g[2][2] = B
g[3][3] = r^2
g[4][4] = r^2 * sin(phi)^2
local gU = Tensor('^uv', table.unpack( (Matrix.inverse(g)) ))
gU = gU:replace(B*A+C^2, 1)()

local i = Props.fields:find(nil, function(field) 
	return field.name == 'Gamma' 
end)
Props.fields[i].calc = function(self)
	local expr = self.GammaL'^a_bc'()
	expr = expr:replace((2 * C * C:diff(t))(), -(A * B):diff(t))()
	expr = expr:replace((2 * C * C:diff(r))(), -(A * B):diff(r))()
	return expr
end
Props.fields = Props.fields:sub(1,i+3)

local props = Props(g, gU)

-- (AB+C^2),r = 0 <=> A,r B + A B,r + 2 C C,r = 0
-- (AB+C^2),t = 0 <=> A,t B + A B,t + 2 C C,t = 0
-- (AB+C^2),rr = 0 <=> (A,r B + A B,r + 2 C C,r),r = A,rr B + 2 A,r B,r + A B,rr + 2 (C,r)^2 + 2 C C,rr = 0
-- (AB+C^2),tt = 0 <=> (A,t B + A B,t + 2 C C,t),t = A,tt B + 2 A,t B,t + A B,tt + 2 (C,t)^2 + 2 C C,tt = 0
-- (AB+C^2),rt = 0 <=> (A,t B + A B,t + 2 C C,t),r = A B,rt + A,r B,t + A,t B,r + A,rt B + 2 C,r C,t + 2 C C,rt = 0

--]]

--[[
local A = var('A', {r,t})
local B = var('B', {r,t})
local C = var('C', {r,t})
local g = Tensor'_uv' 
g[1][1] = -A
g[1][2] = C
g[2][1] = g[1][2]
g[2][2] = B
g[3][3] = r^2
g[4][4] = r^2 * sin(phi)^2
local gU = Tensor('^uv', table.unpack( (Matrix.inverse(g)) ))
gU = gU:replace(B*A+C^2, 1)()

local A_t, A_r, B_t, B_r, C_t, C_r = vars('A_t', 'A_r', 'B_t', 'B_r', 'C_t', 'C_r')
g = g:replace(A, exp(-t*A_t + r*A_r))
	:replace(B, exp(-t*B_t + r*B_r))
	:replace(C, exp(-t*C_t + r*C_r))
gU = gU:replace(A, exp(-t*A_t + r*A_r))
	:replace(B, exp(-t*B_t + r*B_r))
	:replace(C, exp(-t*C_t + r*C_r))
local props = Props(g, gU)
--]]

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
--[[
local R_s = var'R_s'
local psi = var'\\psi'
local A = var('A', {r})
local g = Tensor'_uv' 
g[1][1] = -A * cos(psi)^2 + 1/A * sin(psi)^2
g[1][2] = (A + 1/A) * sin(psi) * cos(psi)
g[2][1] = g[1][2]
g[2][2] = -A * sin(psi)^2 + 1/A * cos(psi)^2
g[3][3] = r^2
g[4][4] = r^2 * sin(phi)^2
local props = Props(g, gU)
--]]


--[[
printbr("looking at vacuum solutions", var'R''_uv':eq(0))
printbr("comparing", var'R''_tt', "with", var'R''_rr')

local R_tt_minus_R_rr = (props.Ricci[1][1] - props.Ricci[2][2])()
printbr((var'R''_tt' - var'R''_rr'):eq( R_tt_minus_R_rr ) )
--]]

print(require 'symmath.tostring.MathJax'.footer)
