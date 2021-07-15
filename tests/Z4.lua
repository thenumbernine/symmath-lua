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


--MathJax.showDivConstAsMulFrac = false


local xNames = table{'x','y','z'}	-- names of spatial dimension vars
local spatialDim = 3
local xs = xNames:mapi(function(name) return var(name) end)
local x,y,z = xs:unpack()
-- time
local t = var't'
local txs = table{t}:append(xs)


--[[
set to true to use alpha_,i as a state var, instead of log(alpha)_,i
using log(alpha)_,i is more common
using alpha_,i can include both positive and negative alpha's
flux jacobian looks the same?
--]]
local useDAlphaAsStateVar = false

--[[
pick only one of these
or pick none = keep lapse as a generic variable 'f'
--]]
local useLapseF_1PlusLog = false		-- f = 2/alpha
local useLapseF_geodesic = false		-- f = 0
local useLapseF_timeHarmonic = false	-- f = 1

--[[
pick one of these
--]]
local useShift_hyperbolicGammaDriver = false
local useShift_minimalDistortionElliptic = true

--[[
dont include alpha and gamma_ij
in the case of favorFluxTerms==false and removeZeroRows==true they tend to be removed anyways
--]]
local eigensystem_dontIncludeGaugeVars = true

--[[
don't consider Z_k,t and Theta_,t in the eigen decomposition
turns out these two have a very ugly wavespeed that chokes up the solver
--]]
local eigensystem_dontIncludeZVars = false

--[[
remove beta^i, b^i_j, B^i from the eigensystem vars
evaluating shiftless + remove zero rows will accomplish this as well
--]]
local eigensystem_dontIncludeShiftVars = true

--[[
false = alpha, gamma_ij flux reduces to zero
true = covnert as many first-derivative state variables into derivatives of state vars
--]]
local favorFluxTerms = false

--[[
remove zero rows from expanded flux jacobian matrix?
--]]
local removeZeroRows = false

--[[
whether to only evaluate the shiftless eigensystem
by default the beta^x's are removed from the flux
but this will remove any other shift terms as well
--]]
local evaluateShiftlessEigensystem = true


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
				y = y:clone()

				-- if we have summed indexes within the TensorRef, and we're trying to replace one of them, then we'll run into trouble ... 
				-- because otherwise we rely on 'reindex', but with repeated indexes ... idk ...

				local fixed, sum, extra = y:getIndexesUsed()
				
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
						
						if sum:find(nil, function(si) return si.symbol == ti.symbol end) then
							error("looks like we're trying to remap from a summed index "..ti.symbol.." to index "..target.symbol.." and with prevSymbol "..tostring(prevSymbol).." (try inserting a delta beforehand)")
						end
						
						if prevSymbol and prevSymbol ~= target.symbol then
							error("tried to remap mul to "..target.symbol.." from "..prevSymbol.." and then from "..ti.symbol.." in TensorRef "..y.." in mul "..x)
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
						-- TODO if not matchingLowers then insert metric symbols instead of delta symbols
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

-- connection
local Gamma = var'\\Gamma'
-- Ricci/Riemann/Gaussian curvature:
local R = var'R'
-- stress-energy
local S = var'S'
local rho = var'\\rho'
-- ADM vars:
local alpha = var'\\alpha'
local beta = var'\\beta'
local K = var'K'
local gamma = var'\\gamma'
local gammaHat = var'\\hat{\\gamma}'
local gammaDelta = var[[\overset{\Delta}{\gamma}]]
-- lapse gauge
local f = var('f', {alpha})
-- Z4 vars
local Z = var'Z'
local Theta = var'\\Theta'
-- 1st derivative state vars
local a = var'a'
local b = var'b'
local d = var'd'
local dHat = var'\\hat{d}'
local dDelta = var[[\overset{\Delta}{d}]]
-- hyperbolic gamma driver parameter
local eta = var'\\eta'
-- hyperbolic gamma driver time derivative state var
local B = var'B'
-- eigenvalue variable
local lambda = var'\\lambda'

alpha:setDependentVars(txs:unpack())
gammaDelta'_ij':setDependentVars(txs:unpack())
a'_k':setDependentVars(txs:unpack())
dDelta'_kij':setDependentVars(txs:unpack())
K'_ij':setDependentVars(txs:unpack())
Theta:setDependentVars(txs:unpack())
Z'_k':setDependentVars(txs:unpack())
beta'^l':setDependentVars(txs:unpack())
b'^l_k':setDependentVars(txs:unpack())
B'^l':setDependentVars(txs:unpack())


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

local conn_ull_from_gamma_uu_d_gamma_lll = (gamma'^im' * conn_lll_def:reindex{i='m'})():simplifyMetrics()()
printbr(conn_ull_from_gamma_uu_d_gamma_lll)

printbr('using', d_gamma_lll_from_d_lll)
local conn_ull_from_gamma_uu_d_lll = conn_ull_from_gamma_uu_d_gamma_lll:substIndex(d_gamma_lll_from_d_lll)()
printbr(conn_ull_from_gamma_uu_d_lll)

printbr('using', d_lll_from_dHat_lll_dDelta_lll)
local conn_ull_from_gamma_uu_dHat_lll_dDelta_lll = conn_ull_from_gamma_uu_d_lll:substIndex(d_lll_from_dHat_lll_dDelta_lll)()
printbr(conn_ull_from_gamma_uu_dHat_lll_dDelta_lll)

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

printHeader'lapse derivative:'

local a_l_def 
if not useDAlphaAsStateVar then -- [[ this is the standard Bona-Masso hyperbolic variable
	a_l_def = a'_i':eq(log(alpha)'_,i')
else --]]
-- [[ but why use log(alpha) when that restricts us to only positive alpha?  esp when we know inside event horizons of charged rotating black holes that alpha can be negative?
	a_l_def = a'_i':eq(alpha'_,i')
--]]
end
printbr(a_l_def)

a_l_def = a_l_def()
printbr(a_l_def)

local d_alpha_l_from_a_l = a_l_def:solve(alpha'_,i')
printbr(d_alpha_l_from_a_l)

printbr()



printbr'lapse evolution:'

local dt_alpha_def = alpha'_,t':eq(alpha'_,i' * beta'^i' - alpha^2 * f * (gamma'^ij' * K'_ij' - 2 * Theta))
printbr(dt_alpha_def)

local f_def
if useLapseF_1PlusLog then
	f_def = f:eq(2 / alpha)
	printbr('using 1+log slicing: ', f_def)
elseif useLapseF_geodesic then
	f_def = f:eq(0)
	printbr('using geodesic slicing: ', f_def)
elseif useLapseF_timeHarmonic then
	f_def = f:eq(1)
	printbr('using time-harmonic slicing: ', f_def)
end
if f_def then
	dt_alpha_def = dt_alpha_def:subst(f_def)()
	printbr(dt_alpha_def)
end

-- rhs only so alpha_,t isn't simplified
printbr('using', d_alpha_l_from_a_l)
dt_alpha_def[2] = dt_alpha_def[2]
	:substIndex(d_alpha_l_from_a_l)
	:simplify()
printbr(dt_alpha_def)

printbr()


printbr'lapse partial evolution'

--local dt_a_l_def = dt_alpha_def'_,k'	-- this wil simplify the same, but it won't look as good
local dt_a_l_def = dt_alpha_def[1]'_,k':eq(dt_alpha_def[2]'_,k')
printbr(dt_a_l_def)

local using = alpha'_,t,k':eq(alpha'_,k''_,t')
printbr('using', using, ';', d_alpha_l_from_a_l:reindex{i='k'})
dt_a_l_def[1] = dt_a_l_def[1]()
dt_a_l_def[1] = dt_a_l_def[1]
	:subst(using)
	:substIndex(d_alpha_l_from_a_l)
	:simplify()
printbr(dt_a_l_def)
	
-- while we're here, only on the lhs, replace a_k with its alpha def ... but not a_k,t .. so simplify() before to combine TensorRef derivatives
printbr('using on lhs only', a_l_def:reindex{i='k'})
dt_a_l_def[1] = dt_a_l_def[1]:substIndex(a_l_def)
printbr(dt_a_l_def)

--[[ this incurs a simplify() which I don't want ...
printbr('solving for', a'_k,t')
dt_a_l_def = dt_a_l_def:solve(a'_k,t')
printbr(dt_a_l_def)
--]]
-- [[ so instead

--[=[
printbr('dividing by', alpha)
dt_a_l_def = (1 / alpha) * dt_a_l_def
dt_a_l_def[1] = dt_a_l_def[1]:simplifyAddMulDiv()
printbr(dt_a_l_def)
--]=]

printbr('subtracting', alpha'_,t' * alpha'_,k' * (1 / alpha), 'from both sides')
dt_a_l_def = dt_a_l_def - alpha'_,t' * alpha'_,k' * (1 / alpha)
dt_a_l_def[1] = dt_a_l_def[1]:simplifyAddMulDiv()
printbr(dt_a_l_def)
--]]

printbr('using', dt_alpha_def)
dt_a_l_def = dt_a_l_def:subst(dt_alpha_def)
printbr(dt_a_l_def)

-- the easy way to do that with the tools I have:
local alpha_t_over_alpha = var'alpha_t_over_alpha'
local alpha_t_over_alpha_def = alpha_t_over_alpha:eq((dt_alpha_def[2] / alpha)())
dt_a_l_def = dt_a_l_def:subst(alpha_t_over_alpha_def:switch())
dt_a_l_def = dt_a_l_def:solve(a'_k,t')
dt_a_l_def = dt_a_l_def:subst(alpha_t_over_alpha_def)
printbr(dt_a_l_def)

-- this is done in the 2008 Yano et al paper, not exactly sure why, not mentioned in the flux of the 2005 Bona et al paper
dt_a_l_def[2] = dt_a_l_def[2]
	+ (beta'^m' * a'_k')'_,m'	-- goes in the flux
	- (beta'^m' * a'_k')'_,m'():substIndex(d_beta_ul_from_b_ul)								-- goes in the source
	- (beta'^m' * a'_m')'_,k'	-- goes in the flux
	+ (beta'^m' * a'_m')'_,k'():substIndex(d_beta_ul_from_b_ul):replace(a'_i,k', a'_k,i')	-- goes in the source
	-- such that half the source terms cancel (thanks to a'_i,k' == a'_k,i')
printbr(dt_a_l_def)

printbr('expanding rhs derivative')
dt_a_l_def = dt_a_l_def()
printbr(dt_a_l_def)

--[[ at this point, even though we can simplify this, dont' do it, because it separates terms from flux and source
local using = beta'^i_,i':eq(b'^i_i')
printbr('using', using)
dt_a_l_def = dt_a_l_def:subst(using)()
printbr(dt_a_l_def)
--]]

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

--[[
printbr('using', d_alpha_l_from_a_l)
dt_a_l_def = dt_a_l_def  
	:substIndex(d_alpha_l_from_a_l)
	:simplify()
printbr(dt_a_l_def)
--]]

printbr('using', d_gamma_uul_from_dHat_lll_dDelta_lll)
dt_a_l_def = dt_a_l_def:subst(d_gamma_uul_from_dHat_lll_dDelta_lll)()
printbr(dt_a_l_def)

--[[ don't do this, assume we have all the b's and beta's as we want them
printbr('using', d_beta_ul_from_b_ul)
dt_a_l_def = dt_a_l_def:substIndex(d_beta_ul_from_b_ul)
printbr(dt_a_l_def)
--]]

local using = a'_i,k':eq(a'_k,i')
printbr('using', using)
dt_a_l_def = dt_a_l_def:subst(using)
printbr(dt_a_l_def)

local using = f'_,k':eq(f:diff(alpha) * alpha'_,k')
printbr('using', using)
dt_a_l_def = dt_a_l_def:subst(using)
printbr(dt_a_l_def)

-- this is a cheap way of fixing the insert-deltas stuff
dt_a_l_def = dt_a_l_def
	:replace(beta'^m_,m', beta'^m_,l' * delta'^l_m')
	:replace(b'^m_m', b'^m_l' * delta'^l_m')
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

printbr('using', d_gamma_lll_from_dHat_lll_dDelta_lll)
dt_gamma_ll_def[2] = dt_gamma_ll_def[2]:substIndex(d_gamma_lll_from_dHat_lll_dDelta_lll)
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

--[[
local dt_dDelta_lll_def = dt_gammaDelta_ll_def:reindex{k='l'}'_,k'
printbr(dt_dDelta_lll_def)
--]]
-- [[
local dt_dDelta_lll_def = dt_gammaDelta_ll_def:reindex{k='l'}
dt_dDelta_lll_def = dt_dDelta_lll_def / 2
dt_dDelta_lll_def = dt_dDelta_lll_def[1]'_,k':eq(dt_dDelta_lll_def[2]'_,k')
dt_dDelta_lll_def[1] = dt_dDelta_lll_def[1]()
printbr(dt_dDelta_lll_def)

printbr('using', d_gammaDelta_lll_from_dDelta_lll, ';', d_gammaHat_lll_from_dHat_lll)
dt_dDelta_lll_def = dt_dDelta_lll_def
	:replace(gammaDelta'_ij,tk', gammaDelta'_ij,k''_,t')
	:replace(gammaHat'_ij,tk', gammaHat'_ij,k''_,t')
	:substIndex(d_gammaDelta_lll_from_dDelta_lll)
	:substIndex(d_gammaHat_lll_from_dHat_lll)
dt_dDelta_lll_def[1] = dt_dDelta_lll_def[1]()
printbr(dt_dDelta_lll_def)
printbr('TODO move the ', gammaHat'_ij', 'and', dHat'_kij', 'values outside of the derivative')

-- this is done in the 2008 Yano et al paper, not exactly sure why, not mentioned in the flux of the 2005 Bona et al paper
dt_dDelta_lll_def[2] = dt_dDelta_lll_def[2]
	+ (beta'^l' * dDelta'_kij')'_,l'	-- goes in the flux
	- (beta'^l' * dDelta'_kij')'_,l'():substIndex(d_beta_ul_from_b_ul)	-- goes in the source
	- (beta'^l' * dDelta'_lij')'_,k'	-- goes in the flux
	+ (beta'^l' * dDelta'_lij')'_,k'():substIndex(d_beta_ul_from_b_ul):replace(dDelta'_lij,k', dDelta'_kij,l')	-- goes in the source
	-- such that half the source terms cancel (thanks to dDelta'_lij,k' == dDelta'_kij,l')
printbr(dt_dDelta_lll_def)
--]]

printbr'expanding rhs derivative'
dt_dDelta_lll_def = dt_dDelta_lll_def()
printbr(dt_dDelta_lll_def)

--[[ at this point, even though we can simplify this, dont' do it, because it separates terms from flux and source
local using = beta'^l_,l':eq(b'^l_l')
printbr('using', using)
dt_a_l_def = dt_a_l_def:subst(using)()
printbr(dt_a_l_def)
--]]

--[[
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
--]]

local using = dDelta'_lij,k':eq(dDelta'_kij,l')
printbr('using', using)
dt_dDelta_lll_def = dt_dDelta_lll_def:subst(using)
printbr(dt_dDelta_lll_def)

-- this is a cheap way of fixing the insert-deltas stuff
dt_dDelta_lll_def = dt_dDelta_lll_def
	:replace(beta'^l_,l', beta'^l_,n' * delta'^n_l')
	:replace(b'^l_l', b'^l_n' * delta'^n_l')
printbr(dt_dDelta_lll_def)


printbr()




printbr'Riemann curvature'

local Riemann_ulll_def = R'^i_jkl':eq(Gamma'^i_jl,k' - Gamma'^i_jk,l' + Gamma'^i_mk' * Gamma'^m_jl' - Gamma'^i_ml' * Gamma'^m_jk')
printbr(Riemann_ulll_def)
printbr()


-- I'm going to center this around the 2005 Bona et al Z4 d_kij terms
printbr'Ricci curvature'

local Ricci_ll_from_Riemann_ulll = R'_ij':eq(R'^k_ikj')
printbr(Ricci_ll_from_Riemann_ulll)

printbr('using', Riemann_ulll_def)
local Ricci_ll_def = Ricci_ll_from_Riemann_ulll:subst(Riemann_ulll_def:reindex{ijkl='kikj'})
printbr(Ricci_ll_def)

printbr('using', conn_ull_from_gamma_uu_d_lll)
local Ricci_ll_from_d_lll = Ricci_ll_def
	--:substIndex(conn_ull_from_gamma_uu_dHat_lll_dDelta_lll)	-- doesn't work well with products of summed vars
	:splitOffDerivIndexes()
	:subst(
		conn_ull_from_gamma_uu_d_lll:reindex{ijkm='kijm'},
		conn_ull_from_gamma_uu_d_lll:reindex{ijkm='kikm'},
		conn_ull_from_gamma_uu_d_lll:reindex{ijkm='kmkl'},
		conn_ull_from_gamma_uu_d_lll:reindex{ijkm='mijn'},
		conn_ull_from_gamma_uu_d_lll:reindex{ijkm='kmjl'},
		conn_ull_from_gamma_uu_d_lll:reindex{ijkm='mikn'}
	)
printbr(Ricci_ll_from_d_lll)

-- simplify d's symmetry but only rearrange these terms:
Ricci_ll_from_d_lll = Ricci_ll_from_d_lll:replace(
	gamma'^kl' * (d'_mlk' + d'_klm' - d'_lmk')(),
	gamma'^kl' * d'_mlk'
)
Ricci_ll_from_d_lll = Ricci_ll_from_d_lll:replace(
	gamma'^km' * (d'_imk' + d'_kmi' - d'_mik')(),
	gamma'^km' * d'_imk'
)
printbr(Ricci_ll_from_d_lll)

printbr('using', d_lll_from_dHat_lll_dDelta_lll)
Ricci_ll_def = Ricci_ll_from_d_lll:substIndex(d_lll_from_dHat_lll_dDelta_lll)	-- doesn't work well with products of summed vars
printbr(Ricci_ll_def)

-- TODO everything from here on down ... not sure if I really need it ... esp since I'm keeping the terms in flux form, so not expanding the derivatives is better

printbr'simplifying...'
Ricci_ll_def = Ricci_ll_def()
printbr(Ricci_ll_def)

printbr('using', d_gamma_uul_from_dHat_lll_dDelta_lll)
Ricci_ll_def = Ricci_ll_def
	:subst(
		d_gamma_uul_from_dHat_lll_dDelta_lll:reindex{ijklm='kmkln'},
		d_gamma_uul_from_dHat_lll_dDelta_lll:reindex{ijklm='kmjln'}
	)
	:simplify()
printbr(Ricci_ll_def)

-- [[
printbr'tidying indexes'
Ricci_ll_def = Ricci_ll_def:tidyIndexes()()

local fixed, sum, extra = Ricci_ll_def:getIndexesUsed()
assert(#fixed == 0)
assert(sum:mapi(function(x) return x.symbol end):concat'_' == 'a_b_c_d')
assert(extra:mapi(function(x) return x.symbol end):concat'_' == 'i_j')
Ricci_ll_def = Ricci_ll_def:reindex{abcd='klmn'}

printbr(Ricci_ll_def)
--]]

printbr'symmetrizing indexes'
Ricci_ll_def = Ricci_ll_def
	:symmetrizeIndexes(dHat, {2,3})
	--:symmetrizeIndexes(dHat, {1,4}, true)
	:symmetrizeIndexes(dDelta, {2,3})
	--:symmetrizeIndexes(dDelta, {1,4}, true)
	:symmetrizeIndexes(gamma, {1,2})
	:simplify()
printbr(Ricci_ll_def)

--[[ no difference if we tidyIndexes() before symmetrizeIndexes()
printbr'tidying indexes'
Ricci_ll_def = Ricci_ll_def:tidyIndexes()()
printbr(Ricci_ll_def)
--]]

printbr()


printHeader'Gaussian curvature'

local R_def = R:eq(gamma'^ij' * R'_ij')
printbr(R_def)

R_def = R_def:subst(Ricci_ll_def)() 
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
	- alpha'_,ij' 
	+ Gamma'^k_ij' * alpha'_,k'

	+ alpha * (
		R'_ij' 
	)
	+ alpha * (
		Z'_i,j'
		+ Z'_j,i'
	)	
	+ alpha * (
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

--[[
local using = alpha'_,ij':eq(frac(1,2) * (alpha'_,ij' + alpha'_,ji')) 
printbr('using', using)
dt_K_ll_def = dt_K_ll_def:subst(using)
printbr(dt_K_ll_def)
--]]
-- [[
local using = alpha'_,ij':eq(frac(1,2) * (alpha'_,ik' * delta'^k_j' + alpha'_,jk' * delta'^k_i')) 
printbr('using', using)
local using = alpha'_,ij':eq(frac(1,2) * (alpha'_,i' * delta'^k_j' + alpha'_,j' * delta'^k_i')'_,k')
printbr('using', using)
local using = alpha'_,ij':eq(frac(1,2) * (alpha'_,i' * delta'^k_j' + alpha'_,j' * delta'^k_i'):substIndex(d_alpha_l_from_a_l)'_,k')
printbr('using', using)
dt_K_ll_def = dt_K_ll_def:subst(using)
printbr(dt_K_ll_def)
--]]

local using = (alpha * (Z'_i,j' + Z'_j,i')):eq(alpha * (Z'_i,k' * delta'^k_j' + Z'_j,k' * delta'^k_i'))
printbr('using', using)
local using = (alpha * (Z'_i,j' + Z'_j,i')):eq(alpha * (Z'_i' * delta'^k_j' + Z'_j' * delta'^k_i')'_,k')
printbr('using', using)
local using = (alpha * (Z'_i,j' + Z'_j,i')):eq( 
	(alpha * (Z'_i' * delta'^k_j' + Z'_j' * delta'^k_i'))'_,k' 			-- flux term
	- alpha'_,k' * (Z'_i' * delta'^k_j' + Z'_j' * delta'^k_i') 			-- source term
)
printbr('using', using)
dt_K_ll_def = dt_K_ll_def:subst(using)

printbr('using', d_alpha_l_from_a_l)
dt_K_ll_def = dt_K_ll_def:substIndex(d_alpha_l_from_a_l)
printbr(dt_K_ll_def)

dt_K_ll_def[2] = dt_K_ll_def[2]
	+ (beta'^k' * K'_ij')'_,k'										-- flux term
	- (beta'^k' * K'_ij')'_,k'():substIndex(d_beta_ul_from_b_ul)	-- source term
printbr(dt_K_ll_def)

printbr('using', d_beta_ul_from_b_ul)
dt_K_ll_def = dt_K_ll_def:substIndex(d_beta_ul_from_b_ul)
printbr(dt_K_ll_def) 

printbr('using definition of ', R'_ij')
dt_K_ll_def = dt_K_ll_def:subst(Ricci_ll_from_d_lll)
	--[[
	what we have: 
		(d_ji^k + d_ij^k - d^k_ij)_,k
		= d_ji^k_,k + d_ij^k_,k - d^k_ij,k
	what we want:
		= (1/2 d_ji^k + 1/2 d_ij^k - d^k_ij)_,k + 1/2 d_ki^k_,j + 1/2 d_kj^k_,i
	--]]
	:replace(
		(gamma'^km' * (d'_imj' + d'_jmi' - d'_mij'))()'_,k',
		-- TODO instead of 1/2 , use the xi parameter
		-- try to use sum terms that the block linear system will use, or it will screw things up 
		(gamma'^kl' * (frac(1,2) * d'_ilj' + frac(1,2) * d'_jli' - d'_lij'))'_,k'
		+ (
			gamma'^kl_,k' * (frac(1,2) * d'_ijl' + frac(1,2) * d'_jil')
			+ gamma'^mp' * (frac(1,2) * d'_mpj' * delta'^k_i' + frac(1,2) * d'_mpi' * delta'^k_j')'_,k'
		)
	)
	
	:replace(
		(gamma'^km' * d'_imk')'_,j',
		(frac(1,2) * gamma'^pq' * (d'_ipq' * delta'^k_j' + d'_jpq' * delta'^k_i'))'_,k'	-- use pq for the sake of the block linear system below
	)
printbr(dt_K_ll_def)

-- HERE is where our flux form ends

-- this only affects source terms:
local using = conn_ull_from_gamma_uu_dHat_lll_dDelta_lll:reindex{ijk='kij'}
printbr('using', using)
dt_K_ll_def = dt_K_ll_def:subst(using)
printbr(dt_K_ll_def)

-- if we use the d_kij def of R_ij then we have to do this too:
printbr('using', d_lll_from_dHat_lll_dDelta_lll)
dt_K_ll_def = dt_K_ll_def:substIndex(d_lll_from_dHat_lll_dDelta_lll)
printbr(dt_K_ll_def)

--[[
printbr('using', d_gamma_lll_from_dHat_lll_dDelta_lll) 
dt_K_ll_def = dt_K_ll_def:substIndex(d_gamma_lll_from_dHat_lll_dDelta_lll)()
printbr(dt_K_ll_def) 
--]]

--[[ not working for 1st derivs
printbr('using', d_alpha_l_from_a_l)
dt_K_ll_def = dt_K_ll_def 
	:splitOffDerivIndexes()
	:substIndex(d_alpha_l_from_a_l)
	:simplify()
printbr(dt_K_ll_def)
--]]
--[[ also not working for 1st derivs
printbr('using', d_alpha_l_from_a_l)
dt_K_ll_def = dt_K_ll_def 
	:splitOffDerivIndexes()
	:subst(d_alpha_l_from_a_l, d_alpha_l_from_a_l:reindex{i='j'})
	:simplify()
printbr(dt_K_ll_def)
--]]
--[[
printbr('using', d_alpha_l_from_a_l)
dt_K_ll_def = dt_K_ll_def 
	:subst(
		d_alpha_l_from_a_l'_,j'(),
		d_alpha_l_from_a_l:reindex{i='j'}'_,i'()
	)
	:substIndex(d_alpha_l_from_a_l)
	:simplify()
printbr(dt_K_ll_def)
--]]

--[[ doesn't help if we used the version of R_ij that already did this ...
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

--[[
printbr('using definition of ', R'_ij')
dt_K_ll_def = dt_K_ll_def:subst(Ricci_ll_def)
printbr(dt_K_ll_def)
--]]

printbr'simplifying...'
dt_K_ll_def = dt_K_ll_def
	:simplify()
	:replaceIndex(delta'^i_j,k', 0)
	:replace(delta'^k_i,k', 0)
	:replace(delta'^k_j,k', 0)
	:simplifyAddMulDiv()
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

printbr('using', conn_ull_from_gamma_uu_dHat_lll_dDelta_lll)
dt_Theta_def = dt_Theta_def:subst(conn_ull_from_gamma_uu_dHat_lll_dDelta_lll:reindex{ijkm='mkln'})()
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

--[[
TODO derive me plz

are you sure there's no beta^i's?

this is 2005 Bona p.61 eqn.3.85
--]]
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

printbr('using', conn_ull_from_gamma_uu_dHat_lll_dDelta_lll)
dt_Z_l_def = dt_Z_l_def:subst(
		conn_ull_from_gamma_uu_dHat_lll_dDelta_lll:reindex{ijkm='nkmp'},
		conn_ull_from_gamma_uu_dHat_lll_dDelta_lll:reindex{ijkm='nlmp'}
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

printHeader'shift evolution:'

local dt_beta_u_def 
local dt_b_ul_def
local dt_B_u_def 
if useShift_hyperbolicGammaDriver then
	printHeader('hyperbolic gamma driver shift evolution:')
	dt_beta_u_def = beta'^i_,t':eq(
		B'^i'
		+ beta'^j' * beta'^i_,j'
	)
	printbr(dt_beta_u_def)
	printbr()

	-- B^i
	local LambdaBar = var[[\bar{\Lambda}]]
	printHeader('hyperbolic gamma driver shift time derivative evolution:')
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
end	-- useShift_hyperbolicGammaDriver
if useShift_minimalDistortionElliptic then
	-- how many of these terms should be state vars instead of state derivatives?
	printHeader('minimum distortion elliptic evolution:')

	dt_beta_u_def = beta'^l_,t':eq(
		beta'^k' * b'^l_k'
		+ alpha^2 * gamma'^kl' * (
			2 * gamma'^jm' * d'_mjk' 
			- gamma'^jm' * d'_kjm' 
			- a'_k'
		)
	)
	printbr(dt_beta_u_def)
	printbr()

	
	printHeader('minimum distortion elliptic spatial derivative evolution:')
	
	-- TODO now how do they convert to flux?
	dt_b_ul_def = dt_beta_u_def:reindex{k='i'}
	dt_b_ul_def = (dt_b_ul_def[1]'_,k')():eq(dt_b_ul_def[2]'_,k')
	dt_b_ul_def[1] = dt_b_ul_def[1]:replace(beta'^l_,tk', beta'^l_,k''_,t'):substIndex(d_beta_ul_from_b_ul)
	printbr(dt_b_ul_def)

	dt_b_ul_def = dt_b_ul_def()
	printbr(dt_b_ul_def)

	printbr()

	-- TODO and how about dt_b_ul_def
end


printHeader'as a system:'

local function assertAndRemoveLastTensorIndex(exprs, lastTensorIndex)
	return exprs:mapi(function(expr)
		local dt = expr:splitOffDerivIndexes()
		assert(TensorRef:isa(dt) 
			and #dt == 2 
			and dt[2] == lastTensorIndex,
			"expected expr to be a TensorRef ending in _,"..lastTensorIndex)
		return dt[1]
	end)
end

--[[
for lapse f=2/α:
matrix of {α, Δγ_ij, a_r, Δd_kij, K_ij}
... give us 0 x15, ±α√(γ^xx) x5
--]]
local UijkltEqns = table()

-- technically beta^i is also a gauge var, but i'm disabling it via dontIncludeShiftVars
if not eigensystem_dontIncludeGaugeVars then
	UijkltEqns:append{
		dt_alpha_def,
		dt_gammaDelta_ll_def,
	}
end

UijkltEqns:append{
	dt_a_l_def,
	dt_dDelta_lll_def,
	dt_K_ll_def,
}

--[[
matrix of {α, Δγ_ij, a_k, Δd_kij, K_ij, Θ, Z_k} 
... gives us 0 x17, ±α√(γ^xx) x5
... and 4 extra waves:
	... for lapse f arbitrary:
		± α √(± 1/2 γ^xx √( (f - 1) (f - 5) ) + f + 1)
	... for lapse f=2/α:
		± √( α γ^xx (α + 1 ± 1/2 √( (α - 2) (5 α - 2) )))
seems these have some ugly wavespeeds
 so ... how do we change that?
--]]
if not eigensystem_dontIncludeZVars then
	UijkltEqns:insert(dt_Theta_def)
	UijkltEqns:insert(dt_Z_l_def)
end

if not eigensystem_dontIncludeShiftVars then
	if dt_beta_u_def then
		UijkltEqns:insert(dt_beta_u_def)
	end
	if dt_b_ul_def then
		UijkltEqns:insert(dt_b_ul_def)
	end
	if dt_B_u_def then
		UijkltEqns:insert(dt_B_u_def)
	end
end

local UijklVars = assertAndRemoveLastTensorIndex(	
	UijkltEqns:mapi(function(eqn) return eqn[1] end),
	TensorIndex{lower=true, symbol='t', derivative=','}
)

-- ijk on the partial_t's
-- pqm on the partial_x^r's

-- factor out the _,t from the lhs
local UijklMat = Matrix(UijklVars):T()

local U_defs = Matrix(UijkltEqns:mapi(function(eqn) 
	return eqn[2]:clone():simplifyAddMulDiv()
end)):T()

--printbr(UijklMat'_,t':eq(U_defs))
for _,eqn in ipairs(UijkltEqns) do
	printbr(eqn)
end
printbr()


local UpqmnVars = UijklVars:mapi(function(x) return x:reindex{ijkl='pqmn'} end)
local UpqmnrVars = UpqmnVars:mapi(function(x) return x'_,r'() end)

printHeader'inserting deltas to help factor linear system'

local rhsWithDeltas = UijkltEqns:mapi(function(eqn) 
	printbr('inserting deltas into '..eqn[1])
	return insertDeltasToSetIndexSymbols(eqn[2], UpqmnrVars)
end)

printHeader'as a balance law system:'

local A, b = factorLinearSystem(rhsWithDeltas, UpqmnrVars)

local dFijkl_dUpqmn_mat = (-A)()

local UpqmnMat = Matrix(UpqmnVars):T()

printbr((UijklMat'_,t' + dFijkl_dUpqmn_mat * UpqmnMat'_,r'):eq(b))
printbr()




-- [==[  if we want to redo but without the zeroes in the flux jacobian matrix
if favorFluxTerms then
	printHeader'replace first-derivative state variables with derivatives of state vars:'

	-- ok now try to replace all the hyperbolic 1st deriv state vars that are not derivatives themselves with the original vars' derivatives
	rhsWithDeltas = UijkltEqns:mapi(function(eqn)
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

	assert(#UijkltEqns == #rhsWithDeltas)
	for i,eqn in ipairs(UijkltEqns) do
		printbr(eqn[1]:eq(rhsWithDeltas[i]))
	end
	printbr()

	printHeader'replace squares of state var derivatives with state var times derivative state var:'
	
	-- TODO right here -- if there are any derivative-time-derivative terms
	--  replace them with state-var-times-derivative terms
	-- which to replace?  you could do symmetric, so alpha_,i beta^k_,j => 1/2 a_i beta^k_,j + 1/2 alpha_,i b^k_j
	rhsWithDeltas = rhsWithDeltas:mapi(function(expr)
		expr = expr:simplifyAddMulDiv()
		local newaddterms = table()
		for x in expr:iteradd() do
			if symmath.op.mul:isa(x) then
				-- find # of derivatives of state vars in this mul
				local derivTerms = table()
				local nonDerivTerms = table()
				
				local isTensorRef = TensorRef:isa(x)
				local tensorDegree
				if isTensorRef then
					tensorDegree = x:countNonDerivIndexes()
				end
				if isTensorRef 
				and x:hasDerivIndex()
				and (
					-- TODO a lot of these only appear in the specific degree
					
					-- these derivs can be replaced with state vars 
					(x[1] == alpha and tensorDegree == 0)
					or (x[1] == gammaDelta and tensorDegree == 2)
					or (x[1] == beta and tensorDegree == 1)
				
					--[[
					or (x[1] == a and tensorDegree == 1)
					or (x[1] == dDelta and tensorDegree == 3)
					or (x[1] == b and tensorDegree == 2)
					--]]
					
					-- these derivs don't have state vars 
					-- so if these are multiplied by derivs of alpha,beta^l,gammaDelta_ij
					-- then only replace the alpha=>a, beta=>b gammaDelta=>dDelta
					-- (don't divy up between the two)
					-- and if they are multipled by derivs of a_k,b^l_j,dDelta_kij,l
					-- then we're stuck ... gotta introduce new state vars for the new derivs?
					--[[
					or (x[1] == K and tensorDegree == 2)
					or (x[1] == Z and tensorDegree == 1)
					or (x[1] == Theta and tensorDegree == 0)
					or (x[1] == B and tensorDegree == 1)
					--]]
				)
				then
					derivTerms:insert(x)
				else
					nonDerivTerms:insert(x)
				end
				
				-- if there's more than 1 ...
				if #derivTerms < 2 then
					newaddterms:insert(x)
				elseif #derivTerms == 2 then
					local function replaceDerivsWithStateVars(z)
						return z
							:substIndex(a_l_def:switch())
							:substIndex(dDelta_lll_def:switch())
							:substIndex(b_ul_def:switch())
					end
					local newmul = frac(1,2) * (
						replaceDerivsWithStateVars(derivTerms[1]) * derivTerms[2]
						+ derivTerms[1] * replaceDerivsWithStateVars(derivTerms[2])
					)
					if #nonDerivTerms == 1 then
						newmul = newmul * nonDerivTerms[1]
					elseif #nonDerivTerms > 1 then
						newmul = newmul * nonDerivTerms:setmetatable(symmath.op.mul)
					end
					newaddterms:insert(newmul)
				else
					error"I didn't expect to find a mul of more than 2 deriv terms"
				end
			else
				newaddterms:insert(x)
			end
		end
		if #newaddterms == 1 then
			expr = newaddterms[1]
		else
			newaddterms:setmetatable(symmath.op.add)
			expr = newaddterms
		end
		return expr
	end)

	assert(#UijkltEqns == #rhsWithDeltas)
	for i,eqn in ipairs(UijkltEqns) do
		printbr(eqn[1]:eq(rhsWithDeltas[i]))
	end
	printbr()

	printHeader'inserting deltas to help factor linear system'

	rhsWithDeltas = rhsWithDeltas:mapi(function(rhs) 
		return insertDeltasToSetIndexSymbols(rhs, UpqmnrVars)
	end)

	assert(#UijkltEqns == #rhsWithDeltas)
	for i,eqn in ipairs(UijkltEqns) do
		printbr(eqn[1]:eq(rhsWithDeltas[i]))
	end
	printbr()

	printHeader'as a balance law system:'

	A, b = factorLinearSystem(rhsWithDeltas, UpqmnrVars)

	dFijkl_dUpqmn_mat = (-A)()

	for i=1,#b do
		b[i][1] = b[i][1]:simplifyAddMulDiv()
	end

	printbr((UijklMat'_,t' + dFijkl_dUpqmn_mat * UpqmnMat'_,r'):eq(b))
end
--]==]




--[=[
printbr[[$\frac{\partial F}{\partial U} \cdot U$:]]

printbr((dFijkl_dUpqmn_mat * UpqmnMat)())
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

local W = Matrix:lambda(dFijkl_dUpqmn_mat:dim(), function(i,j)
	return var('C_{'..i..j..'}')
end) * UpqmnMat	-- relabel U's to something other than ijk or mpq

local reigeqns = (dFijkl_dUpqmn_mat * W):eq(lambda * W)():unravel()
for _,eqn in ipairs(reigeqns) do 
	printbr(eqn:simplifyMetrics())
end
printbr()
--]]


printHeader'removing shift along diagonal, expanding, and removing zero rows/cols:'

-- only remove diagonal shift
dFijkl_dUpqmn_mat = dFijkl_dUpqmn_mat:replace(beta'^r', 0)()

--[[
TODO when considering shift, instead remove only shift along diagonal (for assumption of eigensystem with adjusted eigenvalues)
but this means, if there are no beta^x's along the diagonal of alpha_,t and gamma_ij,t, then we can't use this rule unless they also have zero rows (which they seem to)
--]]
if evaluateShiftlessEigensystem then
	dFijkl_dUpqmn_mat = dFijkl_dUpqmn_mat
		:replaceIndex(b'^i_j', 0)()
end



--[=[ ok this was a bad idea, to replace per-index, when indexes are symmetric
-- better idea: replace vars with dense tensors


-- [[ right eigenvectors in expanded form
local remapRows = table()
local numSrcRows = 0
local function addScalar()
	numSrcRows = numSrcRows + 1
	remapRows:insert{
		src = numSrcRows,
		map = {},
	}
end
local function addVector()
	numSrcRows = numSrcRows + 1
	for l=1,3 do
		remapRows:insert{
			src = numSrcRows,
			map = {l=xNames[l]},
		}
	end
end
local function addOneForm()
	numSrcRows = numSrcRows + 1
	for k=1,3 do
		remapRows:insert{
			src = numSrcRows,
			map = {k=xNames[k]},
		}
	end
end
local function addSym()
	numSrcRows = numSrcRows + 1
	for i=1,3 do
		for j=i,3 do
			remapRows:insert{
				src = numSrcRows,
				map = {i=xNames[i], j=xNames[j]},
			}
		end
	end
end
local function addOneBySym()
	numSrcRows = numSrcRows + 1
	for k=1,3 do
		for i=1,3 do
			for j=i,3 do
				remapRows:insert{
					src = numSrcRows,
					map = {i=xNames[i], j=xNames[j], k=xNames[k]},
				}
			end
		end
	end
end

for _,var in ipairs(UijklVars) do
	if Variable:isa(var) then
		addScalar()
	elseif TensorRef:isa(var) then
		assert(Variable:isa(var[1]))
		local numIndexes = #var-1
		if numIndexes == 1 then
			-- if it's lower then it's a_k or Z_k, if it's upper then it's b^l or B^l
			if var[2].lower then
				addOneForm()
			else
				addVector()
			end
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
local remapRowToCol = {p='i', q='j', m='k', n='l'}
local function expandMatrixIndexes(srcm)
	local srcsize = srcm:dim()
	assert(#srcsize == 2) 	-- matrixes only
	local dstsize = {}
	for i,v in ipairs(srcsize) do
		assert(v == 1 or v == numSrcRows)
		dstsize[i] = v == 1 and 1 or n
	end
	local dstm = Matrix:lambda(dstsize, function(i,j)
		local srci = srcsize[1] == 1 and 1 or remapRows[i].src		-- shouldn't be 1 ever
		local srcj = srcsize[2] == 1 and 1 or remapRows[j].src		-- only 1 for column vectors
		local srcexpr = srcm[srci][srcj]
		
		srcexpr = srcexpr:reindex{r='x'}						-- do this for the 1st direction, whatever that is.
		
		if srcsize[1] > 1 then
			srcexpr = srcexpr:reindex(remapRows[i].map)		-- remap ijkl to #s based on the map
		end
		if srcsize[2] > 1 then
			srcexpr = srcexpr:reindex(remapRowToCol)		-- remap pqmn to ijkl
			srcexpr = srcexpr:reindex(remapRows[j].map)		-- remap pqmn -> ijkl -> #s based on the map
		end
		-- replace deltas with their values
		srcexpr = srcexpr:map(function(x)
			if TensorRef:isa(x)
			and x[1] == delta
			then
				if ({x=true, y=true, z=true})[x[2].symbol] then
					return x[2].symbol == x[3].symbol and 1 or 0
				-- else if it's a matching letter then it's summed and return the spatial dimension
				end
			end
		end)
		
		--[[
		symmetrize #s in expanded gamma^ij's
		TODO this chokes when we are replacing it with fixed indexes
		especially when gamma^xk is multiplied by d_11k
		
		one solution? make fixed-indexes Variables with no TensorRef wrapper
		but that won't always work ...
		
		one solution: replace gamma's indexes first, then symmetrize gamma first
		then replace other tensor's indexes later
		--]]
		--[[
		srcexpr = srcexpr:symmetrizeIndexes(gamma, {1,2})
		--]]
		-- [[ instead only symmetrize the gamme alone
		srcexpr = srcexpr:map(function(x)
			if TensorRef:isa(x)
			and x[1] == gamma
			and x:countNonDerivIndexes() == 2
			then
				return x:symmetrizeIndexes(gamma, {1,2})
			end
		end)
		--]]
		
		-- done
		return srcexpr()
	end)
	return dstm
end

--[[
TODO how about inferring the expanding vars by looking at the combined linear system?
A * b
then look at each row of b vs each col of A, see what sum vars are common (all vs any?) and deduce expansion according to tensor degree
--]]
local dFijkl_dUpqmn_expanded = expandMatrixIndexes(dFijkl_dUpqmn_mat)
local Upqmn_expanded = expandMatrixIndexes(UijklMat)
local Uijkl_expanded = Upqmn_expanded:clone()
printbr(Uijkl_expanded'_,t' + dFijkl_dUpqmn_expanded * Upqmn_expanded'_,1')
printbr()

--]=]
-- [=[ better idea i hope:
Tensor.coords{
	{variables=xs},
}
local d_alphaDense = Tensor('_i', function(i) return alpha:diff(xs[i]) end)
local d_ThetaDense = Tensor('_i', function(i) return Theta:diff(xs[i]) end)
local deltaDenseUL = Tensor('^i_j', function(i,j) return i == j and 1 or 0 end)
local gammaDenseU = Tensor('^ij', function(i,j)
	if i > j then i,j = j,i end
	return var('\\gamma^{'..xNames[i]..xNames[j]..'}', txs)
end)
local aDense = Tensor('_k', function(k) return var('a_'..xNames[k], txs) end)
local ZDense = Tensor('_k', function(k) return var('Z_'..xNames[k], txs) end)
local dDeltaDense = Tensor('_kij', function(k,i,j)
	if i > j then i,j = j,i end
	return var('\\overset{\\Delta}{d}_{'..xNames[k]..xNames[i]..xNames[j]..'}', txs)
end)
local KDense = Tensor('_ij', function(i,j)
	if i > j then i,j = j,i end
	return var('K_{'..xNames[i]..xNames[j]..'}', txs)
end)

local function expandMatrixIndexes(A)
	return A
		:replaceIndex(alpha'_,i', d_alphaDense'_i')
		:replaceIndex(Theta'_,i', d_ThetaDense'_i')
		:replaceIndex(gamma'^ij', gammaDenseU'^ij')
		:replaceIndex(delta'^i_j', deltaDenseUL'^i_j')
		:replace(a, aDense)
		:replace(Z, ZDense)
		:replace(dDelta, dDeltaDense)
		:replace(K, KDense)
		-- any other terms? shift terms maybe?
end


-- combine UijklMat'_,t' + dFijkl_dUpqmn_mat * UpqmnMat'_,r' into a set of eqns
-- do derivative indexes not simplify into matrices? 
--local dFdx_lhs = (UijklMat'_,t' + dFijkl_dUpqmn_mat * UpqmnMat'_,r')()
local dFdx_lhs = (
	-- do we need U,t?  not unless you wanna add 't' as a diff var of all the tensor variables
	--Matrix:lambda(UijklMat:dim(), function(...) return (UijklMat[{...}]:diff(t))() end)
	--+ 
	dFijkl_dUpqmn_mat * 
	Matrix:lambda(UpqmnMat:dim(), function(...) return (UpqmnMat[{...}]'_,r')() end)
)()

local dUdt_lhs = Matrix:lambda(UijklMat:dim(), function(...) return (UijklMat[{...}]:diff(t))() end)
printbr(dUdt_lhs + dFdx_lhs)

local dFdx_lhs_dim = dFdx_lhs:dim()
assert(#dFdx_lhs_dim == 2 and dFdx_lhs_dim[2] == 1)
local dFdx_lhs_exprs = range(dFdx_lhs_dim[1]):mapi(function(i) return dFdx_lhs[i][1] end)
dFdx_lhs_exprs = dFdx_lhs_exprs:mapi(function(expr)
	return expandMatrixIndexes(expr)
end)

--[[ so Derivative doesn't distribution through Tensor's ...
local dUdt_lhs_exprs = range(dFdx_lhs_dim[1]):mapi(function(i) return dUdt_lhs[i][1] end)
dUdt_lhs_exprs = dUdt_lhs_exprs:mapi(function(expr) return expandMatrixIndexes(expr) end)
--]]
-- [[
local dUdt_lhs_exprs = range(dFdx_lhs_dim[1]):mapi(function(i) 
	local expr = expandMatrixIndexes(UijklMat[i][1])()
	if Tensor:isa(expr) then
		for i in expr:iter() do
			expr[i] = expr[i]:diff(t)
		end
	else
		expr = expr:diff(t)
	end
	return expr
end)
--]]

-- [[
printbr'expanding...'
for i=1,#dFdx_lhs_exprs do
	printbr(dUdt_lhs_exprs[i] + dFdx_lhs_exprs[i])
end
printbr()
--]]


for i=1,#dFdx_lhs_exprs do
	local dUdt_i = dUdt_lhs_exprs[i]
	local dFdx_i = dFdx_lhs_exprs[i]
	-- simplify
	dFdx_i  = dFdx_i()
	-- make sure the index storage between the two match up
	-- so that when i iterate between them i can match term for term
	if Tensor:isa(dFdx_i) then
		assert(Tensor:isa(dUdt_i))
		dFdx_i = dFdx_i:permute(' '..table.mapi(dUdt_i.variance, tostring):concat' ')
	else
		assert(not Tensor:isa(dUdt_i))
	end
	dFdx_lhs_exprs[i] = dFdx_i
end
-- [[
printbr'simplifying...'
for i=1,#dFdx_lhs_exprs do
	printbr(dUdt_lhs_exprs[i] + dFdx_lhs_exprs[i])
end
printbr()
--]]

dFdx_lhs_exprs = dFdx_lhs_exprs:mapi(function(expr)
	return expr:map(function(node)
		if Derivative:isa(node)
		and node[2] ~= x
		then
			return 0
		end
	end)()
end)
-- [[
printbr'only in one flux dimension...'
for i=1,#dFdx_lhs_exprs do
	printbr(dUdt_lhs_exprs[i] + dFdx_lhs_exprs[i])
end
printbr()
--]]

local dUdt_lhs_exprs_expanded = table()
local dFdx_lhs_exprs_expanded = table()
for i=1,#dFdx_lhs_exprs do
	local dUdt_i = dUdt_lhs_exprs[i]
	local dFdx_i = dFdx_lhs_exprs[i]
	if Tensor:isa(dFdx_i) then
		assert(Tensor:isa(dUdt_i))
		for j,x in dFdx_i:iter() do
			if not dUdt_lhs_exprs_expanded:find(dUdt_i[j]) then
				dFdx_lhs_exprs_expanded:insert(x)
				dUdt_lhs_exprs_expanded:insert(dUdt_i[j])
			end
		end
	else
		assert(not Tensor:isa(dUdt_i))
		dFdx_lhs_exprs_expanded:insert(dFdx_i)
		dUdt_lhs_exprs_expanded:insert(dUdt_i)
	end
end

local n = #dFdx_lhs_exprs_expanded
-- [[
printbr'unraveling...'
for i=1,n do
	printbr(dUdt_lhs_exprs_expanded[i] + dFdx_lhs_exprs_expanded[i])
end
printbr()
--]]

printbr'as linear system...'
local U_vars_expanded = dUdt_lhs_exprs_expanded:mapi(function(v)
	v = v:clone()
	assert(Derivative:isa(v) and Variable:isa(v[1]) and v[2] == t)
	return v[1]
end)
local dUdx_lhs_exprs_expanded = U_vars_expanded:mapi(function(var)
	return var:diff(x)
end)

local dFijkl_dUpqmn_expanded, dFijkl_dUpqmn_expanded_b = factorLinearSystem(dFdx_lhs_exprs_expanded, dUdx_lhs_exprs_expanded)

local Uijkl_expanded = Matrix(U_vars_expanded):T()
local Upqmn_expanded = Uijkl_expanded:clone()

printbr(Matrix(dUdt_lhs_exprs_expanded):T() + dFijkl_dUpqmn_expanded * Matrix(dUdx_lhs_exprs_expanded):T() + dFijkl_dUpqmn_expanded_b)
printbr()
--]=]




if removeZeroRows then
	printbr'removing zero rows:'
	-- remove all rows/cols that are all zeros
	local m = n
	for i=n,1,-1 do
		local allzero = true
		for j=1,m do
			if not Constant.isValue(dFijkl_dUpqmn_expanded[i][j], 0) then
				allzero = false
				break
			end
		end
		if allzero then
			table.remove(dFijkl_dUpqmn_expanded, i)
			table.remove(Uijkl_expanded, i)
			-- alright, here, if we are removing a row from Uijkl_expanded
			-- then we should also remove the same a row from Upqmn_expanded
			table.remove(Upqmn_expanded, i)
			-- then we should also remove the matching col from dFijkl_dUpqmn_expanded
			for k=1,#dFijkl_dUpqmn_expanded do
				table.remove(dFijkl_dUpqmn_expanded[k], i)
			end
			m = m - 1
			n = n - 1
		end
	end
	for j=m,1,-1 do
		local allzero = true
		for i=1,n do
			if not Constant.isValue(dFijkl_dUpqmn_expanded[i][j], 0) then
				allzero = false
				break
			end
		end
		if allzero then
			for i=1,n do
				table.remove(dFijkl_dUpqmn_expanded[i], j)
			end
			-- remove Upqmn expanded vars here as well
			table.remove(Upqmn_expanded, j)
			-- and TODO if we're removing cols from dFijkl_dUpqmn and rows from Upqmn
			-- then we should remove matching rows from Uijkl
			table.remove(Uijkl_expanded, j)
			-- and removing matching rows from dFijkl_dUpqmn
			table.remove(dFijkl_dUpqmn_expanded, j)
			m = m - 1
			n = n - 1
		end
	end
	printbr(Uijkl_expanded'_,t' + dFijkl_dUpqmn_expanded * Upqmn_expanded'_,1')
	-- TODO if this fails then that means we need find the removed rows from Upqmn and remove the associated columns from dFijkl_dUpqmn
	assert(m == n, "removed a different number of all-zero rows vs columns")
	printbr()
	--]]
end


do
	printHeader'non-zero terms, divided by alpha:'
	for i=1,n do
		local sep = ''
		for j=1,n do
			if not Constant.isValue(dFijkl_dUpqmn_expanded[i][j], 0) then
				print(sep, var('M_{'..(i-1)..','..(j-1)..'}'):eq((dFijkl_dUpqmn_expanded[i][j] / alpha)()))
				sep = ','
			end
		end
		if sep ~= '' then
			printbr()
		end
	end
	printbr()
end


printHeader'calculating charpoly'

local charpoly = dFijkl_dUpqmn_expanded:charpoly(lambda)
printbr(charpoly)


printHeader'finding lambdas'

--	table{Constant(0)}:rep(17),
--	table{alpha * sqrt(gamma'^xx')}:rep(5),
--	table{-alpha * sqrt(gamma'^xx')}:rep(5),

local lambdas = table()
assert(symmath.op.eq:isa(charpoly))
assert(Constant.isValue(charpoly[2], 0))
local x = charpoly[1]:clone()	-- only take the lhs

for _,root in ipairs{
	Constant(0),
	alpha * sqrt(gamma'^xx'),
	-alpha * sqrt(gamma'^xx'),
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
	lambdas:insert(soln[2])
	printbr('root', soln)
end
printbr()

--[[
local x = var'x'
charpoly = 
	(charpoly / lambda^17)()				-- 17 lambda=0 eigenvalues
--	:replace(gamma'^xx', var'a'/alpha^2)	-- a = gamma^xx alpha^2
	:replace(alpha, a)						-- a = alpha
	:replace(gamma'^xx', var'g')			-- g = gamma^xx
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
	* (lambda^2 - gamma'^xx' * alpha^2)^5
	* (lambda^2 - frac(1,2) * gamma'^xx' * alpha^2 * (-sqrt(f^2 - 6*f + 5) + f + 1))
	* (lambda^2 - frac(1,2) * gamma'^xx' * alpha^2 * ( sqrt(f^2 - 6*f + 5) + f + 1))
):eq(0)()
printbr('verify', (charpoly - recreated)())
--]]

--[[ for lapse f=-2/alpha
local recreated = (
	-lambda^17
	* (lambda^2 - gamma'^xx' * alpha^2)^5
	* (lambda^2 - frac(1,2) * gamma'^xx' * alpha^2 * (-sqrt(f^2 - 6*f + 5) + f + 1))
	* (lambda^2 - frac(1,2) * gamma'^xx' * alpha^2 * ( sqrt(f^2 - 6*f + 5) + f + 1))
):eq(0)()
printbr('verify', (charpoly - recreated)())
--]]

--[[
local x = var'x'
charpoly = 
	(charpoly / lambda^17)()
	:replace(gamma'^xx', a/alpha^2)	-- a = gamma^xx alpha^2
	:replace(lambda, sqrt(x))		-- x = lambda^2
	:simplify()
print(charpoly)
--]]

--[[
local lambdas = table():append(
	table{Constant(0)}:rep(17),
	table{alpha * sqrt(gamma'^xx')}:rep(5),
	table{-alpha * sqrt(gamma'^xx')}:rep(5),
	{
		 alpha * sqrt(frac(1,2) * gamma'^xx' * ( sqrt(f^2 - 6*f + 5) + f + 1)),
		 alpha * sqrt(frac(1,2) * gamma'^xx' * (-sqrt(f^2 - 6*f + 5) + f + 1)),
		-alpha * sqrt(frac(1,2) * gamma'^xx' * ( sqrt(f^2 - 6*f + 5) + f + 1)),
		-alpha * sqrt(frac(1,2) * gamma'^xx' * (-sqrt(f^2 - 6*f + 5) + f + 1)),
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

-- [=[
printHeader'calculating eigensystem'
_G.printbr = printbr	-- for Matrix.eigen verbose=true:
local eig = dFijkl_dUpqmn_expanded:eigen{
	lambdaVar = lambda,
	lambdas = lambdas,
--	verbose = true,
	dontCalcL = true,
}

printbr(var'\\Lambda':eq(eig.Lambda))
printbr()

printbr(var'R':eq(eig.R))
printbr()

eig.L = eig.R:inverse()

printbr(var'L':eq(eig.L))
printbr()
--]=]


-- DONE
printHeader()
io.stderr:write('TOTAL: '..(timer() - startTime)..'\n')
io.stderr:flush()
print(MathJax.footer)
