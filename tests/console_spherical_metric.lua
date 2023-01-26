#!/usr/bin/env lua
require 'ext'
require 'symmath'.setup{implicitVars=true, fixVariableNames=true}
local chart = Tensor.Chart{coords={r,theta,phi}}
u = Tensor('^I', r*sin(theta)*cos(phi), r*sin(theta)*sin(phi), r*cos(theta))
print('u^I:\n'..u)
e = u'^I_,a'():permute'_a^I'
print('e_a^I:\n'..e)
delta = Tensor('_IJ', table.unpack(Matrix.identity(3)))
print('delta_IJ:\n'..delta)
g = (e'_a^I' * e'_b^J' * delta'_IJ')()
print('g_ab:\n'..g)
chart:setMetric(g)
dg = g'_ab,c'():permute'_cab'
print('g_ab,c:\n'..dg)
GammaL = ((g'_ab,c' + g'_ac,b' - g'_bc,a')/2)():permute'_abc'
print('Gamma_abc:\n'..GammaL)
Gamma = GammaL'^a_bc'()
print('Gamma^a_bc:\n'..Gamma)
dGamma = Gamma'^a_bc,d'():permute'_d^a_bc'
print('Gamma^a_bc,d:\n'..dGamma)
Riemann = (Gamma'^a_db,c' - Gamma'^a_cb,d' + Gamma'^a_ce' * Gamma'^e_db' - Gamma'^a_de' * Gamma'^e_cb')()():permute'^a_bcd'
print('Riemann^a_bcd:\n'..Riemann)
