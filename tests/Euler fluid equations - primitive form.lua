#!/usr/bin/env luajit
require 'ext'
op = nil	-- make way for _G.op = symmath.op
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='Euler fluid equations - primitive form'}}

local rho = var'\\rho'
local gamma = var'\\gamma'
local tildeGamma = var'\\tilde\\gamma'
local v = var'v'
local g = var'g'
local P = var'P'

printbr('assuming '..g'_ij,t':eq(0))

local rhoDef = (rho'_,t' + (rho * v'^j')'_;j'):eq(0)
local mDef = ((rho * v'^i')'_,t' + (rho * v'^i' * v'^j' + g'^ij' * P)'_;j'):eq(0)
local ETotalDef = ((frac(1,2) * rho * v'^k' * v'_k' + P / tildeGamma)'_,t' + (v'^j' * (frac(1,2) * rho * v'^k' * v'_k' + P / tildeGamma + P))'_;j'):eq(0)

printbr'Euler fluid equations in hyperbolic conservation law form:'
printbr(rhoDef)
printbr(mDef)
printbr(ETotalDef)
printbr()

-- this will expand:
local dt_rhoDef = rhoDef:solve(rho'_,t')
printbr(dt_rhoDef)
printbr()

local dt_vDef = mDef()
printbr(dt_vDef)
dt_vDef = dt_vDef:subst(dt_rhoDef)()
dt_vDef = dt_vDef:replace(g'^ij_;j', 0)()
dt_vDef = (dt_vDef / rho)():solve(v'^i_,t')
-- cheap metric lower:
dt_vDef = dt_vDef
	:replace(v'^i_,t', v'_i,t')
	:replace(v'^i_;j', v'_i;j')
	:replace(P'_;j' * g'^ij', P'_;i')
	()
printbr(dt_vDef)
printbr()

local dt_PDef = ETotalDef()
	:subst(dt_rhoDef)
	:replace(tildeGamma'_,t', 0)
	:replace(tildeGamma'_;j', 0)
	:simplify()
	:factorDivision()
printbr(dt_PDef)
dt_PDef = dt_PDef
	:replace(v'_j' * v'^j_,t', v'^j' * v'_j,t')
	:replace(v'_j' * v'^j_;j', v'^j' * v'_j;j')
	:replace(v'_k' * v'^k_,t', v'^k' * v'_k,t')	-- based on g_ij,t = 0
	:replace(v'_k' * v'^k_;j', v'^k' * v'_k;j')	-- based on g_ij;k = 0
	() 
dt_PDef = (dt_PDef * tildeGamma)()
dt_PDef = dt_PDef:subst(dt_vDef:reindex{i='k'})()
dt_PDef = dt_PDef:reindex{k = 'j'}()
dt_PDef = dt_PDef:solve(P'_,t')()
dt_PDef = dt_PDef:replace(tildeGamma, gamma-1)()
printbr(dt_PDef)
printbr()

printbr'Euler fluid equations in primitive initial-value problem form:'
printbr(dt_rhoDef)
printbr(dt_vDef)
printbr(dt_PDef)
printbr()

local D_rhoDef = (dt_rhoDef + rho'_;j' * v'^j')()
local D_vDef = (dt_vDef + v'_i;j' * v'^j')()
local D_PDef = (dt_PDef + P'_;j' * v'^j')()
printbr'Euler fluid equations in primitive material-derivative form:'
printbr(D_rhoDef)
printbr(D_vDef)
printbr(D_PDef)
printbr()

local Dinf_rhoDef = D_rhoDef:replace(rho'_,t',0)()
local Dinf_vDef = D_vDef:replace(v'_i,t', 0)()
local Dint_PDef = D_PDef:replace(P'_,t', 0)()
printbr'Compressible steady state:'
printbr(Dinf_rhoDef)
printbr(Dinf_vDef)
printbr(Dint_PDef)
printbr()

local Dinf_gradPDef = Dinf_vDef:solve(P'_;i')
printbr'Compressible steady state pressure gradient:'
printbr(Dinf_gradPDef)
printbr()

printbr'Substitute into pressure steady state when allowing compressibility:'
local tmp = (-Dint_PDef):subst(Dinf_gradPDef:reindex{ij='jk'})()
printbr(tmp)
tmp = (tmp / (rho * v'^j_;j'))():switch()
printbr(tmp)
printbr[[So the speed of sound $C_s = \sqrt{\frac{\gamma P}{\rho}} = \sqrt{\frac{v \cdot \nabla_v v}{\nabla \cdot v}}$]]
printbr()

local Dinc_rhoDef = Dinf_rhoDef:replace(v'^j_;j', 0)()
local Dinc_vDef = Dinf_vDef:replace(v'^j_;j', 0)()
local Dint_PDef = Dint_PDef:replace(v'^j_;j', 0)()
printbr'Incompressible steady-state:'
printbr(Dinc_rhoDef)
printbr(Dinc_vDef)
printbr(Dint_PDef)
printbr()

local Dinc_gradPDef = Dinc_vDef:solve(P'_;i')
printbr'Incompressible steady state pressure gradient:'
printbr(Dinc_gradPDef)
printbr()

printbr'Substitute into pressure steady state when allowing compressibility:'
local tmp = (-Dint_PDef):subst(Dinc_gradPDef:reindex{ij='jk'})()
printbr(tmp)
printbr()
