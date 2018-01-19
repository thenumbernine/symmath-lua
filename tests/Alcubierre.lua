#!/usr/bin/env luajit
require 'symmath'.setup()
require 'symmath.tostring.MathJax'.setup()

local t,x,y,z = vars('t', 'x', 'y', 'z')
local coords = {t,x,y,z}

Tensor.coords{
	{
		variables = coords,
	},
	{
		variables = {x,y,z},
		symbols = 'ijklmn',
		metric = {{1,0,0},{0,1,0},{0,0,1}},
	},
}

local alpha = 1
printbr('lapse = '..alpha)

local v = var('v', {t,x,y,z})
printbr('warp bubble velocity = '..v)

local f = var('f', {t,x,y,z})
printbr('some function = '..f)

local beta = Tensor('^i', -v*f, 0, 0)
printbr('shift '..var'\\beta''^i':eq(beta'^i'()))

local gamma = Tensor('_ij', {1,0,0}, {0,1,0}, {0,0,1})
printbr'spatial metric:'
printbr(var'\\gamma''_ij':eq(gamma'_ij'()))
printbr(var'\\gamma''^ij':eq(gamma'^ij'()))

local g = Tensor'_ab'
--[[
g['_tt'] = -alpha^2 + beta'^i' * beta'^j' * gamma'_ij'
g['_it'] = beta'^i' / alpha^2
g['_ti'] = beta'^i' / alpha^2
g['_ij'] = gamma'^ij' - beta'^i' * beta'^j' / alpha^2
--]]
g[{1,1}] = -alpha^2
for i=1,3 do
	g[{i+1,1}] = beta[i] / alpha^2
	g[{1,i+1}] = beta[i] / alpha^2
	for j=1,3 do
		g[{1,1}] = g[{1,1}] + beta[i] * beta[j] * gamma[{i,j}]
		g[{i+1,j+1}] = gamma'^ij'()[{i,j}] - beta[i] * beta[j] / alpha^2
	end
end
g=g()
printbr'4-metric:'
printbr(var'g''_ab':eq(g'_ab'()))

local detg = var('g', {t,x,y,z})
local detg_def = Matrix(table.unpack(g)):determinant()
printbr(var'g':eq(detg_def))

local gU = Tensor('^ab', table.unpack(
	(Matrix(table.unpack(g)):inverse())
))
printbr(var'g''^ab':eq(gU'^ab'()))
gU = gU:replace((-detg_def)(), -detg)
gU = gU:replace( (-detg_def * (1 - v^2*f^2))(), -detg * (1 - v^2 * f^2) )
gU = gU:replace( ((1 - v^2 * f^2)^2)(), (1 - v^2 * f^2)^2 )
printbr(var'g''^ab':eq(gU'^ab'()))

Tensor.metric(g, gU)

local Gamma = ((g'_ab,c' + g'_ac,b' - g'_bc,a') / 2)()
printbr(var'\\Gamma''_abc':eq(Gamma'_abc'()))

Gamma = Gamma'^a_bc'()
printbr(var'\\Gamma''^a_bc':eq(Gamma'^a_bc'()))

local dx = Tensor('^u', function(u) return var('\\dot{x}^'..coords[u].name) end)
local d2x = Tensor('^u', function(u) return var('\\ddot{x}^'..coords[u].name) end)
printbr'geodesic:'
-- TODO unravel equaliy, or print individual assignments
printbr(((d2x'^a' + Gamma'^a_bc' * dx'^b' * dx'^c'):eq(Tensor('^u',0,0,0,0)))())
printbr()

local dGamma = Tensor'^a_bcd'
dGamma['^a_bcd'] = Gamma'^a_bc,d'()
printbr(var'Gamma''^a_bc,d':eq(dGamma))

local GammaSq = Tensor'^a_bcd'
GammaSq['^a_bcd'] = (Gamma'^a_ec' * Gamma'^e_bd')()
printbr(var'Gamma^2''^a_bcd':eq(GammaSq))

local Riemann = Tensor'^a_bcd'
Riemann['^a_bcd'] = (dGamma'^a_bdc' - dGamma'^a_bcd' + GammaSq'^a_bcd' - GammaSq'^a_bdc')()
printbr(var'R''^a_bcd':eq(Riemann))
