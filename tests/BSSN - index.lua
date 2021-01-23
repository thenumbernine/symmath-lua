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


local spatialDim = 3

--[[ latest times:
useful identity: ... 0.072s
useful identity: ... 0.037s
ADM metric evolution: ... 0.259s
Bona-Masso lapse and shift evolution: ... 0.001s
using locally-Minkowski normalized coordinates: ... 0.051s
using locally-Minkowski normalized coordinates: ... 0.027s
using locally-Minkowski normalized coordinates: ... 0.148s
conformal $\phi$: ... 0.002s
conformal $\chi$: ... 0s
conformal W: ... 0.001s
conformal metric: ... 0.001s
conformal metric inverse: ... 0.001s
conformal metric derivative: ... 0.018s
conformal metric determinant: ... 0.001s
conformal metric constraint: ... 0.001s
static grid assumption: ... 0.001s
conformal connection: ... 0.435s
extrinsic curvature trace: ... 0.0010000000000001s
trace-free extrinsic curvature: ... 0.006s
conformal trace-free extrinsic curvature: ... 0.039s
trace-free extrinsic curvature derivative: ... 0.0070000000000001s
Jacobi identity: ... 0s
conformal W evolution: ... 0.57s
using locally-Minkowski normalized coordinates: ... 0.257s
conformal metric evolution: ... 0.924s
conformal metric perturbation: ... 0.00099999999999989s
conformal metric perturbation spatial derivative: ... 0.0060000000000002s
conformal metric perturbation evolution: ... 0.0059999999999998s
using locally-Minkowski normalized coordinates: ... 2.639s
grid vs conformal connection difference: ... 0.0030000000000001s
grid vs conformal connection difference evolution: ... 104.327s
using locally-Minkowski normalized coordinates: ... 324.763s
extrinsic curvature trace evolution: ... 17.434s
using locally-Minkowski normalized coordinates: ... 1.532s
trace-free extrinsic curvature evolution: ... 0.016999999999996s
conformal trace-free extrinsic curvature evolution: ... 27.296s
using locally-Minkowski normalized coordinates: ... 58.253s
collecting partial derivatives: ... 0.013000000000034s
writing results... ... 0.021999999999935s
TOTAL: 539.172
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


-- TODO put an add-mul-div simplification inside Expression somewhere
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
transform all indexes by a specific transformation
this is a lot like the above function

how to generalize the above function?
above: if the lower/upper doesn't match our lower/upper then insert multiplciations with metric tensors
ours: if the capital/lowercase doesn't match our capital/lowercase then do the same

rule:
	defaultSymbols = what default symbols to use.  if this isn't specified then Tensor.defaultSymbols is used
	matches = function(x) returns true to use this TensorRef
	applyToIndex = function(x,i,gs,unusedSymbols)
		x = TensorRef we are examining
		i = the i'th index we are examining
		gs = list of added expressions to insert into
		unusedSymbols = list of unused symbols to take from
		returns true if the TensorRef's index needs to be changed
--]]
local function insertTransformsToSetVariance(expr, rule)
	local mul = require 'symmath.op.mul'

	local defaultSymbols = nil 
		--or args and args.symbols
		or rule.defaultSymbols
		or require 'symmath.Tensor'.defaultSymbols


	-- TODO assert that we are in add-mul-div form?
	-- otherwise this could introduce bad indexes ...
	-- in fact, even if we are in add-mul-div, applying to multiple products will still run into this issue
	local exprFixed, exprSum, exprExtra = expr:getIndexesUsed()
	local exprAll = table():append(exprFixed, exprSum, exprExtra)
	local unusedSymbols = table(defaultSymbols)
	for _,s in ipairs(exprAll) do
		unusedSymbols:removeObject(s.symbol)
	end
	-- so for now i will choose unnecessarily differing symbols
	-- just call tidyIndexes() afterwards to fix this
	
	local handleTerm

	local function fixTensorRef(x)
		x = x:clone()
		-- TODO move this to 'rule'
		if TensorRef.is(x) then
			if not Variable.is(x[1]) then
				x[1] = handleTerm(x[1])
			elseif rule.matches(x) then
				local gs = table()
				for i=2,#x do
					rule.applyToIndex(x, i, gs, unusedSymbols)
				end
				return x, gs:unpack()
			end
		end
		return x
	end

	local function handleMul(x)
		local newMul = table()
		for i=1,#x do
			newMul:append{fixTensorRef(x[i])}
		end
		return mul(newMul:unpack())
	end

	-- could be a single term or multiple multiplied terms
	handleTerm = function (expr)
		expr = expr:clone()
		if mul.is(expr) then
			return handleMul(expr)
		else
			return expr:map(function(x)
				if mul.is(x) then
					return handleMul(x)
				else
					local results = {fixTensorRef(x)}
					if #results == 1 then
						return results[1]
					else
						return mul(table.unpack(results))
					end
				end
			end)
		end
		return expr
	end
	return handleTerm(expr)
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
local function insertMetricsToSetVariance(expr, find, metric)
	assert(metric)
	
	assert(TensorRef.is(find))
	--assert(Variable.is(find[1]))
	assert(not find:hasDerivIndex())	-- TODO handle derivs later?  also TODO call splitOffDerivIndexes() first? or expect the caller to do this 

	return insertTransformsToSetVariance(expr, {
		matches = function(x)
			return find[1] == x[1]			-- TensorRef base variable matches
			and #find == #x					-- number of indexes match
			and not x:hasDerivIndex()	-- not doing this right now
		end,
		applyToIndex = function(x, i, gs, unusedSymbols)
			local xi = x[i]
			local findi = find[i]
			if not not findi.lower ~= not not xi.lower then
				local sumSymbol = unusedSymbols:remove(1)
				assert(sumSymbol, "couldn't get a new symbol")
				local g = TensorRef(
					metric,
					xi:clone(),
					TensorIndex{
						lower = xi.lower,
						symbol = sumSymbol,
					}
				)
				gs:insert(g)
				xi.lower = findi.lower
				xi.symbol = sumSymbol
			end
		end,
	})
end
--]=]

local e = var'e'

local function check(x)
	x = betterSimplify(x)

	local function subcheck(x)
		if require 'symmath.op.add'.is(x) or require 'symmath.op.Equation'.is(x) then
			for i=1,#x do
				subcheck(x[i])
			end
			do return end
		end

		local symbols = x:getExprsForIndexSymbols()
		for symbol,v in pairs(symbols) do
			if #v > 2 then
				printbr("got symbol "..symbol.." with "..#v.." occurrences in expr", x)
				for _,p in ipairs(v) do
					printbr('index', p.index, 'expr', p.expr)
				end
			end
		end
	end
	subcheck(x)
end

-- TODO remove 'find'
-- TODO remove #find == #x constraint
local function insertNormalizationToSetVariance(expr, transformVar)
	transformVar = transformVar or e
	expr = betterSimplify(expr)	-- get into add-mul-div form

	local function isNormalizedSymbol(symbol)
		return symbol:match'^[A-Z]' 
	end


	local defaultSymbols = table(require 'symmath.Tensor'.defaultSymbols)
		-- add normalized indexes A-Z
		:append(
			range(('A'):byte(), ('Z'):byte()):mapi(function(x) return string.char(x) end)
		)


	local function getNormalizedVersionOfSymbol(symbol, unusedSymbols)
		-- another dilemma ...
		-- normalized indexes are capital letters
		-- but these aren't in the default set, only lowercase are
		-- that means now I need to re-evaluate them
		-- or to override the default set to include them
		-- I'll do the latter for now
		-- Be sure to pick the first capital letter
		local sumSymbol
		-- first try the capital version of the current index
		local i = unusedSymbols:find(symbol:upper()) 
		if i then
			sumSymbol = unusedSymbols:remove(i)
		else
			for i=1,#unusedSymbols do
				if isNormalizedSymbol(unusedSymbols[i]) then
					sumSymbol = unusedSymbols:remove(i)
					break
				end
			end
		end
		--assert(sumSymbol, 'failed to find a new capital letter sum symbol')
		if not sumSymbol then printbr('failed to find a new normalized symbol to replace symbol', symbol) end
		return sumSymbol
	end

--printbr('normalizing', expr)

	-- before handling individual terms within a mul, run some optimizations on mul itself:
	local function handleMul(mulexpr)
		mulexpr = mulexpr:clone()

		local exprFixed, exprSum, exprExtra = mulexpr:getIndexesUsed()
		local exprAll = table():append(exprFixed, exprSum, exprExtra)
		local unusedSymbols = table(defaultSymbols)
		for _,s in ipairs(exprAll) do
			unusedSymbols:removeObject(s.symbol)
		end

		-- I would use getIndexesUsed() but I want to filter out indexes inside of derivatives
		local symbolInfo = table()
		for i,mi in ipairs(mulexpr) do
			if TensorRef.is(mi) then
				for j=2,#mi do
					local mindex = mi[j]
					local si = symbolInfo[mindex.symbol]
					if not si then
						si = {
							symbol = mindex.symbol,
							sources = table()
						}
						symbolInfo[mindex.symbol] = si
					end
					si.sources:insert{
						exprloc = i,	-- location of term in mul's children
						indexloc = j,	-- location of TensorIndex in the term's children
					}
				end
			end
		end
		-- now we have collect the index info, look for sums
		for _,si in pairs(symbolInfo) do
			local n = #si.sources
			if n > 2 then
				printbr("found symbol" ,si.symbol, "that occurs", n, "times in the expression")
				printbr("expression:", mulexpr)
				--assert(n <= 2)	-- shouldn't have more than 2 sum indexes
			else
				local isDeriv
				if n == 2 then
					-- make sure the indexes aren't wrapped in comma derivatives
					for _,s in ipairs(si.sources) do
						if mulexpr[s.exprloc]:hasDerivIndex() then
							isDeriv = true
							break
						end
					end
					-- 2 indexes appear, neither wrapped in derivs, they aren't already normalized indexes
					-- ... don't insert transforms and simplify to deltas, but just make them normalized
					if not isDeriv 
					and not isNormalizedSymbol(si.symbol) 
					then
						local normalizedSumSymbol = getNormalizedVersionOfSymbol(si.symbol, unusedSymbols)
						--assert(normalizedSumSymbol)
						if normalizedSumSymbol then
--printbr('directly replacing index from', si.symbol, 'to', normalizedSumSymbol, 'because it has', n, 'occurrences')
							for _,s in ipairs(si.sources) do
								mulexpr[s.exprloc][s.indexloc].symbol = normalizedSumSymbol
							end
						end
					end
				end
			end
		end
		return mulexpr
	end

	local mul = require 'symmath.op.mul'
	if mul.is(expr) then
		expr = handleMul(expr)
	else
		expr = expr:map(function(x)
			if mul.is(x) then
				return handleMul(x)
			end
		end)
	end

	-- split off deriv indexes before remapping non-deriv indexes
	expr = expr:splitOffDerivIndexes()

	-- handle these cases separately so we reset the uniqueVars per term 
	-- alternatively i could just go looking for muls, but also single TensorRefs ...
	if require 'symmath.op.add'.is(expr) or require 'symmath.op.Equation'.is(expr) then
		expr = expr:clone()
		for i=1,#expr do
			expr[i] = insertNormalizationToSetVariance(expr[i], transformVar)
		end
		return expr
	end

	return insertTransformsToSetVariance(expr, {
		defaultSymbols = defaultSymbols,
		matches = function(x)
			return not x:hasDerivIndex()
		end,
		applyToIndex = function(x, i, gs, unusedSymbols)
			local xi = x[i]

			-- TODO skip the \'s in greek LaTeX
			if x[1] ~= transformVar
			and not isNormalizedSymbol(xi.symbol)
			then
				local sumSymbol = getNormalizedVersionOfSymbol(xi.symbol, unusedSymbols)
				--assert(sumSymbol )
				if sumSymbol then	
					-- another dilemma ... 'transformVar' doesn't need indexes, let alone for # indexes to match the search var
					local e = TensorRef(
						assert(transformVar),
						TensorIndex{
							lower = xi.lower,
							symbol = xi.symbol,
						},
						TensorIndex{
							lower = not xi.lower,
							symbol = sumSymbol,
						}
					)
					gs:insert(e)
					xi.symbol = sumSymbol
				end
			end
		end,
	})
end

local delta = Tensor:deltaSymbol()

local function replaceNormalizationTransformsWithDeltas(expr)
	local mul = require 'symmath.op.mul'
	return expr:map(function(x)
		if mul.is(x) then
			x = x:clone()
			local found
			repeat
				found = false
				for i=#x,1,-1 do
					local xi = x[i]
					for j=1,i-1 do
						local xj = x[j]
						if TensorRef.is(xi)
						and #xi == 3
						and xi[1] == e
						and TensorRef.is(xj)
						and #xj == 3
						and xj[1] == e
						and xi[2].symbol == xj[2].symbol
						and xi[2].lower ~= xj[2].lower
						then
							assert(xi[3].lower ~= xj[3].lower)
							assert(xi[3].symbol:upper() == xi[3].symbol)
							assert(xj[3].symbol:upper() == xj[3].symbol)
							table.remove(x, i)
							table.remove(x, j)
							table.insert(x, TensorRef(delta, xi[3], xj[3]))
							found = true
							break
						end
					end
					if found then break end
				end
			until not found
			return x
		end
	end)
end


--[[
-- use i-z first, then a-h
-- come to think of it, I should avoid txyz as well
Tensor.defaultSymbols = range(9,26):append(range(1,8)):mapi(function(x) return string.char(x) end)
--]]


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


--[[ testing:
local expr = ABar'_ij'
printbr(expr)
expr = insertMetricsToSetVariance(expr, ABar'^ij', gammaBar)
printbr(expr)
printbr()

local expr = ABar'_ij' + gammaBar'_ij' * ABar'^kl' * ABar'_kl'
printbr(expr)
expr = insertMetricsToSetVariance(expr, ABar'^ij', gammaBar)
printbr(expr)
printbr()


local expr = ABar'_ij'
printbr(expr)
expr = insertNormalizationToSetVariance(expr)
printbr(expr)
printbr()

local expr = ABar'^ij'
printbr(expr)
expr = insertNormalizationToSetVariance(expr)
printbr(expr)
expr = insertNormalizationToSetVariance(expr)
printbr(expr)
printbr()

local expr = ABar'_IJ'
printbr(expr)
expr = insertNormalizationToSetVariance(expr)
printbr(expr)
printbr()

local expr = beta'^k' * gamma'_ik'
printbr(expr)
expr = insertNormalizationToSetVariance(expr)
printbr(expr)
printbr()

local expr = beta'^k' * gamma'_ik,j'
printbr(expr)
expr = insertNormalizationToSetVariance(expr)
printbr(expr)
printbr()

local expr = beta'^i_,j'
printbr(expr)
expr = insertNormalizationToSetVariance(expr)
printbr(expr)
printbr()

local expr = beta'^i_,j' * alpha'_,i'
printbr(expr)
expr = insertNormalizationToSetVariance(expr)
printbr(expr)
printbr()

os.exit()
--]]



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

dt_gamma_ll_def = dt_gamma_ll_def:splitOffDerivIndexes()
dt_gamma_ll_def = insertMetricsToSetVariance(dt_gamma_ll_def, beta'^i', gamma)
	:tidyIndexes()
	:reindex{a='k'}
printbr(dt_gamma_ll_def)

dt_gamma_ll_def = dt_gamma_ll_def()
printbr(dt_gamma_ll_def)

dt_gamma_ll_def[2] = dt_gamma_ll_def[2]:substIndex(conn_lll_def)()
printbr(dt_gamma_ll_def)

dt_gamma_ll_def = dt_gamma_ll_def:symmetrizeIndexes(gamma, {1,2})()
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

local using = conn_ull_def:reindex{ijk='kij'}
printbr('using', using)
dt_K_ll_def = dt_K_ll_def
	--:substIndex(conn_ull_def:switch())
	:subst(using)
dt_K_ll_def = betterSimplify(dt_K_ll_def)
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


-- alpha

printHeader'Bona-Masso lapse and shift evolution:'
printbr()

printbr'lapse evolution:'
local dt_alpha_def = alpha'_,t':eq(alpha'_,i' * beta'^i' - alpha^2 * f * K)
printbr(dt_alpha_def)


printHeader'using locally-Minkowski normalized coordinates:'
local dt_alpha_norm_def = insertNormalizationToSetVariance(dt_alpha_def:splitOffDerivIndexes())
printbr(dt_alpha_norm_def)
printbr()

--[[ not needed because there are no (non-derivative) summed indexes in alpha_,t's rhs
printbr'cancelling forward and inverse transforms, and simplifying deltas...'
dt_alpha_norm_def = replaceNormalizationTransformsWithDeltas(dt_alpha_norm_def)
	:simplifyMetrics()
printbr(dt_alpha_norm_def) 
--]]


-- beta^i

printbr'shift evolution:'
local dt_beta_u_def = beta'^i_,t':eq(B'^i')
printbr(dt_beta_u_def)

printHeader'using locally-Minkowski normalized coordinates:'
local dt_beta_U_norm_def = insertNormalizationToSetVariance(dt_beta_u_def)
printbr(dt_beta_U_norm_def)
dt_beta_U_norm_def = betterSimplify(dt_beta_U_norm_def)
printbr(dt_beta_U_norm_def)

printbr('using', e'^i_I,t':eq(0))
dt_beta_U_norm_def = betterSimplify(dt_beta_U_norm_def:replace(e'^i_I,t', 0))
printbr(dt_beta_U_norm_def)

printbr'transforming by inverse of normalization basis'
dt_beta_U_norm_def = dt_beta_U_norm_def * e'_i^J'
dt_beta_U_norm_def = betterSimplify(dt_beta_U_norm_def )
dt_beta_U_norm_def = replaceNormalizationTransformsWithDeltas(dt_beta_U_norm_def)
	:simplifyMetrics()
	:reindex{J='I'}
dt_beta_U_norm_def = betterSimplify(dt_beta_U_norm_def)

printbr(dt_beta_U_norm_def)
printbr()


-- B^i

printbr('$B^i$ evolution:')
local dt_B_u_def = B'^i_,t':eq(frac(3,4) * LambdaBar'^i_,t' - eta * B'^i')
printbr(dt_B_u_def) 
printbr()

printHeader'using locally-Minkowski normalized coordinates:'
local dt_B_U_norm_def = insertNormalizationToSetVariance(dt_B_u_def)
	:simplify()
	:replace(e'^i_I,t', 0)		-- set normalization transform time derivative to zero
dt_B_U_norm_def = betterSimplify(dt_B_U_norm_def)
printbr(dt_B_U_norm_def) 

-- remove basis transform on lhs
dt_B_U_norm_def = dt_B_U_norm_def * e'_i^J'
dt_B_U_norm_def = betterSimplify(dt_B_U_norm_def)
dt_B_U_norm_def = replaceNormalizationTransformsWithDeltas(dt_B_U_norm_def)
	:simplifyMetrics()
	:reindex{J='I'}
printbr(dt_B_U_norm_def) 
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


printbr'conformal trace-free extrinsic curvature constraint:'
local tr_ABar_eq_0 = ABar'^i_i':eq(0)
printbr(tr_ABar_eq_0)
printbr()


printHeader'trace-free extrinsic curvature derivative:'
local partial_K_lll_from_partial_A_lll_K = K_ll_from_A_ll_K'_,k'()
printbr(partial_K_lll_from_partial_A_lll_K)
printbr()


printHeader'Jacobi identity:'
local tr_connBar_l_from_det_gammaBar = GammaBar'^j_ji':eq(frac(1,2) * gammaBar'_,i' / gammaBar)
printbr(tr_connBar_l_from_det_gammaBar)
-- 1/2 g_,i / g = conn^j_ji
-- 1/2 g_,i / g = 1/2 g^jk (g_kj,i + g_ki,j - g_ji,k)
-- 1/2 g_,i / g = 1/2 (g^jk g_jk,i + g^jk g_ij,k - g^jk g_ij,k)
-- g_,i / g = g^jk g_jk,i
local jacobi_identity_def = (gammaBar'^jk' * gammaBar'_jk,i'):eq(gammaBar'_,i' / gammaBar)
printbr(jacobi_identity_def)
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

printbr('using', dt_gamma_ll_def)
dt_W_def = dt_W_def:subst(dt_gamma_ll_def)():factorDivision()
printbr(dt_W_def)

local using = (gamma'^ij' * K'_ij'):eq(K)
printbr('using', using)
dt_W_def = dt_W_def:subst(using)()
printbr(dt_W_def)

--[[
printbr('using', conn_lll_from_connBar_lll_W_gammaBar_ll, ',', gamma_ll_from_gammaBar_ll_W, ',', gamma_uu_from_gammaBar_uu_W)
dt_W_def = dt_W_def:substIndex(conn_lll_from_connBar_lll_W_gammaBar_ll, gamma_ll_from_gammaBar_ll_W, gamma_uu_from_gammaBar_uu_W)()
printbr(dt_W_def)
--]]

printbr('using', gamma_ll_from_gammaBar_ll_W, ',', gamma_uu_from_gammaBar_uu_W, ',', partial_gamma_lll_from_partial_gammaBar_lll_W)
dt_W_def = dt_W_def:substIndex(
	gamma_ll_from_gammaBar_ll_W,
	gamma_uu_from_gammaBar_uu_W,
	partial_gamma_lll_from_partial_gammaBar_lll_W)
dt_W_def = betterSimplify(dt_W_def)
printbr(dt_W_def)

printbr('simplifying')
dt_W_def = simplifyBarMetrics(dt_W_def)
	:tidyIndexes()
	:symmetrizeIndexes(GammaBar, {2,3})
	:symmetrizeIndexes(delta, {1,2})
dt_W_def = betterSimplify(dt_W_def)
printbr(dt_W_def)

local using = (delta'^b_b'):eq(spatialDim)
printbr('using', using)
dt_W_def = dt_W_def 
	:subst(using)	-- hmm, how to auto-simplify this ...
	:simplify()
	:reindex{abc='ijk'}
printbr(dt_W_def)

printbr('using', jacobi_identity_def)
dt_W_def = dt_W_def:subst(jacobi_identity_def)
dt_W_def = betterSimplify(dt_W_def)
printbr(dt_W_def)

-- why won't substindex work?
-- doesn't seem to work when there's a sum-index on the lhs
-- TODO test case plz
--dt_W_def = dt_W_def:substIndet(tr_connBar_l_from_det_gammaBar)
--dt_W_def = dt_W_def:substIndex(tr_connBar_l_from_det_gammaBar:reindex{j='k'})
--dt_W_def = betterSimplify(dt_W_def:subst(tr_connBar_l_from_det_gammaBar))
--printbr(dt_W_def)
printbr()



printHeader'using locally-Minkowski normalized coordinates:'
local dt_W_norm_def = insertNormalizationToSetVariance(dt_W_def)
	:simplify()
	:replace(e'^i_I,t', 0)		-- set normalization transform time derivative to zero
dt_W_norm_def = betterSimplify(dt_W_norm_def)
printbr(dt_W_norm_def) 

--[[ not needed because there are no (non-derivative) summed indexes in W_,t's rhs
printbr'cancelling forward and inverse transforms, and simplifying deltas...'
dt_W_norm_def = replaceNormalizationTransformsWithDeltas(dt_W_norm_def)
	:simplifyMetrics()
printbr(dt_W_norm_def) 
--]]

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


--printHeader'skipping epsilonBar_ij,t'
-- [=====[
printHeader'conformal metric evolution:'
local dt_gammaBar_ll_def = gammaBar_ll_from_gamma_ll_W'_,t'
printbr(dt_gammaBar_ll_def)

printbr'distributing derivative...'
dt_gammaBar_ll_def = dt_gammaBar_ll_def()
printbr(dt_gammaBar_ll_def)

printbr('using', dt_gamma_ll_def)
dt_gammaBar_ll_def = dt_gammaBar_ll_def:subst(dt_gamma_ll_def)()
printbr(dt_gammaBar_ll_def)

printbr('using', dt_W_def)
dt_gammaBar_ll_def = dt_gammaBar_ll_def:substIndex(dt_W_def)
dt_gammaBar_ll_def = dt_gammaBar_ll_def:tidyIndexes():reindex{a='k'}
dt_gammaBar_ll_def = betterSimplify(dt_gammaBar_ll_def)
printbr(dt_gammaBar_ll_def )

printbr('using', gamma_ll_from_gammaBar_ll_W)
dt_gammaBar_ll_def = dt_gammaBar_ll_def:substIndex(
	gamma_ll_from_gammaBar_ll_W,
	partial_gamma_lll_from_partial_gammaBar_lll_W:reindex{ijk='ija'}
)
dt_gammaBar_ll_def = betterSimplify(dt_gammaBar_ll_def)
printbr(dt_gammaBar_ll_def )

printbr('using', K_ll_from_ABar_ll_gammaBar_ll_K)
dt_gammaBar_ll_def = dt_gammaBar_ll_def:substIndex(K_ll_from_ABar_ll_gammaBar_ll_K)
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

printHeader'using locally-Minkowski normalized coordinates:'
local dt_epsilonBar_LL_norm_def = insertNormalizationToSetVariance(dt_epsilonBar_ll_def)
	:simplify()
	-- set normalization transform time derivative to zero
	:replace(e'^k_K,t', 0)
	:replace(e'_i^I_,t', 0)
	:replace(e'_j^J_,t', 0)
dt_epsilonBar_LL_norm_def = betterSimplify(dt_epsilonBar_LL_norm_def)
printbr(dt_epsilonBar_LL_norm_def) 
printbr()

-- remove basis transform on lhs
dt_epsilonBar_LL_norm_def = dt_epsilonBar_LL_norm_def * e'^i_M' * e'^j_N'
dt_epsilonBar_LL_norm_def = betterSimplify(dt_epsilonBar_LL_norm_def)
dt_epsilonBar_LL_norm_def = replaceNormalizationTransformsWithDeltas(dt_epsilonBar_LL_norm_def)
	:simplifyMetrics()
	:reindex{IJMN='MNIJ'}
printbr(dt_epsilonBar_LL_norm_def) 
printbr()
--]=====]


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



--[[
printHeader'conformal connection evolution:'
local dt_connBar_ull_def = connBar_ull_def'_,t'
printbr(dt_connBar_ull_def)

dt_connBar_ull_def = dt_connBar_ull_def()
printbr(dt_connBar_ull_def)

printbr('using', dt_gammaBar_uu_from_gammaBar_uu_partial_gammaBar_lll)
dt_connBar_ull_def = dt_connBar_ull_def:substIndex(dt_gammaBar_uu_from_gammaBar_uu_partial_gammaBar_lll)()
printbr(dt_connBar_ull_def)

printbr('using', dt_gammaBar_ll_def)
dt_connBar_ull_def = dt_connBar_ull_def:substIndex(dt_gammaBar_ll_def)
printbr(dt_connBar_ull_def)

printbr('simplifying metrics')
dt_connBar_ull_def = simplifyBarMetrics(dt_connBar_ull_def)
printbr(dt_connBar_ull_def)

printbr('using', dt_gammaBar_ll_def)
dt_connBar_ull_def = dt_connBar_ull_def
	:replaceIndex(gammaBar'_jk,mt', gammaBar'_jk,t''_,m')
	:substIndex(dt_gammaBar_ll_def:reindex{ijkm='jkpq'})
printbr(dt_connBar_ull_def)
dt_connBar_ull_def = dt_connBar_ull_def
	:tidyIndexes()
	:symmetrizeIndexes(gammaBar, {1,2})
	:symmetrizeIndexes(ABar, {1,2})
	:symmetrizeIndexes(delta, {1,2})
dt_connBar_ull_def = betterSimplify(dt_connBar_ull_def)
printbr(dt_connBar_ull_def)
printbr()
--]]


--printHeader'skipping LambdaBar^i_,t'
-- [=====[
printHeader'grid vs conformal connection difference evolution:'

local using = calC'^i_,t':eq(0)
printbr('assuming', using)
local dt_LambdaBar_u_def = LambdaBar_u_def'_,t'():subst(using )()
printbr(dt_LambdaBar_u_def)

printbr('using', DeltaBar_u_def)
dt_LambdaBar_u_def = dt_LambdaBar_u_def
	:splitOffDerivIndexes()
	:subst(DeltaBar_u_def)
	:simplify()
printbr(dt_LambdaBar_u_def)

local using = DeltaBar_ull_def
printbr('using', using)
dt_LambdaBar_u_def = dt_LambdaBar_u_def:splitOffDerivIndexes():substIndex(using)()
printbr(dt_LambdaBar_u_def)

-- constant grid:
local dt_GammaHat_ull_def = GammaHat'^i_jk,t':eq(0)
printbr('assuming', dt_GammaHat_ull_def)
dt_LambdaBar_u_def = dt_LambdaBar_u_def:subst(dt_GammaHat_ull_def)()
printbr(dt_LambdaBar_u_def)

printbr('using', connBar_ull_def)
dt_LambdaBar_u_def = dt_LambdaBar_u_def
	:splitOffDerivIndexes()
	:substIndex(connBar_ull_def)
dt_LambdaBar_u_def = betterSimplify(dt_LambdaBar_u_def)
printbr(dt_LambdaBar_u_def)

printbr('symmetrize', gammaBar'_ij')
dt_LambdaBar_u_def = dt_LambdaBar_u_def
	:tidyIndexes()
	:symmetrizeIndexes(gammaBar, {1,2})
printbr(dt_LambdaBar_u_def)

printbr('using', dt_gammaBar_uu_from_gammaBar_uu_partial_gammaBar_lll)
dt_LambdaBar_u_def = dt_LambdaBar_u_def:substIndex(dt_gammaBar_uu_from_gammaBar_uu_partial_gammaBar_lll)
dt_LambdaBar_u_def = betterSimplify(dt_LambdaBar_u_def)
printbr(dt_LambdaBar_u_def)

printbr('rearrange time derivative of', gammaBar'_ij', 'to come first')
dt_LambdaBar_u_def = betterSimplify(dt_LambdaBar_u_def)
	--[[ TODO fixme?
	:replaceIndex(gammaBar'_ab,cd', gammaBar'_ab,d''_,c')	-- assume the ,t is first
	--]]	
	-- [[ instead
	:replace(gammaBar'_ab,ct', gammaBar'_ab,t''_,c')
	:replace(gammaBar'_bc,at', gammaBar'_bc,t''_,a')
	--]]
printbr(dt_LambdaBar_u_def)

printbr('substitute', dt_gammaBar_ll_def)
dt_LambdaBar_u_def = dt_LambdaBar_u_def:substIndex(dt_gammaBar_ll_def)
printbr(dt_LambdaBar_u_def)

printbr'simplifying'
dt_LambdaBar_u_def = betterSimplify(dt_LambdaBar_u_def)
printbr(dt_LambdaBar_u_def)

printbr'tidying indexes'
dt_LambdaBar_u_def = dt_LambdaBar_u_def:tidyIndexes()
printbr(dt_LambdaBar_u_def)

printbr'simplifying'
dt_LambdaBar_u_def = betterSimplify(dt_LambdaBar_u_def)
printbr(dt_LambdaBar_u_def)

printbr'simplifying bar metrics'
dt_LambdaBar_u_def = simplifyBarMetrics(dt_LambdaBar_u_def)
printbr(dt_LambdaBar_u_def)

printbr'simplifying deltas'
dt_LambdaBar_u_def = dt_LambdaBar_u_def
	:replaceIndex(delta'_a^a', spatialDim) 
	:replaceIndex(delta'^a_a', spatialDim) 
printbr(dt_LambdaBar_u_def)

printbr('using', tr_ABar_eq_0)
dt_LambdaBar_u_def = dt_LambdaBar_u_def:substIndex(tr_ABar_eq_0)
dt_LambdaBar_u_def = betterSimplify(dt_LambdaBar_u_def)
dt_LambdaBar_u_def = betterSimplify(dt_LambdaBar_u_def)
printbr(dt_LambdaBar_u_def)

printbr('tidying indexes')
-- TODO make sure this case is in unit tests: gammaBar^jk beta^a_,a GammaBar^i_jk (was producing erroneously beta^d_,d GammaBar^id_d)
dt_LambdaBar_u_def = dt_LambdaBar_u_def:tidyIndexes()
dt_LambdaBar_u_def = betterSimplify(dt_LambdaBar_u_def)
printbr(dt_LambdaBar_u_def)

printbr('symmetrize', gammaBar'_ij')
dt_LambdaBar_u_def = dt_LambdaBar_u_def
	:symmetrizeIndexes(gammaBar, {1,2})
	:symmetrizeIndexes(beta, {2,3})	-- symmetrize derivative indexes
	:symmetrizeIndexes(GammaHat, {2,3})	-- TODO do this when GammaHat is substituted in
dt_LambdaBar_u_def = betterSimplify(dt_LambdaBar_u_def)
printbr(dt_LambdaBar_u_def)

printbr('factoring out', gammaBar'^ij', 'to form', ABar'_ij')
-- now put the ABar's in lower-lower form so they can be treated as a state variable
--dt_LambdaBar_u_def = dt_LambdaBar_u_def:replaceIndex(ABar'^ij', gammaBar'^ik' * ABar'_kl' * gammaBar'^lj')
dt_LambdaBar_u_def = insertMetricsToSetVariance(dt_LambdaBar_u_def, ABar'_ij', gammaBar)
printbr(dt_LambdaBar_u_def)

printbr('tidying indexes')
dt_LambdaBar_u_def = dt_LambdaBar_u_def:tidyIndexes()
dt_LambdaBar_u_def = betterSimplify(dt_LambdaBar_u_def)
printbr(dt_LambdaBar_u_def)

printbr('using', jacobi_identity_def)
--[[ not working
dt_LambdaBar_u_def = dt_LambdaBar_u_def:substIndex(jacobi_identity_def)
--]]
-- [[ manually
dt_LambdaBar_u_def = dt_LambdaBar_u_def
	:replace(gammaBar'^ab' * gammaBar'_ab,d', gammaBar'_,d' / gammaBar)
	:replace(gammaBar'^ab' * gammaBar'_ab,c', gammaBar'_,c' / gammaBar)
	:replace(gammaBar'^bc' * gammaBar'_bc,d', gammaBar'_,d' / gammaBar)
	:replace(gammaBar'^bc' * gammaBar'_bc,e', gammaBar'_,e' / gammaBar)
	:replace(gammaBar'^de' * gammaBar'_de,c', gammaBar'_,c' / gammaBar)
--]]
dt_LambdaBar_u_def = betterSimplify(dt_LambdaBar_u_def)
printbr(dt_LambdaBar_u_def)

printbr'tidying indexes'
dt_LambdaBar_u_def = dt_LambdaBar_u_def:tidyIndexes()
dt_LambdaBar_u_def = betterSimplify(dt_LambdaBar_u_def)
printbr(dt_LambdaBar_u_def)

printbr()


-- TODO properly reindex
-- maybe make a function to automatically do it
printHeader'using locally-Minkowski normalized coordinates:'
local dt_LambdaBar_U_norm_def = insertNormalizationToSetVariance(dt_LambdaBar_u_def)
	:simplify()
	:replace(e'^i_I,t', 0)		-- set normalization transform time derivative to zero
dt_LambdaBar_U_norm_def = betterSimplify(dt_LambdaBar_U_norm_def) 
printbr(dt_LambdaBar_U_norm_def) 

-- remove basis transform on lhs
printbr'cancelling forward and inverse transforms, and simplifying deltas...'
dt_LambdaBar_U_norm_def = dt_LambdaBar_U_norm_def * e'_i^J'
dt_LambdaBar_U_norm_def = betterSimplify(dt_LambdaBar_U_norm_def)
	
dt_LambdaBar_U_norm_def = replaceNormalizationTransformsWithDeltas(dt_LambdaBar_U_norm_def)
	:simplifyMetrics()
	:reindex{IJ='JI'}
printbr(dt_LambdaBar_U_norm_def) 
printbr()
--]=====]


printHeader'extrinsic curvature trace evolution:'

local dt_K_def = K_def'_,t'
printbr(dt_K_def)

printbr'simplifying'
dt_K_def = dt_K_def()
printbr(dt_K_def)

printbr('using', dt_gamma_uu_from_gamma_uu_partial_gamma_lll)
dt_K_def = dt_K_def:subst(dt_gamma_uu_from_gamma_uu_partial_gamma_lll)
printbr(dt_K_def)

printbr('using', dt_gamma_ll_def)
dt_K_def = dt_K_def:substIndex(dt_gamma_ll_def)
dt_K_def = dt_K_def()
printbr(dt_K_def)

printbr('using', K_ll_from_ABar_ll_gammaBar_ll_K, ',', gamma_uu_from_gammaBar_uu_W, ',', gamma_ll_from_gammaBar_ll_W)
dt_K_def = dt_K_def:substIndex(K_ll_from_ABar_ll_gammaBar_ll_K, gamma_uu_from_gammaBar_uu_W, gamma_ll_from_gammaBar_ll_W)
dt_K_def = dt_K_def()
printbr(dt_K_def)

printbr'simplifying bar metrics'
dt_K_def = simplifyBarMetrics(dt_K_def)
printbr(dt_K_def)

printbr('using', tr_ABar_eq_0)
dt_K_def = dt_K_def:replaceIndex(ABar'_i^i', 0)()
printbr(dt_K_def)

printbr('using', delta'_j^j':eq(spatialDim))
dt_K_def = dt_K_def
	:replaceIndex(delta'_j^j', spatialDim)
	:replaceIndex(delta'^j_j', spatialDim)
	:simplify()
printbr(dt_K_def)

printbr('symmetrizing', gammaBar'_ij')
dt_K_def = dt_K_def
	--:tidyIndexes()	--{fixed='t'}	-- the fact that K_,t has a t in it, and most expressions don't, breaks the tidyIndexes() function
	--:simplify()
	:symmetrizeIndexes(gammaBar, {1,2})
	:simplify()
printbr(dt_K_def)

printbr('using definition of', dt_K_ll_def[1])
dt_K_def = dt_K_def:substIndex(dt_K_ll_def)()
printbr(dt_K_def)

printbr('using', K_ll_from_ABar_ll_gammaBar_ll_K, ',', gamma_uu_from_gammaBar_uu_W, ',', gamma_ll_from_gammaBar_ll_W)
dt_K_def = dt_K_def:substIndex(K_ll_from_ABar_ll_gammaBar_ll_K, gamma_uu_from_gammaBar_uu_W, gamma_ll_from_gammaBar_ll_W)
printbr(dt_K_def)

printbr('simplifying bar metrics')
dt_K_def = simplifyBarMetrics(dt_K_def)
	:symmetrizeIndexes(gammaBar, {1,2})
dt_K_def = betterSimplify(dt_K_def)
printbr(dt_K_def)

printbr('using', tr_ABar_eq_0)
dt_K_def = dt_K_def
	:symmetrizeIndexes(ABar, {1,2})
	:replaceIndex(ABar'_j^j', 0)
	:replaceIndex(ABar'^j_j', 0)
dt_K_def = betterSimplify(dt_K_def)
printbr(dt_K_def)

printbr('using', delta'_j^j':eq(spatialDim))
dt_K_def = dt_K_def
	:replaceIndex(delta'_j^j', spatialDim)
	:replaceIndex(delta'^j_j', spatialDim)
dt_K_def = betterSimplify(dt_K_def)
printbr(dt_K_def)

-- now that there's no more _,t terms, I can use tidyIndexes on the RHS only
printbr'tidying indexes'
dt_K_def[2] = dt_K_def[2]:tidyIndexes()
dt_K_def = betterSimplify(dt_K_def)
printbr(dt_K_def)

printbr('using', K_ll_from_ABar_ll_gammaBar_ll_K)
dt_K_def = dt_K_def
	:replace(K'_bc,a', K'_bc''_,a')
	:substIndex(K_ll_from_ABar_ll_gammaBar_ll_K)
dt_K_def = betterSimplify(dt_K_def)
printbr(dt_K_def)

printbr('simplifying bar metrics')
dt_K_def = simplifyBarMetrics(dt_K_def)
	:symmetrizeIndexes(gammaBar, {1,2})
dt_K_def = betterSimplify(dt_K_def)
printbr(dt_K_def)

printbr('using', tr_ABar_eq_0)
dt_K_def = dt_K_def
	:symmetrizeIndexes(ABar, {1,2})
	:replaceIndex(ABar'_j^j', 0)
	:replaceIndex(ABar'^j_j', 0)
dt_K_def = betterSimplify(dt_K_def)
printbr(dt_K_def)

printbr('using', delta'_j^j':eq(spatialDim))
dt_K_def = simplifyBarMetrics(dt_K_def)()
	:replaceIndex(delta'_j^j', spatialDim)
	:replaceIndex(delta'^j_j', spatialDim)
dt_K_def = betterSimplify(dt_K_def)
printbr(dt_K_def)

printbr('using', conn_lll_def, ',', conn_ull_def, ',', gamma_uu_from_gammaBar_uu_W, ',', gamma_ll_from_gammaBar_ll_W)
dt_K_def = dt_K_def:substIndex(conn_lll_def, conn_ull_def, gamma_uu_from_gammaBar_uu_W, gamma_ll_from_gammaBar_ll_W)
dt_K_def = betterSimplify(dt_K_def)
printbr(dt_K_def)

printbr('simplifying bar metrics')
dt_K_def = simplifyBarMetrics(dt_K_def)
	:symmetrizeIndexes(gammaBar, {1,2})
dt_K_def = betterSimplify(dt_K_def)
printbr(dt_K_def)

printbr('using', tr_ABar_eq_0)
dt_K_def = dt_K_def
	:symmetrizeIndexes(ABar, {1,2})
	:replaceIndex(ABar'_j^j', 0)
	:replaceIndex(ABar'^j_j', 0)
dt_K_def = betterSimplify(dt_K_def)
printbr(dt_K_def)

printbr('using', delta'_j^j':eq(spatialDim))
dt_K_def = simplifyBarMetrics(dt_K_def)()
	:replaceIndex(delta'_j^j', spatialDim)
	:replaceIndex(delta'^j_j', spatialDim)
dt_K_def = betterSimplify(dt_K_def)
printbr(dt_K_def)

printbr('using', partial_gamma_lll_from_partial_gammaBar_lll_W, ',', partial_gammaBar_lll_from_connBar_lll)
dt_K_def = dt_K_def:substIndex(partial_gamma_lll_from_partial_gammaBar_lll_W, partial_gammaBar_lll_from_connBar_lll)
dt_K_def = betterSimplify(dt_K_def)
printbr(dt_K_def)

printbr('simplifying bar metrics')
dt_K_def = simplifyBarMetrics(dt_K_def)
	:symmetrizeIndexes(gammaBar, {1,2})
dt_K_def = betterSimplify(dt_K_def)
printbr(dt_K_def)

printbr('using', tr_ABar_eq_0)
dt_K_def = dt_K_def
	:symmetrizeIndexes(ABar, {1,2})
	:replaceIndex(ABar'_j^j', 0)
	:replaceIndex(ABar'^j_j', 0)
dt_K_def = betterSimplify(dt_K_def)
printbr(dt_K_def)

printbr('using', delta'_j^j':eq(spatialDim))
dt_K_def = simplifyBarMetrics(dt_K_def)()
	:replaceIndex(delta'_j^j', spatialDim)
	:replaceIndex(delta'^j_j', spatialDim)
dt_K_def = betterSimplify(dt_K_def)
printbr(dt_K_def)

printbr('symmetrizing', GammaBar'^i_jk')
dt_K_def = dt_K_def:tidyIndexes()
	:symmetrizeIndexes(GammaBar, {2,3})
printbr(dt_K_def)

local using = (S'_ab' * gammaBar'^ab'):eq(S / W^2)
printbr('using', using)
dt_K_def = dt_K_def :subst(using)
printbr(dt_K_def)

printbr('factoring out', gammaBar'^ij', 'to form', ABar'_ij')
dt_K_def = insertMetricsToSetVariance(dt_K_def, ABar'_ij', gammaBar)
printbr(dt_K_def)	

printbr('using', GammaBar'^ab_b':eq(LambdaBar'^a' - calC'^a' + GammaHat'^a'))
dt_K_def = dt_K_def 
	-- GammaBar^ab_b = GammaBar^a = DeltaBar^a + GammaHat^a
	-- DeltaBar^a = LambdaBar^a - calC^a
	-- so GammaBar^ab_b = LambdaBar^a - calC^a + GammaHat^a
	:replace(GammaBar'^ab_b', LambdaBar'^a' - calC'^a' + GammaHat'^a')	
	:replaceIndex(GammaBar'^ba_b', gammaBar'^ab' * gammaBar'_,b' / gammaBar)
	:replaceIndex(GammaBar'_b^ab', gammaBar'^ab' * gammaBar'_,b' / gammaBar)
	:subst(connBar_lll_def:reindex{ijk='bac'})
--	:reindex{abc='ijk'}
dt_K_def = betterSimplify(dt_K_def)
	:symmetrizeIndexes(gammaBar, {1,2})
dt_K_def = betterSimplify(dt_K_def)
printbr(dt_K_def)

printbr('symmetrizing', GammaBar'^i_jk')
dt_K_def = dt_K_def:tidyIndexes()
dt_K_def = betterSimplify(dt_K_def)
dt_K_def = dt_K_def
	:symmetrizeIndexes(ABar, {1,2})
	:symmetrizeIndexes(gammaBar, {1,2})
	:symmetrizeIndexes(GammaBar, {2,3})
dt_K_def = betterSimplify(dt_K_def)
printbr(dt_K_def)
printbr()

printHeader'using locally-Minkowski normalized coordinates:'
local dt_K_norm_def = insertNormalizationToSetVariance(dt_K_def)
	:simplify()
	:replace(e'^i_I,t', 0)		-- set normalization transform time derivative to zero
dt_K_norm_def = betterSimplify(dt_K_norm_def)
printbr(dt_K_norm_def) 

printbr'cancelling forward and inverse transforms, and simplifying deltas...'
dt_K_norm_def = replaceNormalizationTransformsWithDeltas(dt_K_norm_def)
	:simplifyMetrics()
printbr(dt_K_norm_def) 
printbr()


printHeader'trace-free extrinsic curvature evolution:'
local dt_A_ll_def = A_ll_def'_,t'()
printbr(dt_A_ll_def)
printbr()


printHeader'conformal trace-free extrinsic curvature evolution:'
local dt_ABar_ll_def = ABar_ll_def'_,t'()
printbr(dt_ABar_ll_def)

printbr('using', dt_W_def)
dt_ABar_ll_def = dt_ABar_ll_def:substIndex(dt_W_def)
printbr(dt_ABar_ll_def)

printbr('using', dt_A_ll_def)
dt_ABar_ll_def = dt_ABar_ll_def:subst(dt_A_ll_def)
printbr(dt_ABar_ll_def)

printbr('using', dt_K_ll_def)
dt_ABar_ll_def = dt_ABar_ll_def:subst(dt_K_ll_def)
printbr(dt_ABar_ll_def)

printbr('using', dt_K_def)
dt_ABar_ll_def = dt_ABar_ll_def:subst(dt_K_def:reindex{ij='mn'})
printbr(dt_ABar_ll_def)

printbr'simplifying'
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
dt_ABar_ll_def = dt_ABar_ll_def
	:substIndex(connBar_ull_def)

dt_ABar_ll_def = dt_ABar_ll_def:replace(GammaBar'^bc_a', gammaBar'^bd' * GammaBar'_dea' * gammaBar'^ec')
	:substIndex(connBar_lll_def)
dt_ABar_ll_def = betterSimplify(dt_ABar_ll_def)
	:tidyIndexes()
dt_ABar_ll_def = betterSimplify(dt_ABar_ll_def)
dt_ABar_ll_def = dt_ABar_ll_def 
	:symmetrizeIndexes(ABar, {1,2})
	:symmetrizeIndexes(gammaBar, {1,2})
dt_ABar_ll_def = betterSimplify(dt_ABar_ll_def)


printbr(dt_ABar_ll_def)
printbr()


printHeader'using locally-Minkowski normalized coordinates:'
local dt_ABar_LL_norm_def = insertNormalizationToSetVariance(dt_ABar_ll_def)
	:simplify()
	:replace(e'_i^I_,t', 0)		-- set normalization transform time derivative to zero
	:replace(e'_j^J_,t', 0)
dt_ABar_LL_norm_def = betterSimplify(dt_ABar_LL_norm_def)
printbr(dt_ABar_LL_norm_def) 

-- remove basis transform on lhs
printbr'cancelling forward and inverse transforms, and simplifying deltas...'
dt_ABar_LL_norm_def = dt_ABar_LL_norm_def * e'^i_M' * e'^j_N'
dt_ABar_LL_norm_def = betterSimplify(dt_ABar_LL_norm_def)

dt_ABar_LL_norm_def = replaceNormalizationTransformsWithDeltas(dt_ABar_LL_norm_def)
	:simplifyMetrics()
	:reindex{IJMN='MNIJ'}
printbr(dt_ABar_LL_norm_def) 
printbr()

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
printbr()

printbr'locally-Minkowski:'
printbr(dt_alpha_norm_def)
printbr(dt_beta_U_norm_def)
printbr(dt_B_U_norm_def)
printbr(dt_W_norm_def)
printbr(dt_K_norm_def)
printbr(dt_epsilonBar_LL_norm_def)
printbr(dt_ABar_LL_norm_def)
printbr(dt_LambdaBar_U_norm_def)
printbr()


printbr()
printbr'<hr>'
printHeader'writing results...'

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
	
	'dt_alpha_norm_def = '..export.SymMath(dt_alpha_norm_def),
	'dt_beta_U_norm_def = '..export.SymMath(dt_beta_U_norm_def),
	'dt_B_U_norm_def = '..export.SymMath(dt_B_U_norm_def),
	'dt_W_norm_def = '..export.SymMath(dt_W_norm_def),
	'dt_K_norm_def = '..export.SymMath(dt_K_norm_def),
	'dt_epsilonBar_LL_norm_def = '..export.SymMath(dt_epsilonBar_LL_norm_def),
	'dt_ABar_LL_norm_def = '..export.SymMath(dt_ABar_LL_norm_def),
	'dt_LambdaBar_U_norm_def = '..export.SymMath(dt_LambdaBar_U_norm_def),

	[[
return {
	{dt_alpha_def = dt_alpha_def},
	{dt_beta_u_def = dt_beta_u_def},
	{dt_W_def = dt_W_def},
	{dt_K_def = dt_K_def},
	{dt_epsilonBar_ll_def = dt_epsilonBar_ll_def},
	{dt_ABar_ll_def = dt_ABar_ll_def},
	{dt_LambdaBar_u_def = dt_LambdaBar_u_def},
	{dt_B_u_def = dt_B_u_def},

	{dt_alpha_norm_def = dt_alpha_norm_def},
	{dt_beta_U_norm_def = dt_beta_U_norm_def},
	{dt_B_U_norm_def = dt_B_U_norm_def},
	{dt_W_norm_def = dt_W_norm_def},
	{dt_K_norm_def = dt_K_norm_def},
	{dt_epsilonBar_LL_norm_def = dt_epsilonBar_LL_norm_def},
	{dt_ABar_LL_norm_def = dt_ABar_LL_norm_def},
	{dt_LambdaBar_U_norm_def = dt_LambdaBar_U_norm_def},
}
]]
}:concat'\n\n\n'..'\n'



-- DONE
printHeader()
io.stderr:write('TOTAL: '..(timer() - startTime)..'\n')
io.stderr:flush()
print(MathJax.footer)
