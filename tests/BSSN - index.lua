#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
require 'ext.env'(env)
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env}
local MathJax = symmath.export.MathJax
symmath.tostring = MathJax 
local printbr = MathJax.print
MathJax.header.title = 'BSSN formalism - index notation'
print(MathJax.header)


local alpha = var'\\alpha'
local beta = var'\\beta'
local gamma = var'\\gamma'
local delta = var'\\delta'
local eta = var'\\eta'
local chi = var'\\chi'
local pi = var'\\pi'
local phi = var'\\phi'
local rho = var'\\rho'
local Gamma = var'\\Gamma'
local f = var'f'
local B = var'B'
local K = var'K'
local R = var'R'
local S = var'S'
local W = var'W'
local ABar = var'\\bar{A}'
local RBar = var'\\bar{R}'
local gammaHat = var'\\hat{\\gamma}'
local gammaBar = var'\\bar{\\gamma}'
local epsilonBar = var'\\bar{\\epsilon}'
local LambdaBar = var'\\bar{\\Lambda}'
local GammaBar = var'\\bar{\\Gamma}'

Tensor.metricVariable = gamma

printbr(K'_ij', ' = extrinsic curvature')
printbr(gamma'_ij', ' = spatial metric')
printbr(gamma, ' = spatial metric determinant')
printbr(gammaHat'_ij', ' = grid metric')
printbr(gammaHat, ' = grid metric determinant')
printbr(gammaBar'_ij', ' = conformal metric')
printbr(gammaBar, ' = conformal metric determinant')
printbr()

printbr'useful identity:'
local conn_lll_def = Gamma'_ijk':eq(frac(1,2) * (gamma'_ij,k' + gamma'_ik,j' - gamma'_jk,i'))
printbr(conn_lll_def)
local dgamma_lll_for_conn_lll = (conn_lll_def + conn_lll_def:reindex{ijk='kji'}):symmetrizeIndexes(gamma,{1,2})():switch():reindex{jk='kj'}
printbr(dgamma_lll_for_conn_lll)
printbr()

local conn_ull_def = (gamma'^im' * conn_lll_def:reindex{i='m'})():simplifyMetrics()()
printbr(conn_ull_def)
printbr()

printbr'useful identity:'
local tmp = (gamma'_li' * gamma'^ij')'_,t':eq(0)
printbr(tmp)
tmp = tmp()
printbr(tmp)
tmp = (tmp * gamma'^lm')():factorDivision()
printbr(tmp)
tmp = tmp:replace(gamma'^lm' * gamma'_li', delta'^m_i')()
printbr(tmp)
tmp = tmp:simplifyMetrics()
	:reindex{im='mi'}
	:solve(gamma'^ij_,t')
printbr(tmp)
-- not the prettiest way to show that ...
local partial_gamma_ll_inv_from_partial_gamma_ll = tmp
printbr()


printbr'ADM metric evolution:'
--local dt_gamma_ll_def = gamma'_ij,t':eq(-2 * alpha * K'_ij' + beta'_i;j' + beta'_j;i')
local dt_gamma_ll_def = gamma'_ij,t':eq(-2 * alpha * K'_ij' + beta'_i,j' + beta'_j,i' - 2 * Gamma'^k_ij' * beta'_k')
printbr(dt_gamma_ll_def)

local dt_K_ll_def = K'_ij,t':eq(
--	-alpha'_;ij' 
	- alpha'_,ij' + Gamma'^k_ij' * alpha'_,k'

	+ alpha * (
		R'_ij' 
		+ K * K'_ij'
		- 2 * K'_ik' * K'^k_j'
	) 
	+ 4 * pi * alpha * (
		gamma'_ij' * (S - rho) 
		- 2 * S'_ij'
	) 
	+ K'_ij,k' * beta'^k' 
	+ K'_ki' * beta'^k_,j' 
	+ K'_kj' * beta'^k_,i'
)
printbr(dt_K_ll_def)
printbr()

--[[
printbr'contracted metric evolution:'
local tmp = (dt_gamma_ll_def * gamma'^ij')():factorDivision()
printbr(tmp)
tmp = tmp
	:replace(gamma'^ij' * K'_ij', K)
	:replace(gamma'^ij' * Gamma'^k_ij', Gamma'^k')
	:simplify()
printbr(tmp)
printbr()
--]]


printbr'extrinsic curvature trace evolution:'
local dt_K_def = dt_K_ll_def * gamma'^ij'
printbr(dt_K_def)
-- using K_,t = (K_ij gamma^ij)_,t = K_ij,t gamma^ij + K_ij gamma^ij_,t
dt_K_def[1] = (dt_K_def[1] + K'_,t' - K'_ij,t' * gamma'^ij' - K'_ij' * gamma'^ij_,t')()
dt_K_def = (dt_K_def + K'_ij' * gamma'^ij_,t')()
printbr(dt_K_def)
dt_K_def = dt_K_def
	:replace(K'_ij' * gamma'^ij', K)
	:replace(K'^k_j' * gamma'^ij', K'^ik')
	:replace(K'_ik' * K'^ik', K'_ij' * K'^ij')
	:replace(gamma'_ij' * gamma'^ij', 3)	-- gamma_ij gamma^ij = delta^i_k delta^k_i = delta^i_i = dim
	:replace(R'_ij' * gamma'^ij', R)
	:replace(S'_ij' * gamma'^ij', S)
-- K_ij,k gamma^ij = K_,k - K_ij gamma^ij_,k = 
	:replace(gamma'^ij' * K'_ij,k', K'_,k' - K'_ij' * gamma'^ij_,k')
-- n_,t = 0 <=> (gamma^ij gamma_ij)_,t = 0 <=> gamma^ij_,t gamma_ij = -gamma^ij gamma_ij,t
	:simplify()
printbr(dt_K_def)
dt_K_def = dt_K_def
	:subst(partial_gamma_ll_inv_from_partial_gamma_ll)
	:subst(partial_gamma_ll_inv_from_partial_gamma_ll:reindex{t='k'})
	:simplify()
printbr(dt_K_def)
dt_K_def = dt_K_def
	:subst(dt_gamma_ll_def:reindex{ij='lm'})()
	:simplifyMetrics()()
printbr(dt_K_def)
dt_K_def = dt_K_def
	:replace(beta'_l,m', (gamma'_ln' * beta'^n')'_,m')
	:replace(beta'_m,l', (gamma'_mn' * beta'^n')'_,l')
	:subst(dgamma_lll_for_conn_lll:reindex{ijk='lmk'})
	:subst(dgamma_lll_for_conn_lll:reindex{ijk='lnm'})
	:subst(dgamma_lll_for_conn_lll:reindex{ijk='mnl'})
	:simplify()
printbr(dt_K_def)
dt_K_def = dt_K_def
	:subst(dgamma_lll_for_conn_lll:reindex{ijk='lnm'})
	:subst(dgamma_lll_for_conn_lll:reindex{ijk='mnl'})
	:simplify()
dt_K_def = dt_K_def
	:simplifyMetrics()()
	:replace(K'^lm' * Gamma'_mkl', K'^lm' * Gamma'_lkm')
	:reindex{n='k'}
	:symmetrizeIndexes(Gamma,{2,3})
	:simplify()
	:replace(K'^lm' * Gamma'_mkl', K'^lm' * Gamma'_lkm')
	:simplify()
	:reindex{ml='ij'}
	:replace(K'_k^j', K'^j_k')
	:replace(beta'_k' * K'_ij' * Gamma'^kij', beta'^k' * K'^ij' * Gamma'_kij')
	:replace(K'^ji' * Gamma'_kji', K'^ij' * Gamma'_kij')
--	:symmetrizeIndexes(K,{1,2})	-- hmm, doesn't respect upper/lower
--	:replace(K'_k^j' * beta'^k_,j', K'_k^j' * beta'^k_,j')
	:simplify()
	:replace(Gamma'^kj_j', Gamma'^k')
	:simplify()
printbr(dt_K_def)
printbr()

printbr'Bona-Masso lapse and shift evolution:'
local dt_alpha_def = alpha'_,t':eq(alpha'_,i' * beta'^i' - alpha^2 * f * K)
printbr(dt_alpha_def)

local dt_beta_u_def = beta'^i_,t':eq(B'^i')
printbr(dt_beta_u_def)

local dt_B_u_def = B'^i_,t':eq(frac(3,4) * LambdaBar'^i_,t' - eta * B'^i')
printbr(dt_B_u_def) 
printbr()

--printbr('metric derivative:')

printbr('conformal $\\phi$:')
local phi_def = phi:eq(frac(1,12) * log(frac(gamma, gammaHat)))
printbr(phi_def)
printbr()


printbr('conformal $\\chi$:')
local chi_def = chi:eq(cbrt(frac(gammaHat, gamma)))
printbr(chi_def)
printbr()


printbr('conformal W:')
local W_def = W:eq(frac(gammaHat, gamma)^frac(1,6))
printbr(W_def)
local W_from_chi = W:eq(sqrt(chi))
printbr(W_from_chi)
local W_from_phi = W:eq(exp(-4 * phi))()
printbr(W_from_phi)
printbr()


printbr'conformal metric:'
local gammaBar_ll_from_gamma_ll_W = gammaBar'_ij':eq(W^2 * gamma'_ij')
printbr(gammaBar_ll_from_gamma_ll_W)

local gamma_ll_from_gammaBar_ll_W = gammaBar_ll_from_gamma_ll_W:solve(gamma'_ij')
printbr(gamma_ll_from_gammaBar_ll_W)
printbr()

printbr'conformal metric inverse:'
local gammaBar_uu_from_gamma_uu_W = gammaBar'^ij':eq(W^-2 * gamma'^ij')
printbr(gammaBar_uu_from_gamma_uu_W)

local gamma_uu_from_gammaBar_uu_W = gammaBar_uu_from_gamma_uu_W:solve(gamma'^ij')
printbr(gamma_uu_from_gammaBar_uu_W)
printbr()

printbr'conformal metric derivative:'
local partial_gammaBar_ll_from_partial_gamma_ll_W = gammaBar_ll_from_gamma_ll_W'_,k'()
printbr(partial_gammaBar_ll_from_partial_gamma_ll_W)
local partial_gamma_lll_from_partial_gammaBar_lll_W = partial_gammaBar_ll_from_partial_gamma_ll_W
	:solve(gamma'_ij,k')
	:subst(gamma_ll_from_gammaBar_ll_W)
	:simplify()
printbr(partial_gamma_lll_from_partial_gammaBar_lll_W)
printbr()


printbr'conformal metric determinant:'
local det_gammaBar_ll_from_det_gamma_ll = gammaBar:eq(W^6 * gamma)	-- asserting that the dimension of the spatial metric is 3 ...
printbr(det_gammaBar_ll_from_det_gamma_ll)
local det_gamma_ll_from_det_gammaBar_ll = det_gammaBar_ll_from_det_gamma_ll:solve(gamma)
printbr(det_gamma_ll_from_det_gammaBar_ll)
printbr()


printbr('conformal metric constraint:')
local det_gammaBar_ll_from_det_gammaHat_ll = gammaBar:eq(gammaHat)
printbr(det_gammaBar_ll_from_det_gammaHat_ll)
local det_gammaHat_ll_from_det_gammaBar_ll = det_gammaBar_ll_from_det_gammaHat_ll:solve(gammaHat)
printbr(det_gammaHat_ll_from_det_gammaBar_ll)
printbr()


printbr('static grid assumption:')
local dt_gammaHat_ll_def = gammaHat'_ij,t':eq(0)
printbr(dt_gammaHat_ll_def)
local dt_det_gammaHat_def = gammaHat'_,t':eq(0)
printbr(dt_det_gammaHat_def)
printbr()


--[[
printbr'conformal $\\phi$ derivative:'
local tmp = (12 * phi_def)()
printbr(tmp)
tmp[2] = tmp[2]:expand()
printbr(tmp)
tmp = tmp'_,i'()
printbr(tmp)
tmp = tmp:subst(
	det_gamma_ll_from_det_gammaBar_ll,
	det_gammaBar_ll_from_det_gammaHat_ll
)()
printbr(tmp)
printbr()
--]]


printbr'conformal connection:'
local connBar_lll_def = GammaBar'_ijk':eq(frac(1,2) * (gammaBar'_ij,k' + gammaBar'_ik,j' - gammaBar'_jk,i'))
printbr(connBar_lll_def)
local connBar_lll_from_W_gamma_ll = connBar_lll_def:subst(
	partial_gammaBar_ll_from_partial_gamma_ll_W,
	partial_gammaBar_ll_from_partial_gamma_ll_W:reindex{ijk='ikj'},
	partial_gammaBar_ll_from_partial_gamma_ll_W:reindex{ijk='jki'}
)()
printbr(connBar_lll_from_W_gamma_ll)
local connBar_lll_from_conn_lll_W_gamma_ll = connBar_lll_from_W_gamma_ll:subst(
	conn_lll_def:solve(gamma'_ij,k')
)()
printbr(connBar_lll_from_conn_lll_W_gamma_ll)
local conn_lll_from_connBar_lll_W_gamma_ll = connBar_lll_from_conn_lll_W_gamma_ll:solve(Gamma'_ijk')
printbr(conn_lll_from_connBar_lll_W_gamma_ll)

local connBar_ull_from_conn_ull_W_gamma_ll = 
	(connBar_lll_from_conn_lll_W_gamma_ll:reindex{i='m'} * gamma'^im')()
printbr(connBar_ull_from_conn_ull_W_gamma_ll)
connBar_ull_from_conn_ull_W_gamma_ll[1] = connBar_ull_from_conn_ull_W_gamma_ll[1]
	:subst(gamma_uu_from_gammaBar_uu_W:reindex{j='m'})
	:simplify()
connBar_ull_from_conn_ull_W_gamma_ll = (connBar_ull_from_conn_ull_W_gamma_ll / W^2)()
	-- can't just use 'simplifyMetrics' with the conformal metrics, becaus they are rescaled
	-- also can't use simplifyMetrics with tensors that are conformally rescaled, because they use the conformal metric and not the metric
	-- this is why you should really denote indexes of rescaling and not entire tensors, because the rescaling should be proportional to the number of rescaled indexes, 
	-- and an arbitrary # of indexes can be rescaled
	:replace(gammaBar'^im' * GammaBar'_mjk', GammaBar'^i_jk')():factorDivision()
	:replace(gamma'^im' * gamma'_mj', delta'^i_j')
	:replace(gamma'^im' * gamma'_mk', delta'^i_k')
	:replace(gamma'^im' * Gamma'_mjk', Gamma'^i_jk')
	:simplify()
printbr(connBar_ull_from_conn_ull_W_gamma_ll)
local conn_ull_from_connBar_ull_W_gamma_ll = connBar_ull_from_conn_ull_W_gamma_ll:solve(Gamma'^i_jk')()
printbr(conn_ull_from_connBar_ull_W_gamma_ll)
printbr()


printbr('conformal W derivative:')
local dt_W_def = W_def'_,t'()
printbr(dt_W_def)
printbr('assuming', dt_det_gammaHat_def)
dt_W_def = dt_W_def:subst(dt_det_gammaHat_def)()
printbr(dt_W_def)
dt_W_def[2] = (dt_W_def[2] * W_def[1] / W_def[2])() 
printbr(dt_W_def)
dt_W_def = dt_W_def:replace(gamma'_,t', gamma * gamma'^ij' * gamma'_ij,t')()
printbr(dt_W_def)
dt_W_def = dt_W_def:subst(dt_gamma_ll_def)():factorDivision()
printbr(dt_W_def)
dt_W_def = dt_W_def
	:replace(gamma'^ij' * K'_ij', K)
	:replace(gamma'^ij' * beta'_j,i', gamma'^ij' * beta'_i,j')
	:replace(beta'_k' * Gamma'^k_ij' * gamma'^ij', beta'^k' * Gamma'_k')
	:simplify()
printbr(dt_W_def)
dt_W_def = dt_W_def:replace(beta'_i,j', (beta'^k' * gamma'_ki')'_,j')()
printbr(dt_W_def)
dt_W_def = dt_W_def
	:simplifyMetrics()()
	:replace(beta'^k_,j' * gamma'_k^j', beta'^k_,k')
	:subst(dgamma_lll_for_conn_lll:reindex{ijk='kij'})
	:simplify()
	:simplifyMetrics()
	:replace(Gamma'_kj^j', Gamma'_k')
	:simplify()
printbr(dt_W_def)
--[[
dt_W_def = dt_W_def
	:subst(conn_ull_from_connBar_ull_W_gamma_ll:reindex{ijk='jjk'})
	:replace(delta'^j_j', 3)
	:simplifyMetrics()
	:reindex{m='k'}
	:simplify()
printbr(dt_W_def)
--]]
dt_W_def = dt_W_def
	:subst(conn_ull_def:reindex{ijk='jjk'})
	:simplify()
	:subst(gamma_uu_from_gammaBar_uu_W:reindex{ij='jm'})
	:subst(partial_gamma_lll_from_partial_gammaBar_lll_W:reindex{ijk='jkm'})
	:subst(partial_gamma_lll_from_partial_gammaBar_lll_W:reindex{ijk='mjk'})
	:subst(partial_gamma_lll_from_partial_gammaBar_lll_W:reindex{ijk='mkj'})
	:simplify()
	--:simplifyMetrics{gammaBar}	-- only safe to do if all of the same metric is used.  don't mix and match.
	:replace(gammaBar'^jm' * gammaBar'_mk', delta'^j_k')
	:replace(gammaBar'^jm' * gammaBar'_mj', delta'^j_j')
	:replace(gammaBar'^jm' * gammaBar'_jk', delta'^m_k')
	:simplifyMetrics{delta}
	:replace(delta'^j_j', 3)
	:simplify()
printbr(dt_W_def)
printbr()

--[[
printbr'conformal W partial wrt $\\phi$:'
local partial_W_from_phi = W_from_phi'_,i'():replace(e'_,i', 0)()	-- TODO since e has no depends vars, make e'_,i' always replace to 0 by default.
printbr(partial_W_from_phi)
local tmp = partial_W_from_phi:subst(W_from_phi:switch())()
printbr(tmp)
local partial_phi_from_W = tmp:solve(phi'_,i')()
printbr(partial_phi_from_W)
printbr()

printbr('conformal W second derivative wrt $\\phi$:')
local partial2_W_from_phi = partial_W_from_phi'_,j'():replace(e'_,j', 0)()
printbr(partial2_W_from_phi)
partial2_W_from_phi = partial2_W_from_phi:subst(W_from_phi:switch())()
printbr(partial2_W_from_phi)
partial2_W_from_phi = partial2_W_from_phi:subst(partial_phi_from_W, partial_phi_from_W:reindex{i='j'})()
printbr(partial2_W_from_phi)
local partial2_phi_from_W = partial2_W_from_phi:solve(phi'_,ij')()
printbr(partial2_phi_from_W)
printbr()
--]]

printbr'conformal metric evolution:'
local dt_gammaBar_ll_def = gammaBar_ll_from_gamma_ll_W'_,t'()
printbr(dt_gammaBar_ll_def)
dt_gammaBar_ll_def = dt_gammaBar_ll_def:subst(dt_gamma_ll_def)()
printbr(dt_gammaBar_ll_def)
dt_gammaBar_ll_def = dt_gammaBar_ll_def
	:subst(dt_W_def:reindex{ij='ln'})
	:replace(beta'_i,j', (beta'^k' * gamma'_ki')'_,j')
	:replace(beta'_j,i', (beta'^k' * gamma'_kj')'_,i')
	:replace(beta'_k' * Gamma'^k_ij', beta'^k' * Gamma'_kij')
	:simplify()
printbr(dt_gammaBar_ll_def)
dt_gammaBar_ll_def = dt_gammaBar_ll_def
	:subst(conn_lll_def:reindex{ijk='kij'})
	:simplify()
printbr(dt_gammaBar_ll_def)
dt_gammaBar_ll_def = dt_gammaBar_ll_def
	:subst(partial_gamma_lll_from_partial_gammaBar_lll_W:reindex{ijk='kij'})
	:subst(partial_gamma_lll_from_partial_gammaBar_lll_W:reindex{ijk='kji'})
	:subst(gamma_ll_from_gammaBar_ll_W)
	:subst(gamma_ll_from_gammaBar_ll_W:reindex{ij='ki'})
	:subst(gamma_ll_from_gammaBar_ll_W:reindex{ij='kj'})
	:simplify()
printbr(dt_gammaBar_ll_def)
--[[ doesn't help
dt_gammaBar_ll_def = dt_gammaBar_ll_def
	:symmetrizeIndexes(gammaBar, {1,2})()
	:tidyIndexes()
printbr(dt_gammaBar_ll_def)
--]]
printbr()

printbr'conformal metric perturbation:'
local epsilonBar_def = epsilonBar'_ij':eq(gammaBar'_ij' - gammaHat'_ij')
printbr(epsilonBar_def)
printbr()

printbr'conformal metric perturbation evolution:'
local dt_epsilonBar_ll_def = epsilonBar_def'_,t'()
printbr(dt_epsilonBar_ll_def)
printbr('assuming', dt_gammaHat_ll_def)
dt_epsilonBar_ll_def = dt_epsilonBar_ll_def:subst(dt_gammaHat_ll_def)()
printbr(dt_epsilonBar_ll_def)
printbr()
dt_epsilonBar_ll_def = dt_epsilonBar_ll_def:subst(dt_gammaBar_ll_def)


printbr'<hr>'
--]]
printbr('collecting partial derivatives:')

printbr(dt_alpha_def)
printbr(dt_beta_u_def)
printbr(dt_B_u_def)
printbr(dt_W_def)
printbr(dt_K_def)
printbr(dt_epsilonBar_ll_def)

printbr()

printbr'<hr>'

-- final results, since I'm too lazy to derive them
-- TODO copy these expressions over to bssnok-fd-sym and evaluate them for each grid.  no more intermediate simplifications required.
printbr'using locally-Minkowski-normalized  non-coordinate components:'

local dt_alpha_norm_def = dt_alpha_def:replace(beta'^i', e'^i_I' * beta'^I')()
printbr(dt_alpha_norm_def) 
printbr()

local dt_W_norm_def = W'_,t':eq(
	-frac(1,3) * W * (
		e'^k_K_,k' * beta'^K' 
		+ e'^k_K' * beta'^K_,k' 
		+ GammaBar'^K_LK' * beta'^L' 
		- alpha * K
	) 
	+ W'_,i' * e'^i_I' * beta'^I'
)
printbr(dt_W_norm_def)
printbr()

local dt_K_norm_def = K'_,t':eq(
	frac(1,3) * alpha * K^2 
	+ alpha * ABar'_IJ' * ABar'^IJ' 
	- W * (
		W * gammaBar'^ij' * alpha'_,ij' 
		- W * GammaBar'^K' * e'^k_K' * alpha'_,k' 
		- gammaBar'^IJ' * e'^i_I' * e'^j_J' * alpha'_,i' *  W'_,j'
	) 
	+ K'_,i' * e'^i_I' * beta'^I'
	+ 4 * pi * alpha * (S + rho) 
)
printbr(dt_K_norm_def)
printbr()

local dt_epsilonBar_norm_def = epsilonBar'_IJ,t':eq(
	e'^i_I' * e'^j_J' * (
		frac(2,3) * gammaBar'_ij' * (
			alpha * gammaBar'^kl' * (e'_k^K' * e'_l^L' * ABar'_KL')
			- e'^k_K,k' * beta'^K'
			- e'^k_K' * beta'^K_,k'
			- gammaBar'^k_lk' * e'^l_L' * beta'^L'
		)
		+ gamma'_ki,j' * e'^k_K' * beta'^K'
		+ gamma'_ki' * e'^k_K,j' * beta'^K'
		+ gamma'_ki' * e'^k_K' * beta'^K_,j'
		+ gamma'_kj,i' * e'^k_K' * beta'^K'
		+ gamma'_kj' * e'^k_K,i' * beta'^K'
		+ gamma'_kj' * e'^k_K' * beta'^K_,i'
		- 2 * gammaHat'^k_ij' * e'_k^K' * beta'_K'
		+ e'^k_K' * beta'^K' * (
			e'_i^L_,k' * e'_j^M' * epsilonBar'_LM'
			+ e'_i^L' * e'_j^M_,k' * epsilonBar'_LM'
			+ e'_i^L' * e'_j^M' * epsilonBar'_LM,k'
		) 
		+ epsilonBar'_kj' * (
			e'^k_K,i' * beta'^K'
			+ e'^k_K' * beta'^K_,i'
		)
		+ epsilonBar'_ki' * (
			e'^k_K,j' * beta'^K'
			+ e'^k_K' * beta'^K_,j'
		)
	)
	- 2 * alpha * ABar'_IJ'
)
printbr(dt_epsilonBar_norm_def)
printbr()

local dt_ABar_norm_def = ABar'_IJ,t':eq(
	-frac(2,3) * ABar'_IJ' * (
		e'^k_K,k' * beta'^K'
		+ e'^k_K' * beta'^K_,k'
		+ GammaBar'^K_LK' * beta'^L'
	)
	- 2 * alpha * e'_i^I' * e'_j^J' * ABar'_IK' * ABar'^K_J'
	+ alpha * K * ABar'_IJ'
	+ (
		- frac(1,4) * e'^i_I' * e'^j_J' * alpha * W'_,i' * W'_,j'
		
		+ frac(1,2) * alpha * e'^i_I' * e'^j_J' * W * W'_,ij'
		- frac(1,2) * alpha * e'^k_K' * gammaBar'^K_IJ' * W * W'_,k'
		
		- frac(1,4) * W * e'^i_I' * e'^j_J' * 2 * alpha'_,i' * W'_,j'
		- frac(1,4) * W * e'^i_I' * e'^j_J' * 2 * alpha'_,j' * W'_,i'
		- W^2 * e'^i_I' * e'^j_J' * alpha'_,ij'
		+ W^2 * gammaBar'^K_IJ' * e'^k_K' * alpha'_,k'
		+ W^2 * alpha * (
			RBar'_IJ'
			- 8 * pi * S'_IJ'
		)
	)'^TF'
	+ e'^k_K' * (
		ABar'_IJ,k'
		+ e'^i_I' * e'_i^L_,k' * ABar'_LJ'
		+ e'^j_J' * e'_j^M_,k' * ABar'_IM'
	)
	+ e'^i_I' * (
		ABar'_MJ' * e'_k^M' * e'^k_K,i' * beta'^K'
		+ ABar'_KJ' * beta'^K_,i'
	)
	+ e'^j_J' * (
		ABar'_MI' * e'_k^M' * e'^k_K,j' * beta'^K'
		+ ABar'_KI' * beta'^K_,j'
	)
)
printbr(dt_ABar_norm_def)
printbr()

local dt_B_norm_def = B'^I_,t':eq(
	frac(3,4) * LambdaBar'^I_,t' 
	- eta * B'^I'
)
printbr(dt_B_norm_def) 
printbr()
