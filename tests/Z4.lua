#!/usr/bin/env luajit
--[[
Z4 equations, in index notation
rewritten in terms of first order hyperbolic coordinates
and for a general metric (i.e. difference-of-connections) instead of strictly for cartesian.
same idea as my 'BSSN - index' worksheet (why not just call it 'BSSN' ?)

in fact this is a lot like my 'numerical-relativity-codegen'
but runs a lot faster ... maybe it should replace it?
and it produces the tensor linear systems that my "Documents/Math/Numerical Relativity" notes have, which is nice



TODO TODO TODO
- canonical index sum form, where you lower the first sum indexes you find (and raise their matching sum indexes)
- better simplfiication of source terms



TODO NOTICE FIXME

This really confuses me
The flux has terms in it that, when the derivatives are distributed, the terms later get replaced with 1st-deriv-state-variables
so they end up in the source terms (rhs) instead of in the flux (lhs)
since part of the flux's distributed derivative terms end up on the rhs,
wouldn't this mean that the flux jacobian matrix times the state vector shouldn't equal the flux vector?

but our flux jacobian matrix output matches the 2008 flux jacobian matrix output
and separately (in numerical-relativity-codegen/verify_2008_yano.lua) I have verified that the 2008 yano flux jacobian matrix times the state vector does equal the flux vector.
soooo ...
what's going on?

maybe I should repeat that verification here, flux homogeneity, that the flux-jacobian-matrix times the state-vector equals the flux-vector?
that strongly hints at what I've wanted to do for a while:
extract the flux vector

but especially, which terms are getting moved to the RHS?
it is the derivatives of the gauge variables: alpha, gamma, and maybe beta
these are the variables whose derivatives do have state variables
hmm....

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
--local useShift = 'hyperbolicGammaDriver'
local useShift = 'minimalDistortionElliptic'

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

TODO notice that, if you do use shift, but you don't set this, then you will end up with b^l_k,r's in the rhs ... so you'll have derivs in the rhs
TODO also notice that setting this to false will break things right now.
... I think until I separate out the flux maybe?
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

--[[
whether to output the source term code generation
--]]
local outputSourceTerms = true


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
function printHeader(str)
	local thisTime = timer()
	io.stderr:write(' ... '..(thisTime-lastTime)..'s\n')
	lastTime = thisTime
	if str then
		io.stderr:write(str)
		printbr(str)
	end
	io.stderr:flush()
end

-- returns true if the var matches and the index raise/lower and derivatives all match
--  but doesn't care what the symbols are
function TensorRefIsMatchingIndexForm(a, b)
	local ta = Tensor.Ref:isa(a)
	local tb = Tensor.Ref:isa(b)
	if not ta and not tb then return true end
	if not ta ~= not tb then return false end
	local na = #a
	if na ~= #b then return false end
	if a[1] ~= b[1] then return false end	-- TODO should this function also verify that the vars match?
	for i=2,na do
		if not not a[i].lower ~= not not b[i].lower then return false end
		if a[i].derivative ~= b[i].derivative then return false end
	end
	return true
end

-- returns true if the var is the same, the length is the same, and the different derivs are the same
-- doesn't care about lowers
-- doesn't care about symbols
function TensorRefIsMatchingDegreeAndDeriv(a, b)
	assert(a)
	assert(b)
	local ta = Tensor.Ref:isa(a)
	local tb = Tensor.Ref:isa(b)
	if not ta and not tb then return true end
	if not ta ~= not tb then return false end
	local na = #a
	if na ~= #b then return false end
	if a[1] ~= b[1] then return false end	-- TODO should this function also verify that the vars match?
	for i=2,na do
		if a[i].derivative ~= b[i].derivative then return false end
	end
	return true
end

function tableToMul(t)
	if #t == 0 then return Constant(1) end
	if #t == 1 then return t[1] end
	return symmath.op.mul(table.unpack(t))
end

local function sum(t)
	if #t == 0 then return Constant(0) end
	if #t == 1 then return t[1] end
	return symmath.op.add(table.unpack(t))
end


--[[
look for instances of the TensorRef 'find', with matching lower/deriv
insert deltas to give it symbols matching 'find'

this goes orders of magnitude faster if it processes multiple finds at once
TODO maybe it wouldn't if it didn't rebuild every time, but only upon finding a needed var?  nah, still have to query term indexes as many times
--]]
function insertDeltasToSetIndexSymbols(expr, finds)
	for _,find in ipairs(finds) do
		assert(Tensor.Ref:isa(find))
	end
	local delta = Tensor:deltaSymbol()

	-- TODO maybe I don't need this constraint
	-- if I just make use of 'getIndexesUsed()'
	-- which I should do for other reasons
	expr = expr:simplifyAddMulDiv()

	local unusedSymbols = table(Tensor.defaultSymbols)
	local findSymbols = {}
	for _,find in ipairs(finds) do
		for i=2,#find do
			findSymbols[find[i].symbol] = true
			unusedSymbols:removeObject(find[i].symbol)
		end
	end

	local newaddterms = table()
	for x in expr:iteradd() do
--printbr('reindexing', x)
		local mulFixed, mulSum, mulExtra = x:getIndexesUsed()

		local unusedSymbols = table(unusedSymbols)
		for _,sym in ipairs(table():append(mulFixed, mulSum, mulExtra)) do
			unusedSymbols:removeObject(sym.symbol)
		end

		-- here, if any summed indexes in 'x' are also present in any of the 'find's in 'x'
		-- then reindex them to a new symbol
		--
		-- or the lazy way: just collect all the 'find' symbols
		-- and just avoid using those as sum symbols *here*
		local reindextable = {}
		for _,i in ipairs(mulSum) do
			if findSymbols[i.symbol] then
				reindextable[i.symbol] = unusedSymbols:remove(1)
			end
		end
		if next(reindextable) then
			x = x:reindex(reindextable)
			mulFixed, mulSum, mulExtra = x:getIndexesUsed()
		end
--printbr('after avoiding sum index collision:', x)

		local oldmulterms = table()
		for y in x:itermul() do
			oldmulterms:insert(y)
		end
		local foundIndexesInOldMulTerms = {}
		local count = 0
		for i,y in ipairs(oldmulterms) do
			for j,find in ipairs(finds) do
				if TensorRefIsMatchingDegreeAndDeriv(y,find) then
--printbr("found",y," as", find)
					foundIndexesInOldMulTerms[i] = j
					count = count + 1
				end
			end
		end
		-- ok now depending on the # ...
		-- if we have 0 then just carry it through as-is
		-- if we have 1 then turn that 1 into renames and deltas such that its indexes match the 'find'
		-- if we have more than 1 then for each, add a new fraction ...
		-- like if a_k is a find,
		-- and we have "a_i" then turn it into "delta^k_i a_k"
		-- but we have "a_i a_j" then turn it into "1/2 delta^k_i a_k a_j + 1/2 delta^k_j a_i a_k"
		if count == 0 then
			assert(not next(foundIndexesInOldMulTerms))
			newaddterms:insert(x)
		else
			for _,i in ipairs(table.keys(foundIndexesInOldMulTerms):sort()) do
				local j = foundIndexesInOldMulTerms[i]
				-- ok now oldmulterms[i] is our 'find'
				-- and finds[j] is our 'make it match this form'
				local find = finds[j]
--printbr("fixing",y," to be like", find)
				local m = table(oldmulterms)
				local y = m:remove(i)
				-- ok here, insert deltas for each index whose symbol or lower doesn't match
				for k=2,#find do
--printbr("checking "..find[k])
					if y[k].lower ~= find[k].lower then
--printbr("lower differs")
						assert(y[k].symbol ~= find[k].symbol)
						if find[k].lower then
							m:insert(i, gamma(' ^'..find[k].symbol..' ^'..y[k].symbol))
						else
							m:insert(i, gamma(' _'..find[k].symbol..' _'..y[k].symbol))
						end
						y = y:clone()
						y[k].lower = find[k].lower
						y[k].symbol = find[k].symbol
					else
--printbr("lower matches")
						if y[k].symbol == find[k].symbol then
--printbr("symbol matches")
							-- TODO if this symbol is a sum symbol in the product then
							-- then we have to 1) reindex the product BEFOREHAND
							-- and then 2) well, do it beforehand, and assert its done here
							assert(not mulSum:find(nil, function(i) return i.symbol == y[k].symbol end))
						else
--printbr("symbol doesn't match -- inserting delta")
							-- insert delta
							if find[k].lower then
								m:insert(i, delta(' ^'..find[k].symbol..' _'..y[k].symbol))
							else
								m:insert(i, delta(' ^'..y[k].symbol..' _'..find[k].symbol))
							end
							y = y:clone()
							y[k].lower = find[k].lower
							y[k].symbol = find[k].symbol
						end
					end
				end
				m:insert(i, y)
				if count > 1 then m:insert(1, frac(1,count)) end
				newaddterms:insert(tableToMul(m))
			end
		end
	end
	return sum(newaddterms)
end


function canonicalIndexSumForm(expr)

end


local delta = Tensor:deltaSymbol()


local binTermsByCommaDerivative_noDerivSymbol = ''
function binTermsByCommaDerivative(expr)
	local termsForDerivSymbol = {}
	for x in expr:iteradd() do
		local neg = symmath.op.unm:isa(x)
		if neg then
			x = x[1]
		end
		
		if Tensor.Ref:isa(x)
		and #x == 2
		and x[2].derivative == ','
		then
			local symbol = x[2].symbol
--printbr('found deriv', symbol, 'term', x[1])
			termsForDerivSymbol[symbol] = termsForDerivSymbol[symbol] or table()
			termsForDerivSymbol[symbol]:insert(neg and -x[1] or x[1])
		else
--printbr('found non-deriv term', x)
			local symbol = binTermsByCommaDerivative_noDerivSymbol
			termsForDerivSymbol[symbol] = termsForDerivSymbol[symbol] or table()
			termsForDerivSymbol[symbol]:insert(neg and -x or x)
		end
	end
	return termsForDerivSymbol
end

function combineCommaDerivatives(expr)
	local termsForDerivSymbol = binTermsByCommaDerivative(expr)
	local result = table()
	for symbol,terms in pairs(termsForDerivSymbol) do
		if symbol == binTermsByCommaDerivative_noDerivSymbol then
			result:insert(sum(terms))
		else
			result:insert(sum(terms)(' ,_'..symbol))
		end
	end
	return sum(result)
end

-- TODO the 'fixedsymbols' could be inferred if we just provided an eqn lhs that was a tensor
-- ... which is where this is used in most the time
function combineCommaDerivativesAndRelabel(expr, destsymbol, fixedsymbols)
	local termsForDerivSymbol = binTermsByCommaDerivative(expr)
	local nonDerivTerms = table()
	local derivTerms = table()
	for symbol,terms in pairs(termsForDerivSymbol) do
		if symbol == binTermsByCommaDerivative_noDerivSymbol then
			nonDerivTerms:insert(sum(terms))
		else
			if symbol == destsymbol then
				derivTerms:insert(sum(terms)(' ,_'..destsymbol))
			elseif table.find(fixedsymbols, symbol) then
				derivTerms:insert((sum(terms) * delta(' ^'..destsymbol..' _'..symbol) )(' ,_'..destsymbol))
			else
				derivTerms:insert(sum(terms):reindex{[symbol] = destsymbol}(' ,_'..destsymbol))
			end
		end
	end
	local derivSum = combineCommaDerivatives(sum(derivTerms))
	local nonDerivSum = sum(nonDerivTerms)
	return derivSum + nonDerivSum, derivSum, nonDerivSum
end



local e = var'e'

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
-- if our eigenvalues are sqrt(f gamma^xx) ... gamma^xx being >= 0 makes sense ... but if, for 1+log slicing, f=2/alpha ... then our alpha is constrained to being positive.  no charged, spinning black hole event horizon interiors.
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

-- C names for LaTeX variables:
Gamma:nameForExporter('C', 'conn')
rho:nameForExporter('C', 'rho')
alpha:nameForExporter('C', 'alpha')
beta:nameForExporter('C', 'beta')
gamma:nameForExporter('C', 'gamma')
gammaHat:nameForExporter('C', 'gammaHat')
gammaDelta:nameForExporter('C', 'gammaDelta')
Theta:nameForExporter('C', 'Theta')
dHat:nameForExporter('C', 'dHat')
dDelta:nameForExporter('C', 'dDelta')
-- eta?
-- lambda?

-- used for converting to dense tensor
local dt_dHat = var'\\partial_t \\hat{d}'
local dHat_t = var'\\hat{d}_t'
dt_dHat:nameForExporter('C', 'dt_dHat')
dHat_t:nameForExporter('C', 'dHat_t')





-- TODO store this information inside Variable/TensorRef?
-- TODO how about symmetries in derivatives?  i suppose that's obvious
-- but how about symmetries between deriv- and non-deriv- indexes?  like d_kij,l = d_lij,k
-- NOTICE lower'ness can be sorted as well ... but also notice if g_ij = g_ji then g^i_j != g_j^i, but g^ij = g^ji, so only sort it if the lower-ness is consistent (and if there's no derivatives after it? unless ofc it is deriv'd indexes)
local symmetries = table{
	{gamma'_ij', {1,2}},
	{gammaHat'_ij', {1,2}},
	{gammaDelta'_ij', {1,2}},
	{d'_ijk', {2,3}},
	{dHat'_ijk', {2,3}},
	{dDelta'_ijk', {2,3}},
	{dt_dHat'_ijk', {2,3}},
	{K'_ij', {1,2}},
	{S'_ij', {1,2}},
	{Gamma'_ijk', {2,3}},
	
	-- TODO derivatives automatic? otherwise there are a lot of permtuations ...
	{gamma'_ij,k', {1,2}},
	{gammaHat'_ij,k', {1,2}},
	{gammaDelta'_ij,k', {1,2}},
	{d'_ijk,l', {2,3}, {1,4}},
	{dHat'_ijk,l', {2,3}, {1,4}},
	{dDelta'_ijk,l', {2,3}, {1,4}},
	{dt_dHat'_ijk,l', {2,3}, {1,4}},
	{dHat_t'_ij', {1,2}},
	{dHat_t'_ij,k', {1,2}},
	{K'_ij,k', {1,2}},
}
-- TODO make this a property of the Variable wrt TensorRef (like :dependsOn does)
-- or make it a property of the TensorRef and remember to ctor/clone it
local function getSymmetriesForTensorRef(x)
	assert(Tensor.Ref:isa(x) and Variable:isa(x[1]))
	local _, t = symmetries:find(nil, function(t)
		return TensorRefIsMatchingDegreeAndDeriv(t[1], x)
	end)
	return t
end
-- modify 'x' in-place, rearrange its Tensor.Index'es
function applySymmetriesToIndexes(x)
	--[[
	if the variable matches, the size matches, and the derivs matches (ignore upper/lower) then ...
	TODO how about implicit for derivatives of tensors, like K_(ij) => K_(ij),k
	
	hmm this asks the question, should the symmetries also include deriv-only sets of indexes?
	how about deriv+non-deriv? (like d_kij,l == d_lij,k)
	--]]
	local t = getSymmetriesForTensorRef(x)
	if not t then return end
	local symindexes = t[2]
	-- assert all the sym indexes have matching lower and deriv~=nil
	-- but the lower doesn't have to match the 'find' TensorRef in 'symmetries'
	local index = x[1+symindexes[1]]
	local lower = not not index.lower
	local deriv = index.derivative
	local isolatedIndexes = table{index}
	for j=2,#symindexes do
		local index = x[1+symindexes[j]]
		if lower ~= not not index.lower then return end		-- the lowers of the symmetrized indexes don't match -- can't do anything more for this
		if deriv ~= index.dervative then return end			-- the derivatives don't match
		isolatedIndexes:insert(index)
	end
	local origx = x:clone()
	-- now sort
	isolatedIndexes:sort(function(a,b)
		if a.lower and not b.lower then return true end
		if not a.lower and b.lower then return false end
		return a.symbol < b.symbol
	end)
	-- now re-insert
	for j,i in ipairs(symindexes) do
		x[1+i] = isolatedIndexes[j]
	end
--printbr('applying symmetries from', origx, 'to', x)
end





-- for Expression:simplifyMetrics()
Tensor.metricVariable = gamma

--[==[ test case for insertDeltasToSetIndexSymbols
-- "do end" doesn't reduce the # of local vars, so...
function tmp()
	-- test case for
	local src = frac(1,2) * alpha * gamma'^mp' * dDelta'_mip,j'
	local result = insertDeltasToSetIndexSymbols(src, table{dDelta'_mpq,r'})
	printbr(result)
	os.exit()
end
tmp()
--]==]

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

printbr('using', d_gamma_lll_from_d_lll)
local d_gamma_uul_from_gamma_uu_d_lll = d_gamma_uul_from_gamma_uu_d_gamma_lll:substIndex(d_gamma_lll_from_d_lll)()
printbr(d_gamma_uul_from_gamma_uu_d_lll)

printbr('using', d_lll_from_dHat_lll_dDelta_lll)
local d_gamma_uul_from_dHat_lll_dDelta_lll = d_gamma_uul_from_gamma_uu_d_lll:substIndex(d_lll_from_dHat_lll_dDelta_lll)()
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

-- TODO should I push Tensor.Ref/Prune/evalDeriv earlier?
Tensor.Ref:pushRule'Prune/evalDeriv'

dt_a_l_def[2] = dt_a_l_def[2]:reindex{ij='mn'}
dt_a_l_def = dt_a_l_def
	:symmetrizeIndexes(a, {1,2}, true)
	:simplify()
printbr(dt_a_l_def)

-- combine first and simplify, so the next combine that separates flux and source will have simplified terms
dt_a_l_def[2] = combineCommaDerivatives(dt_a_l_def[2])()
printbr(dt_a_l_def)

-- combine and insert deltas and relabel all derivs to _,r
dt_a_l_def[2], dt_a_l_negflux, dt_a_l_rhs = combineCommaDerivativesAndRelabel(dt_a_l_def[2], 'r', {'k'})
printbr(dt_a_l_def)
printbr(a'_k,t', 'flux term:', -dt_a_l_negflux)
printbr(a'_k,t', 'source term:', dt_a_l_rhs)

Tensor.Ref:popRule'Prune/evalDeriv'

printbr('expanding rhs derivative')
dt_a_l_def = dt_a_l_def()
printbr(dt_a_l_def)

local using = delta'^r_k,r':eq(0)
printbr('using', using)
dt_a_l_def = dt_a_l_def
	:subst(using)
	:simplifyMetrics({
		Expression.simplifyMetricMulRules.delta,	-- only simplify deltas, don't raise/lower
	})
	:simplifyAddMulDiv()
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

local using = d_gamma_uul_from_gamma_uu_d_gamma_lll:reindex{ijlm='mnpq'}
printbr('using', using)
dt_a_l_def = dt_a_l_def:subst(using)()
printbr(dt_a_l_def)

local using = a'_i,k':eq(a'_k,i')
printbr('using', using)
dt_a_l_def = dt_a_l_def:subst(using)
printbr(dt_a_l_def)

local using = f'_,k':eq(f:diff(alpha) * alpha'_,k')
printbr('using', using)
dt_a_l_def = dt_a_l_def:subst(using)
printbr(dt_a_l_def)

--[[ this is a cheap way of fixing the insert-deltas stuff
-- but TODO I have two of these terms ... which cancel ... so do I really want this here?
-- the insert-beta stuff is done before the expanding rhs ...
-- DON'T DELETE THIS JUST YET.  I think it is useful when including gauge vars. unless I already take care of this case later when inserting deltas for all terms.
dt_a_l_def = dt_a_l_def
	:replace(beta'^m_,m', beta'^m_,l' * delta'^l_m')
	:replace(b'^m_m', b'^m_l' * delta'^l_m')
	:simplify()
printbr(dt_a_l_def)
--]]

--[[
NOTICE you can only do this *after* expanding, because then the derivatives get their unique indexes,
and any substitutions we do (without :splitOffDerivIndexes()) will only affect the non-derivatives
which will only affect the source terms (and not the flux terms)

if we aren't using gauge vars in flux
then turn all the gauge var derivatives into 1st-deriv state vars

TODO instead of replacing the most-concise vars for the least, then differentiating, then replacing the least-concise with the most-
how about just doing the replacing in the flux part of the PDE?
since that is the only part that is differentiated
--]]
if eigensystem_dontIncludeGaugeVars then
	printbr('using', d_alpha_l_from_a_l)
	dt_a_l_def = dt_a_l_def:substIndex(d_alpha_l_from_a_l)()
	printbr(dt_a_l_def)

	printbr('using', d_beta_ul_from_b_ul)
	dt_a_l_def = dt_a_l_def:substIndex(d_beta_ul_from_b_ul)
		:replace(b'^r_r', b'^m_m')
		:simplify()
	printbr(dt_a_l_def)
	
	printbr('using', d_gamma_lll_from_d_lll)
	dt_a_l_def = dt_a_l_def:substIndex(d_gamma_lll_from_d_lll)()
	printbr(dt_a_l_def)

	local using = (K'_mn' * gamma'^mn'):eq(K)
	printbr('using', using)
	dt_a_l_def = dt_a_l_def:subst(using)	-- hmm, substIndex and sum indexes on the lhs has trouble ...
	printbr(dt_a_l_def)

	local using = (K'_mn' * gamma'^pm' * gamma'^qn'):eq(K'^pq')
	printbr('using', using)
	dt_a_l_def = dt_a_l_def:subst(using)
	printbr(dt_a_l_def)
end

printbr'symmetrizing indexes'
dt_a_l_def = dt_a_l_def
	:symmetrizeIndexes(K, {1,2})
	:symmetrizeIndexes(gamma, {1,2})
	:symmetrizeIndexes(d, {2,3})
	:simplifyAddMulDiv()
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

local dt_gammaDelta_ll_from_dDelta_lll_dHat_lll = dt_gammaDelta_ll_def:clone()

--[[
assuming nobody is using this,
then convert its state vars into most compact form
but I see dt_dDelta_lll_def is using this
or equivalently
just use the original dt_gamma_ll_def, and only subst the lhs and then solve for gammaDelta_ij
...
now if we are including gauge vars (tho ironically this is in the "dont" cond so rethink this)
then we can make our rhs a bit smaller
but don't do this for what is substituted into the dDelta_ijk,t
--]]
if eigensystem_dontIncludeGaugeVars then
	local usings = table{
		gamma_ll_from_gammaHat_ll_gammaDelta_ll:solve(gammaHat'_ij'),
		-- only replace the dDelta_kij, don't replace the dHat_tij
		d_lll_from_dHat_lll_dDelta_lll:solve(dDelta'_kij'),
	}
	printbr('using', usings:mapi(tostring):concat';')
	dt_gammaDelta_ll_def = dt_gammaDelta_ll_def:substIndex(usings:unpack())()
	printbr(dt_gammaDelta_ll_def)
end

printbr()


printHeader'metric partial delta evolution:'

--[[
local dt_dDelta_lll_def = dt_gammaDelta_ll_def:reindex{k='l'}'_,k'
printbr(dt_dDelta_lll_def)
--]]
-- [[
local dt_dDelta_lll_def = dt_gammaDelta_ll_from_dDelta_lll_dHat_lll :reindex{k='l'}
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

Tensor.Ref:pushRule'Prune/evalDeriv'
dt_dDelta_lll_def = dt_dDelta_lll_def()
printbr(dt_dDelta_lll_def)

dt_dDelta_lll_def[2] = combineCommaDerivatives(dt_dDelta_lll_def[2])()
printbr(dt_dDelta_lll_def)

dt_dDelta_lll_def[2], dt_dDelta_lll_negflux, dt_dDelta_lll_rhs = combineCommaDerivativesAndRelabel(dt_dDelta_lll_def[2], 'r', {'i', 'j', 'k'})
printbr(dt_dDelta_lll_def)
printbr(dDelta'_kij,t', 'flux term:', -dt_dDelta_lll_negflux)
printbr(dDelta'_kij,t', 'source term:', dt_dDelta_lll_rhs)

Tensor.Ref:popRule'Prune/evalDeriv'

printbr'expanding rhs derivative'
dt_dDelta_lll_def = dt_dDelta_lll_def()
printbr(dt_dDelta_lll_def)

local using = delta'^r_k,r':eq(0)
printbr('using', using)
dt_dDelta_lll_def = dt_dDelta_lll_def
	:subst(using)
	:simplifyMetrics({
		Expression.simplifyMetricMulRules.delta,	-- only simplify deltas, don't raise/lower
	})
	:simplifyAddMulDiv()
printbr(dt_dDelta_lll_def)

local using = dDelta'_lij,k':eq(dDelta'_kij,l')
printbr('using', using)
dt_dDelta_lll_def = dt_dDelta_lll_def:subst(using)
printbr(dt_dDelta_lll_def)

--[[ this is a cheap way of fixing the insert-deltas stuff
-- TODO Maybe it is only needed for including gauge vars?
dt_dDelta_lll_def = dt_dDelta_lll_def
	:replace(beta'^l_,l', beta'^l_,n' * delta'^n_l')
	:replace(b'^l_l', b'^l_n' * delta'^n_l')
printbr(dt_dDelta_lll_def)
--]]

-- if we aren't using gauge vars in flux
-- then turn all the gauge var derivatives into 1st-deriv state vars
if eigensystem_dontIncludeGaugeVars then
	printbr('using', d_alpha_l_from_a_l)
	dt_dDelta_lll_def = dt_dDelta_lll_def:substIndex(d_alpha_l_from_a_l)()
	printbr(dt_dDelta_lll_def)

	printbr('using', d_beta_ul_from_b_ul)
	dt_dDelta_lll_def = dt_dDelta_lll_def
		:substIndex(d_beta_ul_from_b_ul)
	:replace(b'^r_r', b'^l_l')
		:simplify()
	printbr(dt_dDelta_lll_def)
	
	printbr('using', d_gammaDelta_lll_from_dDelta_lll, ';', d_gammaHat_lll_from_dHat_lll)
	dt_dDelta_lll_def = dt_dDelta_lll_def
		:replace(gammaDelta'_ij,tk', gammaDelta'_ij,k''_,t')
		:replace(gammaHat'_ij,tk', gammaHat'_ij,k''_,t')
		:substIndex(d_gammaDelta_lll_from_dDelta_lll, d_gammaHat_lll_from_dHat_lll)
		:simplify()
	printbr(dt_dDelta_lll_def)

	-- ok now only replace non-derivs of gammaHat+gammaDelta => gamma and dHat+dDelta => d
	local usings = table{
		gamma_ll_from_gammaHat_ll_gammaDelta_ll:solve(gammaHat'_ij'),
		-- only replace the dDelta_kij, don't replace the dHat_tij
		d_lll_from_dHat_lll_dDelta_lll:solve(dDelta'_kij'),
	}
	printbr('using', usings:mapi(tostring):concat';')
	dt_dDelta_lll_def = dt_dDelta_lll_def:substIndex(usings:unpack())()
	printbr(dt_dDelta_lll_def)
end

printbr'symmetrizing indexes'
dt_dDelta_lll_def = dt_dDelta_lll_def
	:symmetrizeIndexes(K, {1,2})
	:symmetrizeIndexes(gamma, {1,2})
	:symmetrizeIndexes(d, {2,3})
	:symmetrizeIndexes(dDelta, {2,3})
	:symmetrizeIndexes(dHat, {2,3})
	:simplifyAddMulDiv()
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
local Ricci_ll_from_conn_ull = Ricci_ll_from_Riemann_ulll:subst(Riemann_ulll_def:reindex{ijkl='kikj'})
printbr(Ricci_ll_from_conn_ull)

printbr('using', conn_ull_from_gamma_uu_d_lll)
local Ricci_ll_from_d_lll = Ricci_ll_from_conn_ull
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
printbr'cancel terms using symmetries:'
Ricci_ll_from_d_lll = Ricci_ll_from_d_lll:replace(
	gamma'^kl' * (d'_mlk' + d'_klm' - d'_lmk')(),
	gamma'^kl' * d'_mlk'
)
Ricci_ll_from_d_lll = Ricci_ll_from_d_lll:replace(
	gamma'^km' * (d'_imk' + d'_kmi' - d'_mik')(),
	gamma'^km' * d'_imk'
)
printbr(Ricci_ll_from_d_lll)

printbr'split off terms to rearrange gradient:'
local Ricci_ll_def = Ricci_ll_from_d_lll
	--[[
	what we have:
		(d_ji^k + d_ij^k - d^k_ij)_,k
		= d_ji^k_,k + d_ij^k_,k - d^k_ij,k
	what we want:
		= (1/2 d_ji^k + 1/2 d_ij^k - d^k_ij)_,k + 1/2 d_ki^k_,j + 1/2 d_kj^k_,i
	
	TODO bake this into R_ij instead of here, so Theta can use it too
	
	--]]
	:replace(
		(gamma'^km' * (d'_imj' + d'_jmi' - d'_mij'))()'_,k',
		-- TODO instead of 1/2 , use the xi parameter
		-- try to use sum terms that the block linear system will use, or it will screw things up
		(gamma'^kl' * (frac(1,2) * d'_ilj' + frac(1,2) * d'_jli' - d'_lij'))'_,k'
		+ (
			gamma'^kl_,k' * (frac(1,2) * d'_ijl' + frac(1,2) * d'_jil')
			+ (gamma'^mp' * (frac(1,2) * d'_mpj' * delta'^k_i' + frac(1,2) * d'_mpi' * delta'^k_j'))'_,k'
			- gamma'^mp_,k' * (frac(1,2) * d'_mpj' * delta'^k_i' + frac(1,2) * d'_mpi' * delta'^k_j')
		)
	)
	
	:replace(
		(gamma'^km' * d'_imk')'_,j',
		(frac(1,2) * gamma'^pq' * (d'_ipq' * delta'^k_j' + d'_jpq' * delta'^k_i'))'_,k'	-- use pq for the sake of the block linear system below
	)
printbr(Ricci_ll_def)

printbr('using', d_gamma_uul_from_gamma_uu_d_lll)
Ricci_ll_def = Ricci_ll_def:substIndex(d_gamma_uul_from_gamma_uu_d_lll)
printbr(Ricci_ll_def)

Ricci_ll_def:flatten()
printbr'combining derivatives'
Ricci_ll_def[2] = combineCommaDerivatives(Ricci_ll_def[2])
printbr(Ricci_ll_def)


--[=[
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
--]=]

printbr()


printHeader'Gaussian curvature'

local Gaussian_def = R:eq(gamma'^ij' * R'_ij')
printbr(Gaussian_def)

printbr'using Ricci definition'
Gaussian_def = Gaussian_def:subst(Ricci_ll_def)
printbr(Gaussian_def)


-- hmm, no better way to do this?
function mergingDerivKParts(expr)
-- [[
	expr = expr:map(function(x)
		if symmath.op.sub:isa(x) then
			assert(#x == 2)
			if Tensor.Ref:isa(x[2])
			and not Variable:isa(x[2][1])
			then
				x = x:clone()
				x[2][1] = -x[2][1]
				return x[1] + x[2]
			else
				return x[1] + -1 * x[2]
			end
		end
	
		if symmath.op.unm:isa(x) then
			assert(#x == 1)
			if Tensor.Ref:isa(x[1])
			and not Variable:isa(x[1][1])
			then
				x = x:clone()
				x[1][1] = -x[1][1]
				return x[1]
			else
				return -1 * x[1]
			end
		end

	end)
	expr:flatten()
--]]
	assert(symmath.op.add:isa(expr))
	for i=1,#expr do
		assert(not symmath.op.add:isa(expr[i]))
	end

	local nonderiv = table()
	local deriv = table()
	for x in expr:iteradd() do
		if Tensor.Ref:isa(x) then
			assert(#x == 2)
			assert(x[2] == Tensor.Index{symbol='k', lower=true, derivative=','})
			deriv:insert(x[1])
		else
			nonderiv:insert(x)
		end
	end
	
	return deriv, nonderiv
end



local _, deriv, nonderiv
--_, deriv, nonderiv = combineCommaDerivativesAndRelabel(Ricci_ll_def[2], 'k', {'i', 'j'})
deriv, nonderiv = mergingDerivKParts(Ricci_ll_def[2])
Gaussian_def = Gaussian_def[1]:eq(
	(gamma'^ij' * sum(deriv))'_,k'
	- gamma'^ij_,k' * sum(deriv)
	+ sum(nonderiv:mapi(function(x)
		return gamma'^ij' * x
	end))
)
printbr(Gaussian_def)

Gaussian_def = Gaussian_def:replace(
	(gamma'^ij' * (
		Constant(-1) * frac(1,2) * gamma'^pq' * (
			d'_ipq' * delta'^k_j'
			+ d'_jpq' * delta'^k_i'
		)
		+ gamma'^kl'* (
			frac(1,2) * d'_ilj'
			+ frac(1,2) * d'_jli'
			+ Constant(-1) * d'_lij'
		)
	)),
	gamma'^ij' * gamma'^kl' * (d'_ijl' - 2 * d'_lij')
)
printbr(Gaussian_def)

Gaussian_def = Gaussian_def:replace(
	gamma'^ij' * gamma'^mp' * (
		frac(1,2) * d'_mpj' * delta'^k_i'
		+ frac(1,2) * d'_mpi' * delta'^k_j'
	)'_,k',
	
	(gamma'^kl' * gamma'^ij' * d'_ijl')'_,k'
	- (gamma'^ij' * gamma'^mp')'_,k'() * (
		frac(1,2) * d'_mpj' * delta'^k_i'
		+ frac(1,2) * d'_mpi' * delta'^k_j'
	)
)
printbr(Gaussian_def)

printbr('using', d_gamma_uul_from_gamma_uu_d_lll)
Gaussian_def = Gaussian_def:substIndex(d_gamma_uul_from_gamma_uu_d_lll)
printbr(Gaussian_def)


--[[
gamma^ij (P_ij + (Q^k_ij)_,k)
= gamma^ij P_ij + gamma^ij (Q^k_ij)_,k
= gamma^ij P_ij + (gamma^ij Q^k_ij)_,k - gamma^ij_,k Q^k_ij
--]]
--_, deriv, nonderiv = combineCommaDerivativesAndRelabel(Gaussian_def[2], 'k', {})
deriv, nonderiv = mergingDerivKParts(Gaussian_def[2])
Gaussian_def = Gaussian_def[1]:eq(sum(deriv)()'_,k' + sum(nonderiv))
printbr(Gaussian_def)



--[[
printbr('merging derivatives')
Gaussian_def = Gaussian_def:replace(
	gamma'^mp' * (frac(1,2) * d'_mpj' * delta'^k_i' + frac(1,2) * d'_mpi' * delta'^k_j')'_,k',
	(gamma'^mp' * (frac(1,2) * d'_mpj' * delta'^k_i' + frac(1,2) * d'_mpi' * delta'^k_j'))'_,k'
	- gamma'^mp_,k' * (frac(1,2) * d'_mpj' * delta'^k_i' + frac(1,2) * d'_mpi' * delta'^k_j')
)
printbr(Gaussian_def)
--]]

--[[
printbr'tidying indexes'
Gaussian_def = Gaussian_def:tidyIndexes()()
	:reindex{abcdef='klmnpq'}
printbr(Gaussian_def)
--]]

--[[
printbr'symmetrizing indexes'
Gaussian_def = Gaussian_def
	:symmetrizeIndexes(dHat, {2,3})
	:symmetrizeIndexes(dHat, {1,4}, true)
	:symmetrizeIndexes(dDelta, {2,3})
	:symmetrizeIndexes(dDelta, {1,4}, true)
	:symmetrizeIndexes(gamma, {1,2})
	:simplify()
printbr(Gaussian_def)
--]]

--[[
printbr'tidying indexes'
Gaussian_def = Gaussian_def:tidyIndexes()()
printbr(Gaussian_def)
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
local using = alpha'_,ij':eq((frac(1,2) * (alpha'_,i' * delta'^k_j' + alpha'_,j' * delta'^k_i'):substIndex(d_alpha_l_from_a_l))'_,k')
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

printbr('using the definition of ', R'_ij')
--[[ old
dt_K_ll_def = dt_K_ll_def:subst(Ricci_ll_def)
--]]
-- ok now
-- of the R_ij def, part is _,k and part is not _,anything
-- so now I have to chagne the alpha * (...)_,k part into (alpha * (...))_,k - alpha a_k * (...)
-- [[ new
_, deriv, nonderiv = combineCommaDerivativesAndRelabel(Ricci_ll_def[2], 'k', {'i', 'j'})
assert(deriv[1]'_,k' == deriv)
dt_K_ll_def = dt_K_ll_def:replace(
	alpha * Ricci_ll_def[1],
	--alpha * (nonderiv + deriv)
	--alpha * (nonderiv + deriv[1]'_,k')
	--alpha * nonderiv + alpha * deriv[1]'_,k'
	alpha * nonderiv + (alpha * deriv[1])'_,k' - alpha * a'_k' * deriv[1]
)
--]]
printbr(dt_K_ll_def)

printbr'combining derivatives into flux:'
-- hmm, where does this go wrong?
dt_K_ll_def:flatten()
Tensor.Ref:pushRule'Prune/evalDeriv'
dt_K_ll_def[2] = combineCommaDerivatives(dt_K_ll_def[2])
Tensor.Ref:popRule'Prune/evalDeriv'
printbr(dt_K_ll_def)


local _, dt_K_ll_negflux, dt_K_ll_rhs = combineCommaDerivativesAndRelabel(dt_K_ll_def[2], 'r', {'i', 'j'})
printbr(K'_ij,t', '2008 Yano paper flux term:', -dt_K_ll_negflux)
printbr(K'_ij,t', '2008 Yano paper source term:', dt_K_ll_rhs)
printbr'the difference between these flux/source terms and the ones later is that the later ones use the separated background metric and partial metric terms'


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

--[[ doesn't help if we used the version of R_ij that already did this ...
printbr'tidying indexes'
dt_K_ll_def = dt_K_ll_def:tidyIndexes()()
printbr(dt_K_ll_def)

printbr'symmetrizing indexes'
dt_K_ll_def = dt_K_ll_def
	:symmetrizeIndexes(K, {1,2})
	:symmetrizeIndexes(gamma, {1,2})
	:symmetrizeIndexes(dHat, {2,3})
	:symmetrizeIndexes(dDelta, {2,3})
	:simplify()
printbr(dt_K_ll_def)
--]]

--[[
printbr('using the definition of ', R'_ij')
dt_K_ll_def = dt_K_ll_def:subst(Ricci_ll_def)
printbr(dt_K_ll_def)
--]]

dt_K_ll_def[2], dt_K_ll_negflux, dt_K_ll_rhs = combineCommaDerivativesAndRelabel(dt_K_ll_def[2], 'r', {'i', 'j'})
printbr(K'_ij,t', 'flux term:', -dt_K_ll_negflux)
printbr(K'_ij,t', 'source term:', dt_K_ll_rhs)

printbr'expanding rhs derivative'
dt_K_ll_def = dt_K_ll_def()
printbr(dt_K_ll_def)

local usings = table{delta'^r_i,r':eq(0), delta'^r_j,r':eq(0)}
printbr('using', usings:mapi(tostring):concat';')
dt_K_ll_def = dt_K_ll_def
	:subst(usings:unpack())
	:simplifyMetrics({
		Expression.simplifyMetricMulRules.delta,	-- only simplify deltas, don't raise/lower
	})
	:simplifyAddMulDiv()
printbr(dt_K_ll_def)

printbr('using', d_gamma_uul_from_gamma_uu_d_gamma_lll)
dt_K_ll_def = dt_K_ll_def:subst(
	d_gamma_uul_from_gamma_uu_d_gamma_lll:reindex{ijklm='pqjmn'},
	d_gamma_uul_from_gamma_uu_d_gamma_lll:reindex{ijklm='pqimn'},
	d_gamma_uul_from_gamma_uu_d_gamma_lll:reindex{ijklm='mpiqn'},
	d_gamma_uul_from_gamma_uu_d_gamma_lll:reindex{ijklm='mpjqn'},
	d_gamma_uul_from_gamma_uu_d_gamma_lll:reindex{ijklm='rlrmn'}
)()
printbr(dt_K_ll_def)

-- if we aren't using gauge vars in flux
-- then turn all the gauge var derivatives into 1st-deriv state vars
if eigensystem_dontIncludeGaugeVars then
	printbr('using', d_alpha_l_from_a_l)
	dt_K_ll_def = dt_K_ll_def
		:substIndex(d_alpha_l_from_a_l)
		:simplify()
	printbr(dt_K_ll_def)

	printbr('using', d_beta_ul_from_b_ul)
	dt_K_ll_def = dt_K_ll_def
		:substIndex(d_beta_ul_from_b_ul)
		:replace(b'^r_r', b'^k_k')
		:simplify()
	printbr(dt_K_ll_def)
	
	printbr('using', d_gamma_lll_from_d_lll)
	dt_K_ll_def = dt_K_ll_def:substIndex(d_gamma_lll_from_d_lll)()
	printbr(dt_K_ll_def)

	local usings = table{
		gamma_ll_from_gammaHat_ll_gammaDelta_ll:solve(gammaHat'_ij'),
		d_lll_from_dHat_lll_dDelta_lll:solve(dDelta'_kij'),
	}
	printbr('using', usings:mapi(tostring):concat';')
	dt_K_ll_def = dt_K_ll_def:substIndex(usings:unpack()):simplifyAddMulDiv()
	printbr(dt_K_ll_def)

	printbr'simplifying metrics...'
	dt_K_ll_def = dt_K_ll_def:simplifyMetrics():simplifyAddMulDiv()
	printbr(dt_K_ll_def)

	--[[ too bad this puts me in a place where its tough to reindex all the comma deriv indexes back to 'r' ...
	printbr'tidy indexes...'
	dt_K_ll_def = dt_K_ll_def
		-- t = time, r = spatial deriv for flux ...
		-- ... but for sum indexes, 'fixed' doesn't stop it from relabeling ... hmm .... TODO FIXME
		:tidyIndexes{fixed='tijr'}
		:simplifyAddMulDiv()
		:reindex{a='r'}
	printbr(dt_K_ll_def)
	--]]

	local usings = table{d'_b^br':eq(e'^r'), d'^r_b^b':eq(d'^r')}
	printbr('using', usings:mapi(tostring):concat';')
	dt_K_ll_def = dt_K_ll_def:substIndex(usings:unpack()):simplifyAddMulDiv()
	printbr(dt_K_ll_def)
end

printbr'symmetrizing indexes'
dt_K_ll_def = dt_K_ll_def
	:symmetrizeIndexes(K, {1,2})
	:symmetrizeIndexes(gamma, {1,2})
	:symmetrizeIndexes(d, {2,3})
	:symmetrizeIndexes(dHat, {2,3})
	:symmetrizeIndexes(dDelta, {2,3})
	:simplifyAddMulDiv()
printbr(dt_K_ll_def)

printbr()


printHeader[[Z4 $\Theta$ definition]]

-- TODO derive me plz from the original R_uv + 2 Z_(u;v) = 8 pi (T^TR)_uv
-- are you sure there's no beta^i's?
local dt_Theta_def = Theta'_,t':eq(
	
	(Theta * beta'^k')'_,k'
	
	+ (alpha * gamma'^kl' * Z'_l')'_,k'
	
	+ frac(1,2) * alpha * R
	
	- alpha * gamma'^kl_,k' * Z'_l'
	- 2 * gamma'^kl' * Z'_l' * alpha * a'_k'
	
	- alpha * gamma'^kl' * Gamma'^m_kl' * Z'_m'
	+ frac(1,2) * alpha * (
		  gamma'^kl' * K'_kl' * (gamma'^mn' * K'_mn' - 2 * Theta)
		- gamma'^kl' * gamma'^mn' * K'_km' * K'_ln'
		- 16 * pi * rho
	)
	
	- Theta * b'^k_k'
)
printbr(dt_Theta_def)

printbr('using', d_gamma_uul_from_gamma_uu_d_lll)
dt_Theta_def = dt_Theta_def:substIndex(d_gamma_uul_from_gamma_uu_d_lll)
printbr(dt_Theta_def)

printbr('using the definition of R')
--[[
dt_Theta_def = dt_Theta_def:subst(Gaussian_def)
--]]
--[[ breaking off deriv and non-deriv parts, and merging the alpha into the non-deriv part
deriv, nonderiv = mergingDerivKParts(Gaussian_def[2])
dt_Theta_def = dt_Theta_def:replace(
	alpha * Gaussian_def[1],
	
	(alpha * sum(deriv))'_,k'
	- alpha'_,k' * sum(deriv)
	+ alpha * sum(nonderiv)
)
--]]
-- [[
_, deriv, nonderiv = combineCommaDerivativesAndRelabel(Gaussian_def[2], 'k', {})
dt_Theta_def = dt_Theta_def:replace(
	frac(1,2) * alpha * Gaussian_def[1],
	--alpha * (nonderiv + deriv)
	--alpha * (nonderiv + deriv[1]'_,k')
	--alpha * nonderiv + alpha * deriv[1]'_,k'
	frac(1,2) * alpha * nonderiv + (frac(1,2) * alpha * deriv[1])'_,k' - frac(1,2) * alpha * a'_k' * deriv[1]
)
--]]
printbr(dt_Theta_def)

printbr'combining derivatives into flux:'
dt_Theta_def:flatten()
Tensor.Ref:pushRule'Prune/evalDeriv'
dt_Theta_def[2] = combineCommaDerivatives(dt_Theta_def[2])
printbr(dt_Theta_def)
Tensor.Ref:popRule'Prune/evalDeriv'


local dt_Theta_negflux, dt_Theta_rhs
_, dt_Theta_negflux, dt_Theta_rhs = combineCommaDerivativesAndRelabel(dt_Theta_def[2], 'r', {})
printbr(Theta'_,t', '2008 Yano paper flux term:', -dt_Theta_negflux)
printbr(Theta'_,t', '2008 Yano paper source term:', dt_Theta_rhs)
printbr'the difference between these flux/source terms and the ones later is that the later ones use the separated background metric and partial metric terms'


-- last in flux form

--[[
printbr('using', d_alpha_l_from_a_l)
dt_Theta_def = dt_Theta_def:substIndex(d_alpha_l_from_a_l)()
printbr(dt_Theta_def)

printbr('using', conn_ull_from_gamma_uu_dHat_lll_dDelta_lll)
dt_Theta_def = dt_Theta_def:subst(conn_ull_from_gamma_uu_dHat_lll_dDelta_lll:reindex{ijkm='mkln'})()
printbr(dt_Theta_def)
--]]

--[[
printbr'tidying indexes'
dt_Theta_def = dt_Theta_def:tidyIndexes()()
printbr(dt_Theta_def)
--]]


--[[
printbr'tidying indexes'
dt_Theta_def = dt_Theta_def:tidyIndexes()()
printbr(dt_Theta_def)
--]]

_, dt_Theta_negflux, dt_Theta_rhs = combineCommaDerivativesAndRelabel(dt_Theta_def[2], 'r', {})

printbr('using in flux only', d_lll_from_dHat_lll_dDelta_lll)
dt_Theta_negflux = dt_Theta_negflux:substIndex(d_lll_from_dHat_lll_dDelta_lll)
printbr(dt_Theta_negflux)
dt_Theta_def = dt_Theta_def[1]:eq(dt_Theta_negflux + dt_Theta_rhs)

printbr(Theta'_,t', 'flux term:', -dt_Theta_negflux)
printbr(Theta'_,t', 'source term:', dt_Theta_rhs)

printbr'expanding rhs derivative'
dt_Theta_def = dt_Theta_def()
printbr(dt_Theta_def)

printbr('using', delta'^i_j,k':eq(0))
dt_Theta_def = dt_Theta_def
	:subst(
		delta'^r_i,r':eq(0),
		delta'^r_j,r':eq(0),
		delta'^k_i,k':eq(0),
		delta'^k_j,k':eq(0)
	)
	:simplifyMetrics({
		Expression.simplifyMetricMulRules.delta,	-- only simplify deltas, don't raise/lower
	})
	:simplifyAddMulDiv()
printbr(dt_Theta_def)

printbr('using', d_gamma_uul_from_gamma_uu_d_gamma_lll)
dt_Theta_def = dt_Theta_def:subst(
	d_gamma_uul_from_gamma_uu_d_gamma_lll:reindex{ijklm='ijkno'},
	d_gamma_uul_from_gamma_uu_d_gamma_lll:reindex{ijklm='ijino'},
	d_gamma_uul_from_gamma_uu_d_gamma_lll:reindex{ijklm='ijjno'},
	d_gamma_uul_from_gamma_uu_d_gamma_lll:reindex{ijklm='mpino'},
	d_gamma_uul_from_gamma_uu_d_gamma_lll:reindex{ijklm='mpjno'},
	d_gamma_uul_from_gamma_uu_d_gamma_lll:reindex{ijklm='pqjno'},
	d_gamma_uul_from_gamma_uu_d_gamma_lll:reindex{ijklm='pqino'},
	d_gamma_uul_from_gamma_uu_d_gamma_lll:reindex{ijklm='klkno'},
	d_gamma_uul_from_gamma_uu_d_gamma_lll:reindex{ijklm='rlrno'},
	d_gamma_uul_from_gamma_uu_d_gamma_lll:reindex{ijklm='ijrno'}
)()
printbr(dt_Theta_def)

if eigensystem_dontIncludeGaugeVars then
	printbr('using', d_alpha_l_from_a_l)
	dt_Theta_def = dt_Theta_def:substIndex(d_alpha_l_from_a_l)()
	printbr(dt_Theta_def)

	printbr('using', d_beta_ul_from_b_ul)
	dt_Theta_def = dt_Theta_def
		:substIndex(d_beta_ul_from_b_ul)
		:replace(b'^r_r', b'^k_k')
		:simplify()
	printbr(dt_Theta_def)
	
	printbr('using', d_gamma_lll_from_d_lll)
	dt_Theta_def = dt_Theta_def:substIndex(d_gamma_lll_from_d_lll)()
	printbr(dt_Theta_def)

	dt_Theta_def = dt_Theta_def
		:symmetrizeIndexes(dHat, {2,3})
		:symmetrizeIndexes(dDelta, {2,3})
		:simplify()
	printbr(dt_Theta_def)

	local usings = table{
		gamma_ll_from_gammaHat_ll_gammaDelta_ll:solve(gammaHat'_ij'),
		d_lll_from_dHat_lll_dDelta_lll:solve(dDelta'_kij'),
	}
	printbr('using', usings:mapi(tostring):concat';')
	dt_Theta_def = dt_Theta_def:substIndex(usings:unpack()):simplifyAddMulDiv()
	printbr(dt_Theta_def)
	
	--[[ too bad this puts me in a place where its tough to reindex all the comma deriv indexes back to 'r' ...
	printbr'tidy indexes...'
	dt_Theta_def = dt_Theta_def
		-- t = time, r = spatial deriv for flux
		-- ... but for sum indexes, 'fixed' doesn't stop it from relabeling ... hmm .... TODO FIXME
		:tidyIndexes{fixed='tr'}
		:simplifyAddMulDiv()
		:reindex{a='r'}
	printbr(dt_Theta_def)
	--]]

	printbr'simplifying metrics...'
	dt_Theta_def = dt_Theta_def:simplifyMetrics():simplifyAddMulDiv()
	printbr(dt_Theta_def)
end

printbr'symmetrizing indexes'
dt_Theta_def = dt_Theta_def
	:symmetrizeIndexes(K, {1,2})
	:symmetrizeIndexes(gamma, {1,2})
	:symmetrizeIndexes(d, {2,3})
	:symmetrizeIndexes(dHat, {2,3})
	:symmetrizeIndexes(dDelta, {2,3})
	:simplify()
printbr(dt_Theta_def)

function simplifyDAndKTraces(expr)
	return expr:map(function(x)
		if Tensor.Ref:isa(x) then
			if x[1] == d and #x == 4 then
				assert(not x[1].derivative)
				assert(not x[2].derivative)
				assert(not x[3].derivative)
				if x[2].symbol == x[3].symbol then
					assert((not not x[2].lower) ~= (not not x[3].lower))
					return Tensor.Ref(e, x[4])
				elseif x[2].symbol == x[4].symbol then
					assert((not not x[2].lower) ~= (not not x[4].lower))
					return Tensor.Ref(e, x[3])
				elseif x[3].symbol == x[4].symbol then
					assert((not not x[3].lower) ~= (not not x[4].lower))
					return Tensor.Ref(d, x[2])
				end
			end
			if x[1] == K and #x == 3 then
				if x[2].symbol == x[3].symbol then
					assert((not not x[2].lower) ~= (not not x[3].lower))
					assert(not x[2].derivative)
					assert(not x[3].derivative)
					return K
				end
			end
		end
	end)
end

if eigensystem_dontIncludeGaugeVars then
	-- [[ TODO fix replaceIndex ... why doesn't this work?
	dt_Theta_def = simplifyDAndKTraces(dt_Theta_def):simplifyAddMulDiv()
	--]]
	printbr(dt_Theta_def)

	--[[ too bad this puts me in a place where its tough to reindex all the comma deriv indexes back to 'r' ...
	printbr'tidy indexes...'
	dt_Theta_def = dt_Theta_def
		-- t = time, r = spatial deriv for flux
		-- ... but for sum indexes, 'fixed' doesn't stop it from relabeling ... hmm .... TODO FIXME
		:tidyIndexes{fixed='tr'}
		:simplifyAddMulDiv()
		:reindex{a='r'}
	printbr(dt_Theta_def)
	--]]
end

printbr()


printHeader[[Z4 $Z_k$ definition]]

--[[
TODO derive me plz

are you sure there's no beta^i's?

2005 Bona p.61 eqn.3.85
Z_k,t = Z_k,l β^l
	+ Z_l β^l_,k
	+ α (
		γ^lm (
			K_kl,m
			- Γ^n_km K_nl
			- Γ^n_lm K_kn
		)
		- (K_mn γ^mn)_,k
		+ Θ_,k
		- 2 γ^lm K_kl Z_m
		- 8 π S_k
	)
	- Θ α_,k

2008 Yano shows:
Z_i,t + (
		-β^k Z_i
		+ α (
			-K^k_i
			+ δ^k_i (K - Θ)
		)
	)_,k
	= S(Z_i)
--]]
--[[
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
--]]
--[[
reconciling the two:
2005 Bona et al A.2:
Z_k,t
	+ (
		-β^r Z_k
		+ α (
			- γ^rl K_kl
			+ δ^r_k (K_mn γ^mn - Θ)
		)
	)_,r
	=
	+ α (
		+ a_k (K_mn γ^mn - 2 Θ)
		+ K_kl γ^lm (
			- a_m
			+ d_mpq γ^pq
			- 2 Z_m
		)
		- γ^mp γ^nq K_mn d_kpq
		- 8 π S_k
	)
	+ Z_l b^l_k
	- Z_k b^l_l
--]]
-- [[
local dt_Z_l_def = Z'_k,t':eq(
	- (
		-beta'^r' * Z'_k'
		+ alpha * (
			- gamma'^rl' * K'_kl'
			+ delta'^r_k' * (K'_mn' * gamma'^mn' - Theta)
		)
	)'_,r'
	+ alpha * (
		  a'_k' * (K'_mn' * gamma'^mn' - 2 * Theta)
		+ K'_kl' * gamma'^lm' * (
			- a'_m'
			+ d'_mpq' * gamma'^pq'
			- 2 * Z'_m'
		)
		- gamma'^mp' * gamma'^nq' * K'_mn' * d'_kpq'
		- 8 * pi * S'_k'
	)
	+ Z'_l' * b'^l_k'
	- Z'_k' * b'^l_l'
)
--]]
printbr(dt_Z_l_def)

dt_Z_l_def:flatten()
Tensor.Ref:pushRule'Prune/evalDeriv'
dt_Z_l_def[2] = combineCommaDerivatives(dt_Z_l_def[2])
Tensor.Ref:popRule'Prune/evalDeriv'
printbr(dt_Z_l_def)


local _, dt_Z_l_negflux, dt_Z_l_rhs = combineCommaDerivativesAndRelabel(dt_Z_l_def[2], 'r', {'k'})
printbr(Z'_k,t', '2008 Yano paper flux term:', -dt_Z_l_negflux)
printbr(Z'_k,t', '2008 Yano paper source term:', dt_Z_l_rhs)
printbr'the difference between these flux/source terms and the ones later is that the later ones use the separated background metric and partial metric terms'

--[[ doesn't help
printbr'tidying indexes'
dt_Z_l_def = dt_Z_l_def:tidyIndexes()()
printbr(dt_Z_l_def)
--]]

printbr('using', d_gamma_uul_from_gamma_uu_d_lll)
dt_Z_l_def = dt_Z_l_def:substIndex(d_gamma_uul_from_gamma_uu_d_lll)
printbr(dt_Z_l_def)

local _, dt_Z_l_negflux, dt_Z_l_rhs = combineCommaDerivativesAndRelabel(dt_Z_l_def[2], 'r', {'k'})
printbr(Z'_k,t', 'flux term:', -dt_Z_l_negflux)
printbr(Z'_k,t', 'source term:', dt_Z_l_rhs)

printbr('expanding rhs derivative')
dt_Z_l_def = dt_Z_l_def()
printbr(dt_Z_l_def)

local using = delta'^r_k,r':eq(0)
printbr('using', using)
dt_Z_l_def = dt_Z_l_def
	:subst(using)
	:simplifyMetrics({
		Expression.simplifyMetricMulRules.delta,	-- only simplify deltas, don't raise/lower
	})
	:simplifyAddMulDiv()
printbr(dt_Z_l_def)

printbr('using', d_gamma_uul_from_gamma_uu_d_gamma_lll)
dt_Z_l_def = dt_Z_l_def:subst(
	d_gamma_uul_from_gamma_uu_d_gamma_lll:reindex{ijklm='rlrpq'},
	d_gamma_uul_from_gamma_uu_d_gamma_lll:reindex{ijklm='mnkpq'}
)()
printbr(dt_Z_l_def)

-- if we aren't using gauge vars in flux
-- then turn all the gauge var derivatives into 1st-deriv state vars
if eigensystem_dontIncludeGaugeVars then
	printbr('using', d_alpha_l_from_a_l)
	dt_Z_l_def = dt_Z_l_def:substIndex(d_alpha_l_from_a_l)()
	printbr(dt_Z_l_def)

	printbr('using', d_beta_ul_from_b_ul)
	dt_Z_l_def = dt_Z_l_def
		:substIndex(d_beta_ul_from_b_ul)
		:replace(b'^r_r', b'^k_k')
		:replace(b'^l_l', b'^k_k')
		:simplify()
	printbr(dt_Z_l_def)
	
	printbr('using', d_gamma_lll_from_d_lll)
	dt_Z_l_def = dt_Z_l_def:substIndex(d_gamma_lll_from_d_lll)()
	printbr(dt_Z_l_def)

	--[[ too bad this puts me in a place where its tough to reindex all the comma deriv indexes back to 'r' ...
	printbr'tidy indexes...'
	dt_Z_l_def = dt_Z_l_def
		-- t = time, r = spatial deriv for flux
		-- ... but for sum indexes, 'fixed' doesn't stop it from relabeling ... hmm .... TODO FIXME
		:tidyIndexes{fixed='tr'}
		:simplifyAddMulDiv()
		:reindex{a='r'}
	printbr(dt_Z_l_def)
	--]]

	printbr'simplifying metrics...'
	dt_Z_l_def = dt_Z_l_def:simplifyMetrics():simplifyAddMulDiv()
	printbr(dt_Z_l_def)

	dt_Z_l_def = dt_Z_l_def
		:replace(a'^b' * K'_kb', a'^a' * K'_ak')
		:replace(a'_a' * K'_k^a', a'^a' * K'_ak')
	dt_Z_l_def = simplifyDAndKTraces(dt_Z_l_def)
		:simplifyAddMulDiv()
	printbr(dt_Z_l_def)
end

printbr'symmetrizing indexes'
dt_Z_l_def = dt_Z_l_def
	:symmetrizeIndexes(K, {1,2})
	:symmetrizeIndexes(gamma, {1,2})
	:symmetrizeIndexes(d, {2,3})
	:simplify()
printbr(dt_Z_l_def)

printbr()


-- beta^i

printHeader'shift evolution:'

local dt_beta_u_def
local dt_b_ul_def
local dt_B_u_def
local dt_beta_u_negflux, dt_beta_u_rhs
local dt_b_ul_negflux, dt_b_ul_rhs
if useShift == 'hyperbolicGammaDriver' then
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
end	-- useShift == 'hyperbolicGammaDriver'
if useShift == 'minimalDistortionElliptic' then
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


	local _
	_, dt_beta_u_negflux, dt_beta_u_rhs = combineCommaDerivativesAndRelabel(dt_beta_u_def[2], 'r', {'l'})
	printbr(beta'^l_,t', 'flux term:', -dt_beta_u_negflux)
	printbr(beta'^l_,t', 'source term:', dt_beta_u_rhs)

	
	printHeader('minimum distortion elliptic spatial derivative evolution:')
	
	-- TODO now how do they convert to flux?
	dt_b_ul_def = dt_beta_u_def:reindex{k='i'}
	dt_b_ul_def = (dt_b_ul_def[1]'_,k')():eq((delta'^r_k' * dt_b_ul_def[2])'_,r')
	dt_b_ul_def[1] = dt_b_ul_def[1]
		:replace(beta'^l_,tk', beta'^l_,k''_,t')
		:substIndex(d_beta_ul_from_b_ul)
	printbr(dt_b_ul_def)

	_, dt_b_ul_negflux, dt_b_ul_rhs = combineCommaDerivativesAndRelabel(dt_b_ul_def[2], 'r', {'l', 'k'})
	printbr(b'^l_k,t', 'flux term:', -dt_b_ul_negflux)
	printbr(b'^l_k,t', 'source term:', dt_b_ul_rhs)

	dt_b_ul_def = dt_b_ul_def()
	printbr(dt_b_ul_def)

	local using = delta'^r_k,r':eq(0)
	printbr('using', using)
	dt_b_ul_def = dt_b_ul_def:subst(using)()
	printbr(dt_b_ul_def)

	printbr('using', d_gamma_uul_from_gamma_uu_d_gamma_lll)
	dt_b_ul_def = dt_b_ul_def:subst(
		d_gamma_uul_from_gamma_uu_d_gamma_lll:reindex{ijklm='ilrpq'},
		d_gamma_uul_from_gamma_uu_d_gamma_lll:reindex{ijklm='jmrpq'}
	)()
	printbr(dt_b_ul_def)

	if eigensystem_dontIncludeGaugeVars
	and useShift ~= 'minimalDistortionElliptic'
	then
		printbr('using', d_alpha_l_from_a_l)
		dt_b_ul_def = dt_b_ul_def:substIndex(d_alpha_l_from_a_l)()
		printbr(dt_b_ul_def)
		
		printbr('using', d_beta_ul_from_b_ul)
		dt_b_ul_def = dt_b_ul_def:substIndex(d_beta_ul_from_b_ul)()
		printbr(dt_b_ul_def)
	
		printbr('using', d_gamma_lll_from_d_lll)
		dt_b_ul_def = dt_b_ul_def:substIndex(d_gamma_lll_from_d_lll)()
		printbr(dt_b_ul_def)
	
		printbr('using', d_lll_from_dHat_lll_dDelta_lll'_,r'())
		dt_b_ul_def = dt_b_ul_def:substIndex(d_lll_from_dHat_lll_dDelta_lll'_,r'())()
		printbr(dt_b_ul_def)
	end

	printbr()

	-- TODO and how about dt_b_ul_def
end

--[[
TODO HERE

we have three parts:
1) the flux first-derivatives of state-vars,
	be they EFE vars or EFE var first derivs turned into state vars for hyperbolicity, like a_k, d_kij, b^l_k ...
	these are turned into the flux-jacobian matrix

2) the flux first-deriv of not-first-deriv-state-vars
	these seem to be moved over to the rhs with most papers' eigensystem computation
	but are on the lhs in the flux for the flux
	(hmm, if we want homogeneity then wouldn't we want these vars in the flux, and therefore we woudl want the flux matrix to include the gauge vars?)

3) the rhs terms which don't go into the flux
	to speed up calculations, these can be represented in their simplest form (i.e. d^l instead of d^l_ij or dDelta^l_ij + dHat^l_ij)


so what TODO 

1) above, for each var,
	once it is separated into the flux and the source ...
	separate the two:
		- simplify the source further (to make it more compact / easier to code-generate)
		- simplify the flux in converting the 1st derivs of gauge vars into state vars *ONLY IF* we are not including them into the eignesystem
			- and even then, don't add them back into the source (even tho they don't go in the eigensystem).  keep them separate.
	- while yoou're here, might as well separate the shift from non-shift components too?
--]]

printHeader'as a system (for the eigensystem solver ... TODO include the shift eqns in this output):'

--[[
for lapse f=2/α:
matrix of {α, Δγ_ij, a_r, Δd_kij, K_ij}
... give us 0 x15, ±α√(γ^xx) x5
--]]
local UijkltEqns = table()

local function takeOffCommaR(expr)
	if Constant.isValue(expr, 0) then return expr end
	assert(Tensor.Ref:isa(expr))
	assert(expr[#expr].symbol == 'r')
	assert(expr[#expr].derivative == ',')
	assert(expr[#expr].lower)
	if #expr == 2 then
		return expr[1]
	end
	expr = expr:clone()
	table.remove(expr, #expr)
	return expr
end

--[[
here's the flux vector from the 2008 Yano / 2005 Bona paper, irregardless of what state variable derivatives we find later
--]]
local FijklTerms = table()

-- technically beta^i is also a gauge var, but i'm disabling it via dontIncludeShiftVars
if not eigensystem_dontIncludeGaugeVars then
	UijkltEqns:append{
		dt_alpha_def,
		dt_gammaDelta_ll_def,
	}
	FijklTerms:append{
		-takeOffCommaR(dt_alpha_negflux or Constant(0)),
		-takeOffCommaR(dt_gammaDelta_ll_negflux or Constant(0)),
	}
end

UijkltEqns:append{
	dt_a_l_def,
	dt_dDelta_lll_def,
	dt_K_ll_def,
}
FijklTerms:append{
	-takeOffCommaR(dt_a_l_negflux),
	-takeOffCommaR(dt_dDelta_lll_negflux),
	-takeOffCommaR(dt_K_ll_negflux),
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
	UijkltEqns:append{
		dt_Theta_def,
		dt_Z_l_def,
	}
	FijklTerms:append{
		-takeOffCommaR(dt_Theta_negflux),
		-takeOffCommaR(dt_Z_l_negflux),
	}
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
	-- if we exclude the shift vars from the eigensystem ... 
	-- we should still put them in the flux vector
	-- but that means we need a separate lhs dUdt to match up with the flux vector versus the eigensystem
	-- it also might mean keeping track of where the non-shift flux vector terms end if I want to (TODO) change this script to derive the eigensystem from this flux vector
	-- (instead of from all those dt_*_def var rhs's
	-- because doing this means ...
	-- ... TODO ... get rid of all the dt_*_def rhs's after the flux separation
	-- and TODO get rid of all the replace()'s beforehand since in the flux vector I just swap them back
if dt_beta_u_def then
	FijklTerms:insert(-takeOffCommaR(dt_beta_u_negflux))
end
if dt_b_ul_def then
	FijklTerms:insert(-takeOffCommaR(dt_b_ul_negflux))
end
if dt_B_u_def then
	FijklTerms:insert(-takeOffCommaR(dt_B_u_negflux or Constant(0)))
end
local FijklMat = Matrix(FijklTerms):T()

-- ijk on the partial_t's
-- pqm on the partial_x^r's

-- factor out the _,t from the lhs

function assertAndRemoveLastTensorIndex(exprs, lastTensorIndex)
	return exprs:mapi(function(expr)
		local dt = expr:splitOffDerivIndexes()
		assert(Tensor.Ref:isa(dt)
			and #dt == 2
			and dt[2] == lastTensorIndex,
			"expected expr to be a Tensor.Ref ending in _,"..lastTensorIndex)
		return dt[1]
	end)
end

local UijklVars = assertAndRemoveLastTensorIndex(
	UijkltEqns:mapi(function(eqn) return eqn[1] end),
	Tensor.Index{lower=true, symbol='t', derivative=','}
)
local UijklMat = Matrix(UijklVars):T()

local UijklWithShiftVars = table(UijklVars)	-- I just want this for the lhs, for when FijklTerms doesn't match UijkltVars
if eigensystem_dontIncludeShiftVars then
	local addedShiftLhs = table()
	if dt_beta_u_def then
		addedShiftLhs:insert(dt_beta_u_def[1])
	end
	if dt_b_ul_def then
		addedShiftLhs:insert(dt_b_ul_def[1])
	end
	if dt_B_u_def then
		addedShiftLhs:insert(dt_B_u_def[1])
	end
	UijklWithShiftVars:append(assertAndRemoveLastTensorIndex(
		addedShiftLhs,
		Tensor.Index{lower=true, symbol='t', derivative=','}
	))
end
local UijklWithShiftMat = Matrix(UijklWithShiftVars):T()

for _,eqn in ipairs(UijkltEqns) do
	printbr(eqn)
end
printbr()

printbr'flux vector:'
printbr((UijklWithShiftMat'_,t' + FijklMat'_,r'):eq(var'S'))
printbr()

--[[
ok at this point I could just use whats in FijklTerms to calculate the flux jacobian
instead of the whole rhs, which has the flux jacobian terms, the flux gauge derivs-to-first-deriv-state-vars, and the rhs source vars
For now I'm going to simplify FijklTerms to the least number of vars for the purpose of generating flux code
--]]
for i=1,#FijklTerms do
	local term = FijklTerms[i]
	
	-- TODO do this somewhere else?
	local f_alpha = var('(f \\alpha)', alpha)
	f_alpha:nameForExporter('C', 'f_alpha')
	term = term:replace(f, f_alpha / alpha)

	--[[ if you want to represent the flux with the least number of mathematical symbols:
	term = term:substIndex(
		gamma_ll_from_gammaHat_ll_gammaDelta_ll:solve(gammaHat'_ij'),
		d_lll_from_dHat_lll_dDelta_lll:solve(dHat'_kij')
	):simplifyAddMulDiv()
	-- only for tij use the solve-for-dDelta ...
	term = term:subst(d_lll_from_dHat_lll_dDelta_lll:solve(dDelta'_kij'):reindex{k='t'}):simplifyAddMulDiv()
	term = term:simplifyMetrics():simplifyAddMulDiv()
	term = term:tidyIndexes():simplifyAddMulDiv()
	term = simplifyDAndKTraces(term):simplifyAddMulDiv()
	term = term:symmetrizeIndexes(d, {2,3})
	--]]
	-- [[ if you want to represent the flux with state variables:
	term = term:substIndex(d_lll_from_dHat_lll_dDelta_lll)
	-- mind you if you don't call these then maybe there will be less terms?
	-- and maybe I can implement a function to distribute only the deltas, 
	-- and only then simplify the deltas * Tensor.Ref alone (without changing the rest of the expression)
	-- and then i could preserve the structure and simplify some more deltas if possible
	term = term:simplifyAddMulDiv()
	term = term:simplifyMetrics({
		Expression.simplifyMetricMulRules.delta,	-- only simplify deltas, don't raise/lower
	}):simplifyAddMulDiv()
	--]]

	FijklTerms[i] = term
end
FijklMat = Matrix(FijklTerms):T()
printbr((UijklWithShiftMat'_,t' + FijklMat'_,r'):eq(var'S'))
printbr()

local UpqmnVars = UijklVars:mapi(function(x) return x:reindex{ijkl='pqmn'} end)
local UpqmnrVars = UpqmnVars:mapi(function(x) return x'_,r'() end)

printHeader'inserting deltas to help factor linear system'

local rhsWithDeltas = UijkltEqns:mapi(function(eqn)
	printbr('inserting deltas into '..eqn[1])
	return insertDeltasToSetIndexSymbols(eqn[2], UpqmnrVars)
end)

printHeader'as a balance law system:'

local A, SijklMat = factorLinearSystem(rhsWithDeltas, UpqmnrVars)
local dFijkl_dUpqmn_mat = (-A)()
dFijkl_dUpqmn_mat = dFijkl_dUpqmn_mat:simplifyMetrics()()

local UpqmnMat = Matrix(UpqmnVars):T()

if not outputSourceTerms then
	SijklMat = (SijklMat * 0)()
end

printbr((UijklMat'_,t' + dFijkl_dUpqmn_mat * UpqmnMat'_,r'):eq(SijklMat))
printbr()

printHeader'replacing rhs derivatives with 1st derivative state variables:'

if outputSourceTerms then
	SijklMat = SijklMat
		:substIndex(d_alpha_l_from_a_l)
		:substIndex(d_beta_ul_from_b_ul)
		:substIndex(d_gamma_uul_from_dHat_lll_dDelta_lll)

	for i=1,#SijklMat do
		SijklMat[i][1] = SijklMat[i][1]
			:simplifyMetrics({
				Expression.simplifyMetricMulRules.delta,	-- only simplify deltas, don't raise/lower
			})
			:tidyIndexes{fixed='t'}
			:simplifyAddMulDiv()
	end
end

printbr((UijklMat'_,t' + dFijkl_dUpqmn_mat * UpqmnMat'_,r'):eq(SijklMat))
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
				
				local isTensorRef = Tensor.Ref:isa(x)
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


printHeader'expanding, and removing zero rows/cols:'

--[[ only remove diagonal shift.  TODO this for the eigensystem, for acoustic matrix, but do it later after expanding.
dFijkl_dUpqmn_mat = dFijkl_dUpqmn_mat:replace(beta'^r', 0)()
--]]

--[[
TODO when considering shift, instead remove only shift along diagonal (for assumption of eigensystem with adjusted eigenvalues)
but this means, if there are no beta^x's along the diagonal of alpha_,t and gamma_ij,t, then we can't use this rule unless they also have zero rows (which they seem to)
--]]
--[[
if evaluateShiftlessEigensystem then
	dFijkl_dUpqmn_mat = dFijkl_dUpqmn_mat
		:replaceIndex(b'^i_j', 0)()
end
--]]

-- [=[ 
Tensor.Chart{coords=xs}

-- TODO put this in symmath
-- after merging the "symmetries" property into TensorRef
local cachedDenseTensors = table()
local function getDenseTensorCache(x)
	assert(Tensor.Ref:isa(x) and Variable:isa(x[1]))
	local _, t = cachedDenseTensors:find(nil, function(t)
		return TensorRefIsMatchingIndexForm(t[1], x)
	end)
	if not t then return end
	return t[2], t[1]
end
function expandMatrixIndexes(expr)
	--[[
	args:
		var = base var, to replace Tensor.Ref(var, ...) with Tensor.Ref( dense form of var, ...)
		indexes = var indexes
	--]]
	local function makeDenseTensor(x)
		assert(Tensor.Ref:isa(x))
		assert(Variable:isa(x[1]))
--printbr('creating dense tensor', x)	
		local basevar = x[1]:clone()
		local indexes = table.sub(x, 2):mapi(function(index) return index:clone() end)
		local numDeriv = 0
		local indexesWithoutDeriv = indexes:mapi(function(index)
			index = index:clone()
			if index.derivative == ',' then numDeriv = numDeriv + 1 end
			index.derivative = nil
			return index
		end)
		local degreeCSuffix = '_'..indexes:mapi(function(index)
			return index.lower and 'l' or 'u'
		end):concat()
		
		-- ss[1] is the Tensor.Ref, ss[2...] is the 
		local ss = getSymmetriesForTensorRef(x)
		local allsymkeys = {}
		if ss then
			for i=2,#ss do
				for j=1,#ss[i] do
					allsymkeys[ss[i][j]] = true
				end
			end
		end

		local result = Tensor(indexesWithoutDeriv, function(...)
			local is = {...}
			local thisIndexes = indexes:mapi(function(index) return index:clone() end)
			for i=1,#is do
				thisIndexes[i].symbol = xNames[is[i]]
			end
			-- now sort 'thisIndexes' based on symmetries
			local thisRef = Tensor.Ref(basevar, thisIndexes:unpack())
			applySymmetriesToIndexes(thisRef)
			
			-- TODO how to specify names per exporter?
			local v = var(symmath.export.LaTeX:applyLaTeX(thisRef))
		
			-- insert dots between non-sym indexes
			local thisIndexCSuffix = table()
			for i=1,#thisRef-1 do
				local index = thisRef[i+1]
				if i > 1 and not (allsymkeys[i-1] and allsymkeys[i]) then
					thisIndexCSuffix:insert'.'
				end
				thisIndexCSuffix:insert(index.symbol)
			end
			thisIndexCSuffix = thisIndexCSuffix:concat()
			
			local derivCPrefix
			if numDeriv == 0 then
				derivCPrefix = ''
			elseif numDeriv == 1 then
				derivCPrefix = 'partial_'
			else
				derivCPrefix = 'partial'..numDeriv..'_'
			end
			local cname = derivCPrefix .. basevar:nameForExporter'C'..degreeCSuffix..'.'..thisIndexCSuffix
			v:nameForExporter('C', cname)
			
			return v
		end)
		return result
	end
	
	local function replaceWithDense(expr)
		return expr:map(function(x)
			if Tensor.Ref:isa(x)
			and Variable:isa(x[1])
			then
--printbr('found tensorref', x)
				local indexes = table.sub(x, 2):mapi(function(index) return index:clone() end)
				-- remove deriv, needed for permuting the Tensor into the TensorRef(Variable)'s form
				local indexesWithoutDeriv = indexes:mapi(function(index)
					index = index:clone()
					index.derivative = nil
					return index
				end)
				-- scalar derivatives need to be generated
				-- otherwise tensors need the derivative indexes picked off, ten replace with dense, then replace with ref with full derivative indexes
				-- or just don't bother with derivatives, and encode everything in the variable name
				local dense, cachedRef = getDenseTensorCache(x)
				if dense then
--printbr('...matched to cached tensorref', cachedRef)
--printbr('found associated dense', dense)
				else
					dense = makeDenseTensor(x)
--printbr('...created new dense', dense)
					cachedDenseTensors:insert{x:clone(), dense}
				end
				local result = Tensor.Ref(dense, indexesWithoutDeriv:unpack())
--printbr('...returning dense tensorref', result)
				return result
			end
		end)
	end

	-- special for our time deriv, since the "t" is a fixed dim, not a tensor index
	-- how about TODO a 'fixed indexes'?  remove these from the dense tensor generation
	local dHat_t_Dense = makeDenseTensor(dHat_t'_ij')
	expr = expr:replace(dHat'_tij', dHat_t_Dense'_ij')
	local dt_dHatDense = makeDenseTensor(dt_dHat'_kij')
	expr = expr:replace(dHat'_tij,k', dt_dHatDense'_kij')
	
	-- another special case
	local deltaDenseUL = Tensor('^i_j', function(i,j) return i == j and 1 or 0 end)
	expr = expr:replaceIndex(delta'^i_j', deltaDenseUL'^i_j')

	-- now for everything else
	return replaceWithDense(expr)
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
printbr((dUdt_lhs + dFdx_lhs):eq(SijklMat))

local dFdx_lhs_dim = dFdx_lhs:dim()
assert(#dFdx_lhs_dim == 2 and dFdx_lhs_dim[2] == 1)
local dFdx_lhs_exprs = range(dFdx_lhs_dim[1]):mapi(function(i) return dFdx_lhs[i][1] end)
dFdx_lhs_exprs = dFdx_lhs_exprs:mapi(function(expr,i)
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
local dUdt_lhs_withShift_exprs = range(#UijklWithShiftMat):mapi(function(i)
	local expr = expandMatrixIndexes(UijklWithShiftMat[i][1])()
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


-- replace the tensor index matrix form of _,t with _,x
local dUdx_lhs = Matrix:lambda(UijklMat:dim(), function(...)
	return UijklMat[{...}]'_,x'()
end)

-- convert it into a matrix of our dense-tensor derivative terms
local dUdx_lhs_exprs = range(dFdx_lhs_dim[1]):mapi(function(i) return dUdx_lhs[i][1] end)
dUdx_lhs_exprs = dUdx_lhs_exprs:mapi(function(expr) return expandMatrixIndexes(expr)() end)

local S_rhs_exprs = range(dFdx_lhs_dim[1]):mapi(function(i) return SijklMat[i][1] end)
S_rhs_exprs = S_rhs_exprs:mapi(function(expr) return expandMatrixIndexes(expr) end)

local F_lhs_exprs = range(#FijklMat):mapi(function(i) return FijklMat[i][1] end)
F_lhs_exprs = F_lhs_exprs:mapi(function(expr) return expandMatrixIndexes(expr) end) 

--[[ show eqns in dense-tensor form
printbr'expanding...'
for i=1,#dFdx_lhs_exprs do
	printbr((dUdt_lhs_exprs[i] + dFdx_lhs_exprs[i]):eq(S_rhs_exprs[i]))
end
printbr()
--]]

-- NOTICE this can go slow if the dense tensors aren't replaced correctly 
S_rhs_exprs = S_rhs_exprs:mapi(function(expr) return expr() end)

F_lhs_exprs = F_lhs_exprs:mapi(function(expr) return expr() end)

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
--[[ show eqns in dense-tensor form
printbr'simplifying...'
for i=1,#dFdx_lhs_exprs do
	printbr((dUdt_lhs_exprs[i] + dFdx_lhs_exprs[i]):eq(S_rhs_exprs[i]))
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
--[[ show dense-tensor form
printbr'only in one flux dimension...'
for i=1,#dFdx_lhs_exprs do
	printbr((dUdt_lhs_exprs[i] + dFdx_lhs_exprs[i]):eq(S_rhs_exprs[i]))
end
printbr()
--]]

local rowsplits = table()
local dUdt_lhs_exprs_expanded = table()
local dFdx_lhs_exprs_expanded = table()
local S_rhs_exprs_expanded = table()
local dUdx_lhs_exprs_expanded = table()
for i=1,#dFdx_lhs_exprs do
	local dUdt_i = dUdt_lhs_exprs[i]
	local dFdx_i = dFdx_lhs_exprs[i]
	local dUdx_i = dUdx_lhs_exprs[i]
	local S_i = S_rhs_exprs[i]
	rowsplits:insert(#dUdt_lhs_exprs_expanded)
	if Tensor:isa(dFdx_i) then
		assert(Tensor:isa(dUdt_i))
		assert(Tensor:isa(S_i) or Constant.isValue(S_i, 0))
		assert(Tensor:isa(dUdx_i))
		for j,x in dFdx_i:iter() do
			if not dUdt_lhs_exprs_expanded:find(dUdt_i[j]) then
				dFdx_lhs_exprs_expanded:insert(x)
				dUdt_lhs_exprs_expanded:insert(dUdt_i[j])
				-- TODO no need to test for Constant if, when dUdt_i is a Tensor and S_i is 0, then we just turn S_i into a Tensor of same variance
				local S_i_j = Constant.isValue(S_i, 0) and Constant(0) or assert(S_i[j])
--printbr(dUdt_i[j]:eq(S_i_j))
				S_rhs_exprs_expanded:insert(S_i_j)
				dUdx_lhs_exprs_expanded:insert(dUdx_i[j][1])	-- dUdx_i has a last _,x
			end
		end
	else
		dFdx_lhs_exprs_expanded:insert(dFdx_i)
		assert(not Tensor:isa(dUdt_i))
		dUdt_lhs_exprs_expanded:insert(dUdt_i)
		assert(not Tensor:isa(S_i))
--printbr(dUdt_i:eq(S_i))
		S_rhs_exprs_expanded:insert(assert(S_i))
		assert(Tensor:isa(dUdx_i))
		dUdx_lhs_exprs_expanded:insert(dUdx_i[1])	-- dUdx_i has a last _,x, so always assume its a Tensor
	end
end

local dUdt_lhs_withShift_exprs_expanded = table()
local F_lhs_exprs_expanded = table()
for i=1,#F_lhs_exprs do
	local dUdt_i = dUdt_lhs_withShift_exprs[i]
	local F_i = F_lhs_exprs[i]
	if Tensor:isa(dUdt_i) then
		for j,x in dUdt_i:iter() do
			if not dUdt_lhs_withShift_exprs_expanded:find(dUdt_i[j]) then
				dUdt_lhs_withShift_exprs_expanded:insert(dUdt_i[j])
				local F_i_j_x = Constant.isValue(F_i, 0) and Constant(0) or assert(F_i[j][1])
				F_lhs_exprs_expanded:insert(F_i_j_x)
			end
		end
	else
		assert(not Tensor:isa(dUdt_i))
		dUdt_lhs_withShift_exprs_expanded:insert(dUdt_i)
		F_lhs_exprs_expanded:insert(F_i[1])
	end
end

local n = #dFdx_lhs_exprs_expanded
-- [[
printbr'unraveling flux for eigensystem + source...'
for i=1,#dUdt_lhs_exprs_expanded do
	printbr((dUdt_lhs_exprs_expanded[i] + dFdx_lhs_exprs_expanded[i]):eq(S_rhs_exprs_expanded[i]))
end
printbr'unraveling flux vector...'
for i=1,#dUdt_lhs_withShift_exprs_expanded do
	printbr((dUdt_lhs_withShift_exprs_expanded[i] + F_lhs_exprs_expanded[i]'_,r'):eq(var'source'))
end
printbr()
--]]

printbr'as linear system...'
local U_vars_expanded = dUdt_lhs_exprs_expanded:mapi(function(v)
	v = v:clone()
	assert(Derivative:isa(v) and Variable:isa(v[1]) and v[2] == t)
	return v[1]
end)
local U_vars_withShift_expanded = dUdt_lhs_withShift_exprs_expanded:mapi(function(v)
	v = v:clone()
	assert(Derivative:isa(v) and Variable:isa(v[1]) and v[2] == t)
	return v[1]
end)

--[[
ok new dilemma
dense-tensor-generation is a lot easeier when I just remove all derivatives from the vars inside the dense tensor
so is name generation for the derivatives-of-dense-tensor ...
... otherwise they are Derivatives and code-gen will have to do exceptional things for the names
but
factoring the linear system has an easier name if I use Derivative's in the dense-tensor-generation ...
... hmm ... 
can I use the dense-derivative-generated variables in the factor-linear-system vars?
--]]
--[[
local dUdx_lhs_exprs_expanded = U_vars_expanded:mapi(function(var)
	return var:diff(x)
end)
--]]
--[[
so instead of using the U vars :diff(x), instead use the dense vars of _,x that are comma-expanded
and just use the system we used for unraveling S_i etc
--]]

local dFijkl_dUpqmn_expanded, dFijkl_dUpqmn_expanded_b = factorLinearSystem(dFdx_lhs_exprs_expanded, dUdx_lhs_exprs_expanded)
-- TODO should I assert dFijkl_dUpqmn_expanded_b == 0? and if so then should I just leave it out?
dFijkl_dUpqmn_expanded.colsplits = rowsplits
dFijkl_dUpqmn_expanded.rowsplits = rowsplits
dFijkl_dUpqmn_expanded_b.rowsplits = rowsplits

local Sijkl_expanded = Matrix(S_rhs_exprs_expanded):T()
Sijkl_expanded.rowsplits = rowsplits

local Uijkl_expanded = Matrix(U_vars_expanded):T()
local Upqmn_expanded = Uijkl_expanded:clone()

local dUdt_lhs_exprs_expanded_mat = Matrix(dUdt_lhs_exprs_expanded):T()
dUdt_lhs_exprs_expanded_mat.rowsplits = rowsplits
local dUdx_lhs_exprs_expanded_mat = Matrix(dUdx_lhs_exprs_expanded):T()
dUdx_lhs_exprs_expanded_mat.rowsplits = rowsplits

-- somewhere in here I need to subtract out the diagonal -beta^x if I want to help the eigen solver 
local betaUx = getDenseTensorCache(beta'^i')[1]
printbr('subtracting ', -betaUx * var'I', '...')
dFijkl_dUpqmn_expanded = (dFijkl_dUpqmn_expanded + Matrix.identity(#dFijkl_dUpqmn_expanded) * betaUx)()
dFijkl_dUpqmn_expanded.colsplits = rowsplits
dFijkl_dUpqmn_expanded.rowsplits = rowsplits

local Uijkl_withShift_expanded = Matrix(U_vars_withShift_expanded):T()
-- this should match dF/dU * U ... if we have homogeneity 
local Fijkl_withShift_expanded = Matrix(F_lhs_exprs_expanded):T()
Fijkl_withShift_expanded.rowsplits = rowsplits

printbr(
	(
		dUdt_lhs_exprs_expanded_mat
		+ (dFijkl_dUpqmn_expanded - betaUx * var'I')
		* dUdx_lhs_exprs_expanded_mat
		+ dFijkl_dUpqmn_expanded_b	-- should be zero ...or full of all the y and z dir flux terms
	):eq(
		Sijkl_expanded
	)
)
printbr()

local dUdt_lhs_withShift_exprs_expanded_mat = Matrix(dUdt_lhs_withShift_exprs_expanded):T()
dUdt_lhs_withShift_exprs_expanded_mat.rowsplits = rowsplits

printbr'flux vector:'
printbr((dUdt_lhs_withShift_exprs_expanded_mat'_,t' + Fijkl_withShift_expanded'_,r'):eq(var'S'))
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
			table.remove(Sijkl_expanded, i)
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
			table.remove(Sijkl_expanded, j)
			m = m - 1
			n = n - 1
		end
	end
	printbr((Uijkl_expanded'_,t' + dFijkl_dUpqmn_expanded * Upqmn_expanded'_,r'):eq(Sijkl_expanded))
	-- TODO if this fails then that means we need find the removed rows from Upqmn and remove the associated columns from dFijkl_dUpqmn
	assert(m == n, "removed a different number of all-zero rows vs columns")
	printbr()
	--]]

	--[[
	for i=#Fijkl_withShift_expanded,1,-1 do
		if Constant.isValue(Fijkl_withShift_expanded[i][0], 0) then
			table.remove(Fijkl_withShift_expanded, i)
			table.remove(Uijkl_withShift_expanded, i)
		end
	end
	--]]
	printbr'flux vector:'
	printbr((Uijkl_withShift_expanded'_,t' + Fijkl_withShift_expanded'_,r'):eq(var'S'))
	printbr()
end


--[[ CHECK -- verify that the matrix matches the 2008 Yano flux jacobian matrix ...
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
--]]

-- TODO replace f with f_alpha / alpha and df/dalpha with alphaSq_dalpha_f / alpha^2
export.C.numberType = 'real const'
printHeader'generating code'
print'<pre>'
print'source:'
assert(#Sijkl_expanded == #Uijkl_expanded)
print(export.C:toCode{
	output = range(#Uijkl_expanded):mapi(function(i)
		return {['deriv->'..export.C(Uijkl_expanded[i][1])] = Sijkl_expanded[i][1]}
	end),
	notmp = true,
	assignOnly = true,
})
print()
print'flux:'
assert(#Fijkl_withShift_expanded == #Uijkl_withShift_expanded)
print(export.C:toCode{
	output = range(#Uijkl_withShift_expanded):mapi(function(i)
		return {['(resultFlux)->'..export.C(Uijkl_withShift_expanded[i][1])] = Fijkl_withShift_expanded[i][1]}
	end),
	--notmp = true,
	assignOnly = true,
})
print'</pre>'

--[[
-- ok before going any further into eigensystem stuff,
-- lets codegen the
-- (a) flux matrix
-- (b) source terms
-- (c) flux jacobian linear system

--local fluxesAndSources = table()
for _,info in ipairs(fluxesAndSources) do
	printbr(info.lhs)
	print'<pre>'
	for _,key in ipairs{
		'negFluxNoShift',
		'negFluxShift',
		'sourceNoShift',
		'sourceShift',
	} do
		print(key)
		print(export.C:toCode{
			output = {
				info[key],
			},
			notmp = true,
			assignOnly = true,
		})
	end
	print'</pre>'
end
--]]


--[==[ too many locals, so i'll just separate this out for now

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

local gammaUxxVar = var'\\gamma^{xx}'
for _,root in ipairs{
--[[ easiest first
	Constant(0),
	alpha * sqrt(gammaUxxVar),
	-alpha * sqrt(gammaUxxVar),
	alpha * sqrt(f * gammaUxxVar),
	-alpha * sqrt(f * gammaUxxVar),
--]]
-- [[ hardest first
	-alpha * sqrt(f * gammaUxxVar),
	alpha * sqrt(f * gammaUxxVar),
	-alpha * sqrt(gammaUxxVar),
	alpha * sqrt(gammaUxxVar),
	Constant(0),
--]]
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
printbr()
printbr('<pre>', (export.Lua(x)), '</pre>')
printbr()
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

-- ok so now these rules might come in handy:
--symmath.op.div:popRule'Prune/conjOfSqrtInDenom'
assert(symmath.op.div:popRule'Factor/polydiv')

printHeader'calculating eigensystem'
_G.printbr = printbr	-- for Matrix.eigen verbose=true:
local eig = dFijkl_dUpqmn_expanded:eigen{
	lambdaVar = lambda,
	lambdas = lambdas,
	verbose = true,
	nullspaceVerbose = true,
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
--]==]

-- DONE
printHeader()
io.stderr:write('TOTAL: '..(timer() - startTime)..'\n')
io.stderr:flush()
print(MathJax.footer)
