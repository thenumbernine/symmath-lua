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
useful identity: ... 0.126633s
useful identity: ... 0.061306s
ADM metric evolution: ... 0.067632s
Bona-Masso lapse and shift evolution: ... 0.001311s
conformal $\phi$: ... 0.00032599999999999s
conformal $\chi$: ... 0.00021899999999997s
conformal W: ... 0.001671s
conformal metric: ... 0.001867s
conformal metric inverse: ... 0.002299s
conformal metric derivative: ... 0.04122s
conformal metric determinant: ... 0.00084800000000002s
conformal metric constraint: ... 0.00025399999999998s
static grid assumption: ... 0.00017300000000003s
conformal connection: ... 0.457651s
extrinsic curvature trace: ... 0.00011799999999995s
trace-free extrinsic curvature: ... 0.01345s
conformal trace-free extrinsic curvature: ... 0.04241s
trace-free extrinsic curvature derivative: ... 0.02202s
conformal W evolution: ... 0.645108s
conformal metric evolution: ... 0.676557s
conformal metric perturbation: ... 0.000251s
conformal metric perturbation spatial derivative: ... 0.0037090000000002s
conformal metric perturbation evolution: ... 0.0095679999999998s
grid vs conformal connection difference: ... 0.0020720000000001s
conformal connection evolution: ... 18.457025s
grid vs conformal connection difference evolution: ... 11.12785s
extrinsic curvature trace evolution: ... 17.178297s
trace-free extrinsic curvature evolution: ... 0.036847999999999s
conformal trace-free extrinsic curvature evolution: ... 18.900488s
collecting partial derivatives: ... 0.020855000000012s
TOTAL: 67.900628
--]]


local spatialDim = 3

local timer = os.clock
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



-- [=[
--[[
expr = expression to replace TensorRef's of
t = TensorRef
metric (optional) = metric to use

For this particular TensorRef (of a variable and indexes),
looks for all the TensorRefs of matching variable with matching # of indexes
(and no derivatives for that matter ... unless they are covariant derivatives, or the last index only is changed?),
and insert enough metric terms to raise/lower these so that they will match the 't' argument.
--]]
local function insertMetricsToSetVariance(expr, t, metric)
	assert(TensorRef.is(t))
	--assert(Variable.is(t[1]))
	assert(not t:hasDerivIndex())	-- TODO handle derivs later?
	local n = #t

	local mul = require 'symmath.op.mul'

	local function fixTensorRef(x)
		if TensorRef.is(x)
		and t[1] == x[1]
		and n == #x
		and not x:hasDerivIndex()
		then
			local replx = x:clone()
			local gs = table()
			for i=2,n do
				if not not t[i].lower ~= not not x[i].lower then
					-- find a new symbol
					local g = TensorRef(
						metric,
						replx[i]:clone(),
						TensorIndex{
							lower = replx[i].lower,
							symbol = sumSymbol,
						}
					)
					replx:insert(g)
					replx[i].lower = t[i].lower
					replx[i].symbol = sumSymbol
				end
			end
			return replx, gs:unpack()
		end
	end

	return expr:map(function(x)
		if mul.is(x) then
			local newMul = table()
			for i=1,#x do
				newMul[i] = fixTensorRef(x[i])
				needsRepl = needsRepl or newMul[i]
			end
			if needsRepl then
				return mul(newMul:unpack())
			end
		else
			local results = {fixTensorRef(x)}
			if #results == 0 then
				return
			elseif #results == 1 then
				return results[1]
			else
				return mul(table.unpack(results))
			end
		end
	end)
end
--]=]

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
		--return t[1] ~= require 'symmath.Tensor':deltaSymbol()
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
local partial_gamma_lll_from_conn_lll = (conn_lll_def + conn_lll_def:reindex{ijk='kji'}):symmetrizeIndexes(gamma,{1,2})():switch():reindex{jk='kj'}
printbr(partial_gamma_lll_from_conn_lll)
local partial_gammaBar_lll_from_connBar_lll = partial_gamma_lll_from_conn_lll
	:replace(gamma, gammaBar)
	:replace(Gamma, GammaBar)
printbr(partial_gammaBar_lll_from_connBar_lll)
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
local dt_gamma_ll_def = gamma'_ij,t':eq(-2 * alpha * K'_ij' + beta'_i,j' + beta'_j,i' - 2 * beta'^k' * Gamma'_kij')
printbr(dt_gamma_ll_def)
dt_gamma_ll_def = dt_gamma_ll_def:replaceIndex(beta'_i,j', (beta'^k' * gamma'_ki')'_,j')()
printbr(dt_gamma_ll_def)
dt_gamma_ll_def[2] = dt_gamma_ll_def[2]:substIndex(partial_gamma_lll_from_conn_lll)()
printbr(dt_gamma_ll_def)
dt_gamma_ll_def = dt_gamma_ll_def:symmetrizeIndexes(Gamma, {2,3})()
printbr(dt_gamma_ll_def)
printbr()

local dt_K_ll_def = K'_ij,t':eq(
--	-alpha'_;ij' 
	- alpha'_,ij' + Gamma'^k_ij' * alpha'_,k'

	+ alpha * (
		R'_ij' 
		+ K * K'_ij'
		- 2 * K'_ik' * gamma'^kl' * K'_lj'
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
local W_from_phi = W:eq(exp(-2 * phi))()
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
conn_lll_from_connBar_lll_W_gamma_ll = betterSimplify(conn_lll_from_connBar_lll_W_gamma_ll )
printbr(conn_lll_from_connBar_lll_W_gamma_ll)

local conn_lll_from_connBar_lll_W_gammaBar_ll = conn_lll_from_connBar_lll_W_gamma_ll:substIndex(gamma_ll_from_gammaBar_ll_W, gamma_uu_from_gammaBar_uu_W)
conn_lll_from_connBar_lll_W_gammaBar_ll = betterSimplify(conn_lll_from_connBar_lll_W_gammaBar_ll)
printbr(conn_lll_from_connBar_lll_W_gammaBar_ll)

local connBar_ull_def = simplifyBarMetrics(gammaBar'^im' * connBar_lll_def:reindex{i='m'})
printbr(connBar_ull_def)

local connBar_ull_from_conn_ull_W_gamma_ll = connBar_ull_def
	:substIndex(gammaBar_uu_from_gamma_uu_W)
	:substIndex(partial_gammaBar_lll_from_partial_gamma_lll_W)
	:subst(conn_lll_def:solve(gamma'_ij,k'):reindex{ijk='mjk'})
	:factorDivision()
	:simplifyMetrics()
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

local A_ll_from_ABar_ll = betterSimplify(ABar_ll_def:solve(A'_ij'))
printbr(A_ll_from_ABar_ll)

local ABar_uu_from_A_uu = (gammaBar'^mi' * ABar_ll_def * gammaBar'^jn')()
printbr(ABar_uu_from_A_uu)

ABar_uu_from_A_uu[1] = simplifyBarMetrics(ABar_uu_from_A_uu[1])
ABar_uu_from_A_uu = ABar_uu_from_A_uu:substIndex(gammaBar_uu_from_gamma_uu_W)
ABar_uu_from_A_uu = betterSimplify(ABar_uu_from_A_uu)
printbr(ABar_uu_from_A_uu)

ABar_uu_from_A_uu = ABar_uu_from_A_uu:simplifyMetrics()():reindex{mn='ij'}
printbr(ABar_uu_from_A_uu)

local A_uu_from_ABar_uu = ABar_uu_from_A_uu:solve(A'^ij')
printbr(A_uu_from_ABar_uu)

local K_ll_from_ABar_ll_gammaBar_ll_K = K_ll_from_A_ll_K:subst(A_ll_from_ABar_ll, gamma_ll_from_gammaBar_ll_W)
K_ll_from_ABar_ll_gammaBar_ll_K = betterSimplify(K_ll_from_ABar_ll_gammaBar_ll_K)
printbr(K_ll_from_ABar_ll_gammaBar_ll_K)
printbr()


printHeader'trace-free extrinsic curvature derivative:'
local partial_K_lll_from_partial_A_lll_K = K_ll_from_A_ll_K'_,k'()
printbr(partial_K_lll_from_partial_A_lll_K)
printbr()


printHeader'jacobi identity:'
local tr_connBar_l_from_det_gammaBar = GammaBar'^j_ji':eq(frac(1,2) * gammaBar'_,i' / gammaBar)
printbr(tr_connBar_l_from_det_gammaBar)
printbr()


printHeader'conformal W evolution:'

local dt_W_def = W_def'_,t'()
printbr(dt_W_def)

printbr('assuming', dt_det_gammaHat_def)
dt_W_def = dt_W_def:subst(dt_det_gammaHat_def)()
printbr(dt_W_def)

dt_W_def[2] = (dt_W_def[2] * W_def[1] / W_def[2])() 
printbr(dt_W_def)

local using = gamma'_,t':eq(gamma * gamma'^ij' * gamma'_ij,t')
printbr('using', using) 

dt_W_def = dt_W_def:subst(using)()
printbr(dt_W_def)

dt_W_def = dt_W_def:subst(dt_gamma_ll_def)():factorDivision()
printbr(dt_W_def)

dt_W_def = dt_W_def:replace(gamma'^ij' * K'_ij', K)()
printbr(dt_W_def)

dt_W_def = dt_W_def:substIndex(conn_lll_from_connBar_lll_W_gammaBar_ll, gamma_ll_from_gammaBar_ll_W, gamma_uu_from_gammaBar_uu_W)()
printbr(dt_W_def)

dt_W_def = simplifyBarMetrics(dt_W_def)
	:symmetrizeIndexes(GammaBar, {2,3})
	:symmetrizeIndexes(delta, {1,2})
	:tidyIndexes()
	:replace(GammaBar'_b^b_a', 	GammaBar'^b_ba')	-- hmm, how to auto-simplify this ...
	:replace(delta'^b_b', spatialDim)
	:simplify()
	:reindex{ab='ij'}
printbr(dt_W_def)

-- why won't substindex work?
-- doesn't seem to work when there's a sum-index on the lhs
-- TODO test case plz
--dt_W_def = dt_W_def:substIndet(tr_connBar_l_from_det_gammaBar)
dt_W_def = dt_W_def:substIndex(tr_connBar_l_from_det_gammaBar:reindex{j='k'})
--dt_W_def = betterSimplify(dt_W_def:subst(tr_connBar_l_from_det_gammaBar))
printbr(dt_W_def)
printbr()

os.exit()


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
local dt_gammaBar_ll_def = gammaBar_ll_from_gamma_ll_W'_,t'
printbr(dt_gammaBar_ll_def)
dt_gammaBar_ll_def = dt_gammaBar_ll_def()
printbr(dt_gammaBar_ll_def)
dt_gammaBar_ll_def = dt_gammaBar_ll_def:subst(dt_gamma_ll_def)()
printbr(dt_gammaBar_ll_def)
dt_gammaBar_ll_def = dt_gammaBar_ll_def:substIndex(dt_W_def, gamma_ll_from_gammaBar_ll_W, conn_lll_from_connBar_lll_W_gammaBar_ll, K_ll_from_ABar_ll_gammaBar_ll_K)
printbr(dt_gammaBar_ll_def)
dt_gammaBar_ll_def = dt_gammaBar_ll_def
	:tidyIndexes()	-- TODO seems like tidyIndexes() doesn't ue source sum indexes as dest sum indexes ...
	:symmetrizeIndexes(gammaBar, {1,2})
-- this still has errors.  beta^c Gamma^d_dc => beta^c Gamma_c^d_d
--	:symmetrizeIndexes(GammaBar, {2,3})
	:simplify()
	:reindex{cd='kl'}
dt_gammaBar_ll_def = betterSimplify(dt_gammaBar_ll_def)
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
local dt_connBar_ull_def = connBar_ull_def'_,t'
printbr(dt_connBar_ull_def)
dt_connBar_ull_def = dt_connBar_ull_def()
printbr(dt_connBar_ull_def)
dt_connBar_ull_def = dt_connBar_ull_def:subst( connBar_lll_def:solve(gammaBar'_ij,k'):reindex{i='m'} )()
printbr(dt_connBar_ull_def)
dt_connBar_ull_def = dt_connBar_ull_def:substIndex(dt_gammaBar_uu_from_gammaBar_uu_partial_gammaBar_lll)()
-- hmm, not working?
dt_connBar_ull_def = dt_connBar_ull_def:replaceIndex(gammaBar'^im' * GammaBar'_mjk', GammaBar'^i_jk')()
printbr(dt_connBar_ull_def)
--dt_connBar_ull_def = dt_connBar_ull_def:subst(dt_gammaBar_ll_def:reindex{ijkm='bapq'})
dt_connBar_ull_def = dt_connBar_ull_def:substIndex(dt_gammaBar_ll_def)
printbr(dt_connBar_ull_def)
dt_connBar_ull_def = simplifyBarMetrics(dt_connBar_ull_def)
printbr(dt_connBar_ull_def)
--dt_connBar_ull_def = dt_connBar_ull_def:tidyIndexes{fixed='t'} 	-- can't do this yet.  the later add complains that it is combining T_ijk and T_ijkt's, which is true.  i guess it is more proper wrt current system to substitute-away all the _,t's first.
printbr(dt_connBar_ull_def)
dt_connBar_ull_def = dt_connBar_ull_def
	:replaceIndex(gammaBar'_jk,mt', gammaBar'_jk,t''_,m')
	:substIndex(dt_gammaBar_ll_def:reindex{ijkm='jkpq'})		-- hmm, would be nice if substIndex correctly renamed sum terms to not collide with its insertions.
	:substIndex(partial_gammaBar_lll_from_connBar_lll)
printbr(dt_connBar_ull_def)
dt_connBar_ull_def = dt_connBar_ull_def()		-- simplify to distribute derivative
	:substIndex(partial_gammaBar_lll_from_connBar_lll)()	-- and make this substitution again
	--:tidyIndexes()()
printbr(dt_connBar_ull_def)
dt_connBar_ull_def = simplifyBarMetrics(dt_connBar_ull_def)
	:symmetrizeIndexes(gammaBar, {1,2})
	:tidyIndexes()()
	:symmetrizeIndexes(gammaBar, {1,2})
	:symmetrizeIndexes(ABar, {1,2})
	:symmetrizeIndexes(delta, {1,2})
-- TODO how about adding index symmetry rule to tensors (and of course by default for derivatives), then any time a function inserts a tensor - like simplifyMetrics(), have it auto-sort the indexes?  
-- but this is problematic with the mul symmetrizeIndexes rules, where symmetrizing a tensor that is * another tensor does symmetrize the other tensor too
-- a better way is just simplifying by comparing graphs of tensors.
	:simplify()			
printbr(dt_connBar_ull_def)
-- convert all connBar^i_jk,l's to connBar_ijk,l's
dt_connBar_ull_def[2] = dt_connBar_ull_def[2]
	:replaceIndex(GammaBar'^i_jk,l', (gammaBar'^im' * GammaBar'_mjk')'_,l')()
	:substIndex(dt_gammaBar_uu_from_gammaBar_uu_partial_gammaBar_lll)()
	:substIndex(partial_gammaBar_lll_from_connBar_lll)()
printbr(dt_connBar_ull_def)
dt_connBar_ull_def = dt_connBar_ull_def
	--:replaceIndex(GammaBar'_ijk,l', GammaBar'_ijk'',l')
	:substIndex(connBar_lll_def'_,l'())()
dt_connBar_ull_def = simplifyBarMetrics(dt_connBar_ull_def)	
	:tidyIndexes()()
	:symmetrizeIndexes(gammaBar, {1,2})()
	:symmetrizeIndexes(gammaBar, {3,4})()
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
	:subst(DeltaBar_ull_def'_,t'())
	:simplify()
printbr(dt_LambdaBar_u_def)
-- constant grid:
local dt_GammaHat_ull_def = GammaHat'^i_jk,t':eq(0)
printbr('assuming', dt_GammaHat_ull_def)
dt_LambdaBar_u_def = dt_LambdaBar_u_def:subst(dt_GammaHat_ull_def)
printbr(dt_LambdaBar_u_def)
dt_LambdaBar_u_def = dt_LambdaBar_u_def
	:subst(dt_gammaBar_uu_from_gammaBar_uu_partial_gammaBar_lll:reindex{ijm='jkn'})
	:subst(dt_gammaBar_uu_from_gammaBar_uu_partial_gammaBar_lll:reindex{ijm='imn'})
	:simplify()
printbr(dt_LambdaBar_u_def)
dt_LambdaBar_u_def = dt_LambdaBar_u_def:substIndex(dt_gammaBar_ll_def)
printbr(dt_LambdaBar_u_def)
dt_LambdaBar_u_def = dt_LambdaBar_u_def()
printbr(dt_LambdaBar_u_def)
dt_LambdaBar_u_def = simplifyBarMetrics(dt_LambdaBar_u_def)
printbr(dt_LambdaBar_u_def)
dt_LambdaBar_u_def = dt_LambdaBar_u_def:symmetrizeIndexes(DeltaBar, {2,3})()
printbr(dt_LambdaBar_u_def)
dt_LambdaBar_u_def = dt_LambdaBar_u_def:subst(dt_connBar_ull_def)
printbr(dt_LambdaBar_u_def)
-- here we have gammaBar^jk delta^i_j beta^c_,c,k
dt_LambdaBar_u_def = simplifyBarMetrics(dt_LambdaBar_u_def())
printbr(dt_LambdaBar_u_def)
	-- once again, tidyIndexes is going wrong.  turns gammaBar^jk beta^a_,a GammaBar^i_jk => beta^d_,d GammaBar^id_d
dt_LambdaBar_u_def = dt_LambdaBar_u_def:tidyIndexes()
printbr(dt_LambdaBar_u_def)
dt_LambdaBar_u_def = simplifyBarMetrics(dt_LambdaBar_u_def())
	:symmetrizeIndexes(beta, {2,3})()	-- derivatives
	:replace(GammaBar'_f^f_e', GammaBar'^f_fe')()
	:symmetrizeIndexes(GammaBar, {2,3})()
	:symmetrizeIndexes(DeltaBar, {2,3})()
	:symmetrizeIndexes(gammaBar, {1,2})()
printbr(dt_LambdaBar_u_def)
-- now put the ABar's in lower-lower form so they can be treated as a state variable
dt_LambdaBar_u_def = dt_LambdaBar_u_def
	:replaceIndex(ABar'^ij', gammaBar'^ik' * ABar'_kl' * gammaBar'^lj')
	:replaceIndex(ABar'_i^j', ABar'_ik' * gammaBar'^kj')
dt_LambdaBar_u_def = betterSimplify(dt_LambdaBar_u_def)
printbr(dt_LambdaBar_u_def)
dt_LambdaBar_u_def = dt_LambdaBar_u_def:replaceIndex(DeltaBar'^ij_j', DeltaBar'^i')
dt_LambdaBar_u_def = dt_LambdaBar_u_def:replaceIndex(GammaBar'^ij_j', GammaBar'^i')
dt_LambdaBar_u_def = insertMetricsToSetVariance(dt_LambdaBar_u_def, GammaBar'_abc', gammaBar)
dt_LambdaBar_u_def = insertMetricsToSetVariance(dt_LambdaBar_u_def, GammaBar'^a', gammaBar)
dt_LambdaBar_u_def = insertMetricsToSetVariance(dt_LambdaBar_u_def, DeltaBar'_abc', gammaBar)
dt_LambdaBar_u_def = insertMetricsToSetVariance(dt_LambdaBar_u_def, DeltaBar'^a', gammaBar)
dt_LambdaBar_u_def = betterSimplify(dt_LambdaBar_u_def)
printbr(dt_LambdaBar_u_def)

dt_LambdaBar_u_def = dt_LambdaBar_u_def:tidyIndexes()
dt_LambdaBar_u_def = betterSimplify(dt_LambdaBar_u_def)

dt_LambdaBar_u_def = dt_LambdaBar_u_def:replace(DeltaBar'_abc', GammaBar'_abc' - GammaHat'_abc')
dt_LambdaBar_u_def = dt_LambdaBar_u_def:replaceIndex(DeltaBar'^i', LambdaBar'^i' - calC'^i')
dt_LambdaBar_u_def = dt_LambdaBar_u_def:replaceIndex(GammaBar'^a', LambdaBar'^a' - calC'^a' + GammaHat'^a')
dt_LambdaBar_u_def = dt_LambdaBar_u_def:symmetrizeIndexes(GammaBar, {2,3})
dt_LambdaBar_u_def = dt_LambdaBar_u_def:symmetrizeIndexes(DeltaBar, {2,3})
dt_LambdaBar_u_def = dt_LambdaBar_u_def:replaceIndex(GammaBar'^b_ab', frac(1,2) * gammaBar'_,a' / gammaBar)
printbr(dt_LambdaBar_u_def)
printbr()
os.exit()


printHeader'extrinsic curvature trace evolution:'
local dt_K_def = K_def'_,t'()
printbr(dt_K_def)
dt_K_def = dt_K_def:subst(dt_gamma_uu_from_gamma_uu_partial_gamma_lll)
printbr(dt_K_def)
dt_K_def = dt_K_def:substIndex(dt_gamma_ll_def)
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
	--:replaceIndex(delta'_j^j', spatialDim)
	:replace(delta'_j^j', spatialDim)
	:simplify()
	--:tidyIndexes()	--{fixed='t'}	-- the fact that K_,t has a t in it, and most expressions don't, breaks the tidyIndexes() function
	--:simplify()
	:symmetrizeIndexes(gammaBar, {1,2})
	:simplify()
printbr(dt_K_def)
dt_K_def = dt_K_def:substIndex(dt_K_ll_def)()
printbr(dt_K_def)
dt_K_def = dt_K_def:substIndex(K_ll_from_ABar_ll_gammaBar_ll_K, gamma_uu_from_gammaBar_uu_W, gamma_ll_from_gammaBar_ll_W)
printbr(dt_K_def)
dt_K_def = simplifyBarMetrics(dt_K_def)
printbr(dt_K_def)
dt_K_def = dt_K_def
	:symmetrizeIndexes(delta, {1,2})
	:replace(delta'^j_j', spatialDim)
	:symmetrizeIndexes(ABar, {1,2})
	:replace(ABar'^j_j', 0)
	:simplify()
	:symmetrizeIndexes(gammaBar, {1,2})
	:simplify()
printbr(dt_K_def)
-- now that there's no more _,t terms, I can use tidyIndexes on the RHS only
dt_K_def[2] = dt_K_def[2]:tidyIndexes()()
printbr(dt_K_def)
dt_K_def = dt_K_def
	:replace(K'_bc,a', K'_bc''_,a')
	:substIndex(K_ll_from_ABar_ll_gammaBar_ll_K)
	:simplify()
dt_K_def = simplifyBarMetrics(dt_K_def)()
dt_K_def = betterSimplify(dt_K_def)
printbr(dt_K_def)
dt_K_def = dt_K_def
	:substIndex(conn_lll_def, conn_ull_def, gamma_uu_from_gammaBar_uu_W, gamma_ll_from_gammaBar_ll_W)
	:simplify()
	:symmetrizeIndexes(gammaBar, {1,2})
	:symmetrizeIndexes(delta, {1,2})
	:replace(delta'^e_e', spatialDim)
	:symmetrizeIndexes(ABar, {1,2})
	:replace(ABar'^e_e', 0)
	:simplify()
dt_K_def = betterSimplify(dt_K_def)
printbr(dt_K_def)
dt_K_def = simplifyBarMetrics(dt_K_def):simplify()
	:symmetrizeIndexes(ABar, {1,2})
	:replace(ABar'^c_c', 0)
dt_K_def = betterSimplify(dt_K_def)
printbr(dt_K_def)
dt_K_def = dt_K_def:substIndex(partial_gamma_lll_from_partial_gammaBar_lll_W, partial_gammaBar_lll_from_connBar_lll)
dt_K_def = betterSimplify(dt_K_def)
printbr(dt_K_def)
dt_K_def = betterSimplify(dt_K_def)
dt_K_def = simplifyBarMetrics(dt_K_def):symmetrizeIndexes(gammaBar, {1,2})
printbr(dt_K_def)
dt_K_def = dt_K_def:tidyIndexes()
	:symmetrizeIndexes(delta, {1,2})
	:replace(delta'^b_b', spatialDim)
	:replace(delta'^c_c', spatialDim)
	:symmetrizeIndexes(ABar, {1,2})
	:replace(ABar'^a_a', 0)
	:replace(ABar'^b_b', 0)
	:replace(GammaBar'_ba^b', GammaBar'^b_ab')
	:replace(GammaBar'_b^ab', GammaBar'^ba_b')
	:symmetrizeIndexes(GammaBar, {2,3})
	:symmetrizeIndexes(gammaBar, {1,2})
	:replace(S'_ab' * gammaBar'^ab', S / W^2)
	:replaceIndex(ABar'^bc', gammaBar'^bd' * ABar'_de' * gammaBar'^ec')
dt_K_def = betterSimplify(dt_K_def)
printbr(dt_K_def)
printbr()


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
dt_ABar_ll_def = dt_ABar_ll_def:subst(dt_K_def:reindex{ij='mn'})
printbr(dt_ABar_ll_def)
dt_ABar_ll_def = betterSimplify(dt_ABar_ll_def)
printbr(dt_ABar_ll_def)
dt_ABar_ll_def = dt_ABar_ll_def
	:subst(dt_gamma_ll_def)
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
	:substIndex(partial_gammaBar_lll_from_connBar_lll)
printbr(dt_ABar_ll_def)
dt_ABar_ll_def = simplifyBarMetrics(dt_ABar_ll_def)
	:substIndex(partial_gammaBar_lll_from_connBar_lll)
dt_ABar_ll_def = betterSimplify(dt_ABar_ll_def)
	:replaceIndex(ABar'_i^j', ABar'_ik' * gammaBar'^kj')
	:replaceIndex(ABar'^ij', gammaBar'^im' * ABar'_mn' * gammaBar'^nj')
	:symmetrizeIndexes(gammaBar, {1,2})
	:symmetrizeIndexes(GammaBar, {2,3})
dt_ABar_ll_def = dt_ABar_ll_def:tidyIndexes()
dt_ABar_ll_def = betterSimplify(dt_ABar_ll_def)
dt_ABar_ll_def = dt_ABar_ll_def:replace(GammaBar'^ab_b', GammaBar'^a')
dt_ABar_ll_def = betterSimplify(dt_ABar_ll_def)
dt_ABar_ll_def = dt_ABar_ll_def:replace(gammaBar'^db' * gammaBar'^ec' * GammaBar'_dae', GammaBar'^bc_a')
dt_ABar_ll_def = betterSimplify(dt_ABar_ll_def)
printbr(dt_ABar_ll_def)
printbr()


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
file['BSSN - index - using GammaBar - cache.lua'] = table{
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
