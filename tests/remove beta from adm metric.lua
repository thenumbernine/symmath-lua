#!/usr/bin/env luajit
require 'symmath'.setup{MathJax={useCommaDerivative=true, title='remove beta from ADM metric'}}

local alpha = var'\\alpha'
local beta = var'\\beta'
local gamma = var'\\gamma'
local delta = var'\\delta'
local Lambda = var'\\Lambda'
local g = var'g'
local n = var'n'

local g_def = Matrix(
	{-alpha^2+beta'^k'*beta'_k', beta'_j'},
	{beta'_i', gamma'_ij'}
)
printbr(g'_uv':eq(g_def))

local Lambda_def = Matrix(
	{gamma, -gamma * beta * n'_j'},
	{-gamma * beta * n'^i', delta'^i_j' + (gamma - 1) * n'^i' * n'_j'}
)
printbr(Lambda'^u_v':eq(Lambda_def))
