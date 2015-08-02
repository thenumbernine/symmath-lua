#! /usr/bin/env luajit

local symmath = require 'symmath'
local Tensor = symmath.Tensor 
symmath.tostring = require 'symmath.tostring.SingleLine'

local t,x,y,z = symmath.vars('t', 'x', 'y', 'z')

Tensor.coords{
	{
		variables = {t,x,y,z}
	},
	{
		variables = {x,y,z},
		symbols = 'ijklmn',
		metric = Tensor({1,0,0},{0,1,0},{0,0,1}),
	},
}

local alpha = 1
print('alpha = '..alpha)

local v = symmath.var'v'
print('v = '..v)

local f = symmath.var'f'
print('f = '..f)

local beta = Tensor('^i', -v*f, 0, 0)
print('beta^i = '..beta)

local gamma = Tensor('_ij', {1,0,0}, {0,1,0}, {0,0,1})
print('gamma_ij = '..gamma)
print('gamma^ij = '..gamma'^ij')

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
		g[{i+1,j+1}] = gamma'^ij'[{i,j}] - beta[i] * beta[j] / alpha^2
	end
end
g=g:simplify()

Tensor.metric(g)

print('g_ab = '..g'_ab')
print('g^ab = '..g'^ab')
do return end

local conn = 1/2 * (g'_ab,c' + g'_ac,b' - g'_bc,a')
print(conn'_abc')
print(conn'^a_bc')

