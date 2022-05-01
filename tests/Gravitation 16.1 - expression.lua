#!/usr/bin/env luajit
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, implicitVars=true, fixVariableNames=true, MathJax={title='Gravitation 16.1 - expression'}}

local delta = Tensor:deltaSymbol()

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

g_gU_ident = g_gU_ident:subst(g_def:reindex{ab='cb'}, gU_def:reindex{ab='ac'}):simplify()
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

ConnL_def = ConnL_def:subst(dg_def, dg_def:reindex{abc='acb'}, dg_def:reindex{abc='bca'})()
printbr(ConnL_def)

local Conn_def = Gamma'^a_bc':eq(g'^ad' * Gamma'_dbc')
printbr(Conn_def)

Conn_def = Conn_def:subst(gU_def:reindex{ab='ad'}, ConnL_def:reindex{abc='dbc'})()
printbr(Conn_def)

local function isTensorRef(x) return require 'symmath.tensor.Ref':isa(x) end

printbr('let ', Phi:eq(0), ', but keep ', Phi'_,a', 'to find:')
Conn_def = Conn_def:replace(Phi, 0, isTensorRef)()
printbr(Conn_def)
printbr()

printbr'covariant derivative of velocity:'
local du_def = u'^a_;b':eq(u'^a_,b' + Gamma'^a_cb' * u'^c')
printbr(du_def)

du_def = du_def:subst(Conn_def:reindex{abc='acb'})
	:simplify()
printbr(du_def)

local duit_def = du_def:reindex{ab='it'}
printbr(duit_def)

local duij_def = du_def:reindex{ab='ij'}
printbr(duij_def)

printbr()

printbr'gravitational acceleration:'
local gravExpr = -Gamma'^a_bc' * u'^b' * u'^c'
printbr(gravExpr)
gravExpr = gravExpr:substIndex(Conn_def)
printbr(gravExpr)
gravExpr = gravExpr:simplifyAddMulDiv()
printbr(gravExpr)
-- TODO for timelike velocities
-- you should end up with the gradient of Phi 
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
dT_def = dT_def:lhs():eq( dT_def:rhs():reindex{b='t'} + dT_def:rhs():reindex{b='j'} )
printbr(dT_def)

printbr'look at t component of a:'
local dTt_def = dT_def:reindex{a='t'}
printbr(dTt_def)

printbr'substitute...'
dTt_def = dTt_def
	:replace(u'^t', 1)
	:replace(u'^t_;t', 0)
	:replace(u'^t_;j', 0)
	:subst(du_def:reindex{ab='jj'})
	:replace(eta'^tt', -1)
	:replace(eta'^tj', 0)
	:simplify()
printbr(dTt_def)
printbr()

printbr'look at i component of a:'
local dTi_def = dT_def:reindex{a='i'}
printbr(dTi_def)

printbr'substitute...'
dTi_def = dTi_def
	:replace(u'^t', 1)
	:replace(eta'^ti', 0)
	:replace(eta'^it', 0)
	:replace(eta'^tj', 0)
	:simplify()
printbr(dTi_def)
