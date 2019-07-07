#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup{implicitVars=true, MathJax={title='Gravitation 16.1 - expression'}}

local deta_eq_0 = eta'_ab,c':eq(0)
local ddelta_eq_0 = delta'_ab,c':eq(0)

printbr'metric:'
local g_def = g'_ab':eq(eta'_ab' - 2 * Phi * delta'_ab')
printbr(g_def)
printbr()

printbr'metric inverse:'
-- gU = -1/(1+2 Phi), 1 / (1 - 2 Phi)
--		= ( -1+2Phi, 1+2Phi )/(1-4Phi^2)
local gU_def = g'^ab':eq( frac(1, 1 - 4 * Phi^2) * (eta'^ab' + 2 * Phi * delta'^ab'))
printbr(gU_def)

local g_gU_ident = g'^ac' * g'_cb'
printbr(g_gU_ident)

g_gU_ident = g_gU_ident:subst(g_def:reindex{cb='ab'}, gU_def:reindex{ac='ab'}):simplify()
printbr(g_gU_ident)

g_gU_ident = g_gU_ident
	:replace(eta'^ac' * eta'_cb', delta'^a_b')
	-- none of these are being replace ...
	:replace(-2 * eta'^ac' * Phi * delta'_cb', 0)
	:replace(2 * Phi * delta'^ac' * eta'_cb', 0)
	:replace(-4 * Phi^2 * delta'^ac' * delta'_cb', -4 * Phi^2 * delta'^a_b')
	:simplify()
printbr(g_gU_ident)
-- and then this should turn out to be delta^a_b * (1 - 4 Phi^2) / (1 - 4 Phi^2)
printbr()

printbr'metric derivative:'
local dg_def = g_def'_,c'()
printbr(dg_def)

dg_def = dg_def:subst(deta_eq_0, ddelta_eq_0)()
printbr(dg_def)

printbr'connections:'
local ConnL_def = Gamma'_abc':eq(frac(1,2) * (g'_ab,c' + g'_ac,b' - g'_bc,a'))
printbr(ConnL_def)

ConnL_def = ConnL_def:subst(dg_def, dg_def:reindex{acb='abc'}, dg_def:reindex{bca='abc'})()
printbr(ConnL_def)

local Conn_def = Gamma'^a_bc':eq(g'^ad' * Gamma'_dbc')
printbr(Conn_def)

Conn_def = Conn_def:subst(gU_def:reindex{ad='ab'}, ConnL_def:reindex{dbc='abc'})()
printbr(Conn_def)

printbr('let ', Phi:eq(0), ', but keep ', Phi'_,a', 'to find:')
Conn_def = Conn_def:replace(Phi, 0, require 'symmath.tensor.TensorRef'.is)()
printbr(Conn_def)
printbr()

local du_def = u'^a_;b':eq(u'^a_,b' + Gamma'^a_cb' * u'^c')
printbr(du_def)

du_def = du_def:subst(Conn_def:reindex{acb='abc'})
	:simplify()
printbr(du_def)

local duit_def = du_def:reindex{it='ab'}
printbr(duit_def)

local duij_def = du_def:reindex{ij='ab'}
printbr(duij_def)

printbr()

-- TODO let Phi,t = 0 as well, but that means splitting Conn into time and space
printbr'stress-energy:'
local T_def = T'^ab':eq( (rho + P) * u'^a' * u'^b' + P * g'^ab')
printbr(T_def)

printbr'divergence-free...'
local dT_def = T_def'_;b'()
printbr(dT_def)

printbr'substitute...'
dT_def = dT_def
	:replace(g'^ab_;b', 0)
	:replace(g'^ab', eta'^ab')
	:replace(P'_;b', P'_,b')
	:replace(rho'_;b', rho'_,b')
	:simplify()
printbr(dT_def) 

printbr'separate b index into t and j:'
dT_def = dT_def:lhs():eq( dT_def:rhs():reindex{t='b'} + dT_def:rhs():reindex{j='b'} )
printbr(dT_def)

printbr'look at t component of a:'
local dTt_def = dT_def:reindex{t='a'}
printbr(dTt_def)

printbr'substitute...'
dTt_def = dTt_def
	:replace(u'^t', 1)
	:replace(u'^t_;t', 0)
	:replace(u'^t_;j', 0)
	:subst(du_def:reindex{jj='ab'})
	:replace(eta'^tt', -1)
	:replace(eta'^tj', 0)
	:simplify()
printbr(dTt_def)
printbr()

printbr'look at i component of a:'
local dTi_def = dT_def:reindex{i='a'}
printbr(dTi_def)

printbr'substitute...'
dTi_def = dTi_def
	:replace(u'^t', 1)
	:replace(eta'^ti', 0)
	:replace(eta'^it', 0)
	:replace(eta'^tj', 0)
	:simplify()
printbr(dTi_def)
