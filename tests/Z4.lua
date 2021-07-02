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
α
Δγ_ij
a_i
Δd_kij
K_ij
Θ
Z^i
β^i
b^i_j
B^i

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


printbr(alpha, '= lapse')
printbr()

printHeader'log lapse derivative:'

local a_l_def = a'_i':eq(log(alpha)'_,i')
printbr(a_l_def)

a_l_def = a_l_def()
printbr(a_l_def)

local d_alpha_l_from_a_l = a_l_def:solve(alpha'_,i')
printbr(d_alpha_l_from_a_l)

printbr()



printbr'Bona-Masso lapse evolution:'

local dt_alpha_def = alpha'_,t':eq(alpha'_,i' * beta'^i' - alpha^2 * f * (gamma'^ij' * K'_ij' - 2 * Theta))
printbr(dt_alpha_def)

-- rhs only so alpha_,t isn't simplified
dt_alpha_def[2] = dt_alpha_def[2]
	:substIndex(d_alpha_l_from_a_l)
	:simplify()
printbr(dt_alpha_def)

printbr()


printbr'lapse parameter'

local dalpha_f_var = var"f'"	-- TODO alpha is dependent
local dalpha_f_def = f'_,k':eq(dalpha_f_var * alpha'_,k')
printbr(dalpha_f_def)
printbr()


printbr'hyperbolic alpha var time evolution'

local dt_a_l_def = dt_alpha_def'_,k'()
printbr(dt_a_l_def)

printbr('using', dalpha_f_def)
dt_a_l_def = dt_a_l_def:substIndex(dalpha_f_def)()
printbr(dt_a_l_def)

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
		+ K * (K - 2 * Theta)
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
local dt_beta_u_def = beta'^i_,t':eq(B'^i')
printbr(dt_beta_u_def)
printbr()


-- B^i

local LambdaBar = var'\\bar{\\Lambda}'	--TODO replace this with its value
printHeader('hyperbolic shift $B^i$ evolution:')
local dt_B_u_def = B'^i_,t':eq(frac(3,4) * LambdaBar'^i_,t' - eta * B'^i')
printbr(dt_B_u_def) 
printbr()


printHeader'as a linear system:'

local function assertAndRemoveLastTensorIndex(exprs, lastTensorIndex)
	return exprs:mapi(function(expr)
		local dt = expr:splitOffDerivIndexes()
		assert(TensorRef:isa(dt) 
			and #dt == 2 
			and dt[2] == lastTensorIndex)
		return dt[1]
	end)
end

local dt_eqns = table{
	dt_alpha_def,
	dt_gammaDelta_ll_def,
	dt_a_l_def,
	dt_dDelta_lll_def,
	dt_K_ll_def,
	dt_Theta_def,
	dt_Z_l_def
}

-- ijk on the partial_t's
-- pqm on the partial_x's

-- factor out the _,t from the lhs
local U_vars = Matrix(
	assertAndRemoveLastTensorIndex(	
		dt_eqns:mapi(function(eqn) 
			return eqn[1]
		end),
		TensorIndex{lower=true, symbol='t', derivative=','}
	)
):T()

local U_defs = Matrix(dt_eqns:mapi(function(eqn) 
	return eqn[2]:clone():simplifyAddMulDiv()
end)):T()
printbr(U_vars'_,t':eq(U_defs))
printbr()


--[[
now in advance of calling 'factorLinearSystem', make sure our terms are all using common indexes:
alpha_,r except all the alpha_,r's are already in the form of a_r's
beta^n,r except they are already b^n_r
a_m,r
d_mpq,r
K_pq,r
Z_m,r
b^n_m,r
--]]

local dxVars = table{
	alpha'_,r',
	gammaDelta'_pq,r',
	a'_m,r',
	dDelta'_mpq,r',
	K'_pq,r',
	Theta'_,r',
	Z'_m,r',
}

printHeader'inserting deltas to help factor linear system'

local rhsWithDeltas = dt_eqns:mapi(function(eqn) 
	rhs = eqn[2]:clone()
	rhs = insertDeltasToSetIndexSymbols(rhs, dxVars)
	return rhs
end)

printHeader'as a balance law system:'

local A, b = factorLinearSystem(
	rhsWithDeltas,
	dxVars
)

printbr(
	(
		U_vars'_,t'
		+ (-A)() * Matrix(
			assertAndRemoveLastTensorIndex(
				dxVars,
				TensorIndex{lower=true, symbol='r', derivative=','}
			)
		):T()
	):eq(b)
)


printHeader'favoring flux terms'

-- ok now try to replace all the hyperbolic 1st deriv state vars that are not derivatives themselves with the original vars' derivatives
rhsWithDeltas = dt_eqns:mapi(function(eqn)
	local rhs = eqn[2]:clone()
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
	return insertDeltasToSetIndexSymbols(rhs, dxVars)
end)

printHeader'as a balance law system:'

local A, b = factorLinearSystem(
	rhsWithDeltas,
	dxVars
)
for i=1,#b do
	b[i][1] = b[i][1]:simplifyAddMulDiv()
end
printbr(
	(
		U_vars'_,t'
		+ (-A)() * Matrix(
			assertAndRemoveLastTensorIndex(
				dxVars,
				TensorIndex{lower=true, symbol='r', derivative=','}
			)
		):T()
	):eq(b)
)



-- DONE
printHeader()
io.stderr:write('TOTAL: '..(timer() - startTime)..'\n')
io.stderr:flush()
print(MathJax.footer)
