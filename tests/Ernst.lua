#!/usr/bin/env luajit
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, implicitVars=true, fixVariableNames=true, MathJax={title='Ernst'}}

local chart = Tensor.Chart{coords={t,r,theta,phi}}

--local Lambda = 1 + B^2 * r^2 * sin(theta)^2
local Lambda = var('Lambda', {t,r,theta,phi})
local M = 0
g = Tensor('_ab', table.unpack(Matrix.diagonal( -Lambda^2 * (1 - 2 * M / r), Lambda^2 / (1 - 2 * M / r), Lambda^2 * r^2, r^2 * sin(theta)^2 / Lambda^2 )))
print'<hr>'
g:printElem'g'
printbr()

local gU = Tensor('^ab', table.unpack((Matrix.inverse(g))))
print'<hr>'
gU:printElem'g'
printbr()

chart:setMetric(g, gU)

local dg = Tensor'_abc'
dg['_abc'] = g'_ab,c'()

local GammaL = Tensor'_abc'
GammaL['_abc'] = (frac(1,2) * (dg'_abc' + dg'_acb' - dg'_bca'))()

local Gamma = (GammaL'^a_bc')()
print'<hr>'
Gamma:printElem'Gamma'
printbr()

local GammaSq = Tensor'^a_bcd'
GammaSq['^a_bcd'] = (Gamma'^a_ec' * Gamma'^e_bd')()

local dGamma = Tensor'^a_bcd'
dGamma['^a_bcd'] = Gamma'^a_bc,d'()

local Riemann = Tensor'^a_bcd'
Riemann['^a_bcd'] = (dGamma'^a_bdc' - dGamma'^a_bcd' + GammaSq'^a_bcd' - GammaSq'^a_bdc')()
print'<hr>'
Riemann:printElem'R'
printbr()

local Ricci = (Riemann'^c_acb')()
print'<hr>'
Ricci:printElem'R'
printbr()

local Gaussian = (Ricci'^a_a')()
print'<hr>'
printbr(G:eq(Gaussian))
printbr()

local Einstein = (Ricci'_ab' - frac(1,2) * g'_ab' * Gaussian)()
print'<hr>'
Einstein:printElem'G'
printbr()
