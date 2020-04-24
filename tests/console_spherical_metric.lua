#!/usr/bin/env lua
require 'ext'
require 'symmath'.setup{implicitVars=true}
Tensor.coords{{variables={r,theta,phi}}}
u = Tensor('^I', r*sin(theta)*cos(phi), r*sin(theta)*sin(phi), r*cos(theta))
print('u^I:\n'..u)
e = Tensor'_i^I'
e['_a^I'] = u'^I_,a'()
print('e_a^I:\n'..e)
delta = Tensor('_IJ', table.unpack(Matrix.identity(3)))
print('delta_IJ:\n'..delta)
g = (e'_a^I' * e'_b^J' * delta'_IJ')()
print('g_ab:\n'..g)
Tensor.metric(g)
dg = Tensor'_abc'
dg['_abc'] = g'_ab,c'()
print('g_ab,c:\n'..dg)
GammaL = ((dg'_abc' + dg'_acb' - dg'_bca')/2)()
print('Gamma_abc:\n'..GammaL)
Gamma = GammaL'^a_bc'()
print('Gamma^a_bc:\n'..Gamma)
dGamma = Tensor'^a_bcd'
dGamma['^a_bcd'] = Gamma'^a_bc,d'()
print('Gamma^a_bc,d:\n'..dGamma)
GammaSq = Tensor'^a_bcd'
GammaSq['^a_bcd'] = (Gamma'^a_ce' * Gamma'^e_db')()
Riemann = Tensor'^a_bcd'
Riemann['^a_bcd'] = (dGamma'^a_dbc' - dGamma'^a_cbd' + GammaSq'^a_bcd' - GammaSq'^a_bdc')()
print('Riemann^a_bcd:\n'..Riemann)
