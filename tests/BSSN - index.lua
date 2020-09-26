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

--[[ times:
useful identity: ... 0.19531106948853s
useful identity: ... 0.091263771057129s
ADM metric evolution: ... 0.004716157913208s
Bona-Masso lapse and shift evolution: ... 0.0013840198516846s
conformal $\phi$: ... 0.00024604797363281s
conformal $\chi$: ... 0.00031781196594238s
conformal W: ... 0.0027329921722412s
conformal metric: ... 0.0040051937103271s
conformal metric inverse: ... 0.0064499378204346s
conformal metric derivative: ... 0.061810970306396s
conformal metric determinant: ... 0.0014359951019287s
conformal metric constraint: ... 0.00031805038452148s
static grid assumption: ... 0.00028300285339355s
conformal connection: ... 0.6639039516449s
extrinsic curvature trace: ... 0.00037002563476563s
trace-free extrinsic curvature: ... 0.013814926147461s
conformal trace-free extrinsic curvature: ... 0.049103975296021s
trace-free extrinsic curvature derivative: ... 0.021255970001221s
conformal W derivative: ... 1.1865050792694s
conformal metric evolution: ... 0.85421395301819s
conformal metric perturbation: ... 0.00016093254089355s
conformal metric perturbation spatial derivative: ... 0.0035240650177002s
conformal metric perturbation evolution: ... 0.011292934417725s
grid vs conformal connection difference: ... 0.009087085723877s
conformal connection evolution: ... 39.595111131668s
grid vs conformal connection difference evolution: ... 26.742503881454s
extrinsic curvature trace evolution: ... 30.551944971085s
trace-free extrinsic curvature evolution: ... 0.044536113739014s
conformal trace-free extrinsic curvature evolution: ... 21.1120429039s
collecting partial derivatives: ... 0.025572061538696s
TOTAL: 121.25661706924
--]]

-- setup timer.  
-- os.time() is second-resolution.  
-- os.clock() has higher resolution, but counts time x # cores afaik
-- nope.  looks like os.clock() matches gettimeofday() pretty closely
local timer = os.clock
local result, ffi = pcall(require, 'ffi')
if result and ffi then
	require 'ffi.c.sys.time'
	local tv = ffi.new'struct timeval[1]'
	timer = function()
		ffi.C.gettimeofday(tv, nil)
		return tonumber(tv[0].tv_sec) + 1e-6 * tonumber(tv[0].tv_usec)
	end
end

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


local function betterSimplify(x)
	return x():factorDivision()
	:map(function(y)
		if symmath.op.add.is(y) then
			local newadd = table()
			for i=1,#y do
				newadd[i] = y[i]():factorDivision()
			end
			return #newadd == 1 and newadd[1] or symmath.op.add(newadd:unpack())
		end
	end)
end


--[[
-- use i-z first, then a-h
-- come to think of it, I should avoid txyz as well
Tensor.defaultSymbols = range(9,26):append(range(1,8)):mapi(function(x) return string.char(x) end)
--]]


local delta = Tensor:deltaSymbol()
local alpha = var'\\alpha'
local beta = var'\\beta'
local gamma = var'\\gamma'
local eta = var'\\eta'
local chi = var'\\chi'
local pi = var'\\pi'
local phi = var'\\phi'
local rho = var'\\rho'
local Gamma = var'\\Gamma'
local f = var'f'
local A = var'A'
local B = var'B'
local K = var'K'
local R = var'R'
local S = var'S'
local W = var'W'
local ABar = var'\\bar{A}'
local RBar = var'\\bar{R}'
local gammaBar = var'\\bar{\\gamma}'
local epsilonBar = var'\\bar{\\epsilon}'
local GammaBar = var'\\bar{\\Gamma}'
local DeltaBar = var'\\bar{\\Delta}'
local LambdaBar = var'\\bar{\\Lambda}'

local barVars = table{
	ABar,
	RBar,
	gammaBar,
	epsilonBar,
	GammaBar,
	DeltaBar,
	LambdaBar,
}

local gammaHat = var'\\hat{\\gamma}'
local GammaHat = var'\\hat{\\Gamma}'

Tensor.metricVariable = gamma


local simplifyMetricGammaBarRule = {
	isMetric = function(g)
		return g[1] == gammaBar
	end,
	canSimplify = function(g, t, gi, ti)
		return barVars:find(t[1])
		and t[ti].lower ~= g[gi].lower
		and not t:hasDerivIndex()
	end,
}

local function simplifyBarMetrics(expr)
	return expr:simplifyMetrics{simplifyMetricGammaBarRule, Tensor.simplifyMetricsRules.delta}
end


printbr(K'_ij', ' = extrinsic curvature')
printbr(gamma'_ij', ' = spatial metric')
printbr(gamma, ' = spatial metric determinant')
printbr(gammaHat'_ij', ' = grid metric')
printbr(gammaHat, ' = grid metric determinant')
printbr(gammaBar'_ij', ' = conformal metric')
printbr(gammaBar, ' = conformal metric determinant')
printbr()


printHeader'useful identity:'
local conn_lll_def = Gamma'_ijk':eq(frac(1,2) * (gamma'_ij,k' + gamma'_ik,j' - gamma'_jk,i'))
printbr(conn_lll_def)
local dgamma_lll_for_conn_lll = (conn_lll_def + conn_lll_def:reindex{ijk='kji'}):symmetrizeIndexes(gamma,{1,2})():switch():reindex{jk='kj'}
printbr(dgamma_lll_for_conn_lll)
printbr()

local conn_ull_def = (gamma'^im' * conn_lll_def:reindex{i='m'})():simplifyMetrics()()
printbr(conn_ull_def)
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


printHeader'ADM metric evolution:'
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
printHeader'contracted metric evolution:'
local tmp = (dt_gamma_ll_def * gamma'^ij')():factorDivision()
printbr(tmp)
tmp = tmp
	:replace(gamma'^ij' * K'_ij', K)
	:replace(gamma'^ij' * Gamma'^k_ij', Gamma'^k')
	:simplify()
printbr(tmp)
printbr()
--]]


printHeader'Bona-Masso lapse and shift evolution:'
local dt_alpha_def = alpha'_,t':eq(alpha'_,i' * beta'^i' - alpha^2 * f * K)
printbr(dt_alpha_def)

local dt_beta_u_def = beta'^i_,t':eq(B'^i')
printbr(dt_beta_u_def)

local dt_B_u_def = B'^i_,t':eq(frac(3,4) * LambdaBar'^i_,t' - eta * B'^i')
printbr(dt_B_u_def) 
printbr()

--printHeader'metric derivative:'

printHeader'conformal $\\phi$:'
local phi_def = phi:eq(frac(1,12) * log(frac(gamma, gammaHat)))
printbr(phi_def)
printbr()


printHeader'conformal $\\chi$:'
local chi_def = chi:eq(cbrt(frac(gammaHat, gamma)))
printbr(chi_def)
printbr()


printHeader'conformal W:'
local W_def = W:eq(frac(gammaHat, gamma)^frac(1,6))
printbr(W_def)
local W_from_chi = W:eq(sqrt(chi))
printbr(W_from_chi)
local W_from_phi = W:eq(exp(-4 * phi))()
printbr(W_from_phi)
printbr()


printHeader'conformal metric:'
local gammaBar_ll_from_gamma_ll_W = gammaBar'_ij':eq(W^2 * gamma'_ij')
printbr(gammaBar_ll_from_gamma_ll_W)

local gamma_ll_from_gammaBar_ll_W = gammaBar_ll_from_gamma_ll_W:solve(gamma'_ij')
printbr(gamma_ll_from_gammaBar_ll_W)
printbr()

printHeader'conformal metric inverse:'
local gammaBar_uu_from_gamma_uu_W = gammaBar'^ij':eq(W^-2 * gamma'^ij')
printbr(gammaBar_uu_from_gamma_uu_W)

local gamma_uu_from_gammaBar_uu_W = gammaBar_uu_from_gamma_uu_W:solve(gamma'^ij')
printbr(gamma_uu_from_gammaBar_uu_W)
printbr()

printHeader'conformal metric derivative:'
local partial_gammaBar_lll_from_partial_gamma_lll_W = gammaBar_ll_from_gamma_ll_W'_,k'()
printbr(partial_gammaBar_lll_from_partial_gamma_lll_W)
local partial_gamma_lll_from_partial_gammaBar_lll_W = partial_gammaBar_lll_from_partial_gamma_lll_W
	:solve(gamma'_ij,k')
	:subst(gamma_ll_from_gammaBar_ll_W)
	:simplify()
printbr(partial_gamma_lll_from_partial_gammaBar_lll_W)
printbr()


printHeader'conformal metric determinant:'
local det_gammaBar_ll_from_det_gamma_ll = gammaBar:eq(W^6 * gamma)	-- asserting that the dimension of the spatial metric is 3 ...
printbr(det_gammaBar_ll_from_det_gamma_ll)
local det_gamma_ll_from_det_gammaBar_ll = det_gammaBar_ll_from_det_gamma_ll:solve(gamma)
printbr(det_gamma_ll_from_det_gammaBar_ll)
printbr()


printHeader'conformal metric constraint:'
local det_gammaBar_ll_from_det_gammaHat_ll = gammaBar:eq(gammaHat)
printbr(det_gammaBar_ll_from_det_gammaHat_ll)
local det_gammaHat_ll_from_det_gammaBar_ll = det_gammaBar_ll_from_det_gammaHat_ll:solve(gammaHat)
printbr(det_gammaHat_ll_from_det_gammaBar_ll)
printbr()


printHeader'static grid assumption:'
local dt_gammaHat_ll_def = gammaHat'_ij,t':eq(0)
printbr(dt_gammaHat_ll_def)
local dt_det_gammaHat_def = gammaHat'_,t':eq(0)
printbr(dt_det_gammaHat_def)
printbr()


--[[
printHeader'conformal $\\phi$ derivative:'
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


printHeader'conformal connection:'
local connBar_lll_def = GammaBar'_ijk':eq(frac(1,2) * (gammaBar'_ij,k' + gammaBar'_ik,j' - gammaBar'_jk,i'))
printbr(connBar_lll_def)
local connBar_lll_from_W_gamma_ll = connBar_lll_def:subst(
	partial_gammaBar_lll_from_partial_gamma_lll_W,
	partial_gammaBar_lll_from_partial_gamma_lll_W:reindex{ijk='ikj'},
	partial_gammaBar_lll_from_partial_gamma_lll_W:reindex{ijk='jki'}
)()
printbr(connBar_lll_from_W_gamma_ll)
local connBar_lll_from_conn_lll_W_gamma_ll = connBar_lll_from_W_gamma_ll:subst(
	conn_lll_def:solve(gamma'_ij,k')
)()
printbr(connBar_lll_from_conn_lll_W_gamma_ll)
local conn_lll_from_connBar_lll_W_gamma_ll = connBar_lll_from_conn_lll_W_gamma_ll:solve(Gamma'_ijk')
printbr(conn_lll_from_connBar_lll_W_gamma_ll)

local conn_lll_from_connBar_lll_W_gammaBar_ll = conn_lll_from_connBar_lll_W_gamma_ll
	:substIndex(gamma_ll_from_gammaBar_ll_W, gamma_uu_from_gammaBar_uu_W)()
printbr(conn_lll_from_connBar_lll_W_gammaBar_ll)

local connBar_ull_def = (gammaBar'^im' * connBar_lll_def:reindex{i='m'})()
	:replace(gammaBar'^im' * GammaBar'_mjk', GammaBar'^i_jk')()
printbr(connBar_ull_def)

local connBar_ull_from_conn_ull_W_gamma_ll = connBar_ull_def
	:substIndex(gammaBar_uu_from_gamma_uu_W)
	:substIndex(partial_gammaBar_lll_from_partial_gamma_lll_W)
	:subst(conn_lll_def:solve(gamma'_ij,k'):reindex{ijk='mjk'})
	:factorDivision()
	:replace(gamma'^im' * Gamma'_mjk', Gamma'^i_jk')
	:replace(gamma'^im' * gamma'_mj', delta'^i_j')
	:replace(gamma'^im' * gamma'_mk', delta'^i_k')
	:simplify()
printbr(connBar_ull_from_conn_ull_W_gamma_ll)

local conn_ull_from_connBar_ull_W_gamma_ll = connBar_ull_from_conn_ull_W_gamma_ll:solve(Gamma'^i_jk')()
printbr(conn_ull_from_connBar_ull_W_gamma_ll)

local conn_ull_from_connBar_ull_W_gammaBar_ll = conn_ull_from_connBar_ull_W_gamma_ll
	:substIndex(gamma_ll_from_gammaBar_ll_W, gamma_uu_from_gammaBar_uu_W)()
printbr(conn_ull_from_connBar_ull_W_gammaBar_ll)
printbr()



printHeader'extrinsic curvature trace:'
local K_def = K:eq(K'_ij' * gamma'^ij')
printbr(K_def)
--[[
local K_from_K_ll_gammaBar_uu = K_def:subst(gamma_uu_from_gammaBar_uu_W)
printbr(K_from_K_ll_gammaBar_uu)
--]]
printbr()



printHeader'trace-free extrinsic curvature:'
local A_ll_def = A'_ij':eq(K'_ij' - frac(1,3) * gamma'_ij' * K)
printbr(A_ll_def)
local K_ll_from_A_ll_K = A_ll_def:solve(K'_ij')
printbr(K_ll_from_A_ll_K)
local A_uu_def = A'^ij':eq(K'^ij' - frac(1,3) * gamma'^ij' * K)
printbr(A_uu_def)
local K_uu_from_A_uu_K = A_uu_def:solve(K'^ij')
printbr(K_uu_from_A_uu_K)
printbr()

printHeader'conformal trace-free extrinsic curvature:'
local ABar_ll_def = ABar'_ij':eq(W^2 * A'_ij')
printbr(ABar_ll_def)
local A_ll_from_ABar_ll = ABar_ll_def:solve(A'_ij')
printbr(A_ll_from_ABar_ll)
local ABar_uu_from_A_uu = (gammaBar'^mi' * ABar_ll_def * gammaBar'^jn')()
printbr(ABar_uu_from_A_uu)
ABar_uu_from_A_uu = ABar_uu_from_A_uu 
	:replace(gammaBar'^mi' * ABar'_ij' * gammaBar'^jn', ABar'^mn')
	:substIndex(gammaBar_uu_from_gamma_uu_W)
	:simplify()
printbr(ABar_uu_from_A_uu)
ABar_uu_from_A_uu = ABar_uu_from_A_uu 
	:replace(A'_ij' * gamma'^jn' * gamma'^mi', A'^mn')
	:simplify()
	:reindex{mn='ij'}
printbr(ABar_uu_from_A_uu)
local A_uu_from_ABar_uu = ABar_uu_from_A_uu:solve(A'^ij')
printbr(A_uu_from_ABar_uu)

local K_ll_from_ABar_ll_gammaBar_ll_K = K_ll_from_A_ll_K:subst(A_ll_from_ABar_ll, gamma_ll_from_gammaBar_ll_W)()
printbr(K_ll_from_ABar_ll_gammaBar_ll_K)
printbr()


printHeader'trace-free extrinsic curvature derivative:'
local partial_K_lll_from_partial_A_lll_K = K_ll_from_A_ll_K'_,k'()
printbr(partial_K_lll_from_partial_A_lll_K)
printbr()



printHeader'conformal W derivative:'
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
	:subst(dgamma_lll_for_conn_lll:reindex{ijk='kij'})
	:simplifyMetrics()
	:replace(Gamma'_kj^j', Gamma'_k')
	:simplify()
printbr(dt_W_def)
dt_W_def = dt_W_def
	:subst(conn_ull_def:reindex{ijk='jjk'})
	:simplify()
	:subst(gamma_uu_from_gammaBar_uu_W:reindex{ij='jm'})
	:subst(partial_gamma_lll_from_partial_gammaBar_lll_W:reindex{ijk='jkm'})
	:subst(partial_gamma_lll_from_partial_gammaBar_lll_W:reindex{ijk='mjk'})
	:subst(partial_gamma_lll_from_partial_gammaBar_lll_W:reindex{ijk='mkj'})
	:simplify()
printbr(dt_W_def)
dt_W_def = simplifyBarMetrics(dt_W_def)
	:replace(delta'_m^m', 3)
	:replace(gammaBar'^jm' * gammaBar'_mk,j', gammaBar'^jm' * gammaBar'_jk,m')
	:simplify()
	:tidyIndexes()
	:reindex{abc='ijk'}
	:symmetrizeIndexes(gammaBar, {1,2})
printbr(dt_W_def)
printbr()


--[[
printHeader'conformal W partial wrt $\\phi$:'
local partial_W_from_phi = W_from_phi'_,i'():replace(e'_,i', 0)()	-- TODO since e has no depends vars, make e'_,i' always replace to 0 by default.
printbr(partial_W_from_phi)
local tmp = partial_W_from_phi:subst(W_from_phi:switch())()
printbr(tmp)
local partial_phi_from_W = tmp:solve(phi'_,i')()
printbr(partial_phi_from_W)
printbr()

printHeader'conformal W second derivative wrt $\\phi$:'
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

printHeader'conformal metric evolution:'
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
	:subst(K_ll_from_A_ll_K, A_ll_from_ABar_ll)
	:subst(partial_gamma_lll_from_partial_gammaBar_lll_W)
	:subst(partial_gamma_lll_from_partial_gammaBar_lll_W:reindex{ijk='kij'})
	:subst(partial_gamma_lll_from_partial_gammaBar_lll_W:reindex{ijk='kji'})
	:substIndex(gamma_ll_from_gammaBar_ll_W)
	:simplify()
	:tidyIndexes{fixed='ij'}
	:simplify()
	:reindex{abc='kmn'}
printbr(dt_gammaBar_ll_def)
printbr()



printHeader'conformal metric perturbation:'
local epsilonBar_def = epsilonBar'_ij':eq(gammaBar'_ij' - gammaHat'_ij')
printbr(epsilonBar_def)
printbr()

printHeader'conformal metric perturbation spatial derivative:'
printbr(epsilonBar_def'_,k'())
printbr()

printHeader'conformal metric perturbation evolution:'
local dt_epsilonBar_ll_def = epsilonBar_def'_,t'()
printbr(dt_epsilonBar_ll_def)
printbr('assuming', dt_gammaHat_ll_def)
dt_epsilonBar_ll_def = dt_epsilonBar_ll_def:subst(dt_gammaHat_ll_def)()
printbr(dt_epsilonBar_ll_def)
printbr()
dt_epsilonBar_ll_def = dt_epsilonBar_ll_def:subst(dt_gammaBar_ll_def)
-- no need to print it again


printHeader'grid vs conformal connection difference:'
local DeltaBar_ull_def = DeltaBar'^i_jk':eq(GammaBar'^i_jk' - GammaHat'^i_jk')
printbr(DeltaBar_ull_def)
local DeltaBar_u_def = DeltaBar'^i':eq(DeltaBar'^i_jk' * gammaBar'^jk')
printbr(DeltaBar_u_def)

local calC = var'\\mathcal{C}'
printbr(calC'^i', '= arbitrary constant')
local LambdaBar_u_def = LambdaBar'^i':eq(DeltaBar'^i' + calC'^i')
printbr(LambdaBar_u_def)
local DeltaBar_u_from_LambdaBar_u = LambdaBar_u_def:solve(DeltaBar'^i')
printbr(DeltaBar_u_from_LambdaBar_u)
printbr()



printHeader'conformal connection evolution:'
local dt_connBar_ull_def = connBar_ull_def'_,t'()
printbr(dt_connBar_ull_def)
dt_connBar_ull_def = dt_connBar_ull_def
	--:substIndex(dt_gamma_uu_from_gamma_uu_partial_gamma_lll)
	--:subst(dt_gamma_uu_from_gamma_uu_partial_gamma_lll:reindex{jm='mn'})
	:substIndex(dt_gammaBar_uu_from_gammaBar_uu_partial_gammaBar_lll)()
printbr(dt_connBar_ull_def)
dt_connBar_ull_def = dt_connBar_ull_def
	:subst(dt_gammaBar_ll_def:reindex{ijkm='bapq'})
printbr(dt_connBar_ull_def)
dt_connBar_ull_def = simplifyBarMetrics(dt_connBar_ull_def)
printbr(dt_connBar_ull_def)
dt_connBar_ull_def = dt_connBar_ull_def
	:replace(gammaBar'_jk,mt', gammaBar'_jk,t''_,m')
	:replace(gammaBar'_mj,kt', gammaBar'_mj,t''_,k')
	:replace(gammaBar'_mk,jt', gammaBar'_mk,t''_,j')
	:subst(dt_gammaBar_ll_def:reindex{ijkm='jkpq'})
	:subst(dt_gammaBar_ll_def:reindex{ijkm='mjpq'})
	:subst(dt_gammaBar_ll_def:reindex{ijkm='mkpq'})
	:symmetrizeIndexes(gammaBar, {1,2})
dt_connBar_ull_def = simplifyBarMetrics(dt_connBar_ull_def)
printbr(dt_connBar_ull_def)
dt_connBar_ull_def = dt_connBar_ull_def:tidyIndexes()()
dt_connBar_ull_def = simplifyBarMetrics(dt_connBar_ull_def)
--dt_connBar_ull_def = dt_connBar_ull_def
--	:symmetrizeIndexes(beta, {2,3})	-- hmm, turned a b^d_,cd into a b^c_,dd ... that's not good
--	:symmetrizeIndexes(gammaBar, {3,4})
	:replace(beta'^d_,kc', beta'^d_,ck')
	:replace(beta'^d_,jc', beta'^d_,cj')
	:simplify()
printbr(dt_connBar_ull_def)
printbr()


printHeader'grid vs conformal connection difference evolution:'
local dt_LambdaBar_u_def = LambdaBar_u_def'_,t'()
	:replace(calC'^i_,t', 0)()
printbr(dt_LambdaBar_u_def)
dt_LambdaBar_u_def = dt_LambdaBar_u_def
	:splitOffDerivIndexes()
	:subst(DeltaBar_u_def)
	:simplify()
printbr(dt_LambdaBar_u_def)
dt_LambdaBar_u_def = dt_LambdaBar_u_def
	--:splitOffDerivIndexes()
	:subst(DeltaBar_ull_def'_,t'())
	:simplify()
printbr(dt_LambdaBar_u_def)
-- constant grid:
local dt_GammaHat_ull_def = GammaHat'^i_jk,t':eq(0)
printbr('assuming', dt_GammaHat_ull_def)
dt_LambdaBar_u_def = dt_LambdaBar_u_def
	:subst(dt_GammaHat_ull_def)
printbr(dt_LambdaBar_u_def)
dt_LambdaBar_u_def = dt_LambdaBar_u_def
	:subst(dt_gammaBar_uu_from_gammaBar_uu_partial_gammaBar_lll:reindex{ijm='jkn'})
	:subst(dt_gammaBar_uu_from_gammaBar_uu_partial_gammaBar_lll:reindex{ijm='imn'})
	:simplify()
printbr(dt_LambdaBar_u_def)
dt_LambdaBar_u_def = dt_LambdaBar_u_def
	:substIndex(dt_gammaBar_ll_def)
printbr(dt_LambdaBar_u_def)
dt_LambdaBar_u_def = dt_LambdaBar_u_def
	:simplify()
printbr(dt_LambdaBar_u_def)
dt_LambdaBar_u_def = dt_LambdaBar_u_def
	:replace(gammaBar'^lj' * gammaBar'_ln' * gammaBar'^nk' * DeltaBar'^i_jk', DeltaBar'^i')
	:replace(gammaBar'^lj' * gammaBar'^nk' * DeltaBar'^i_jk', DeltaBar'^iln')
	:replace(
		gammaBar'_cn' * beta'^c_,l' * DeltaBar'^iln', 
		gammaBar'_cl' * beta'^c_,n' * DeltaBar'^iln')
	:simplify()
printbr(dt_LambdaBar_u_def)
dt_LambdaBar_u_def = dt_LambdaBar_u_def
	--:substIndex(dt_connBar_ull_def)	-- can't do this unless you set 't' to a fixed index, which subst() can't do just yet
	:subst(dt_connBar_ull_def)
-- here we have gammaBar^jk delta^i_j beta^c_,c,k
printbr(dt_LambdaBar_u_def)
dt_LambdaBar_u_def = simplifyBarMetrics(dt_LambdaBar_u_def)
printbr(dt_LambdaBar_u_def)
dt_LambdaBar_u_def = dt_LambdaBar_u_def
	:replace(delta'^k_k', 3)
	:replace(ABar'^k_k', 0)
	:simplify()
	-- tidyIndexes starts at 'g', why, because all the previous sum indexes ended at 'f' maybe?
	-- so TODO allow tidyIndexes result sum indexes to take from the same pool as the input expression sum indexes, as long as they don't overlap any upon result
	:tidyIndexes()
	:symmetrizeIndexes(gammaBar, {1,2})
	:simplify()
	-- where did this come from?
	:replace(delta'_p^p', 3)
	:simplify()
	:replaceIndex(ABar'^ij', gammaBar'^im' * ABar'_mn' * gammaBar'^nj')
	:substIndex(DeltaBar_u_from_LambdaBar_u)
	:replaceIndex(DeltaBar'^i_j^k', gammaBar'^km' * DeltaBar'^i_jm')
	:replaceIndex(DeltaBar'^ij_k', gammaBar'^jm' * DeltaBar'^i_mk')
	:replaceIndex(DeltaBar'^ijk', DeltaBar'^i_mn' * gammaBar'^jm' * gammaBar'^kn')
	:substIndex(DeltaBar_ull_def)
	:substIndex(connBar_ull_def)
printbr(dt_LambdaBar_u_def)
dt_LambdaBar_u_def = dt_LambdaBar_u_def
	:substIndex(dt_gammaBar_uu_from_gammaBar_uu_partial_gammaBar_lll)
-- [[
	:symmetrizeIndexes(gammaBar, {1,2})
-- can't call 'simplifyBarMetrics' without it simplifying the ABar's ... so I'll just ask simplify ot only run on the gammaBar's 
--dt_LambdaBar_u_def = simplifyBarMetrics(dt_LambdaBar_u_def):replaceIndex(ABar'^ij', gammaBar'^im' * ABar'_mn' * gammaBar'^nj')
-- the alternative: make your own rule, simplify gammaBar metrics, only apply to other gammaBar metrics, and then simplify deltas
dt_LambdaBar_u_def = dt_LambdaBar_u_def:simplifyMetrics{
	{
		isMetric = function(g)
			return g[1] == gammaBar
		end,
		canSimplify = function(g, t, gi, ti)
			return t[1] == gammaBar
			and t[ti].lower ~= g[gi].lower
			and not t:hasDerivIndex()
		end,
	},
	Tensor.simplifyMetricsRules.delta,
}
--]]
printbr(dt_LambdaBar_u_def)
printbr()



printHeader'extrinsic curvature trace evolution:'
local dt_K_def = K_def'_,t'()
printbr(dt_K_def)
dt_K_def = dt_K_def:subst(dt_gamma_uu_from_gamma_uu_partial_gamma_lll)
printbr(dt_K_def)
dt_K_def = dt_K_def:substIndex(dt_gamma_ll_def)
	:replace(Gamma'^k_lm' * beta'_k', Gamma'_klm' * beta'^k')-- TODO make gamma_ij,t in terms of beta^k, not beta_k
printbr(dt_K_def)
dt_K_def = dt_K_def:replaceIndex(beta'_i,j', (gamma'_ik' * beta'^k')'_,j')
printbr(dt_K_def)
dt_K_def = dt_K_def()	
printbr(dt_K_def)
dt_K_def = dt_K_def:substIndex(K_ll_from_ABar_ll_gammaBar_ll_K, gamma_uu_from_gammaBar_uu_W, gamma_ll_from_gammaBar_ll_W)
printbr(dt_K_def)
dt_K_def = dt_K_def()
printbr(dt_K_def)
dt_K_def = simplifyBarMetrics(dt_K_def)
printbr(dt_K_def)
dt_K_def = dt_K_def
	--:replaceIndex(ABar'_i^i', 0)
	:replace(ABar'_i^i', 0)
	:replace(ABar'_j^j', 0)
	--:replaceIndex(delta'_j^j', 3)
	:replace(delta'_j^j', 3)
	:simplify()
	--:tidyIndexes()	--{fixed='t'}	-- the fact that K_,t has a t in it, and most expressions don't, breaks the tidyIndexes() function
	--:simplify()
	:symmetrizeIndexes(gammaBar, {1,2})
	:simplify()
printbr(dt_K_def)
dt_K_def = dt_K_def:substIndex(dt_K_ll_def)()
printbr(dt_K_def)
dt_K_def = dt_K_def
	:replaceIndex(K'^k_j', gamma'^kl' * K'_lj')
	:substIndex(K_ll_from_ABar_ll_gammaBar_ll_K, gamma_uu_from_gammaBar_uu_W, gamma_ll_from_gammaBar_ll_W)
printbr(dt_K_def)
dt_K_def = simplifyBarMetrics(dt_K_def)
printbr(dt_K_def)
dt_K_def = dt_K_def
	:replace(delta'^j_j', 3)
	:replace(delta'_j^j', 3)
	:replace(ABar'^j_j', 0)
	:simplify()
	:symmetrizeIndexes(gammaBar, {1,2})
	--:symmetrizeIndexes(ABar, {1,2})
	:simplify()
printbr(dt_K_def)
-- now that there's no more _,t terms, I can use tidyIndexes on the RHS only
dt_K_def[2] = dt_K_def[2]:tidyIndexes()()
printbr(dt_K_def)
dt_K_def = dt_K_def
	:replace(K'_cd,b', K'_cd''_,b')
	:substIndex(K_ll_from_ABar_ll_gammaBar_ll_K)
	:simplify()
dt_K_def = simplifyBarMetrics(dt_K_def)
	:replace(delta'_d^d', 3)
	:replace(ABar'^d_d', 0)
dt_K_def = betterSimplify(dt_K_def)
printbr(dt_K_def)
dt_K_def = dt_K_def
	:substIndex(conn_lll_def, conn_ull_def, gamma_uu_from_gammaBar_uu_W, gamma_ll_from_gammaBar_ll_W)
	:simplify()
	:symmetrizeIndexes(gammaBar, {1,2})
	--:symmetrizeIndexes(ABar, {1,2})
	:simplify()
dt_K_def = betterSimplify(dt_K_def)
printbr(dt_K_def)
dt_K_def = dt_K_def:substIndex(partial_gamma_lll_from_partial_gammaBar_lll_W)
dt_K_def = betterSimplify(dt_K_def)
printbr(dt_K_def)
dt_K_def = betterSimplify(dt_K_def)
dt_K_def = simplifyBarMetrics(dt_K_def)
	:replace(delta'^d_d', 3)
	:replace(delta'_d^d', 3)
	:replace(ABar'_d^d', 0)
	:replace(gammaBar'^cd' * gammaBar'_ad,c', gammaBar'^cd' * gammaBar'_ac,d')
	--:replace(ABar'^cd' * gammaBar'_cb,d', ABar'^cd' * gammaBar'_bc,d')
	--:replace(A
	:symmetrizeIndexes(gammaBar, {1,2})
	--:symmetrizeIndexes(ABar, {1,2})
dt_K_def = betterSimplify(dt_K_def)
dt_K_def = dt_K_def:tidyIndexes()
	:symmetrizeIndexes(gammaBar, {1,2})
	--:symmetrizeIndexes(ABar, {1,2})
	:replace(ABar'^f_e', ABar'_e^f')
	:replace(ABar'^fe', ABar'^ef')
dt_K_def = betterSimplify(dt_K_def)
printbr(dt_K_def)


printHeader'trace-free extrinsic curvature evolution:'
local dt_A_ll_def = A_ll_def'_,t'()
printbr(dt_A_ll_def)
printbr()


printHeader'conformal trace-free extrinsic curvature evolution:'
local dt_ABar_ll_def = ABar_ll_def'_,t'()
printbr(dt_ABar_ll_def)
dt_ABar_ll_def = dt_ABar_ll_def:substIndex(dt_W_def)
printbr(dt_ABar_ll_def)
dt_ABar_ll_def = dt_ABar_ll_def:subst(dt_A_ll_def)
printbr(dt_ABar_ll_def)
dt_ABar_ll_def = dt_ABar_ll_def:subst(dt_K_ll_def)
printbr(dt_ABar_ll_def)
dt_ABar_ll_def = dt_ABar_ll_def:subst(dt_gamma_ll_def)
	:replaceIndex(beta'_i,j', (beta'^k' * gamma'_ki')'_,j')
printbr(dt_ABar_ll_def)
dt_ABar_ll_def = dt_ABar_ll_def:subst(dt_K_def:reindex{ij='mn'})
printbr(dt_ABar_ll_def)
dt_ABar_ll_def = betterSimplify(dt_ABar_ll_def)
printbr(dt_ABar_ll_def)
dt_ABar_ll_def = dt_ABar_ll_def
	:replace(beta'_k' * Gamma'^k_ij', beta'^k' * Gamma'_kij')
	:substIndex(conn_lll_def)
	:substIndex(conn_ull_def)
	:replaceIndex(K'^k_j', gamma'^kl' * K'_lj')
	:replace(K'_ij,k', K'_ij''_,k')
	:substIndex(K_ll_from_A_ll_K)
	:substIndex(A_ll_from_ABar_ll)
	:substIndex(gamma_ll_from_gammaBar_ll_W)
	:substIndex(gamma_uu_from_gammaBar_uu_W)
	:substIndex(partial_gamma_lll_from_partial_gammaBar_lll_W)
printbr(dt_ABar_ll_def)
dt_ABar_ll_def = simplifyBarMetrics(dt_ABar_ll_def)
	:tidyIndexes()
dt_ABar_ll_def = betterSimplify(dt_ABar_ll_def)
	:replaceIndex(ABar'_i^j', ABar'_ik' * gammaBar'^kj')
	:replaceIndex(ABar'^ij', gammaBar'^im' * ABar'_mn' * gammaBar'^nj')
printbr(dt_ABar_ll_def)


printbr'<hr>'
--]]
printHeader'collecting partial derivatives:'

printbr(dt_alpha_def)
printbr(dt_beta_u_def)
printbr(dt_B_u_def)
printbr(dt_W_def)
printbr(dt_K_def)
printbr(dt_epsilonBar_ll_def)
printbr(dt_ABar_ll_def)
printbr(dt_LambdaBar_u_def)


-- now save them, and write them out for specific coordinate systems
file['BSSN - index - cache.lua'] = table{
	[[
local env = setmetatable({}, {__index=_G})
require 'ext.env'(env)
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env}
]],
	'dt_alpha_def = '..export.SymMath(dt_alpha_def),
	'dt_beta_u_def = '..export.SymMath(dt_beta_u_def),
	'dt_B_u_def = '..export.SymMath(dt_B_u_def),
	'dt_W_def = '..export.SymMath(dt_W_def),
	'dt_epsilonBar_ll_def = '..export.SymMath(dt_epsilonBar_ll_def),
	'dt_K_def = '..export.SymMath(dt_K_def),
	'dt_ABar_ll_def = '..export.SymMath(dt_ABar_ll_def),
	'dt_LambdaBar_u_def = '..export.SymMath(dt_LambdaBar_u_def),
	[[
return 
	dt_alpha_def,
	dt_beta_u_def,
	dt_W_def,
	dt_K_def,
	dt_epsilonBar_ll_def,
	dt_ABar_ll_def,
	dt_LambdaBar_u_def,
	dt_B_u_def
]]
}:concat'\n\n\n'..'\n'


--[[
printbr()

printbr'<hr>'

-- final results, since I'm too lazy to derive them
-- TODO copy these expressions over to bssnok-fd-sym and evaluate them for each grid.  no more intermediate simplifications required.
printHeader'using locally-Minkowski-normalized  non-coordinate components:'

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
--]]


-- DONE
printHeader()
io.stderr:write('TOTAL: '..(timer() - startTime)..'\n')
io.stderr:flush()
print(MathJax.footer)
