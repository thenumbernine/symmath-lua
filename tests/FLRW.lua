#!/usr/bin/env luajit
--flrw in spherical form: -dt^2 + a^2 (dr^2 / (1 - k r^2) + r^2 (dtheta^2 + sin(theta)^2 dphi^2)
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='FLRW metric'}}

-- coordinates
local t, r, theta, phi = vars('t', 'r', '\\theta', '\\phi')
local coords = {t,r,theta,phi}

local chart = Tensor.Chart{coords=coords}

-- metric variables
local a = var('a', {t})		-- radius of curvature
local k = var'k'			-- constant: +1, 0, -1

-- EFE variables
local rho = var'\\rho'
local p = var'p'
local Lambda = var'\\Lambda'

-- constants
local pi = var'\\pi'

-- schwarzschild metric in cartesian coordinates

-- start with zero
local g = Tensor('_uv', table.unpack(Matrix.diagonal(
	-1, a^2 / (1 - k * r^2), a^2 * r^2, a^2 * r^2 * sin(theta)^2
)))
printbr'metric:'
printbr(var'g''_uv':eq(g'_uv'()))

chart:setMetric(g)

-- metric inverse, assume diagonal
printbr'metric inverse:'
printbr(var'g''^uv':eq(g'^uv'()))

-- connections of 1st kind
local Gamma = ((g'_ab,c' + g'_ac,b' - g'_bc,a') / 2)()
printbr'1st kind Christoffel:'
printbr(var'\\Gamma''_abc':eq(Gamma'_abc'()))
printbr()

-- connections of 2nd kind
Gamma = Gamma'^a_bc'()
printbr'2nd kind Christoffel:'
printbr(var'\\Gamma''^a_bc':eq(Gamma'^a_bc'()))
printbr()

local dx = Tensor('^u', function(u) return var('\\dot{'..coords[u].name..'}') end)
local d2x = Tensor('^u', function(u) return var('\\ddot{'..coords[u].name..'}') end)
printbr'geodesic:'
-- TODO unravel equaliy, or print individual assignments
printbr(((d2x'^a' + Gamma'^a_bc' * dx'^b' * dx'^c'):eq(Tensor('^a',0,0,0,0)))())
printbr()

local Riemann = (Gamma'^a_bd,c' - Gamma'^a_bc,d' + Gamma'^a_uc' * Gamma'^u_bd' - Gamma'^a_ud' * Gamma'^u_bc')()
printbr'Riemann curvature tensor:'
-- TODO trig simplification
Riemann = Riemann:replace(cos(theta)^2, 1 - sin(theta)^2)
-- also TODO the other thing that doesn't appear to work is factoring out negatives of the denominator for simplification 
printbr(var'R''^a_bcd':eq(Riemann'^a_bcd'()))

local Ricci = Riemann'^c_acd'()
printbr'Ricci curvature tensor:'
printbr(var'R''_ab':eq(Ricci'_ab'()))

printbr'Gaussian curvature'
local Gaussian = Ricci'^a_a'()
printbr(var'R':eq(Gaussian))
printbr()

-- matter stress-energy tensor
printbr'matter stress-energy tensor:'
local u = Tensor('^a', 1,0,0,0)
printbr(var'u''^a':eq(u'^a'()))

local T = (g'_ab' * p + u'_a' * u'_b' * (rho + p))()
printbr(var'T''_ab':eq(T'_ab'()))
printbr()

-- Einstein field equations
printbr'Einstein field equations'
-- G_uv + Lambda g_uv = 8 pi T_mu
-- R_uv + g_uv (Lambda - 1/2 R) = 8 pi T_uv
--[[
T_uv = (rho + p) u_u u_v + p g_uv
u is normalized <> u_u u_v g^uv = -1
g^uv = diag(-1, 1, 1/r^2 1/(r^2 sin(theta)^2) )

let u be purely timelike: u_u = [1,0,0,0]
u_t^2 g^tt = -1 <=> -u_t^2 = -1 <=> u_t = 1

T_uv = 
[rho + p 0 0 0 ]     [-1  0     0             0           ]
[      0 0 0 0 ]     [ 0 a^2    0             0           ]
[      0 0 0 0 ] + p [ 0  0  a^2 r^2          0           ]
[      0 0 0 0 ]     [ 0  0     0    a^2 r^2 sin(theta)^2 ]
=
[rho  0       0             0             ]
[ 0  p a^2    0             0             ]
[ 0  0   p a^2 r^2          0             ]
[ 0  0       0     p a^2 r^2 sin(theta)^2 ]
--]]
local lhs = (Ricci'_ab' + g'_ab' * Gaussian / 2)()
local rhs = (8 * pi * T'_ab')()
printbr(lhs:eq(rhs))

local eqns = table()
for i=1,4 do
	for j=1,4 do
		local lhs_ij = lhs[i][j]
		local rhs_ij = rhs[i][j]
		if lhs_ij ~= Constant(0)
		or rhs_ij ~= Constant(0)
		then
			eqns:insert(lhs_ij:eq(rhs_ij))
		end
	end
end
for _,eqn in ipairs(eqns) do
	printbr(eqn)
end
assert(#eqns == 4)
-- eqn 1 is the density eqn
-- eqns 2 thru 4 are the pressure eqn scaled by various things ... 

print[[
	</body>
</html>
]]
