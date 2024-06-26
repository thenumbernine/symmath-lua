#!/usr/bin/env luajit
--[[
kerr in cartesian form: 

Alcubierre p. 56, Baumgarte & Shapiro p. 52
ds^2 = (eta_uv + 2 H l_u l_v)
	for eta_uv = diag(-1,1,1,1)
		H = (r M - Q^2 / 2) / (r^2 + a^2 z^2 / r^2)
		l_u = (1, (rx + ay) / (r^2 + a^2), (ry - ax) / (r^2 + a^2), z / r)
		r is defined as (x^2 + y^2) / (r^2 + a^2) + z^2 / r^2 = 1

solving for r ...
(x^2 + y^2) / (r^2 + a^2) + z^2 / r^2 = 1
r^2 (x^2 + y^2) + (r^2 + a^2) z^2 = r^2 (r^2 + a^2)
r^2 x^2 + r^2 y^2 + r^2 z^2 + a^2 z^2 = r^4 + a^2 r^2
-r^4 + r^2 x^2 + r^2 y^2 + r^2 z^2 + r^2 a^2 + a^2 z^2 = 0
-r^4 + r^2 (x^2 + y^2 + z^2 + a^2) + a^2 z^2 = 0
...has roots
	r^2 = 1/2 ((x^2 + y^2 + z^2 + a^2) +- sqrt((x^2 + y^2 + z^2 + a^2)^2 + 4 a^2 z^2))
--]]

-- TODO inverting the metric goes really slow...

require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='Kerr-Schild - dense', usePartialLHSForDerivative=true}}

-- coordinates
local t, x, y, z = vars('t', 'x', 'y', 'z')
local spatialCoords = table{x,y,z}
local coords = {t, x, y, z}

local a = var('a')
local M = var'M'
local Q = var'Q'

local chart = Tensor.Chart{coords=coords}
local spatialChart = Tensor.Chart{coords=spatialCoords, symbols='ijklmn'}
local chart_t = Tensor.Chart{coords={t}, symbols='t'}
local chart_x = Tensor.Chart{coords={x}, symbols='x'}
local chart_y = Tensor.Chart{coords={y}, symbols='y'}
local chart_z = Tensor.Chart{coords={z}, symbols='z'}

local rho = var('\\rho', spatialCoords)
local rho_def = rho:eq(x^2 + y^2 + z^2 - a^2)
printbr(rho_def)
local drho_dx_defs = table()
for i,xi in ipairs(spatialCoords) do
	drho_dx_defs[i] = rho_def:diff(xi)()
	printbr(drho_dx_defs[i])
end
printbr()

local r = var('r', spatialCoords)
local rSq_def = (r^2):eq(frac(1,2) * (rho + sqrt(rho^2 + 4*a^2*z^2)))
printbr(rSq_def)
local dr_dx_defs = table()
for i,xi in ipairs(spatialCoords) do
	local dr_dx = rSq_def:diff(xi)():solve(r:diff(xi)):subst(drho_dx_defs:unpack())()
	printbr(dr_dx)
	dr_dx_defs:insert(dr_dx)
end
printbr()

local H = var('H', spatialCoords)

local H_def = H:eq((r * M - Q^2 / 2) / (r^2 + a^2 * z^2 / r^2))
printbr(H_def)
printbr(H_def:diff(x)())
printbr(H_def:diff(y)())
printbr(H_def:diff(z)())
printbr()

-- Minkowski metric
local eta = Tensor('_uv', function(u,v) return u == v and (u == 1 and -1 or 1) or 0 end)
printbr(var'\\eta''_uv':eq(eta'_uv'()))

local etaU = Tensor('^uv', function(u,v) return u == v and (u == 1 and -1 or 1) or 0 end)
printbr(var'\\eta''^uv':eq(etaU'^uv'()))


--[[
local l = Tensor('_u', 
	1,
	(r*x + a*y) / (r^2 + a^2),
	(r*y - a*x) / (r^2 + a^2),
	z / r
)
--]]
-- [[
--]]
local lvar = var'l'

local lt_def = lvar'_t':eq(1)
local lx_def = lvar'_x':eq((r*x + a*y) / (r^2 + a^2))
local ly_def = lvar'_y':eq((r*y - a*x) / (r^2 + a^2))
local lz_def = lvar'_z':eq(z / r)
printbr(lt_def)
printbr(lx_def)
printbr(ly_def)
printbr(lz_def)
printbr()
for i,xi in ipairs(spatialCoords) do
	printbr(lx_def:diff(xi)())
end
for i,xi in ipairs(spatialCoords) do
	printbr(ly_def:diff(xi)())
end
for i,xi in ipairs(spatialCoords) do
	printbr(lz_def:diff(xi)())
end

local l = Tensor('_u', function(u) 
	if u == 1 then return 1 end
	return var('l_'..coords[u].name, spatialCoords)
end)
printbr(lvar'_u':eq(l'_u'()))

printbr(lvar'^u':eq(lvar'_v' * var'\\eta''^uv'))
local lU = (l'_v' * etaU'^uv')()
printbr(lvar'^u':eq(lU'^u'()))

-- Kerr metric in cartesian coordinates
-- Alcubierre's num rel book, eqn 1.16.16
printbr(var'g''_uv':eq(var'\\eta''_uv' + 2 * var'H' * lvar'_u' * lvar'_v'))
local g = (eta'_uv' + 2 * H * l'_u' * l'_v')()
printbr(var'g''_uv':eq(g'_uv'()))

-- Alcubierre's num rel book, eqn 1.16.19
printbr(var'g''^uv':eq(var'\\eta''^uv' - 2 * var'H' * lvar'^u' * lvar'^v'))
local gInv = (etaU'^uv' - 2 * H * lU'^u' * lU'^v')()
printbr(var'g''^uv':eq(gInv'^uv'()))

chart:setMetric(g, gInv)

-- metric partial
-- assume dr/dt is zero
local dg = g'_uv,w'()
dg = dg:replace(r:diff(t), 0)()
printbr(var'g''_uv,w':eq(dg'_uvw'()))

-- Christoffel: G_abc = 1/2 (g_ab,c + g_ac,b - g_bc,a) 
local Gamma = ((dg'_uvw' + dg'_uwv' - dg'_vwu') / 2)()
printbr(var'\\Gamma''_abc':eq(Gamma'_abc'()))

-- Gamma_a, for x''^u = -g^uv Gamma_v
printbr(var'\\Gamma''_a':eq(var'\\Gamma''_abc' * var'g''^bc'):eq( Gamma'_ab^b'() ))
os.exit()

-- Christoffel: G^a_bc = g^ae G_ebc
Gamma = Gamma'^a_bc'()
printbr(var'\\Gamma''^a_bc':eq(Gamma'^a_bc'()))

-- Geodesic: x''^u = -G^u_vw x'^v x'^w
local diffx = Tensor('^u', function(u) return var('{d x^'..u..'}\\over{d\\tau}', coords) end)
local diffx2 = (-Gamma'^u_vw' * diffx'^v' * diffx'^w')()
printbr(var'\\ddot{x}':eq(diffx2))

-- Christoffel partial: G^a_bc,d
local dGamma = Gamma'^a_bc,d'()
printbr(var'\\Gamma''^a_bc,d':eq(dGamma'^a_bcd'()))

--Riemann: R^a_bcd = G^a_bd,c - G^a_bc,d + G^a_uc G^u_bd - G^a_ud G^u_bc
local Riemann = (dGamma'^a_bdc' - dGamma'^a_bcd' + Gamma'^a_uc' * Gamma'^u_bd' - Gamma'^a_ud' * Gamma'^u_bc')()
printbr(var'R''^a_bcd':eq(Riemann'^a_bcd'()))

-- Ricci: R_ab = R^u_aub
local Ricci = Riemann'^u_aub'()
printbr(var'R''_ab':eq(Ricci'_ab'))

-- Gaussian curvature: R = g^ab R_ab
local Gaussian = Ricci'^a_a'()
printbr(var'R':eq(Gaussian))
