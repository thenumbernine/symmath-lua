#! /usr/bin/env luajit

local symmath = require 'symmath'
local Tensor = require 'symmath.Tensor'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
print(MathJax.header)

local function printbr(...)
	print(...)
	print'<br>'
end

local t,x,y,z = symmath.vars('t', 'x', 'y', 'z')

Tensor.coords{
	{
		variables = {t,x,y,z},
	},
	{
		variables = {x,y,z},
		symbols = 'ijklmn',
		metric = {{1,0,0},{0,1,0},{0,0,1}},
	},
}

local alpha = 1
printbr('lapse = '..alpha)

local v = symmath.var('v', {t,x,y,z})
printbr('warp bubble velocity = '..v)

local f = symmath.var('f', {t,x,y,z})
printbr('some function = '..f)

local beta = Tensor('^i', -v*f, 0, 0)
printbr('shift \\( \\beta^i = \\)'..beta)

local gamma = Tensor('_ij', {1,0,0}, {0,1,0}, {0,0,1})
printbr'spatial metric:'
printbr('\\(\\gamma_{ij} = \\)'..gamma)
printbr('\\(\\gamma^{ij} = \\)'..gamma'^ij')

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

printbr'4-metric:'
printbr([[\(g_{ab} = \)]]..g'_ab')
printbr([[\(g^{ab} = \)]]..g'^ab')

local dg = (g'_ab,c'):simplify()
printbr([[\(g_{ab,c} = \)]]..dg)
local conn = (dg'_abc' + dg'_acb' - dg'_bca'):simplify()
printbr([[\(\Gamma_{abc} = \)]]..conn'_abc')
do return end
local conn = (1/2 * (g'_ab,c' + g'_ac,b' - g'_bc,a')):simplify()
printbr([[\(\Gamma_{abc} = \)]]..conn)	-- TODO correctly re-order indexes for arithmetic operations
--printbr('conn_abc = '..conn'_abc')
--printbr(conn'^a_bc')

print(MathJax.footer)
