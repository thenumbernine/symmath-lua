#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup{tostring='MathJax', MathJax={title='Kerr-Schild - expression', usePartialLHSForDerivative=true}}

local t, x, y, z = vars('t', 'x', 'y', 'z')
local spatialCoords = table{x,y,z}
local coords = {t, x, y, z}

Tensor.coords{
	{variables=coords},
	{
		variables = spatialCoords,
		symbols = 'ijklmn',
	},
	{symbols='t', variables={t}},
	{symbols='x', variables={x}},
	{symbols='y', variables={y}},
	{symbols='z', variables={z}},

}

-- black hole parameters
local a = var('a')
local M = var'M'
local Q = var'Q'


local eta = var'\\eta'
local eta_def = eta'_uv':eq(Tensor('_uv', function(u,v) return u~=v and 0 or u==1 and -1 or 1 end))
--printbr(eta_def)
printbr(eta_def[2]:printElem(eta_def[1][1].name))
printbr()

local rho = var('\\rho', spatialCoords)
local rho_def = rho:eq(x^2 + y^2 + z^2 - a^2)
printbr(rho_def)
local drho_dx_defs = table()
for i,xi in ipairs(spatialCoords) do
	drho_dx_defs[i] = rho_def:diff(xi)()
	printbr(drho_dx_defs[i])
end
printbr()

local rhoPlus = var('\\rho_+', spatialCoords)
local rhoPlus_def = rhoPlus:eq(sqrt(rho^2 + 4*a^2*z^2))()
printbr(rhoPlus_def)
local drhoPlus_dx_defs = table()
for i,xi in ipairs(spatialCoords) do
	drhoPlus_dx_defs[i] = rhoPlus_def:diff(xi)()
		:subst(rhoPlus_def:switch(), drho_dx_defs:unpack())
	printbr(drhoPlus_dx_defs[i])
end
printbr()

local r = var('r', spatialCoords)
local rSq_def = (r^2):eq(frac(1,2) * (rho + rhoPlus))
printbr(rSq_def)
local dr_dx_defs = table()
for i,xi in ipairs(spatialCoords) do
	local dr_dx = rSq_def:diff(xi)():solve(r:diff(xi))
		:subst(drho_dx_defs:unpack())
		:subst(drhoPlus_dx_defs:unpack())
		:simplify()
	printbr(dr_dx)
	dr_dx_defs:insert(dr_dx)
end
printbr()

local H = var('H', spatialCoords)
local H_def = H:eq((r * M - Q^2 / 2) / (r^2 + a^2 * z^2 / r^2))
printbr(H_def)
local dH_dx_defs = table()
for i,xi in ipairs(spatialCoords) do
	local dH_dx_def = H_def:diff(xi)():subst(dr_dx_defs:unpack())()
	printbr(dH_dx_def)
	dH_dx_defs:insert(dH_dx_def)
end
printbr()

local l = var'l'
local l_def = l'_u':eq(Tensor('_u', function(u)
	return ({
		1,
		(r*x + a*y) / (r^2 + a^2),
		(r*y - a*x) / (r^2 + a^2),
		z / r,
	})[u]
end))
--printbr(l_def)
printbr(l_def[2]:printElem(l_def[1][1].name))
printbr()

for i,xi in ipairs(spatialCoords) do
	for j,xj in ipairs(spatialCoords) do
		local dl_dx_def = l('_'..xi.name..','..xj.name):eq(
			l_def[2][i+1]:diff(xj)
		)
		printbr(dl_dx_def)
		dl_dx_def = dl_dx_def() 
		printbr('=', dl_dx_def[2])
		dl_dx_def = dl_dx_def:subst(dr_dx_defs:unpack())
		printbr('=', dl_dx_def[2])
		dl_dx_def = dl_dx_def() 
		printbr('=', dl_dx_def[2])
		printbr()
	end
end

local g = var'g'
local g_ll_def = g'_uv':eq(eta'_uv' + 2 * H * l'_u' * l'_v')
printbr(g_ll_def)

local lStar = var'l_*'
local lStar_def = lStar'^u':eq(eta'^uv' * l'_v')
printbr(lStar_def)

local g_uu_def = g'^uv':eq(eta'^uv' - 2 * H * lStar'^u' * lStar'^v')
printbr(g_uu_def)

local dg_lll_def = g_ll_def',w'():replace(eta'_uv,w', 0)()
printbr(dg_lll_def)

local Gamma = var'\\Gamma'
local Gamma_lll_def = Gamma'_abc':eq(frac(1,2) * (g'_ab,c' + g'_ac,b' - g'_bc,a'))
printbr(Gamma_lll_def)

-- this isn't working correctly ...
--Gamma_lll_def = Gamma_lll_def:substIndex(dg_lll_def)
-- so here's this instead:
Gamma_lll_def = Gamma_lll_def():subst(
	dg_lll_def:reindex{abc = 'uvw'},
	dg_lll_def:reindex{acb = 'uvw'},
	dg_lll_def:reindex{bca = 'uvw'}
)

Gamma_lll_def = Gamma_lll_def()
printbr(Gamma_lll_def)

local u = var'u'
local du = var'\\dot{u}'

local accel_l_def = du'_a':eq(-Gamma'_abc' * u'^b' * u'^c')
printbr(accel_l_def)

accel_l_def = accel_l_def:subst(Gamma_lll_def)()
printbr(accel_l_def)

accel_l_def = accel_l_def():tidyIndexes()
printbr(accel_l_def)
