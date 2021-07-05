#!/usr/bin/env luajit
--[[
Z4 equations, in index notation
rewritten in terms of first order hyperbolic coordinates
and for a general metric (i.e. difference-of-connections) instead of strictly for cartesian.
same idea as my 'BSSN - index' worksheet (why not just call it 'BSSN' ?)

in fact this is a lot like my 'numerical-relativity-codegen'
but runs a lot faster ... maybe it should replace it?
and it produces the tensor linear systems that my "Documents/Math/Numerical Relativity" notes have, which is nice
--]]
local env = setmetatable({}, {__index=_G})
require 'ext.env'(env)
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env}
local MathJax = symmath.export.MathJax
symmath.tostring = MathJax 
local printbr = MathJax.print
MathJax.header.title = 'Z4, metric-invariant'
print(MathJax.header)


-- these were giving BSSN some trouble, so here they are as well.
symmath.op.div:pushRule'Prune/conjOfSqrtInDenom'
symmath.op.div:pushRule'Factor/polydiv'
symmath.op.pow.wildcardMatches = nil
symmath.matchMulUnknownSubstitution = false

--[[
connections: ... 0.039s
metric inverse partial: ... 0.022s
log lapse derivative: ... 0.252s
metric evolution: ... 0.04s
metric partial delta evolution: ... 2.581s
Gaussian curvature ... 1.593s
extrinsic curvature evolution: ... 0.877s
Z4 $\Theta$ definition ... 1.362s
Z4 $Z_k$ definition ... 0.192s
TOTAL: 6.967

This is quite a bit faster than the 'BSSN - index' worksheet
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


--[[
look for instances of the TensorRef 'find', with matching lower/deriv
insert deltas to give it symbols matching 'find'

this goes orders of magnitude faster if it processes multiple finds at once
TODO maybe it wouldn't if it didn't rebuild every time, but only upon finding a needed var?  nah, still have to query term indexes as many times
--]]
local function insertDeltasToSetIndexSymbols(expr, finds)
	for _,find in ipairs(finds) do
		assert(TensorRef:isa(find))
	end
	local delta = Tensor:deltaSymbol()

	-- TODO maybe I don't need this constraint
	-- if I just make use of 'getIndexesUsed()'
	-- which I should do for other reasons
	expr = expr:simplifyAddMulDiv()

	local newaddterms = table()
	for x in expr:iteradd() do
		local newmulterms = table()
		
		local mulFixed, mulSum, mulExtra = x:getIndexesUsed()

		-- how come this isn't producing mul terms?
		local reallyReindexTheMul = {}
		local verifyNoDuplicateRemapsInsideTheMul = {}
		for y in x:itermul() do
			if TensorRef:isa(y) then
				
				local indexRemap = {}
				local function addSymbol(ti, target)
					assert(TensorIndex:isa(ti))
					assert(not not ti.lower == not not target.lower)
					assert(ti.derivative == target.derivative)
					if ti.symbol ~= target.symbol then
						
						-- verifyNoDuplicateRemapsInsideTheMul to make sure if we insert deltas to change the index on the tensor, that this tensor isn't used elsewhere in the mul term
						-- what if it is used elsewhere?
						-- I should be just query indexes used up front.
						local prevSymbol = verifyNoDuplicateRemapsInsideTheMul[ti.symbol]
						if prevSymbol and prevSymbol ~= target.symbol then
							error("tried to remap mul to "..target.symbol.." from "..prevSymbol.." and then from "..ti.symbol)
						end
						verifyNoDuplicateRemapsInsideTheMul[ti.symbol] = target.symbol

						local prevSymbol = indexRemap[ti.symbol] and indexRemap[ti.symbol].symbol
						if prevSymbol then
							if prevSymbol ~= target.symbol then
								error("tried to remap to "..target.symbol.." from "..prevSymbol.." and then from "..ti.symbol)
							end
							assert(indexRemap[ti.symbol].deriv == target.derivative, "index changed derivative")
						end
						indexRemap[ti.symbol] = target:clone()
					end
				end
		
				for _,find in ipairs(finds) do
					if y[1] == find[1] 
					and #y == #find
					then	-- ignore non-index-matching form
						
						local matchingLowers = true
						for i=2,#y do
							if not not y[i].lower ~= not not find[i].lower 
							-- TODO check deriv match and bail on fail, don't assert it will match
							then
								matchingLowers = false
							end
						end
						-- TODO if not matchingLowres then insert metric symbols instead of delta symbols
						if matchingLowers then
							for i=2,#y do
								addSymbol(y[i], find[i])
							end
							break
						end
					end
				end
				
				if next(indexRemap) then
					--newTI.lower must match the old ti's lower
					for oldSym,newTI in pairs(indexRemap) do
						
						-- if it's a sum term then just relabel the sum term in the entire mul
						if mulSum:find(nil, function(t)
							return t.symbol == oldSym
						end) then
							reallyReindexTheMul[oldSym] = newTI.symbol
						else
							-- only insert deltas if it's not a sum term
							newmulterms:insert(
								TensorRef(
									delta,
									TensorIndex{
										lower = not newTI.lower,
										symbol = assert(newTI.symbol),
									},
									TensorIndex{
										lower = newTI.lower,
										symbol = assert(oldSym),
									}
								)
							)
						end
					end
					newmulterms:insert(y:reindex(table.map(indexRemap, function(v,k)
						return v.symbol, k
					end):setmetatable(nil)))
				else
					newmulterms:insert(y)
				end
			else
				newmulterms:insert(y)
			end
		end
		
		local newMul
		if #newmulterms == 1 then
			newMul = newmulterms[1]
		else
			newMul = newmulterms:setmetatable(symmath.op.mul)
		end
		if next(reallyReindexTheMul) then
			newMul = newMul:reindex(reallyReindexTheMul)
		end
		newaddterms:insert(newMul)
	end
	if #newaddterms == 1 then
		expr = newaddterms[1]
	else
		newaddterms:setmetatable(symmath.op.add)
		expr = newaddterms
	end
	return expr
end





local e = var'e'
local delta = Tensor:deltaSymbol()

local alpha = var'\\alpha'
local beta = var'\\beta'
local gamma = var'\\gamma'
local eta = var'\\eta'
local lambda = var'\\lambda'
local rho = var'\\rho'
local dHat = var'\\hat{d}'
local dDelta = var[[\overset{\Delta}{d}]]
local a = var'a'
local b = var'b'
local d = var'd'
local f = var'f'
local B = var'B'
local K = var'K'
local R = var'R'
local S = var'S'
local Z = var'Z'
local Gamma = var'\\Gamma'
local Theta = var'\\Theta'
local gammaHat = var'\\hat{\\gamma}'
local gammaDelta = var[[\overset{\Delta}{\gamma}]]
local GammaHat = var'\\hat{\\Gamma}'

-- for Expression:simplifyMetrics()
Tensor.metricVariable = gamma

--[[
ADM:
γ_ij,t =  ...
K_ij,t = ...

gauge:
α_,t = ...
β^i_,t = ...

hyperbolic first order variables:
a_i = ln(α)_,i
d_kij = 1/2 γ_ij,k

general coordinate:
d_kij = dHat_kij + Δd_kij
γ_kij = γHat_kij + Δγ_kij

Z4 GLM vars:
Z^i = γ^i_μ Z^μ
Θ = -Z^μ n_μ

hyperbolic γ driver shift:
b^i_j = β^i_,j
B^i = β^i_,t

so our state variables will be:
{α, Δγ_ij, a_k, Δd_kij, K_ij, Θ, Z_k, β^l, b^l_k, B^l}

--]]


printbr(gammaHat'_ij', ' = spatial background metric')
printbr(gammaDelta'_ij', ' = difference of spatial metric and spatial background metric')

local gamma_ll_from_gammaHat_ll_gammaDelta_ll = gamma'_ij':eq(gammaHat'_ij' + gammaDelta'_ij')
printbr(gamma_ll_from_gammaHat_ll_gammaDelta_ll, '= spatial metric')
printbr()


local dHat_lll_def = dHat'_kij':eq(frac(1,2) * gammaHat'_ij,k')
printbr(dHat_lll_def, '= spatial background metric derivative')

local d_gammaHat_lll_from_dHat_lll = dHat_lll_def:solve(gammaHat'_ij,k') 
printbr(d_gammaHat_lll_from_dHat_lll)
printbr()


local dDelta_lll_def = dDelta'_kij':eq(frac(1,2) * gammaDelta'_ij,k')
printbr(dDelta_lll_def, '= difference of spatial metric derivative and spatial background metric derivative, hyperbolic state variable')

local d_gammaDelta_lll_from_dDelta_lll = dDelta_lll_def:solve(gammaDelta'_ij,k')
printbr(d_gammaDelta_lll_from_dDelta_lll)
printbr()


local d_lll_def = d'_kij':eq(frac(1,2) * gamma'_ij,k')
printbr(d_lll_def, '= spatial metric derivative')

local d_gamma_lll_from_d_lll = d_lll_def:solve(gamma'_ij,k')
printbr(d_gamma_lll_from_d_lll)
printbr()

local d_gamma_lll_from_d_gammaHat_lll_d_gammaDelta_lll = gamma_ll_from_gammaHat_ll_gammaDelta_ll'_,k'()
printbr(d_gamma_lll_from_d_gammaHat_lll_d_gammaDelta_lll)

local d_gamma_lll_from_d_gammaHat_lll_dDelta_lll = clone(d_gamma_lll_from_d_gammaHat_lll_d_gammaDelta_lll)
	:subst(d_gammaDelta_lll_from_dDelta_lll)()
printbr(d_gamma_lll_from_d_gammaHat_lll_dDelta_lll)

local d_gamma_lll_from_dHat_lll_dDelta_lll = clone(d_gamma_lll_from_d_gammaHat_lll_dDelta_lll)
	:subst(d_gammaHat_lll_from_dHat_lll)()
printbr(d_gamma_lll_from_dHat_lll_dDelta_lll)

local d_lll_from_dHat_lll_dDelta_lll = d_gamma_lll_from_dHat_lll_dDelta_lll
	:subst(d_gamma_lll_from_d_lll)()
	:solve(d'_kij')
printbr(d_lll_from_dHat_lll_dDelta_lll)
printbr()


local b_ul_def = b'^i_j':eq(beta'^i_,j')
printbr(b_ul_def)
local d_beta_ul_from_b_ul = b_ul_def:solve(beta'^i_,j')
printbr(d_beta_ul_from_b_ul)
printbr()


printHeader'connections:'
local conn_lll_def = Gamma'_ijk':eq(frac(1,2) * (gamma'_ij,k' + gamma'_ik,j' - gamma'_jk,i'))
printbr(conn_lll_def)
local d_gamma_lll_from_conn_lll = (conn_lll_def + conn_lll_def:reindex{ijk='kji'}):symmetrizeIndexes(gamma,{1,2})():switch():reindex{jk='kj'}
printbr(d_gamma_lll_from_conn_lll)
printbr()

local conn_ull_def = (gamma'^im' * conn_lll_def:reindex{i='m'})():simplifyMetrics()()
printbr(conn_ull_def)

printbr('using', d_gamma_lll_from_dHat_lll_dDelta_lll)
conn_ull_def = conn_ull_def:substIndex(d_gamma_lll_from_dHat_lll_dDelta_lll)()
printbr(conn_ull_def)

printbr()


printHeader'metric inverse partial:'
local d_gamma_uul_from_gamma_uu_d_gamma_lll = (gamma'_li' * gamma'^ij')'_,k':eq(0)
printbr(d_gamma_uul_from_gamma_uu_d_gamma_lll)
d_gamma_uul_from_gamma_uu_d_gamma_lll = d_gamma_uul_from_gamma_uu_d_gamma_lll()
printbr(d_gamma_uul_from_gamma_uu_d_gamma_lll)
d_gamma_uul_from_gamma_uu_d_gamma_lll = (d_gamma_uul_from_gamma_uu_d_gamma_lll * gamma'^lm')():factorDivision()
printbr(d_gamma_uul_from_gamma_uu_d_gamma_lll)
d_gamma_uul_from_gamma_uu_d_gamma_lll = d_gamma_uul_from_gamma_uu_d_gamma_lll:simplifyMetrics()
	:reindex{im='mi'}
	:solve(gamma'^ij_,k')
printbr(d_gamma_uul_from_gamma_uu_d_gamma_lll)	-- not the prettiest way to show that ...

printbr('using', d_gamma_lll_from_dHat_lll_dDelta_lll)
local d_gamma_uul_from_dHat_lll_dDelta_lll = d_gamma_uul_from_gamma_uu_d_gamma_lll:substIndex(d_gamma_lll_from_dHat_lll_dDelta_lll)()
printbr(d_gamma_uul_from_dHat_lll_dDelta_lll)
printbr()


-- alpha
-- TODO why use a_i = log(alpha)_,i?
-- esp if alpha can go negative within event horizons
-- in that case, we are guaranteeing a numerical error inside horizons 


printbr(alpha, '= lapse')
printbr()

printHeader'log lapse derivative:'

--[[ this is the standard Bona-Masso hyperbolic variable
local a_l_def = a'_i':eq(log(alpha)'_,i')
--]]
-- [[ but why use log(alpha) when that restricts us to only positive alpha?  esp when we know inside event horizons of charged rotating black holes that alpha can be negative?
local a_l_def = a'_i':eq(alpha'_,i')
--]]
printbr(a_l_def)

a_l_def = a_l_def()
printbr(a_l_def)

local d_alpha_l_from_a_l = a_l_def:solve(alpha'_,i')
printbr(d_alpha_l_from_a_l)

printbr()



printbr'Bona-Masso lapse evolution:'

local dt_alpha_def = alpha'_,t':eq(alpha'_,i' * beta'^i' - alpha^2 * f * (gamma'^ij' * K'_ij' - 2 * Theta))
printbr(dt_alpha_def)

local f_def = f:eq(2 / alpha)
printbr('using 1+log slicing: ', f_def)
dt_alpha_def = dt_alpha_def:subst(f_def)()
printbr(dt_alpha_def)

-- rhs only so alpha_,t isn't simplified
printbr('using', d_alpha_l_from_a_l)
dt_alpha_def[2] = dt_alpha_def[2]
	:substIndex(d_alpha_l_from_a_l)
	:simplify()
printbr(dt_alpha_def)

printbr()


printbr'hyperbolic alpha var time evolution'

local dt_a_l_def = dt_alpha_def'_,k'()
printbr(dt_a_l_def)


--[[ for the sake of eigenvector calculations, lets choose our lapse f up front
printbr'lapse parameter'

local dalpha_f_var = var"f'"	-- TODO alpha is dependent
local dalpha_f_def = f'_,k':eq(dalpha_f_var * alpha'_,k')
printbr(dalpha_f_def)
printbr()

printbr('using', dalpha_f_def)
dt_a_l_def = dt_a_l_def:substIndex(dalpha_f_def)()
printbr(dt_a_l_def)
--]]

local using = alpha'_,t,k':eq(alpha'_,k''_,t')
printbr('using', using, ';', d_alpha_l_from_a_l)
dt_a_l_def = dt_a_l_def  
	:subst(using)
	:substIndex(d_alpha_l_from_a_l)
	:simplify()
printbr(dt_a_l_def)

dt_a_l_def = dt_a_l_def:solve(a'_k,t')()
printbr(dt_a_l_def)

printbr('using', dt_alpha_def)
dt_a_l_def = dt_a_l_def:subst(dt_alpha_def)()
printbr(dt_a_l_def)

printbr('using', d_gamma_uul_from_dHat_lll_dDelta_lll)
dt_a_l_def = dt_a_l_def:subst(d_gamma_uul_from_dHat_lll_dDelta_lll)()
printbr(dt_a_l_def)

printbr('using', d_beta_ul_from_b_ul)
dt_a_l_def = dt_a_l_def:substIndex(d_beta_ul_from_b_ul)
printbr(dt_a_l_def)

local using = a'_i,k':eq(a'_k,i')
printbr('using', using)
dt_a_l_def = dt_a_l_def:subst(using)
printbr(dt_a_l_def)

printbr()


printHeader'metric evolution:'

-- TODO derive this?
--local dt_gamma_ll_def = gamma'_ij,t':eq(-2 * alpha * K'_ij' + beta'_i;j' + beta'_j;i')
local dt_gamma_ll_def = gamma'_ij,t':eq(-2 * alpha * K'_ij' + beta'_i,j' + beta'_j,i' - 2 * beta'^k' * Gamma'_kij')
printbr(dt_gamma_ll_def)

dt_gamma_ll_def = dt_gamma_ll_def:splitOffDerivIndexes()
dt_gamma_ll_def = dt_gamma_ll_def:insertMetricsToSetVariance(beta'^i', gamma)
	:tidyIndexes()
	:reindex{a='k'}
printbr(dt_gamma_ll_def)

dt_gamma_ll_def = dt_gamma_ll_def()
printbr(dt_gamma_ll_def)

printbr('using', conn_lll_def)
dt_gamma_ll_def[2] = dt_gamma_ll_def[2]:substIndex(conn_lll_def)()
printbr(dt_gamma_ll_def)

printbr('symmetrizing', gamma'_ij')
dt_gamma_ll_def = dt_gamma_ll_def:symmetrizeIndexes(gamma, {1,2})()
printbr(dt_gamma_ll_def)

printbr('using', d_beta_ul_from_b_ul)
dt_gamma_ll_def = dt_gamma_ll_def:substIndex(d_beta_ul_from_b_ul)
printbr(dt_gamma_ll_def)

printbr('using', d_gamma_lll_from_d_gammaHat_lll_dDelta_lll)
dt_gamma_ll_def[2] = dt_gamma_ll_def[2]:substIndex(d_gamma_lll_from_d_gammaHat_lll_dDelta_lll)
printbr(dt_gamma_ll_def)

printbr()


printbr'metric delta evolution'

local dt_gammaDelta_ll_def = dt_gamma_ll_def:splitOffDerivIndexes()
	:substIndex(gamma_ll_from_gammaHat_ll_gammaDelta_ll)
printbr(dt_gammaDelta_ll_def)

dt_gammaDelta_ll_def = dt_gammaDelta_ll_def()
	:solve(gammaDelta'_ij,t')
printbr(dt_gammaDelta_ll_def)

-- only rhs so the ,t doesn't mix us up
printbr('using', d_gammaDelta_lll_from_dDelta_lll, ';', d_gammaHat_lll_from_dHat_lll)
dt_gammaDelta_ll_def[2] = dt_gammaDelta_ll_def[2]
	:substIndex(d_gammaDelta_lll_from_dDelta_lll, d_gammaHat_lll_from_dHat_lll)
	:simplify()
printbr(dt_gammaDelta_ll_def)

printbr()


printHeader'metric partial delta evolution:'

local dt_dDelta_lll_def = dt_gammaDelta_ll_def:reindex{k='l'}'_,k'()
printbr(dt_dDelta_lll_def)

printbr('using', d_gammaDelta_lll_from_dDelta_lll, ';', d_gammaHat_lll_from_dHat_lll)
dt_dDelta_lll_def = dt_dDelta_lll_def
	:replace(gammaDelta'_ij,tk', gammaDelta'_ij,k''_,t')
	:replace(gammaHat'_ij,tk', gammaHat'_ij,k''_,t')
	:substIndex(d_gammaDelta_lll_from_dDelta_lll)
	:substIndex(d_gammaHat_lll_from_dHat_lll)
	:simplify()
	:solve(dDelta'_kij,t')
printbr(dt_dDelta_lll_def)

printbr('using', d_alpha_l_from_a_l, ';', d_beta_ul_from_b_ul)
dt_dDelta_lll_def = dt_dDelta_lll_def:substIndex(d_alpha_l_from_a_l, d_beta_ul_from_b_ul)()
printbr(dt_dDelta_lll_def)

local using = dDelta'_lij,k':eq(dDelta'_kij,l')
printbr('using', using)
dt_dDelta_lll_def = dt_dDelta_lll_def:subst(using)
printbr(dt_dDelta_lll_def)

printbr()


printbr'Riemann curvature'

local R_ulll_def = R'^i_jkl':eq(Gamma'^i_jl,k' - Gamma'^i_jk,l' + Gamma'^i_mk' * Gamma'^m_jl' - Gamma'^i_ml' * Gamma'^m_jk')
printbr(R_ulll_def)
printbr()


printbr'Ricci curvature'

local R_ll_def = R'_ij':eq(R'^k_ikj')
printbr(R_ll_def)

printbr('using', R_ulll_def)
R_ll_def = R_ll_def:subst(R_ulll_def:reindex{ijkl='kikj'})
printbr(R_ll_def)

printbr('using', conn_ull_def)
R_ll_def = R_ll_def
	--:substIndex(conn_ull_def)	-- doesn't work well with products of summed vars
	:splitOffDerivIndexes()
	:subst(
		conn_ull_def:reindex{ijkm='kijm'},
		conn_ull_def:reindex{ijkm='kikm'},
		conn_ull_def:reindex{ijkm='kmkl'},
		conn_ull_def:reindex{ijkm='mijn'},
		conn_ull_def:reindex{ijkm='kmjl'},
		conn_ull_def:reindex{ijkm='mikn'}
	)
printbr(R_ll_def)

R_ll_def = R_ll_def()
printbr(R_ll_def)

printbr('using', d_gamma_uul_from_dHat_lll_dDelta_lll)
R_ll_def = R_ll_def
	:subst(
		d_gamma_uul_from_dHat_lll_dDelta_lll:reindex{ijklm='kmkln'},
		d_gamma_uul_from_dHat_lll_dDelta_lll:reindex{ijklm='kmjln'}
	)
	:simplify()
printbr(R_ll_def)

-- [[
printbr'tidying indexes'
R_ll_def = R_ll_def:tidyIndexes()()

local fixed, sum, extra = R_ll_def:getIndexesUsed()
assert(#fixed == 0)
assert(sum:mapi(function(x) return x.symbol end):concat'_' == 'a_b_c_d')
assert(extra:mapi(function(x) return x.symbol end):concat'_' == 'i_j')
R_ll_def = R_ll_def:reindex{abcd='klmn'}

printbr(R_ll_def)
--]]

printbr'symmetrizing indexes'
R_ll_def = R_ll_def
	:symmetrizeIndexes(dHat, {2,3})
	:symmetrizeIndexes(dHat, {1,4}, true)
	:symmetrizeIndexes(dDelta, {2,3})
	:symmetrizeIndexes(dDelta, {1,4}, true)
	:symmetrizeIndexes(gamma, {1,2})
	:simplify()
printbr(R_ll_def)

--[[ no difference if we tidyIndexes() before symmetrizeIndexes()
printbr'tidying indexes'
R_ll_def = R_ll_def:tidyIndexes()()
printbr(R_ll_def)
--]]

printbr()


printHeader'Gaussian curvature'

local R_def = R:eq(gamma'^ij' * R'_ij')
printbr(R_def)

R_def = R_def:subst(R_ll_def)() 
printbr(R_def)

-- [[
printbr'tidying indexes'
R_def = R_def:tidyIndexes()()
	:reindex{abcdef='klmnpq'}
printbr(R_def)
--]]

printbr'symmetrizing indexes'
R_def = R_def
	:symmetrizeIndexes(dHat, {2,3})
	:symmetrizeIndexes(dHat, {1,4}, true)
	:symmetrizeIndexes(dDelta, {2,3})
	:symmetrizeIndexes(dDelta, {1,4}, true)
	:symmetrizeIndexes(gamma, {1,2})
	:simplify()
printbr(R_def)

--[[
printbr'tidying indexes'
R_def = R_def:tidyIndexes()()
printbr(R_def)
--]]

printbr()


printHeader'extrinsic curvature evolution:'

-- TODO derive this?
local dt_K_ll_def = K'_ij,t':eq(
--	-alpha'_;ij' 
	- alpha'_,ij' + Gamma'^k_ij' * alpha'_,k'

	+ alpha * (
		R'_ij' 
		+ Z'_i,j'
		+ Z'_j,i'
		- 2 * Gamma'^k_ij' * Z'_k'
		+ K'_ij' * (K - 2 * Theta)
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

local using = conn_ull_def:reindex{ijk='kij'}
printbr('using', using)
dt_K_ll_def = dt_K_ll_def
	--:substIndex(conn_ull_def:switch())
	:subst(using)
	:simplifyAddMulDiv()
printbr(dt_K_ll_def)

printbr('using', d_gamma_lll_from_dHat_lll_dDelta_lll) 
dt_K_ll_def = dt_K_ll_def:substIndex(d_gamma_lll_from_dHat_lll_dDelta_lll)()
printbr(dt_K_ll_def) 

printbr('using', d_beta_ul_from_b_ul)
dt_K_ll_def = dt_K_ll_def:substIndex(d_beta_ul_from_b_ul)
printbr(dt_K_ll_def) 

local using = alpha'_,ij':eq(frac(1,2) * (alpha'_,ij' + alpha'_,ji')) 
printbr('using', using)
dt_K_ll_def = dt_K_ll_def
	:subst(using)
	:simplify()
printbr(dt_K_ll_def)

printbr('using', d_alpha_l_from_a_l)
--[[ not working for 1st derivs
dt_K_ll_def = dt_K_ll_def 
	:splitOffDerivIndexes()
	:substIndex(d_alpha_l_from_a_l)
	:simplify()
--]]
--[[ also not working for 1st derivs
dt_K_ll_def = dt_K_ll_def 
	:splitOffDerivIndexes()
	:subst(d_alpha_l_from_a_l, d_alpha_l_from_a_l:reindex{i='j'})
	:simplify()
--]]
-- [[
dt_K_ll_def = dt_K_ll_def 
	:subst(
		d_alpha_l_from_a_l'_,j'(),
		d_alpha_l_from_a_l:reindex{i='j'}'_,i'()
	)
	:substIndex(d_alpha_l_from_a_l)
	:simplify()
--]]
printbr(dt_K_ll_def)

--[[ doesn't help
printbr'tidying indexes'
dt_K_ll_def = dt_K_ll_def:tidyIndexes()()
printbr(dt_K_ll_def)

printbr'symmetrizing indexes'
dt_K_ll_def = dt_K_ll_def
	:symmetrizeIndexes(K, {1,2})
	:symmetrizeIndexes(gamma, {1,2})
	:symmetrizeIndexes(dHat, {2,3})
	:symmetrizeIndexes(dGamma, {2,3})
	:simplify()
printbr(dt_K_ll_def)
--]]

printbr('using definition of ', R'_ij')
dt_K_ll_def = dt_K_ll_def:subst(R_ll_def)()
printbr(dt_K_ll_def)

printbr()


printHeader[[Z4 $\Theta$ definition]]

-- TODO derive me plz from the original R_uv + 2 Z_(u;v) = 8 pi (T^TR)_uv
-- are you sure there's no beta^i's?
local dt_Theta_def = Theta'_,t':eq(
	Theta'_,k' * beta'^k'
	+ frac(1,2) * alpha * (
		R
		+ 2 * gamma'^kl' * Z'_k,l'
		- 2 * gamma'^kl' * Gamma'^m_kl' * Z'_m'
		+ gamma'^kl' * K'_kl' * (gamma'^mn' * K'_mn' - 2 * Theta)
		- gamma'^kl' * gamma'^mn' * K'_km' * K'_ln'
		- 16 * pi * rho
	)
	- gamma'^kl' * Z'_k' * alpha'_,l'
)
printbr(dt_Theta_def)

printbr('using', d_alpha_l_from_a_l)
dt_Theta_def = dt_Theta_def:substIndex(d_alpha_l_from_a_l)()
printbr(dt_Theta_def)

printbr('using', conn_ull_def)
dt_Theta_def = dt_Theta_def:subst(conn_ull_def:reindex{ijkm='mkln'})()
printbr(dt_Theta_def)

printbr('using definition of R')
dt_Theta_def = dt_Theta_def:subst(R_def)()
printbr(dt_Theta_def)

--[[
printbr'tidying indexes'
dt_Theta_def = dt_Theta_def:tidyIndexes()()
printbr(dt_Theta_def)
--]]

printbr'symmetrizing indexes'
dt_Theta_def = dt_Theta_def
	:symmetrizeIndexes(K, {1,2})
	:symmetrizeIndexes(gamma, {1,2})
	:symmetrizeIndexes(dHat, {2,3})
	:symmetrizeIndexes(dGamma, {2,3})
	:simplify()
printbr(dt_Theta_def)

--[[
printbr'tidying indexes'
dt_Theta_def = dt_Theta_def:tidyIndexes()()
printbr(dt_Theta_def)
--]]

printbr()


printHeader[[Z4 $Z_k$ definition]]

-- TODO derive me plz
-- are you sure there's no beta^i's?
local dt_Z_l_def = Z'_k,t':eq(
	Z'_k,l' * beta'^l'
	+ Z'_l' * beta'^l_,k'
	+ alpha * (
		gamma'^lm' * (
			K'_kl,m'
			- Gamma'^n_km' * K'_nl'
			- Gamma'^n_lm' * K'_kn'
		)
		- (K'_mn' * gamma'^mn')'_,k'
		+ Theta'_,k'
		- 2 * gamma'^lm' * K'_kl' * Z'_m'
		- 8 * pi * S'_k'
	)
	- Theta * alpha'_,k'
)
printbr(dt_Z_l_def)

dt_Z_l_def = dt_Z_l_def()
printbr(dt_Z_l_def)

printbr('using', d_gamma_uul_from_dHat_lll_dDelta_lll)
dt_Z_l_def = dt_Z_l_def:subst(d_gamma_uul_from_dHat_lll_dDelta_lll:reindex{ijklm='mnklp'})()
printbr(dt_Z_l_def)

printbr('using', d_alpha_l_from_a_l)
dt_Z_l_def = dt_Z_l_def:substIndex(d_alpha_l_from_a_l)()
printbr(dt_Z_l_def)

printbr('using', d_beta_ul_from_b_ul)
dt_Z_l_def = dt_Z_l_def:substIndex(d_beta_ul_from_b_ul)()
printbr(dt_Z_l_def)

printbr('using', conn_ull_def)
dt_Z_l_def = dt_Z_l_def:subst(
		conn_ull_def:reindex{ijkm='nkmp'},
		conn_ull_def:reindex{ijkm='nlmp'}
	):simplify()
printbr(dt_Z_l_def)

printbr'symmetrizing indexes'
dt_Z_l_def = dt_Z_l_def
	:symmetrizeIndexes(K, {1,2})
	:symmetrizeIndexes(gamma, {1,2})
	:symmetrizeIndexes(dHat, {2,3})
	:symmetrizeIndexes(dGamma, {2,3})
	:simplify()
printbr(dt_Z_l_def)

--[[ doesn't help
printbr'tidying indexes'
dt_Z_l_def = dt_Z_l_def:tidyIndexes()()
printbr(dt_Z_l_def)
--]]

printbr()


-- beta^i

printHeader'Bona-Masso shift evolution:'

--[[
hyperbolic gamma driver shift
--]]
local dt_beta_u_def = beta'^i_,t':eq(
	B'^i'
	+ beta'^j' * beta'^i_,j'
)
printbr(dt_beta_u_def)
printbr()


-- B^i
local LambdaBar = var[[\bar{\Lambda}]]
printHeader('hyperbolic shift $B^i$ evolution:')
local dt_B_u_def = B'^i_,t':eq(
	beta'^j' * B'^i_,j'
	- eta * B'^i'
	+ frac(3,4) * LambdaBar
)
printbr(dt_B_u_def) 
printbr()
--[[ TODO
LambdaBar_def = LambdaBar:eq(cbrt(gamma / gammaHat) * (
		
		+ gamma'^jk' * connHat_j connHat_k beta'^i'

		+ frac(1,3) * gamma'^ij' connBar_j (connBar_l beta^l)
		
		+ (
			frac(1,3) * gamma'^jk' * (
				beta'^l_,l' 
				+ frac(1,2) * beta'^m' * (
					+ gamma'^ln' * gamma'_ln,m'
					- gamma'_,m' / gamma 
					+ gammaHat'_,m' / gammaHat
				)
			)
			
			+ alpha * (K'^jk' - frac(1,3) * K * gamma'^jk')
		
		) * (
			- frac(1,3) * (gamma'_,k' / gamma - gammaHat'_,k' / gammaHat) * delta'^i_j'
			- frac(1,3) * (gamma'_,j' / gamma - gammaHat'_,j' / gammaHat) * delta'^i_k'
			+ frac(1,3) * (gamma'_,m' / gamma - gammaHat'_,m' / gammaHat) * gamma'^im' * gamma'_jk'
			+ gamma'^im' (
				+ gamma'_mj,k'
				+ gamma'_mk,j'
				- gamma'_jk,m'
			)
			
			- gammaHat'^im' * (
				gammaHat'_mj,k' 
				+ gammaHat'_mk,j' 
				- gammaHat'_jk,m'
			)
		)
	
		+ (K'^ik' - frac(1,3) * K * gamma'^ik') * (
			alpha * (gamma'_,k' / gamma - gammaHat'_,k' / gammaHat)
			- 2 * alpha'_,k'
		)

		- frac(4,3) * alpha * gamma'^ij' * K'_,j'
		
		+ 2 * gamma'^ij' * (
			alpha * Theta'_,j'
			- Theta * alpha'_,j'
		)
		
		- frac(4,3) * alpha * K * Z'^i'
		
		+ 2 * (
			frac(2,3) * Z'^i' * delta'^k_j'
			- Z'^k' * delta'^j_i'
		) * (
			beta'^j_,k' 
			+ frac(1,2) * gammaHat'^jm' * (gammaHat'_ml,k' + gammaHat'_mk,l' - gammaHat'_lk,m') * beta'^l'
		)

		- 16 * pi * alpha * gamma'^ij' * S'_j'
	)
)
--]]


printHeader'as a system:'

local function assertAndRemoveLastTensorIndex(exprs, lastTensorIndex)
	return exprs:mapi(function(expr)
		local dt = expr:splitOffDerivIndexes()
		assert(TensorRef:isa(dt) 
			and #dt == 2 
			and dt[2] == lastTensorIndex)
		return dt[1]
	end)
end

local UkijtEqns = table{
--[[
for lapse f=2/α:
matrix of {α, Δγ_ij, a_r, Δd_kij, K_ij}
... give us 0 x15, ±α√(γ^11) x5
--]]
	dt_alpha_def,
	dt_gammaDelta_ll_def,
	dt_a_l_def,
	dt_dDelta_lll_def,
	dt_K_ll_def,

--[[
matrix of {α, Δγ_ij, a_k, Δd_kij, K_ij, Θ, Z_k} 
... gives us 0 x17, ±α√(γ^11) x5
... and 4 extra waves:
	... for lapse f arbitrary:
		± α √(± 1/2 γ^11 √( (f - 1) (f - 5) ) + f + 1)
	... for lapse f=2/α:
		± √( α γ^11 (α + 1 ± 1/2 √( (α - 2) (5 α - 2) )))

--]]
--seems these have some ugly wavespeeds
--	dt_Theta_def,
--	dt_Z_l_def
-- so ... how do we change that?
}

local UkijVars = assertAndRemoveLastTensorIndex(	
	UkijtEqns:mapi(function(eqn) return eqn[1] end),
	TensorIndex{lower=true, symbol='t', derivative=','}
)

-- ijk on the partial_t's
-- pqm on the partial_x^r's

-- factor out the _,t from the lhs
local UkijMat = Matrix(UkijVars):T()

local U_defs = Matrix(UkijtEqns:mapi(function(eqn) 
	return eqn[2]:clone():simplifyAddMulDiv()
end)):T()

--printbr(UkijMat'_,t':eq(U_defs))
for _,eqn in ipairs(UkijtEqns) do
	printbr(eqn)
end
printbr()


local UmpqVars = UkijVars:mapi(function(x) return x:reindex{ijk='pqm'} end)
local UmpqrVars = UmpqVars:mapi(function(x) return x'_,r'() end)

printHeader'inserting deltas to help factor linear system'

local rhsWithDeltas = UkijtEqns:mapi(function(eqn) 
	return insertDeltasToSetIndexSymbols(eqn[2], UmpqrVars)
end)

printHeader'as a balance law system:'

local A, b = factorLinearSystem(rhsWithDeltas, UmpqrVars)

local dFkij_dUmpq_mat = (-A)()

local UmpqMat = Matrix(UmpqVars):T()

printbr((UkijMat'_,t' + dFkij_dUmpq_mat * UmpqMat'_,r'):eq(b))
printbr()

--[=[
printbr[[$\frac{\partial F}{\partial U} \cdot U$:]]

printbr((dFkij_dUmpq_mat * UmpqMat)())
printbr()
printbr'TODO prove this matches the non-source part of the flux'
printbr()
--]=]

--[[
but we can only use fluxes in Godunov schemes if F = dF/dU * U, right?

right-eigenvectors:
A_ab U_b = lambda U_a

in other news, the eigenfields i.e. left-eigenvectors:
W_a = C_ab U_b s.t. W_a,t + lambda W_a,r = 0
--]]

--[[ right eigenvectors in tensor index form
printHeader'right eigenvectors:'

local W = Matrix:lambda(dFkij_dUmpq_mat:dim(), function(i,j)
	return var('C_{'..i..j..'}')
end) * UmpqMat	-- relabel U's to something other than ijk or mpq

local reigeqns = (dFkij_dUmpq_mat * W):eq(lambda * W)():unravel()
for _,eqn in ipairs(reigeqns) do 
	printbr(eqn:simplifyMetrics())
end
printbr()
--]]


-- [[ right eigenvectors in expanded form
local remapRows = table()
local remapSrcIndex = 0
local function addScalar()
	remapSrcIndex = remapSrcIndex + 1
	remapRows:insert{
		src = remapSrcIndex,
		map = {},
	}
end
local function addOneForm()
	remapSrcIndex = remapSrcIndex + 1
	for k=1,3 do
		remapRows:insert{
			src = remapSrcIndex,
			map = {k=k},
		}
	end
end
local function addSym()
	remapSrcIndex = remapSrcIndex + 1
	for i=1,3 do
		for j=i,3 do
			remapRows:insert{
				src = remapSrcIndex,
				map = {i=i, j=j},
			}
		end
	end
end
local function addOneBySym()
	remapSrcIndex = remapSrcIndex + 1
	for k=1,3 do
		for i=1,3 do
			for j=i,3 do
				remapRows:insert{
					src = remapSrcIndex,
					map = {k=k, i=i, j=j},
				}
			end
		end
	end
end

for _,var in ipairs(UkijVars) do
	if Variable:isa(var) then
		addScalar()
	elseif TensorRef:isa(var) then
		assert(Variable:isa(var[1]))
		local numIndexes = #var-1
		if numIndexes == 1 then
			assert(var[2].lower)
			addOneForm()
		elseif numIndexes == 2 then	-- all our degree-2 are symmetric
			-- TODO save symmetry info in the TensorRef (so long as it wraps a Variable)
			-- and TODO consider it during simplification -- no more need for symmetrizeIndexes
			addSym()
		elseif numIndexes == 3 then
			addOneBySym()			-- all our degree-3 are symmetric on 2nd and 3rd indexes
		else
			error'here'
		end
	else
		error'here'
	end
end

local n = #remapRows
local remapRowToCol = {m='k', p='i', q='j'}
local dFkij_dUmpq_expanded = Matrix:lambda({n, n}, function(i,j)
	local srci = remapRows[i].src
	local srcj = remapRows[j].src
	local srcexpr = dFkij_dUmpq_mat[srci][srcj]
	return srcexpr
		:reindex{r=1}				-- do this for the 1st direction, whatever that is.
		:reindex(remapRows[i].map)	-- remap kij to #s based on the map
		:reindex(remapRowToCol)		-- remap mpq to kij
		:reindex(remapRows[j].map)	-- remap mpq -> kij -> #s based on the map
		:map(function(x)
			if TensorRef:isa(x)
			and x[1] == delta
			then
				if tonumber(x[2].symbol) then
					return x[2].symbol == x[3].symbol and 1 or 0
				-- else if it's a matching letter then it's summed and return the spatial dimension
				end
			end
		end)
		:symmetrizeIndexes(gamma, {1,2})
		:simplify()
end)
-- remove all rows/cols that are all zeros
local oldn = n
local m = n
for i=n,1,-1 do
	local allzero = true
	for j=1,m do
		if not Constant.isValue(dFkij_dUmpq_expanded[i][j], 0) then
			allzero = false
			break
		end
	end
	if allzero then
		-- TODO remove U mpq expanded vars here as well
		table.remove(dFkij_dUmpq_expanded, i)
		n = n - 1
	end
end
for j=m,1,-1 do
	local allzero = true
	for i=1,n do
		if not Constant.isValue(dFkij_dUmpq_expanded[i][j], 0) then
			allzero = false
			break
		end
	end
	if allzero then
		for i=1,n do
			table.remove(dFkij_dUmpq_expanded[i], j)
		end
		m = m - 1
	end
end
printbr(dFkij_dUmpq_expanded)
assert(m == n)
printbr()
--]]

local dFkij_dUmpq_expanded_shiftless = dFkij_dUmpq_expanded:replace(beta'^1', 0)()


printHeader'calculating charpoly'

local charpoly = dFkij_dUmpq_expanded_shiftless:charpoly(lambda)
printbr(charpoly)


printHeader'finding lambdas'

--	table{Constant(0)}:rep(17),
--	table{alpha * sqrt(gamma'^11')}:rep(5),
--	table{-alpha * sqrt(gamma'^11')}:rep(5),

local lambdas = table()
assert(symmath.op.eq:isa(charpoly))
assert(Constant.isValue(charpoly[2], 0))
local x = charpoly[1]:clone()	-- only take the lhs

for _,root in ipairs{
	Constant(0),
	alpha * sqrt(gamma'^11'),
	-alpha * sqrt(gamma'^11'),
} do
	while true do
		local p, q = polydiv.polydivr(x, (lambda - root)(), lambda)
		if Constant.isValue(q, 0) then
			printbr('root', lambda:eq(root))
			lambdas:insert(root)
			x = p
		else
			break
		end
	end
end
printbr("solving what's left, which is ", x)
local solns = table{x:eq(0):solve(lambda)}
for _,soln in ipairs(solns) do
	printbr('root:', soln)
end
printbr()

--[[
local x = var'x'
charpoly = 
	(charpoly / lambda^17)()				-- 17 lambda=0 eigenvalues
--	:replace(gamma'^11', var'a'/alpha^2)	-- a = gamma^11 alpha^2
	:replace(alpha, a)						-- a = alpha
	:replace(gamma'^11', var'g')			-- g = gamma^11
	:replace(lambda, sqrt(x))				-- x = lambda^2
local pc = charpoly:polyCoeffs(x)
local sum = 0
for _,i in ipairs(table.keys(pc):sort()) do
	if i == 'extra' or i == 0 then
		sum = sum + pc[i]
	else
		sum = sum + pc[i] * x^i
	end
end
print'<pre>'
print(export.Lua(sum))
print'</pre>'
--]]

-- so for f arbitrary and for f=2/alpha, both we get some sqrt(sqrt(...) + ...)'s as lambdas ... makes calcs frustrating

--[=[ this is all for shift-less Z4 for generic 'f' shift parameter

printHeader'verifying charpoly'

--[[ WORKS for shift-less Z4.  those last sets of roots don't look familiar.
local recreated = (
	-lambda^17
	* (lambda^2 - gamma'^11' * alpha^2)^5
	* (lambda^2 - frac(1,2) * gamma'^11' * alpha^2 * (-sqrt(f^2 - 6*f + 5) + f + 1))
	* (lambda^2 - frac(1,2) * gamma'^11' * alpha^2 * ( sqrt(f^2 - 6*f + 5) + f + 1))
):eq(0)()
printbr('verify', (charpoly - recreated)())
--]]

--[[ for lapse f=-2/alpha
local recreated = (
	-lambda^17
	* (lambda^2 - gamma'^11' * alpha^2)^5
	* (lambda^2 - frac(1,2) * gamma'^11' * alpha^2 * (-sqrt(f^2 - 6*f + 5) + f + 1))
	* (lambda^2 - frac(1,2) * gamma'^11' * alpha^2 * ( sqrt(f^2 - 6*f + 5) + f + 1))
):eq(0)()
printbr('verify', (charpoly - recreated)())
--]]

--[[
local x = var'x'
charpoly = 
	(charpoly / lambda^17)()
	:replace(gamma'^11', a/alpha^2)	-- a = gamma^11 alpha^2
	:replace(lambda, sqrt(x))		-- x = lambda^2
	:simplify()
print(charpoly)
--]]

--[[
local lambdas = table():append(
	table{Constant(0)}:rep(17),
	table{alpha * sqrt(gamma'^11')}:rep(5),
	table{-alpha * sqrt(gamma'^11')}:rep(5),
	{
		 alpha * sqrt(frac(1,2) * gamma'^11' * ( sqrt(f^2 - 6*f + 5) + f + 1)),
		 alpha * sqrt(frac(1,2) * gamma'^11' * (-sqrt(f^2 - 6*f + 5) + f + 1)),
		-alpha * sqrt(frac(1,2) * gamma'^11' * ( sqrt(f^2 - 6*f + 5) + f + 1)),
		-alpha * sqrt(frac(1,2) * gamma'^11' * (-sqrt(f^2 - 6*f + 5) + f + 1)),
	}
)
--]]

printbr()
--]=]

--[[ sqrt simplification can't handle this
local recreated = -1
for i=#lambdas,1,-1 do
	local root = lambdas[i]
	recreated = (recreated * (lambda - root))()
end
recreated = recreated:eq(0)
printbr('verify', (charpoly - recreated)())
--]]

--[=[
printHeader'calculating eigensystem'
_G.printbr = printbr
local eig = dFkij_dUmpq_expanded_shiftless:eigen{
	lambdaVar = lambda,
	lambdas = lambdas,
	verbose = true,
	--dontCalcL = true,
}

printbr(var'\\Lambda':eq(eig.Lambda))
printbr()

printbr(var'R':eq(eig.R))
printbr()

printbr(var'L':eq(eig.L))
printbr()
--]=]


--[==[

printHeader'redo, favoring flux terms'

-- ok now try to replace all the hyperbolic 1st deriv state vars that are not derivatives themselves with the original vars' derivatives
rhsWithDeltas = UkijtEqns:mapi(function(eqn)
	local rhs = eqn[2]:clone()
	-- TODO don't just insert the state vars, but in the case that there are quadratic vars, insert averages between the replacements
	return rhs
		:simplifyAddMulDiv()
		:substIndex(a_l_def)
		:substIndex(dDelta_lll_def)
		:substIndex(b_ul_def)
		:simplify()
		:symmetrizeIndexes(dHat, {2,3})
		:symmetrizeIndexes(dHat, {1,4}, true)
		:symmetrizeIndexes(dDelta, {2,3})
		:symmetrizeIndexes(dDelta, {1,4}, true)
		:symmetrizeIndexes(gamma, {1,2})
		:simplify()
end)

printHeader'inserting deltas to help factor linear system'

rhsWithDeltas = rhsWithDeltas:mapi(function(rhs) 
	return insertDeltasToSetIndexSymbols(rhs, UmpqrVars)
end)

printHeader'as a balance law system:'

local A, b = factorLinearSystem(rhsWithDeltas, UmpqrVars)

local dFkij_dUmpq_mat = (-A)()

for i=1,#b do
	b[i][1] = b[i][1]:simplifyAddMulDiv()
end

printbr((UkijMat'_,t' + dFkij_dUmpq_mat * UmpqMat'_,r'):eq(b))

--]==]


-- DONE
printHeader()
io.stderr:write('TOTAL: '..(timer() - startTime)..'\n')
io.stderr:flush()
print(MathJax.footer)
