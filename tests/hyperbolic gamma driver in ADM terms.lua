#!/usr/bin/env luajit
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env}
local MathJax = symmath.export.MathJax
symmath.tostring = MathJax 
local printbr = MathJax.print
MathJax.header.title = 'hyperbolic gamma driver in ADM terms'
print(MathJax.header)

-- setup timer.  
-- os.time() is second-resolution.  
-- os.clock() has higher resolution, but counts time x # cores afaik
-- nope.  looks like os.clock() matches gettimeofday() pretty closely
local timer = require 'ext.timer'.getTime

local startTime = timer()
local lastTime = startTime
local function printHeader(str)
	local thisTime = timer()
	io.stderr:write(' ... '..(thisTime-lastTime)..'s\n')
	lastTime = thisTime
	if str then 
		io.stderr:write(str) 
		printbr(str)
	end
	io.stderr:flush()
end


local spatialDim = 3

local B = var'B'
local K = var'K'
local W = var'W'
local alpha = var[[\alpha]]
local beta = var[[\beta]]
local gamma = var[[\gamma]]
local zeta = var[[\zeta]]
local eta = var[[\eta]]
local GammaBar = var[[\bar{\Gamma}]]
local gammaBar = var[[\bar{\gamma}]]

Tensor.metricVariable = gamma
local delta = Tensor:deltaSymbol()


printHeader'Jacobi identity:'
local Jacobi_identity = gamma'_,t':eq( gamma * gamma'^ij' * gamma'_ij,t')
printbr(Jacobi_identity)
printbr()


printHeader'useful identity:'
local dt_gamma_uu_from_gamma_uu_partial_gamma_lll = (gamma'_li' * gamma'^ij')'_,t':eq(0)
printbr(dt_gamma_uu_from_gamma_uu_partial_gamma_lll)
dt_gamma_uu_from_gamma_uu_partial_gamma_lll = dt_gamma_uu_from_gamma_uu_partial_gamma_lll()
printbr(dt_gamma_uu_from_gamma_uu_partial_gamma_lll)
dt_gamma_uu_from_gamma_uu_partial_gamma_lll = (dt_gamma_uu_from_gamma_uu_partial_gamma_lll * gamma'^lm')():factorDivision()
printbr(dt_gamma_uu_from_gamma_uu_partial_gamma_lll)
dt_gamma_uu_from_gamma_uu_partial_gamma_lll = dt_gamma_uu_from_gamma_uu_partial_gamma_lll:simplifyMetrics()
	:reindex{im='mi'}
	:solve(gamma'^ij_,t')
printbr(dt_gamma_uu_from_gamma_uu_partial_gamma_lll)
-- not the prettiest way to show that ...
printbr()

local dt_gammaBar_uu_from_gammaBar_uu_partial_gammaBar_lll = dt_gamma_uu_from_gamma_uu_partial_gamma_lll:replace(gamma, gammaBar)


printHeader'spatial metric evolution:'
local dt_gamma_ll_def = gamma'_ij,t':eq(
	-2 * alpha * K'_ij'
	+ gamma'_ij,k' * beta'^k'
	+ gamma'_kj' * beta'^k_,i'
	+ gamma'_ik' * beta'^k_,j'
)
printbr(dt_gamma_ll_def)
printbr()


printHeader'conformal factor:'
local W_def = W:eq( ( gammaBar / gamma ) ^ frac(1,6))
printbr(W_def)
printbr()

printHeader'conformal factor derivative:'
local partial_W_l_def = W_def'_,i'()
partial_W_l_def[2] = (
	partial_W_l_def[2] / W_def[2] * W_def[1]
):simplifyAddMulDiv()
printbr(partial_W_l_def)
printbr()

printHeader'conformal factor evolution:'
local dt_W_def = partial_W_l_def:reindex{i='t'}
	:replace(gammaBar'_,t', 0)
	:substIndex(Jacobi_identity)
dt_W_def = dt_W_def:simplifyAddMulDiv()
printbr(dt_W_def)
dt_W_def = dt_W_def
	:substIndex(dt_gamma_ll_def)
	:simplifyMetrics()
	:tidyIndexes()
printbr(dt_W_def)
printbr()


printHeader'conformal metric:'
local gammaBar_ll_def = gammaBar'_ij':eq( W^2 * gamma'_ij' )
printbr(gammaBar_ll_def)
printbr()


printHeader'conformal metric derivative:'
local dgammaBar_lll_def = (gammaBar_ll_def'_,k')()
printbr(dgammaBar_lll_def)
printbr()


printHeader'conformal metric inverse:'
local gammaBar_uu_def = gammaBar'^ij':eq( W^(-2) * gamma'^ij' )
printbr(gammaBar_uu_def)
printbr()


printHeader'conformal connection:'
local GammaBar_ull_def = GammaBar'^i_jk':eq( frac(1,2) * gammaBar'^im' * (gammaBar'_mj,k' + gammaBar'_mk,j' - gammaBar'_jk,m') )
printbr(GammaBar_ull_def)
GammaBar_ull_def = GammaBar_ull_def
	:substIndex(dgammaBar_lll_def)
	:substIndex(gammaBar_uu_def)
	:simplifyMetrics()
	:simplifyAddMulDiv()
printbr(GammaBar_ull_def)
printbr()


printHeader'conformal connection trace:'
local GammaBar_u_def = GammaBar'^i':eq(GammaBar'^i_jk' * gammaBar'^jk')
printbr(GammaBar_u_def)
GammaBar_u_def = GammaBar_u_def 
	:substIndex(GammaBar_ull_def)
	:substIndex(gammaBar_uu_def)
	:simplifyMetrics()
	:replace(delta'^k_k', spatialDim)
	:tidyIndexes()
	:symmetrizeIndexes(gamma, {1,2})
GammaBar_u_def = GammaBar_u_def:simplifyAddMulDiv()
printbr(GammaBar_u_def)
printbr()

printHeader'conformal connection trace evolution:'
local dt_GammaBar_u_def = GammaBar_u_def'_,t':simplifyAddMulDiv()
printbr(dt_GammaBar_u_def)
dt_GammaBar_u_def = dt_GammaBar_u_def
	:substIndex(dt_gamma_uu_from_gamma_uu_partial_gamma_lll)
printbr(dt_GammaBar_u_def)
dt_GammaBar_u_def = dt_GammaBar_u_def
	:replace(W'_,at', W'_,t''_,a')
	--:subst(dt_W_def)		-- has two 'a' indexes
	--:substIndex(dt_W_def)	-- has two trace(K) terms
	:subst(dt_W_def:reindex{abc='fde'})
printbr(dt_GammaBar_u_def)

dt_GammaBar_u_def = dt_GammaBar_u_def:simplifyAddMulDiv()
printbr(dt_GammaBar_u_def)

dt_GammaBar_u_def = dt_GammaBar_u_def
	:tidyIndexes()
printbr(dt_GammaBar_u_def)

dt_GammaBar_u_def = dt_GammaBar_u_def
	:symmetrizeIndexes(gamma, {1,2})
dt_GammaBar_u_def = dt_GammaBar_u_def:simplifyAddMulDiv()
printbr(dt_GammaBar_u_def)

dt_GammaBar_u_def = dt_GammaBar_u_def
	:replace(gamma'_ab,ct', gamma'_ab,t''_,c')
	:subst(dt_gamma_ll_def:reindex{ij='ab'})
	
	:replace(gamma'_bc,at', gamma'_bc,t''_,a')
	:subst(dt_gamma_ll_def:reindex{ij='bc'})
	
	--:subst(dt_gamma_ll_def:reindex{ij='bc'})
	:subst(dt_gamma_ll_def:reindex{ij='cd'})
	:subst(dt_gamma_ll_def:reindex{ij='bd'})
dt_GammaBar_u_def = dt_GammaBar_u_def:simplifyAddMulDiv()
	:subst(
		dt_gammaBar_uu_from_gammaBar_uu_partial_gammaBar_lll:reindex{ijt='cdb'}
	)
dt_GammaBar_u_def = dt_GammaBar_u_def:simplifyAddMulDiv()
printbr(dt_GammaBar_u_def)

dt_GammaBar_u_def = dt_GammaBar_u_def
	:simplifyMetrics()
	:tidyIndexes()
	:symmetrizeIndexes(beta, {2,3})
	:symmetrizeIndexes(gamma, {3,4})
dt_GammaBar_u_def = dt_GammaBar_u_def:simplifyAddMulDiv()
printbr(dt_GammaBar_u_def)

dt_GammaBar_u_def = dt_GammaBar_u_def
	:splitOffDerivIndexes()
	:replace( K'^a_a', gamma'^mn' * K'_mn')
	:replace( K'^b_b', gamma'^mn' * K'_mn')
dt_GammaBar_u_def = dt_GammaBar_u_def:simplifyAddMulDiv()
	:simplifyMetrics()
	:tidyIndexes()
	:symmetrizeIndexes(gamma, {1,2})
dt_GammaBar_u_def = dt_GammaBar_u_def:simplifyAddMulDiv()
printbr(dt_GammaBar_u_def)
printbr()


printHeader'B evolution:'
local dt_B_u_def = (B'^i_,t'):eq(
	-- zeta == 3/4 / alpha^2 ... so get rid of the alpha^2 ...
	alpha^2 * zeta * (
		GammaBar'^i_,t'
		- beta'^j' * GammaBar'^i_,j'
	)
	-- eta = 1?
	- eta * B'^i'
	- beta'^j' * B'^i_,j'
)
printbr(dt_B_u_def)
dt_B_u_def = dt_B_u_def
	:subst(dt_GammaBar_u_def)
	:splitOffDerivIndexes()
	:substIndex(GammaBar_u_def)
printbr(dt_B_u_def)
dt_B_u_def = dt_B_u_def:simplifyAddMulDiv()
printbr(dt_B_u_def)
printbr()


-- DONE
printHeader()
io.stderr:write('TOTAL: '..(timer() - startTime)..'\n')
io.stderr:flush()
print(MathJax.footer)
