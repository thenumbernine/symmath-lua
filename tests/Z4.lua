#!/usr/bin/env luajit
--[[
Z4 equations, in index notation

Based on my worksheet at: https://thenumbernine.github.io/math/Numerical%20Relativity/Z4%20From%20Killing%20Vectors.html
Which lists a few Z4 formulations in literature, then derives.
Itself is based on the "Differential Geometry" worksheets at https://thenumbernine.github.io/

rewritten in terms of first order hyperbolic coordinates
and for a general metric (i.e. difference-of-connections) instead of strictly for cartesian.
same idea as my 'BSSN - index' worksheet (why not just call it 'BSSN' ?)

in fact this is a lot like my 'numerical-relativity-codegen'
but runs a lot faster ... maybe it should replace it?
and it produces the tensor linear systems that my "Documents/Math/Numerical Relativity" notes have, which is nice

TODO TODO

why did I start working on this when I had "Z4 metric-invariant.symmath" to work on?
move this over to a .symmath file, get rid of this and get rid of the old .symmath file ...
and TODO have an "export to html" features in symmath/standalone.lua

TODO

my "Math Worksheets/Differential Geometry" worksheets that branch off into ADM document how to go from the EFE to ADM ...
but I don't anywhere document how to go from the Z4 EFE-with-Killing-vectors to Z4-ADM ...

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
local xs = xNames:mapi(function(name) return var(name) end)
local x,y,z = xs:unpack()
-- time
local t = var't'
local txs = table{t}:append(xs)


--[[
set to true to use α_,i as a state var, instead of log(α)_,i
using log(α)_,i is more common
using α_,i can include both positive and negative α's
flux jacobian looks the same?
--]]
useDAlphaAsStateVar = false

--[[
for the gauge vars, should we move the shift-derivative of the Lie derivative into the flux?
--]]
makeFluxForGaugeVars = true

--[[
pick only one of these
or pick none = keep lapse as a generic variable 'f'
--]]
useLapseF_1PlusLog = false		-- f = 2/α
useLapseF_geodesic = false		-- f = 0
useLapseF_timeHarmonic = false	-- f = 1

--[[
pick one of these for the eigensystem
TODO how about generating all of them at once?
for the sake of flux and source term code generation, thats fine
for the sake of eigensystem computations it gets difficult, so better do one at a time
so then TODO turn this into an 'eigensystem_' var?
--]]

-- 2005 Bona et al, section B.1, "to convert the minimal distortion elliptic equations into time-dependent parabolic equations by means of the Hamilton-Jacobi method"
useShift = 'HarmonicParabolic'
-- ... and its hyperbolic version.  no literature has this ... probably for a good reason.
--useShift = 'HarmonicHyperbolic'
--useShift = 'MinimalDistortionParabolic'	-- eh out of commission until I can think of what to do with the 2nd derivatives
--useShift = 'MinimalDistortionHyperbolic'
--useShift = 'GammaDriverParabolic'			-- also out of commission
--useShift = 'GammaDriverHyperbolic'

--[[
within shift equations, exchange _,t with _,t - _,k β^k
--]]
useShiftingShift = true

--[[
include α, γ_ij in the calculations and code-generation
--]]
flux_includeGaugeVars = true

--[[
include Z_k and Θ in the flux and source codegen
--]]
flux_includeZVars = true

--[[
consider β^i b^i_j B^i in the flux and source vars
--]]
flux_includeShiftVars = true


--[[
include α, γ_ij
--]]
eigensystem_includeGaugeVars = true

--[[
consider Z_k,t and Θ_,t in the eigen decomposition
turns out these two have a very ugly wavespeed that chokes up the solver
--]]
eigensystem_includeZVars = true

--[[
add β^i, b^i_j, B^i from the eigensystem vars
evaluating shiftless + remove zero rows = the same as setting this to 'false'

TODO notice that, if you do use shift, but you don't set this, then you will end up with b^l_k,r's in the rhs ... so you'll have derivs in the rhs
TODO also notice that setting this to false will break things right now.
... I think until I separate out the flux maybe?
--]]
eigensystem_includeShiftVars = true

--[[
remove zero rows from expanded flux jacobian matrix?
--]]
eigensystem_removeZeroRows = false

--[[
whether to only evaluate the shiftless eigensystem
by default the β^x's are removed from the flux
but this will remove any other shift terms as well
TODO now courtesy of my homogeneity flux jacobian design, there's always a -U column at β^x
therefore this does nothing without eigensystem_includeShiftVars=false as well
--]]
eigensystem_removeShiftVars = false


--[[
once we have our full dU/dt + dF/dU dU/dx,
set this to true to simplify the dF/dU terms to be only in terms of U (and gamma^ij and df/dalpha)
set this to false to keep it in simplest terms
--]]
eigensystem_exportOnlyUs = true

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

function separateSum(sum, cond)
	local with = table()
	local without = table()
	for x in sum:iteradd() do
		if cond(x) then
			with:insert(x)
		else
			without:insert(x)
		end
	end
	return tableToAdd(with), tableToAdd(without)
end

function removeCommaDeriv(expr, symbolMustBe)
	if Constant.isValue(expr, 0) then return expr end
	assert(Tensor.Ref:isa(expr))
	if symbolMustBe then
		assert(expr[#expr].symbol == symbolMustBe)
	end
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

	local gamma = Tensor.metricVariable

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
				if Tensor.Ref.matchesDegreeAndDeriv(y,find) then
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
	return tableToAdd(newaddterms)
end


-- make sure indexes are raised-lowered in matching manner
-- TODO this doesn't seem to work for single-term sums: d_ki^k vs d^k_ik
function simplifySumIndexes(expr)
	local prods = expr:simplifyAddMulDiv():sumToTable()
	for k=1,#prods do
		prod = prods[k]:clone()
		prods[k] = prod
		local fixed, sum, extra = prod:getIndexesUsed()
--for _,index in ipairs(sum) do
--	printbr('sum index', index)
--end
		local sumIndexSymbols = sum:mapi(function(index) return true, index.symbol end):setmetatable(nil)
		local lowerForSumIndexSymbol = table(sumIndexSymbols):setmetatable(nil)
		local terms = prod:mulToTable()
		local modified
		for i=1,#terms do
			local term = terms[i]
--printbr('in term', term)
			-- if term has a sum index then set it to the current sum index lower/upper state (lower first, upper second)
			if Tensor.Ref:isa(term) then
				term = term:clone()
				terms[i] = term
				for j=2,#term do
					local symj = term[j].symbol
--printbr('found index', term[j])
					if sumIndexSymbols[symj] then
					-- TODO NOT ACROSS COMMA DERIVATIVES
					-- find all instances of the sum index in the expression
					-- and make sure there's no comma derivs in any indexes
--printbr('is a sum index')
						local newlower = lowerForSumIndexSymbol[symj]
						--if newlower ~= term[j].lower then ... TODO clone upon request
						term[j].lower = newlower
--printbr('lower is now', term[j].lower)
						lowerForSumIndexSymbol[symj] = not lowerForSumIndexSymbol[symj]
					end
				end
			end
		end
		prods[k] = tableToMul(terms)
	end
	return tableToAdd(prods)
end

--[[ testing
local d = var'd'
print(simplifySumIndexes(d'_ab^c' * d'^ab_c'))
os.exit()
--]]


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
			result:insert(tableToAdd(terms))
		else
			result:insert(tableToAdd(terms)(' ,_'..symbol))
		end
	end
	return tableToAdd(result)
end

-- TODO the 'fixedsymbols' could be inferred if we just provided an eqn lhs that was a tensor
-- ... which is where this is used in most the time
function combineCommaDerivativesAndRelabel(expr, destsymbol, fixedsymbols)
	local termsForDerivSymbol = binTermsByCommaDerivative(expr)
	local nonDerivTerms = table()
	local derivTerms = table()
	for symbol,terms in pairs(termsForDerivSymbol) do
		if symbol == binTermsByCommaDerivative_noDerivSymbol then
			nonDerivTerms:insert(tableToAdd(terms))
		else
			if symbol == destsymbol then
				derivTerms:insert(tableToAdd(terms)(' ,_'..destsymbol))
			elseif table.find(fixedsymbols, symbol) then
				derivTerms:insert((tableToAdd(terms) * delta(' ^'..destsymbol..' _'..symbol) )(' ,_'..destsymbol))
			else
				derivTerms:insert(tableToAdd(terms):reindex{[symbol] = destsymbol}(' ,_'..destsymbol))
			end
		end
	end
	local derivSum = combineCommaDerivatives(tableToAdd(derivTerms))
	local nonDerivSum = tableToAdd(nonDerivTerms)
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
-- lapse gauge
-- if our eigenvalues are sqrt(f gamma^xx) ... gamma^xx being >= 0 makes sense ... but if, for 1+log slicing, f=2/alpha ... then our alpha is constrained to being positive.  no charged, spinning black hole event horizon interiors.
local f = var('f', {alpha})
-- Z4 vars
local Z = var'Z'
local Theta = var'\\Theta'
-- Z4 constraint parameters
local kappa1 = var'\\kappa_1'
local kappa2 = var'\\kappa_2'
-- 1st derivative state vars
local a = var'a'
local b = var'b'
local d = var'd'
local GDelta = var[[\overset{\Delta}{G}]]
-- hyperbolic gamma driver time derivative state var
local B = var'B'
-- eigenvalue variable
local lambda = var'\\lambda'

-- its easier to use a separate var for the trace, esp when swapping back
local tr_b = var'tr(b)'
local tr_K = var'tr(K)'

alpha:setDependentVars(txs:unpack())
gamma'_ij':setDependentVars(txs:unpack())
a'_k':setDependentVars(txs:unpack())
d'_kij':setDependentVars(txs:unpack())
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
Theta:nameForExporter('C', 'Theta')
GDelta:nameForExporter('C', 'GDelta')
kappa1:nameForExporter('C', 'solver->kappa1')
kappa2:nameForExporter('C', 'solver->kappa2')
-- lambda?

tr_b:nameForExporter('C', 'tr_b')
tr_K:nameForExporter('C', 'tr_K')

-- used for converting to dense tensor

gamma'_ij':setSymmetries{1,2}
d'_ijk':setSymmetries{2,3}
K'_ij':setSymmetries{1,2}
S'_ij':setSymmetries{1,2}
Gamma'_ijk':setSymmetries{2,3}

-- TODO derivatives automatic? otherwise there are a lot of permtuations ...
gamma'_ij,k':setSymmetries{1,2}
d'_ijk,l':setSymmetries({2,3}, {1,4})
K'_ij,k':setSymmetries{1,2}
b'_ij,k':setSymmetries{2,3}


-- [[ ok not typical Z4 vars but i'm using it for MDE and for GammaDriver shift flux codegen ...
-- TODO substitute these *after* flux code generation
A = var'A'
A'_ij':setSymmetries{1,2}
A'_ij,k':setSymmetries{1,2}
DBeta = var'(\\nabla\\beta)'			-- ∇_j β^i = β^i_,j + Γ^i_kj β^k = b^i_j + Γ^i_kj β^k
DBeta:nameForExporter('C', 'DBeta')
DBeta'_ij':setSymmetries{1,2}
DBeta'_ij,k':setSymmetries{1,2}
tr_DBeta = var'(\\nabla \\cdot \\beta)'	-- ∇∙β = ∇_i β^i = β^i_,i + Γ^i_ij β^j = b^i_i + Γ^i_ij β^j = tr_b + Γ^i_ij β^j = tr_b + d_j β^j
tr_DBeta:nameForExporter('C', 'tr_DBeta')
--]]

-- TODO make this a property of the Variable wrt TensorRef (like :dependsOn does)
-- or make it a property of the TensorRef and remember to ctor/clone it
-- I'm thinking property of Variable, since TensorRef's are created arbitrarily from Variables , like K'_ab' * K'^ab' etc
-- so if the symmetry (related to the TensorRef) is stored in the Variabel then K will remember this

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
					return tr_K
				end
			end
		end
	end)
end


-- for Expression:simplifyMetrics()
Tensor.metricVariable = gamma

--[==[ test case for insertDeltasToSetIndexSymbols
-- "do end" doesn't reduce the # of local vars, so...
function tmp()
	-- test case for
	local src = frac(1,2) * alpha * gamma'^mp' * d'_mip,j'
	local result = insertDeltasToSetIndexSymbols(src, table{d'_mpq,r'})
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
d_kij
γ_kij

Z4 GLM vars:
Z^i = γ^i_μ Z^μ
Θ = -Z^μ n_μ

hyperbolic γ driver shift:
b^i_j = β^i_,j
B^i = β^i_,t

so our state variables will be:
{α, Δγ_ij, a_k, Δd_kij, K_ij, Θ, Z_k, β^l, b^l_k, B^l}

--]]

function usingSubst(expr, ...)
	printbr('using', table{...}:mapi(tostring):concat';')
	local newexpr = expr:subst(...)
	if newexpr == expr then
		printbr("...didn't make a difference")
	end
	printbr(newexpr)
	return newexpr
end

function usingSubstSimplify(expr, ...)
	printbr('using', table{...}:mapi(tostring):concat';')
	local newexpr = expr:subst(...)()
	if newexpr == expr then
		printbr("...didn't make a difference")
	end
	printbr(newexpr)
	return newexpr
end


function usingSubstIndex(expr, ...)
	printbr('using', table{...}:mapi(tostring):concat';')
	local newexpr = expr:substIndex(...)
	if newexpr == expr then
		printbr("...didn't make a difference")
	end
	printbr(newexpr)
	return newexpr
end

function usingSubstIndexSimplify(expr, ...)
	printbr('using', table{...}:mapi(tostring):concat';')
	local newexpr = expr:substIndex(...)()
	if newexpr == expr then
		printbr("...didn't make a difference")
	end
	printbr(newexpr)
	return newexpr
end

-- modifies in-place, no need to return.  TODO don't modify in-place?
function usingRHSSubstIndex(expr, ...)
	printbr('using', table{...}:mapi(tostring):concat';')
	assert(symmath.op.Equation:isa(expr))
	local rhs = expr:rhs()
	local newrhs = rhs:substIndex(...)
	if newrhs == rhs then
		printbr("...didn't make a difference")
	else
		expr[2] = newrhs
	end
	printbr(expr)
	return expr
end

-- modifies in-place, no need to return.  TODO don't modify in-place?
function usingRHSSubstIndexSimplify(expr, ...)
	printbr('using', table{...}:mapi(tostring):concat';')
	assert(symmath.op.Equation:isa(expr))
	local rhs = expr:rhs()
	local newrhs = rhs:substIndex(...)()
	if newrhs == rhs then
		printbr("...didn't make a difference")
	else
		expr[2] = newrhs
	end
	printbr(expr)
	return expr
end


printbr[[
Z4 formulation<br>

For more background, see my derivation from the Einstein Field Equations (with Z4 Killing vectors) to initial value problems
<a href='https://thenumbernine.github.io/math/Numerical%20Relativity/Z4%20From%20Killing%20Vectors.html'>here</a>.<br>
]]


printbr(gamma'_ij', '= spatial metric')
printbr()


local d_lll_def = d'_kij':eq(frac(1,2) * gamma'_ij,k')
printbr(d_lll_def, '= spatial metric derivative')

local d_gamma_lll_from_d_lll = d_lll_def:solve(gamma'_ij,k')
printbr(d_gamma_lll_from_d_lll)
printbr()

printbr()

local d_l_from_d_llu = d'_i':eq(d'_ik^k')
printbr(d_l_from_d_llu)

local e_l_from_d_ull = e'_i':eq(d'^k_ki')
printbr(e_l_from_d_ull)
printbr()


local b_ul_def = b'^i_j':eq(beta'^i_,j')
printbr(b_ul_def)
local d_beta_ul_from_b_ul = b_ul_def:solve(beta'^i_,j')
printbr(d_beta_ul_from_b_ul)
printbr()


printHeader'connections:'
local conn_lll_def = Gamma'_ijk':eq(frac(1,2) * (gamma'_ij,k' + gamma'_ik,j' - gamma'_jk,i'))
printbr(conn_lll_def)
local d_gamma_lll_from_conn_lll = (conn_lll_def + conn_lll_def:reindex{ijk='kji'})
	:symmetrizeIndexes(gamma,{1,2})():switch():reindex{jk='kj'}
printbr(d_gamma_lll_from_conn_lll)
printbr()

local conn_ull_from_gamma_uu_d_gamma_lll = (gamma'^im' * conn_lll_def:reindex{i='m'})():simplifyMetrics()()
printbr(conn_ull_from_gamma_uu_d_gamma_lll)

local conn_ull_from_gamma_uu_d_lll = usingSubstIndexSimplify(conn_ull_from_gamma_uu_d_gamma_lll, d_gamma_lll_from_d_lll)

local conn_ull_from_d_ull_d_llu = conn_ull_from_gamma_uu_d_lll:clone()
conn_ull_from_d_ull_d_llu = conn_ull_from_d_ull_d_llu:simplifyMetrics():replaceIndex(d'_a^c_b', d'_ab^c')
printbr('simplifying metrics:')
printbr(conn_ull_from_d_ull_d_llu)
printbr()

printbr(log(sqrt(gamma))'_,i':eq(Gamma'^k_ki'), 'definition:')
local d_l_from_conn_ull_tr12 = conn_ull_from_d_ull_d_llu:reindex{ijk='kki'}
printbr(d_l_from_conn_ull_tr12)
--[[ hmm why isn't this working for single terms?
d_l_from_conn_ull_tr12 = d_l_from_conn_ull_tr12 :applySymmetries()()
d_l_from_conn_ull_tr12 = simplifySumIndexes(d_l_from_conn_ull_tr12)()
printbr(d_l_from_conn_ull_tr12)
--]]
--[[ instead:
d_l_from_conn_ull_tr12 = usingSubstSimplify(d_l_from_conn_ull_tr12, d'_ki^k':eq(d'^k_ki'))
--]]
-- [[ or just use ...
d_l_from_conn_ull_tr12 = simplifyDAndKTraces(d_l_from_conn_ull_tr12)()
--printbr(d_l_from_conn_ull_tr12)
--]]

--d_l_from_conn_ull_tr12 = usingSubst(d_l_from_conn_ull_tr12, d_l_from_d_llu:switch())
d_l_from_conn_ull_tr12 = d_l_from_conn_ull_tr12:solve(d'_i')
printbr(d_l_from_conn_ull_tr12)
printbr()

local conn_u_from_conn_ull = Gamma'^i':eq(Gamma'^i_jk' * gamma'^jk')
printbr(conn_u_from_conn_ull)
local conn_u_from_d_ull_d_llu = usingSubstIndex(conn_u_from_conn_ull, conn_ull_from_d_ull_d_llu)

printbr'simplifying metrics and simplifying traces:'
conn_u_from_d_ull_d_llu = conn_u_from_d_ull_d_llu:simplifyMetrics():applySymmetries()
--[[ hmm once again its not working
conn_u_from_d_ull_d_llu = simplifySumIndexes(conn_u_from_d_ull_d_llu)()
printbr(conn_u_from_d_ull_d_llu)
--]]
--[[ so until I get this working ...
conn_u_from_d_ull_d_llu = usingSubstSimplify(conn_u_from_d_ull_d_llu, d'_k^ik':eq(d'^ki_k'))
--]]
-- [[ or just use this ..
conn_u_from_d_ull_d_llu = simplifyDAndKTraces(conn_u_from_d_ull_d_llu)()
printbr(conn_u_from_d_ull_d_llu)
--]]
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

local d_gamma_uul_from_gamma_uu_d_lll = usingSubstIndexSimplify(d_gamma_uul_from_gamma_uu_d_gamma_lll, d_gamma_lll_from_d_lll)
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

local dt_alpha_def = alpha'_,t':eq(alpha'_,i' * beta'^i' - alpha^2 * f * (tr_K - 2 * Theta))
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

local before = dt_alpha_def:clone()

-- rhs only so alpha_,t isn't simplified
dt_alpha_def = usingRHSSubstIndexSimplify(dt_alpha_def, d_alpha_l_from_a_l)

-- save here and use this for subst in a_k's def
-- (otherwise in a_k you'll have to subst the 2nd-deriv vars as 1st-derivs of 1st-deriv-state-vars)
local dt_alpha_noflux_def = dt_alpha_def:clone()

if makeFluxForGaugeVars then
	dt_alpha_def = before
	dt_alpha_def[2] = (dt_alpha_def[2] - alpha'_,i' * beta'^i')()
	dt_alpha_def[2] = dt_alpha_def[2] + (alpha * beta'^r')'_,r' - alpha * tr_b
	dt_alpha_def:flatten()
	printbr(dt_alpha_def)
end

local dt_alpha_negflux, dt_alpha_rhs
_, dt_alpha_negflux, dt_alpha_rhs = combineCommaDerivativesAndRelabel(dt_alpha_def:rhs(), 'r', {})
printbr(dt_alpha_def:lhs(), 'flux term', -dt_alpha_negflux)
printbr(dt_alpha_def:lhs(), 'source term', dt_alpha_rhs)
printbr()


printbr'lapse partial evolution'

--local dt_a_l_def = dt_alpha_def'_,k'	-- this wil simplify the same, but it won't look as good
local dt_a_l_def = dt_alpha_noflux_def:lhs()'_,k':eq(dt_alpha_noflux_def:rhs()'_,k')
printbr(dt_a_l_def)

local using = alpha'_,t,k':eq(alpha'_,k''_,t')
printbr('using', using, ';', d_alpha_l_from_a_l)
dt_a_l_def[1] = dt_a_l_def[1]()
dt_a_l_def[1] = dt_a_l_def[1]
	:subst(using)
	:substIndex(d_alpha_l_from_a_l)()
printbr(dt_a_l_def)

-- while we're here, only on the lhs, replace a_k with its alpha def ... but not a_k,t .. so simplify() before to combine TensorRef derivatives
printbr('using on lhs only', a_l_def:reindex{i='k'})
dt_a_l_def[1] = dt_a_l_def[1]:substIndex(a_l_def)
printbr(dt_a_l_def)

printbr('subtracting', alpha'_,t' * alpha'_,k' * (1 / alpha), 'from both sides')
dt_a_l_def = dt_a_l_def - alpha'_,t' * alpha'_,k' * (1 / alpha)
dt_a_l_def[1] = dt_a_l_def[1]:simplifyAddMulDiv()
printbr(dt_a_l_def)
--]]

dt_a_l_def = usingSubst(dt_a_l_def, dt_alpha_noflux_def)

-- the easy way to do that with the tools I have:
local alpha_t_over_alpha = var'alpha_t_over_alpha'
local alpha_t_over_alpha_def = alpha_t_over_alpha:eq((dt_alpha_noflux_def:rhs() / alpha)())
dt_a_l_def = dt_a_l_def:subst(alpha_t_over_alpha_def:switch())
dt_a_l_def = dt_a_l_def:solve(a'_k,t')
dt_a_l_def = dt_a_l_def:subst(alpha_t_over_alpha_def)
printbr(dt_a_l_def)

-- this is done in the 2008 Yano et al paper, not exactly sure why, not mentioned in the flux of the 2005 Bona et al paper
dt_a_l_def[2] = dt_a_l_def[2]
	+ (beta'^m' * a'_k')'_,m'	-- goes in the flux
	- (beta'^m' * a'_k')'_,m'():substIndex(d_beta_ul_from_b_ul):replaceIndex(b'^m_m', tr_b)								-- goes in the source
	- (beta'^m' * a'_m')'_,k'	-- goes in the flux
	+ (beta'^m' * a'_m')'_,k'():substIndex(d_beta_ul_from_b_ul):replaceIndex(b'^m_m', tr_b):replace(a'_i,k', a'_k,i')	-- goes in the source
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

dt_gamma_ll_def = usingRHSSubstIndexSimplify(dt_gamma_ll_def, conn_lll_def)

printbr('symmetrizing', gamma'_ij')
dt_gamma_ll_def = dt_gamma_ll_def:symmetrizeIndexes(gamma, {1,2})()
printbr(dt_gamma_ll_def)

before = dt_gamma_ll_def:clone()

dt_gamma_ll_def = usingSubstIndex(dt_gamma_ll_def, d_beta_ul_from_b_ul)
dt_gamma_ll_def = usingRHSSubstIndex(dt_gamma_ll_def, d_gamma_lll_from_d_lll)

dt_gamma_ll_noflux_def = dt_gamma_ll_def:clone()

if makeFluxForGaugeVars then
	-- then move the gamma_ij,k beta^k into the flux
	dt_gamma_ll_def = before:clone()
-- [[
	dt_gamma_ll_def[2] = (dt_gamma_ll_def[2] - gamma'_ij,k' * beta'^k')()
	dt_gamma_ll_def[2] = dt_gamma_ll_def[2]:substIndex(d_beta_ul_from_b_ul)
	dt_gamma_ll_def[2] = dt_gamma_ll_def[2]
		+ (gamma'_ij' * beta'^r')'_,r'
		- gamma'_ij' * tr_b
--]]
	dt_gamma_ll_def[2]:flatten()
	printbr(dt_gamma_ll_def)
end

local _
_, dt_gamma_ll_negflux, dt_gamma_ll_rhs = combineCommaDerivativesAndRelabel(dt_gamma_ll_def:rhs(), 'r', {'i', 'j'})
printbr(dt_gamma_ll_def:lhs(), 'flux term', -dt_gamma_ll_negflux)
printbr(dt_gamma_ll_def:lhs(), 'source term', dt_gamma_ll_rhs)

-- TODO HERE optionally insert

printbr()


-- alright so this isn't used except for the eigensystem part
-- but it *could* also be used in the next step ...
printHeader'metric partial evolution:'
local dt_d_lll_def = dt_gamma_ll_noflux_def:reindex{k='l'}
dt_d_lll_def = dt_d_lll_def / 2
dt_d_lll_def = dt_d_lll_def[1]'_,k':eq(dt_d_lll_def[2]'_,k')
dt_d_lll_def[1] = dt_d_lll_def[1]()
printbr(dt_d_lll_def)

dt_d_lll_def = dt_d_lll_def:replace(gamma'_ij,tk', gamma'_ij,k''_,t')
dt_d_lll_def = usingSubstIndex(dt_d_lll_def, d_gamma_lll_from_d_lll)
dt_d_lll_def[1] = dt_d_lll_def[1]()
printbr(dt_d_lll_def)

-- this is done in the 2008 Yano et al paper, not exactly sure why, not mentioned in the flux of the 2005 Bona et al paper
printbr'inserting flux shift terms...'
dt_d_lll_def[2] = dt_d_lll_def[2]
	+ (beta'^l' * d'_kij')'_,l'	-- goes in the flux
	- (beta'^l' * d'_kij')'_,l'():substIndex(d_beta_ul_from_b_ul):replaceIndex(b'^l_l', tr_b)	-- goes in the source
	- (beta'^l' * d'_lij')'_,k'	-- goes in the flux
	+ (beta'^l' * d'_lij')'_,k'():substIndex(d_beta_ul_from_b_ul):replaceIndex(b'^l_l', tr_b):replace(d'_lij,k', d'_kij,l')	-- goes in the source
	-- such that half the source terms cancel (thanks to d'_lij,k' == d'_kij,l')
printbr(dt_d_lll_def)

Tensor.Ref:pushRule'Prune/evalDeriv'

printbr'simplifying without distributing flux derivative'
dt_d_lll_def = dt_d_lll_def()
printbr(dt_d_lll_def)

printbr'combining derivatives'
dt_d_lll_def[2] = combineCommaDerivatives(dt_d_lll_def[2])
printbr(dt_d_lll_def)

printbr'simplifying without distributing flux derivative'
dt_d_lll_def = dt_d_lll_def()
printbr(dt_d_lll_def)

Tensor.Ref:popRule'Prune/evalDeriv'

dt_d_lll_def[2], dt_d_lll_negflux, dt_d_lll_rhs = combineCommaDerivativesAndRelabel(dt_d_lll_def[2], 'r', {'i', 'j', 'k'})
printbr(dt_d_lll_def)
printbr(d'_kij,t', 'flux term:', -dt_d_lll_negflux)
printbr(d'_kij,t', 'source term:', dt_d_lll_rhs)

printbr()


printbr'Riemann curvature'

local Riemann_ulll_def = R'^i_jkl':eq(Gamma'^i_jl,k' - Gamma'^i_jk,l' + Gamma'^i_mk' * Gamma'^m_jl' - Gamma'^i_ml' * Gamma'^m_jk')
printbr(Riemann_ulll_def)
printbr()


-- I'm going to center this around the 2005 Bona et al Z4 d_kij terms
printbr'Ricci curvature'
local Ricci_ll_from_Riemann_ulll = R'_ij':eq(R'^k_ikj')
printbr(Ricci_ll_from_Riemann_ulll)

local Ricci_ll_def = usingSubstSimplify(Ricci_ll_from_Riemann_ulll, Riemann_ulll_def:reindex{ijkl='kikj'})

-- this rule is up above but in the form Gamma^k_ki = d_i ... so ...
local d_l_from_conn_ull_tr13 = d'_i':eq(Gamma'^k_ik')

Ricci_ll_def = Ricci_ll_def:splitOffDerivIndexes()
Ricci_ll_def = usingSubstIndexSimplify(Ricci_ll_def, d_l_from_conn_ull_tr13:switch())

Ricci_ll_def = Ricci_ll_def
	-- this is
	-- 1) the symmetry of d_i,j = d_(i,j)
	-- 2) inserting deltas to set the indexes
	-- 3) factoring deltas inside derivatives (so i can combine the derivatives later)
	:replace(d'_i,j', (frac(1,2) * (d'_i' * delta'^k_j' + d'_j' * delta'^k_i'))'_,k')
	:splitOffDerivIndexes()	-- split Gamma'^k_ij,k' into Gamma'^k_ij''_,k' for the sake of 'combineCommaDerivativesAndRelabel' next
	--:flatten()
printbr(Ricci_ll_def)

-- TODO HERE collect the derivative terms of Ricci_ll, leave the source alone
printbr('combining derivatives')
-- can't use this because one of the comma-derivs we want to bin is a _,j ...
-- so beforehand ... insert a delta ...
-- TODO use 'insertDeltas'
--Ricci_ll_def = usingSubst(Ricci_ll_def, Gamma'^k_ik,j', Gamma'^l_il,j' * delta'^k_j')
-- but why insert deltas now when I can use some Gamma^k_ik = d_i instead?
Ricci_ll_def[2], Ricci_ll_negflux, Ricci_ll_rhs = combineCommaDerivativesAndRelabel(Ricci_ll_def[2], 'k', {'i', 'j'})
printbr(Ricci_ll_def)

--[[ this turns Gamma^i_jk into its d_ijk form ... should I even bother?
-- the Gamma^i_jk form has less terms in the flux.
Ricci_ll_negflux = usingSubstIndex(removeCommaDeriv(Ricci_ll_negflux, 'k'), conn_ull_from_d_ull_d_llu)'_,k'
Ricci_ll_def[2] = Ricci_ll_negflux + Ricci_ll_rhs
printbr(Ricci_ll_def)
--]]

printbr('Ricci_ll_negflux', Ricci_ll_negflux)
printbr('Ricci_ll_rhs', Ricci_ll_rhs)

printbr()


printHeader'extrinsic curvature evolution:'

local dt_K_ll_def = K'_ij,t':eq(
	-- source terms
--	-alpha'_;ij'
	- alpha'_,ij' + Gamma'^k_ij' * alpha'_,k'

	-- keep these separated/distributed so I can replace() them individually below
	+ alpha * (
		R'_ij'
	)
	+ alpha * (
		Z'_i,j'
		+ Z'_j,i'
	)
	+ alpha * (
		- 2 * Gamma'^k_ij' * Z'_k'
		+ K'_ij' * (tr_K - 2 * Theta)
		- 2 * K'_ik' * gamma'^kl' * K'_lj'
	)

	- alpha * kappa1 * (1 + kappa2) * gamma'_ij' * Theta
	
	-- matter terms
	+ 4 * pi * alpha * (
		gamma'_ij' * (S - rho)
		- 2 * S'_ij'
	)

	-- Lie derivative terms
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
dt_K_ll_def = usingSubst(dt_K_ll_def, using)
--]]

dt_K_ll_def = usingSubst(dt_K_ll_def, (K'_ij,k' * beta'^k'):eq((K'_ij' * beta'^k')'_,k' - K'_ij' * tr_b) )
dt_K_ll_def = usingSubstIndex(dt_K_ll_def, d_beta_ul_from_b_ul)

local using = (alpha * (Z'_i,j' + Z'_j,i')):eq(alpha * (Z'_i,k' * delta'^k_j' + Z'_j,k' * delta'^k_i'))
printbr('using', using)
local using = (alpha * (Z'_i,j' + Z'_j,i')):eq(alpha * (Z'_i' * delta'^k_j' + Z'_j' * delta'^k_i')'_,k')
printbr('using', using)
local using = (alpha * (Z'_i,j' + Z'_j,i')):eq(
	(alpha * (Z'_i' * delta'^k_j' + Z'_j' * delta'^k_i'))'_,k' 			-- flux term
	- alpha'_,k' * (Z'_i' * delta'^k_j' + Z'_j' * delta'^k_i') 			-- source term
)
dt_K_ll_def = usingSubst(dt_K_ll_def, using)
dt_K_ll_def = usingSubstIndex(dt_K_ll_def, d_alpha_l_from_a_l)


printbr('using the definition of ', R'_ij')
--[[ old
dt_K_ll_def = dt_K_ll_def:subst(Ricci_ll_def)
--]]
-- ok now
-- of the R_ij def, part is _,k and part is not _,anything
-- so now I have to chagne the alpha * (...)_,k part into (alpha * (...))_,k - alpha a_k * (...)
-- [[ new
assert(removeCommaDeriv(Ricci_ll_negflux, 'k')'_,k' == Ricci_ll_negflux)
dt_K_ll_def = dt_K_ll_def:replace(
	alpha * Ricci_ll_def:lhs(),
	--alpha * (nonderiv + deriv)
	--alpha * (nonderiv + deriv[1]'_,k')
	--alpha * nonderiv + alpha * deriv[1]'_,k'
	alpha * Ricci_ll_rhs + (alpha * removeCommaDeriv(Ricci_ll_negflux,'k'))'_,k' - alpha * a'_k' * removeCommaDeriv(Ricci_ll_negflux,'k')
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

--[[ TODO don't do this anymore now that I"m trying to keep the flux and source in most simple terms as possible (and breaking them down into state derivs in the eigensystem part later)
-- this only affects source terms:
dt_K_ll_def = usingSubst(dt_K_ll_def, conn_ull_from_gamma_uu_d_lll:reindex{ijk='kij'})
--]]

local dt_K_ll_negflux, dt_K_ll_rhs
_, dt_K_ll_negflux, dt_K_ll_rhs = combineCommaDerivativesAndRelabel(dt_K_ll_def:rhs(), 'r', {'i', 'j'})
printbr(K'_ij,t', 'flux term:', -dt_K_ll_negflux)
printbr(K'_ij,t', 'source term:', dt_K_ll_rhs)

printbr()



printHeader'Gaussian curvature'

local Gaussian_def = R:eq(gamma'^ij' * R'_ij')
printbr(Gaussian_def)

--[[
Ricci: R_ij = P_ij + Q^k_ij,k
Gaussian: R = γ^ij R_ij

R = γ^ij (P_ij + (Q^k_ij)_,k)
R = γ^ij P_ij + γ^ij (Q^k_ij)_,k
R = γ^ij P_ij + (γ^ij Q^k_ij)_,k - γ^ij_,k Q^k_ij
R = γ^ij P_ij + (γ^ij Q^k_ij)_,k + γ^im γ_mn,k γ^nj Q^k_ij
R = (P^i_i + 2 d_kij Q^kij) + (Q^ki_i)_,k
--]]

printbr'using Ricci definition'
Gaussian_def = Gaussian_def:subst(Ricci_ll_def)
printbr(Gaussian_def)


Gaussian_def = Gaussian_def[1]:eq(
	(gamma'^ij' * removeCommaDeriv(Ricci_ll_negflux, 'k'))'_,k'
	- gamma'^ij_,k' * removeCommaDeriv(Ricci_ll_negflux, 'k')
	+ tableToAdd(Ricci_ll_rhs:sumToTable():mapi(function(x)
		return gamma'^ij' * x
	end))
)
printbr(Gaussian_def)

Gaussian_def = usingSubstIndex(Gaussian_def, d_gamma_uul_from_gamma_uu_d_lll)

Gaussian_def = usingSubstIndex(Gaussian_def, conn_ull_from_d_ull_d_llu)


--[[
γ^ij (P_ij + (Q^k_ij)_,k)
= γ^ij P_ij + γ^ij (Q^k_ij)_,k
= γ^ij P_ij + (γ^ij Q^k_ij)_,k - γ^ij_,k Q^k_ij
--]]
_, Gaussian_negflux, Gaussian_rhs = combineCommaDerivativesAndRelabel(Gaussian_def:rhs(), 'k', {})
printbr('Gaussian_negflux', Gaussian_negflux)
printbr('Gaussian_rhs', Gaussian_rhs)

Gaussian_negflux[1] = simplifyDAndKTraces(Gaussian_negflux[1]:simplifyMetrics())()
Gaussian_rhs = simplifyDAndKTraces(Gaussian_rhs:simplifyMetrics())()
	:tidyIndexes()()
Gaussian_rhs = simplifySumIndexes(Gaussian_rhs)()
	:applySymmetries()()
	:reindex{abc='lmn'}
	:replace(d'_lmn' * d'^nlm', d'_lmn' * d'^mln')()

printbr('Gaussian_negflux', Gaussian_negflux)
printbr('Gaussian_rhs', Gaussian_rhs)

Gaussian_def = Gaussian_def:lhs():eq(
	removeCommaDeriv(Gaussian_negflux, 'k')()'_,k' + Gaussian_rhs
)
printbr(Gaussian_def)

printbr()



printHeader[[Z4 $\Theta$ definition]]

local dt_Theta_def = Theta'_,t':eq(

	(Theta * beta'^k')'_,k'
	
	+ (alpha * Z'^k')'_,k'
	
	+ frac(1,2) * alpha * R
	
	+ alpha * (d'^k' - 2 * a'^k') * Z'_k'
	
	+ frac(1,2) * alpha * (
		  tr_K * (tr_K - 2 * Theta)
		- K'^m_n' * K'^n_m'
		- 16 * pi * rho
	)

	- alpha * kappa1 * (kappa2 + 2) * Theta

	- Theta * tr_b
)
printbr(dt_Theta_def)

printbr('using the definition of R')
--[[
dt_Theta_def = dt_Theta_def:subst(Gaussian_def)
--]]
-- [[
_, deriv, nonderiv = combineCommaDerivativesAndRelabel(Gaussian_def[2], 'k', {})
dt_Theta_def = dt_Theta_def:replace(
	frac(1,2) * alpha * Gaussian_def[1],
	--alpha * (nonderiv + deriv)
	--alpha * (nonderiv + removeCommaDeriv(deriv, 'k')'_,k')
	--alpha * nonderiv + alpha * removeCommaDeriv(deriv, 'k')'_,k'
	frac(1,2) * alpha * nonderiv
		+ (frac(1,2) * alpha * removeCommaDeriv(deriv, 'k'))'_,k'
		- frac(1,2) * alpha * a'_k' * removeCommaDeriv(deriv, 'k')
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
printbr(Theta'_,t', 'flux term:', -dt_Theta_negflux)
printbr(Theta'_,t', 'source term:', dt_Theta_rhs)

printbr()



printHeader[[Z4 $Z_k$ definition]]

--[[
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

dt_Z_l_def = usingSubstIndexSimplify(dt_Z_l_def, d_alpha_l_from_a_l)
dt_Z_l_def = usingSubstIndexSimplify(dt_Z_l_def, d_beta_ul_from_b_ul)
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
			- K'^r_k'
			+ delta'^r_k' * (tr_K - Theta)
		)
	)'_,r'
	+ alpha * (
		  a'_k' * (tr_K - 2 * Theta)
		+ K'_kl' * (
			- a'^l'
			+ d'^l'
			- 2 * Z'^l'
		)
		- d'_kpq' * K'^pq'
		- kappa1 * Z'_k'
		- 8 * pi * S'_k'
	)
	+ Z'_l' * b'^l_k'
	- Z'_k' * tr_b
)
--]]
printbr(dt_Z_l_def)

dt_Z_l_def:flatten()
Tensor.Ref:pushRule'Prune/evalDeriv'
dt_Z_l_def[2] = combineCommaDerivatives(dt_Z_l_def[2])
Tensor.Ref:popRule'Prune/evalDeriv'
printbr(dt_Z_l_def)


_, dt_Z_l_negflux, dt_Z_l_rhs = combineCommaDerivativesAndRelabel(dt_Z_l_def[2], 'r', {'k'})
printbr(Z'_k,t', 'flux term:', -dt_Z_l_negflux)
printbr(Z'_k,t', 'source term:', dt_Z_l_rhs)

printbr()


-- beta^i

printHeader'shift evolution:'

-- this is supposed to be the eqn rhs that you plug in the shift expression, then set according 'shiftingShift', 'useHyperbolic', etc flags, and it spits out PDEs of that rhs
--[[
args:
	subscript
	beta_rhs
	useHyperbolic
	name
--]]
function makeShift(args)
	local subscript = args.subscript
	local beta_rhs = args.beta_rhs
	local useHyperbolic = args.useHyperbolic
	local useShiftingShift = args.useShiftingShift
	local name = args.name
	
	printHeader('shift: '..name)
	
	-- this is parabolic form, where we solve β^l_,t instead of β^l_,tt
	local dt_beta_u_def
	local dt_B_u_def		-- only used with useHyperbolic
	if useHyperbolic then
		dt_beta_u_def = beta'^l_,t':eq(B'^l')
		dt_B_u_def = B'^l_,t':eq(beta_rhs)
	else
		dt_beta_u_def = beta'^l_,t':eq(beta_rhs)
	end
	if useShiftingShift then
		if makeFluxForGaugeVars then
			-- [[ if you want flux as well:
			-- β^l_,t = B^l + (β^m β^l)_,m - β^l b^m_m
			-- B^l_,t = S(B)^l + (β^m B^l)_,m - B^l b^m_m
			dt_beta_u_def[2] = dt_beta_u_def:rhs() + (beta'^k' * beta'^l')'_,k' - beta'^l' * tr_b
			if useHyperbolic then
				dt_B_u_def[2] = dt_B_u_def:rhs() + (beta'^k' * B'^l')'_,k' - B'^l' * tr_b
			end
			--]]
		else
			-- [[ if you want all-source:
			-- β^l_,t = B^l + β^m β^l_,m
			-- B^l_,t = S(B)^l + β^m B^l_,m
			dt_beta_u_def[2] = dt_beta_u_def:rhs() + beta'^k' * b'^l_k'
			if useHyperbolic then
				dt_B_u_def[2] = dt_B_u_def:rhs() + B'^k' * b'^l_k'
			end
			--]]
		end
	end
	printbr(dt_beta_u_def)
	if dt_B_u_def then
		printbr(dt_B_u_def)
	end
	printbr()

	dt_beta_u_def:flatten()
	local _, dt_beta_u_negflux, dt_beta_u_rhs = combineCommaDerivativesAndRelabel(dt_beta_u_def:rhs(), 'r', {'l'})
	printbr(beta'^l_,t', 'flux term:', -dt_beta_u_negflux)
	printbr(beta'^l_,t', 'source term:', dt_beta_u_rhs)
	
	local _, dt_B_u_negflux, dt_B_u_rhs
	if useHyperbolic then
		dt_B_u_def:flatten()
		_, dt_B_u_negflux, dt_B_u_rhs = combineCommaDerivativesAndRelabel(dt_B_u_def:rhs(), 'r', {'l'})
		printbr(B'^l_,t', 'flux term:', -dt_B_u_negflux)
		printbr(B'^l_,t', 'source term:', dt_B_u_rhs)
	end
	
	local dt_b_ul_def = dt_beta_u_def:reindex{k='i'}
	dt_b_ul_def = (
		(dt_b_ul_def:lhs()'_,k')()
		:replace(beta'^l_,tk', beta'^l_,k''_,t')
		:substIndex(d_beta_ul_from_b_ul)
	):eq(
		(delta'^r_k' * dt_b_ul_def:rhs())'_,r'
	)
	printbr(dt_b_ul_def)

	if makeFluxForGaugeVars then
		dt_b_ul_def = dt_b_ul_def:replace(
			(beta'^i' * beta'^l')'_,i',
			beta'^l' * tr_b + beta'^i' * b'^l_i'
		):flatten()
		dt_b_ul_def = dt_b_ul_def:replace(
			beta'^l' * tr_b - beta'^l' * tr_b,
			0
		):flatten()

		--[[ would be nice to introduce the shift to the flux
		-- but then we end up with this extra 1st deriv term
		dt_b_ul_def[2] = dt_b_ul_def[2]
			- (beta'^r' * b'^l_k')'_,r'
			+ tr_b * b'^l_k'
			+ beta'^r' * b'^l_r,k'
		--]]
		
		dt_b_ul_def[2] = dt_b_ul_def[2]
			- (delta'^r_k' * beta'^i' * b'^l_i')'_,r'
			+ (beta'^r' * b'^l_k')'_,r'
	end
	printbr(dt_b_ul_def)

	-- how to insert a -β^r b^l_k term into the flux? ... without adding a derivative to the rhs
	--dt_b_ul_def = dt_b_ul_def + (-beta'^r' * b'^l_k')'_,r' + tr_b * b'^l_k' + beta'^r' * b'^l_k,r'
	-- what if instead (For hyperbolic) we have β^l_,t = B^l - β^m B^l_,m
	-- β^l_,t = B^l + β^m β^l_,m
	-- to make a flux term out of this ...
	-- β^l_,t = B^l + β^m β^l_,m + (β^m β^l)_,m - β^m β^l_,m - β^m_,m β^l
	-- β^l_,t = B^l + (β^m β^l)_,m - β^l b^m_m

	dt_b_ul_def:flatten()
	local _, dt_b_ul_negflux, dt_b_ul_rhs = combineCommaDerivativesAndRelabel(dt_b_ul_def:rhs(), 'r', {'l', 'k'})
	printbr(b'^l_k,t', 'flux term:', -dt_b_ul_negflux)
	printbr(b'^l_k,t', 'source term:', dt_b_ul_rhs)


	-- create these distinct vars, they'll be put on the lhs when inserting into the flux eqns
	local betaVar = var('(\\beta_{'..subscript..'})')
	local bVar = var('(b_{'..subscript..'})')
	local BVar = var('(B_{'..subscript..'})')
	-- temp soln: change the C names
	-- TODO to fix this -- group the codegen exprs by which shift they belong to and auto-wrap them in their blocks
	betaVar:nameForExporter('C', 'beta')--..subscript)
	bVar:nameForExporter('C', 'b')--..subscript)
	BVar:nameForExporter('C', 'B')--..subscript)
	betaVar'^l':setDependentVars(txs:unpack())
	bVar'^l_k':setDependentVars(txs:unpack())
	BVar'^l':setDependentVars(txs:unpack())
	local substs = table{beta:eq(betaVar), b:eq(bVar), B:eq(BVar)}


	return {
		name = name,
		beta_u = {
			dt_def = dt_beta_u_def,
			dt_negflux = dt_beta_u_negflux,
			dt_rhs = dt_beta_u_rhs,
		},
		b_ul = {
			dt_def = dt_b_ul_def,
			dt_negflux = dt_b_ul_negflux,
			dt_rhs = dt_b_ul_rhs,
		},
		B_u = {
			dt_def = dt_B_u_def,
			dt_negflux = dt_B_u_negflux,
			dt_rhs = dt_B_u_rhs,
		},
		vars = {
			beta = betaVar,
			b = bVar,
			B = BVar,
		},
		substs = substs,
	}
end

allShifts = table()

-- how many of these terms should be state vars instead of state derivatives?
printHeader'harmonic shift evolution:'

-- use ^l as the index for shift expressions
local harmonicShiftExpr = alpha^2 * (2 * e'^l' - d'^l' - a'^l')
printbr(harmonicShiftExpr)
printbr()

shiftHarmonicParabolic = makeShift{
	name = "HarmonicParabolic",
	beta_rhs = harmonicShiftExpr,
	subscript = 'h.p.',
	useHyperbolic = false,
	useShiftingShift = useShiftingShift,
}
allShifts:insert(shiftHarmonicParabolic)

shiftHarmonicHyperbolic = makeShift{
	name = "HarmonicHyperbolic",
	beta_rhs = harmonicShiftExpr,
	subscript = 'h.h.',
	useHyperbolic = true,
	useShiftingShift = useShiftingShift,
}
allShifts:insert(shiftHarmonicHyperbolic)


-- [==[ minimum distortion elliptic evolution
-- how do you do time evolution for b^l_k,t = (β^l_,t)_,k
-- seems i'm getting 2nd deriv β^l_,ij terms in here
-- unless you're supposed to implement them as finite-difference on the rhs?
-- or unless you include this MDE vector value as a separate state var
-- (just like we do with conformal-gamma to do the gamma-driver)

printHeader'minimal distortion shift evolution:'

local mdeShiftEpsilon = var'\\epsilon_{mde}'
mdeShiftEpsilon:nameForExporter('C', 'mdeShiftEpsilon')

--[[
R^l_j β^j
...
R_ij = P_ij + Q_ij^k_,k
...
γ^li R_ij β^j = γ^li (P_ij + Q_ij^k_,k) β^j
= γ^li P_ij β^j + γ^li Q_ij^k_,k β^j
= γ^li P_ij β^j + (γ^li Q_ij^k β^j)_,k + Q_ij^k (γ^li β^j)_,k
= γ^li P_ij β^j + Q_ij^k (- 2 d_k^li β^j + γ^li b^j_k) + (γ^li Q_ij^k β^j)_,k
+ R^l_j β^j ... rhs
--]]
local minimalDistortionShiftExpr =
	(
		mdeShiftEpsilon * (
			-- β^l;j_j ... negflux
			DBeta'^lk'
			-- 1/3 β_j^;jl ... negflux
			+ frac(1,3) * gamma'^kl' * tr_DBeta
			-- + R^l_j β^j ... negflux
			+ gamma'^li' * removeCommaDeriv(Ricci_ll_negflux, 'k') * beta'^j'
			-- - 2 (α A^lj)_;j ... negflux
			- 2 * alpha * A'^lk'
		)
	)'_,k'

	+ mdeShiftEpsilon * (
		-- β^l;j_j ... rhs
		DBeta'^lj' * d'_j'
		+ DBeta'^nk' * Gamma'^l_nk'

		-- 1/3 β_j^;jl ... rhs
		+ frac(2,3) * tr_DBeta * e'^l'

		-- + R^l_j β^j ... rhs
		+ gamma'^li' * beta'^j' * Ricci_ll_rhs
		+ removeCommaDeriv(Ricci_ll_negflux, 'k') * (-2 * d'_k^li' * beta'^j' + gamma'^li' * b'^j_k')
	
		-- - 2 (α A^lj)_;j ... rhs
		- 2 * alpha * (
			A'^mn' * Gamma'^l_nm'
			+ A'^lm' * Gamma'^n_nm'
		)
	)

--[[ hmm, but this introduces 2nd deriv vars.  what to do with them ...
-- TODO put them on the rhs?
shiftMinimalDistortionParabolic = makeShift{
	name = "MinimalDistortionParabolic",
	beta_rhs = minimalDistortionShiftExpr,
	subscript = 'm.p.',
	useHyperbolic = false,
	useShiftingShift = useShiftingShift,
}
allShifts:insert(shiftMinimalDistortionParabolic)
--]]

-- [[
shiftMinimalDistortionHyperbolic = makeShift{
	name = "MinimalDistortionHyperbolic",
	beta_rhs = minimalDistortionShiftExpr,
	subscript = 'm.h.',
	useHyperbolic = true,
	useShiftingShift = useShiftingShift,
}
allShifts:insert(shiftMinimalDistortionHyperbolic)
--]]
--]==]

-- [==[
printHeader'gamma driver shift evolution:'

--[[
parabolic version:

hyperbolic version:
	β^i_,t = β^i_,j β^j + 3/4 (_Λ^i_,t - _Λ^i_,j β^j) - η _Λ^i
... mind you this is hyperbolic ... but doesn't allow for any b^i_j as a state var
 	because if we introduce it as a state var then it will need a 2nd deriv in its update

2017 Ruchlin, Etienne, Baumgarte - "SENR-NRPy- Numerical Relativity in Singular Curvilinear Coordinate Systems"
eqn 14.a: β^i_,t = B^i
eqn 14.b: B^i_,t - B^i_,j β^j = 3/4 (_Λ^i_,t - _Λ^i_,j β^j) - η B^i
eqn 11.e: _Λ^i_,t - _Λ^i_,j β^j + _Λ^j β^i_,j = _γ^jk ^D_j ^D_k β^i + 2/3 ΔΓ^i (_D_j β^j) + 1/3 _D^i _D_j β^j - 2 _A^ij (α_,j - 6 φ_,j) + 2 _A^jk ΔΓ^i_jk - 4/3 α _γ^ij K_,j

b^i_j,t = β^i_,tk ... can only be hyperbolic if β^i_,t itself has no derivative terms, but only rhs source terms.
and in fact that might be perfect for hyperbolic, so b^i_j,t = B^i_,j

in fact can b^i_j,t be defined for parabolic?
	β^i_,t += _Λ^i_,j which has 2nd derivs in it ... but only if useShift is used. so you can skip that.
	but b^i_j,t = (β^i_,t)_,j += (_Λ^i_,t)_,j ... and _Λ^i_,t has first-order terms
	... so now we need 2nd-order terms
	... so parabolic won't work

insert shifting-shift: _Λ^i_,t -> _Λ^i_,0 = _Λ^i_,t - _Λ^i_,j β^j
becomes:
_Λ^i_,0 =
	- _Λ^j β^i_,j
	+ _γ^jk ^D_j ^D_k β^i
	+ 2/3 ΔΓ^i (_D_j β^j)
	+ 1/3 _D^i _D_j β^j
	- 2 _A^ij (α_,j - 6 φ_,j)
	+ 2 _A^jk ΔΓ^i_jk
	- 4/3 α _γ^ij K_,j

... in flux form (how about looking at the ccz4 paper?)

ok
let G_i = log(√γ)_,i = Γ^j_ji
let ^G_i = _G_i = log(√^γ)_,i = log(√_γ)_,i = ^Γ^j_ji = _Γ^j_ji
let ΔG_i = G_i - ^G_i
ΔG_i = Γ^j_ji - ^Γ^j_ji
ΔG_i = d_i - ^d_ijk ^γ^jk		<- ^d_ijk isn't raised/lowered by ^γ^ij, *AND* because Δd_ijk is the difference *IN COVARIANT FORM*
									(this is why I'm thinking maybe use conn and connHat as state vars, and deltaConn instead of deltaMetricPartial)
lets define ΔG^i = γ^ij ΔG_j
(though tbf, G_i and ^G_i should be using different basis, so subtracting their components is worthless)

using:
exp(φ) = (γ/_γ)^(1/12)
φ = 1/12 log(γ/_γ)
φ_,i = 1/12 (log(γ)_,i - log(_γ)_,i)
φ_,i = 1/6 (log(√γ)_,i - log(√_γ)_,i)
φ_,i = 1/6 ΔG_i
W = exp(-2 φ)
W = (_γ/γ)^(1/6)
W_,i = -2 exp(-2 φ) φ_,i
W_,i = -2 W φ_,i			<=> 	φ_,i = -1/2 W_,i / W
W_,i = -1/3 W (log(√γ)_,i - log(√_γ)_,i)
W_,i = -1/3 W (log(√γ)_,i - log(√^γ)_,i)
W_,i = -1/3 W (Γ^j_ji - ^Γ^j_ji)		<- notice Γ^j_ji is raised/lowered by γ^ij while ^Γ^j_ji is raised/lowered by ^γ^ij
W_,i = -1/3 W ΔG_i
_A^ij = A^ij W^-2
_γ_ij = γ_ij W^2
_γ^ij = γ^ij W^-2

Γ^i_jk = d_kj^i + d_jk^i - d^i_jk

log(√(γ/^γ))_,i = log(√γ)_,i - log(√^γ)_,i = Γ^j_ji - ^Γ^j_ji = ΔG_i
also notice that if we impose the ^γ = _γ constraint then _Γ^j_ji = ^Γ^j_ji and ^d_ijk ^γ^jk = _d_ijk _γ^jk

_Γ^i_jk = Γ^i_jk + (δ^i_j W_,k + δ^i_k W_,j - γ_jk W_,l γ^li) / W
_Γ^i_jk = Γ^i_jk - 2 (δ^i_j φ_,k + δ^i_k φ_,j - γ_jk γ^li φ_,l)
_Γ^i_jk = Γ^i_jk - 1/3 (δ^i_j ΔG_k + δ^i_k ΔG_j - γ_jk γ^li ΔG_l)

_Γ^i = _Γ^i_jk _γ^jk
_Γ^i = _Γ^i_jk γ^jk W^2
_Γ^i = (Γ^i_jk + (δ^i_j W_,k + δ^i_k W_,j - γ_jk W_,l γ^li) / W) γ^jk W^2
_Γ^i = W^2 Γ^i - W W_,j γ^ji
_Γ^i = W^2 (Γ^i - γ^ji W_,j / W)
_Γ^i = W^2 (Γ^i + 1/3 ΔG^i)

ΔΓ^i_jk = _Γ^i_jk - ^Γ^i_jk
_Γ^i_jk = Γ^i_jk - 1/3 (δ^i_j ΔG_k + δ^i_k ΔG_j - γ_jk ΔG^i)

I'm starting to think that instead of Δd_kij = 1/2 (γ_ij,k - ^γ_ij,k) I should be using my own var Δconn^i_jk = Γ^i_jk - ^Γ^i_jk ...
... this would fit with my idea of connection-as-state-var (just like Palatini does)
... but is it more or is it less numerically stable?

ΔΓ^i = ΔΓ^i_jk _γ^jk
ΔΓ^i = (_Γ^i_jk - ^Γ^i_jk) _γ^jk
ΔΓ^i = _Γ^i - ^Γ^i_jk _γ^jk
ΔΓ^i = W^2 (Γ^i + 1/3 ΔG^i) - ^Γ^i_jk _γ^jk

_Λ^i = ΔΓ^i + C^i


-- the "real" delta-Gamma
-- this is difference of the connection and the conformal connection
-- whereas the BSSN delta-Gamma is the difference of the conformal connection and grid (hat) connection.
(_Γ->Γ)^i_jk = Γ^i_jk - _Γ^i_jk

_∇∙β = _∇_i β^i
_∇∙β = β^i_,i + _Γ^i_ij β^j
_∇∙β = b^i_i + log(√_γ)_,i β^j
_∇∙β = b^i_i + log(√^γ)_,i β^j
_∇∙β = β^i_,i + ^Γ^i_ij β^j
_∇∙β = ^∇∙β

^Γ^i_kj = ^γ^il ^Γ_lkj

Ok some temps so I don't confuse myself with the tensors not raised/lowered by the metric.
(TODO REWRITE THE BSSN DERIVATION USING DENOTED *INDEXES* AND NOT TENSORS SO IT MAKES SENSE)
Bleh1^i_j = ^∇_j β^i = β^i_,j + ^Γ^i_kj β^k = b^i_j + ^Γ^i_kj β^k
... then Bleh1 is raised/lowered by γ^ij
Bleh2^i = ΔΓ^i_jk γ^jk
Bleh3^i = A^jk ΔΓ^i_jk
Bleh4^i = γ^jk ^Γ^i_mj Bleh1^m_k - γ^jk ^Γ^m_kj Bleh1^i_m
_Λ^i_,0 =
	- _Λ^j b^i_j								<- source terms
	+ W^-2 (
		+ 2/3 (^∇∙β) Bleh2^i					<- source terms
		- 2 A^ij (α a_j - ΔG_j)					<- source terms
		+ 2 Bleh3^i								<- source terms
		+ 4/3 α K (a^i + 2/3 ΔG^i - 2 e^i)		<- source terms ... byproduct of - 4/3 α _γ^ij K_,j
		+ 2/3 (-1/3 ΔG^i + e^i) ^∇∙β			<- source terms ... from 1/3 _γ^ji (^∇∙β)_,j
		+ 2 (-1/3 ΔG^k + e^k) Bleh1^i_k			<- source terms
		+ Bleh4^i
	)
	+ (
		1/3 W^-2 (^∇∙β - 4 α K) γ^ij + W^-2 Bleh1^ij
	)_,j

TODO don't represent this unless either
1) either modifying the simplifyMetrics rule to avoid the hatted/accented quantities or
2) replace them all with non-accented tensors that raise/lower using the metric itself

--]]

local gammaDriverK = frac(3,4)

invW = var'(1/W)'
gammaDriverEta = var'\\eta'
det_gamma = var'{det(\\gamma)}'
det_gammaHat = var'{det(\\hat{\\gamma})}'
GammaHat = var'\\hat{\\Gamma}'
GammaBar = var'\\bar{\\Gamma}'
DeltaGamma = var'\\Delta\\Gamma'
LambdaBar = var'\\bar{\\Lambda}'
tr_DHatBeta = var'{(\\hat{\\nabla}\\cdot\\beta)}'	-- ^∇∙β = b^i_i + Δd_j β^j
DHatBeta = var'{(\\hat{\\nabla}\\beta)}'			-- ^∇_j β^i = β^i_,j + ^Γ^i_kj β^k = b^i_j + ^Γ^i_kj β^k
invW:nameForExporter('C', 'invW')
gammaDriverEta:nameForExporter('C', 'gammaDriver_eta')
det_gamma:nameForExporter('C', 'det_gamma')
det_gammaHat:nameForExporter('C', 'det_gammaHat')
GammaHat:nameForExporter('C', 'connHat')
GammaBar:nameForExporter('C', 'connBar')
DeltaGamma:nameForExporter('C', 'DeltaGamma')	-- or "connDelta?" but this is the dif of conformal conn with background conn ...
LambdaBar:nameForExporter('C', 'LambdaBar')
tr_DHatBeta:nameForExporter('C', 'tr_DHatBeta')
DHatBeta:nameForExporter('C', 'DHatBeta')
GammaHat'_ijk':setSymmetries{2,3}
GammaBar'_ijk':setSymmetries{2,3}
DeltaGamma'_ijk':setSymmetries{2,3}
-- TODO really do this derivation in the CAS ... until then i'm gonna do this by hand ...
GammaDriverSource = var'GammaDriverSource'
GammaDriverDeriv = var'GammaDriverDeriv'
nonsense = var'nonsense'

-- _Λ^l_,0 = _Λ^l_,t - _Λ^l_,k β^k
local d0_LambdaBar_u_def =
	(
		gammaDriverK * (
			invW^2 * (
				gamma'^rk' * DHatBeta'^l_k'
				+ frac(1,3) * gamma'^lr' * (tr_DHatBeta - 4 * alpha * tr_K)
			)
		)
	)'_,r'
	+ gammaDriverK * invW^2 * (
		2 * e'^k' * DHatBeta'^l_k'
		+ gamma'^jk' * (
			GammaHat'^l_jm' * b'^m_k'
			- GammaHat'^m_jk' * b'^l_m'
			+ GammaHat'^l_jm' * GammaHat'^m_nk' * beta'^n'
			- GammaHat'^m_jk' * GammaHat'^l_nm' * beta'^n'
		)
		+ frac(2,3) * tr_DHatBeta * DeltaGamma'^l_mn' * gamma'^mn'
		+ frac(2,3) * tr_DHatBeta * e'^l'
		- 2 * A'^lj' * (alpha * a'_j' - GDelta'_j')
		+ 2 * A'^jk' * DeltaGamma'^l_jk'
		+ frac(4,3) * alpha * tr_K * (a'^l' - 2 * e'^l')
		- frac(2,3) * (
			GDelta'^k' * DHatBeta'^l_k'
			+ frac(1,3) * GDelta'^l' * (tr_DHatBeta - 4 * alpha * tr_K)
		)
	)
	- gammaDriverK * LambdaBar'^j' * b'^l_j'

	--[[
	(nonsense * GammaDriverDeriv'^lr')'_,r'	-- TODO without extra scalar the GammaDriverDeriv doesn't get moved to the flux ...
	+ GammaDriverSource'^l'
	--]]

--[[
printbr'gamma driver shift, parabolic:'

local gammaDriverParabolicShiftExpr =
	d0_LambdaBar_u_def
	- gammaDriverEta * LambdaBar'^l'	-- for parabolic, converge to LambdaBar^l ... for hyperbolic, converge to B^l

printbr(gammaDriverParabolicShiftExpr)
printbr()

-- now we have a problem ... how to handle evolution of b^i_j,t = β^i_,jt ?
-- if we have a parabolic term for β^i_,t then the result is no longer first-order
-- solution ... don't evolve b^i_j for GammaDriverParabolic, and instead treat it as a rhs source term?
shiftGammaDriverParabolic = makeShift{
	name = "GammaDriverParabolic",
	beta_rhs = gammaDriverParabolicShiftExpr,
	subscript = 'γ.p.',
	useHyperbolic = false,
	useShiftingShift = false,
}
allShifts:insert(shiftGammaDriverParabolic)
--]]

-- [[
printbr'gamma driver shift, hyperbolic:'

local gammaDriverHyperbolicShiftExpr =
	d0_LambdaBar_u_def
	- gammaDriverEta * B'^l'

printbr(gammaDriverHyperbolicShiftExpr)
printbr()

shiftGammaDriverHyperbolic = makeShift{
	name = "GammaDriverHyperbolic",
	beta_rhs = gammaDriverHyperbolicShiftExpr,
	subscript = 'γ.h.',
	useHyperbolic = true,
	useShiftingShift = useShiftingShift,
}
allShifts:insert(shiftGammaDriverHyperbolic)
--]]
--]==]

-- TODO for parabolic be sure to replace dt_LambdaBar'^l' with dt_LambdaBar'^l' - LambdaBar'^l_,m' * beta'^m'

printbr()

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
	to speed up calculations, these can be represented in their simplest form (i.e. d^l instead of d^l_ij


so what TODO

1) above, for each var,
	once it is separated into the flux and the source ...
	separate the two:
		- simplify the source further (to make it more compact / easier to code-generate)
		- simplify the flux in converting the 1st derivs of gauge vars into state vars *ONLY IF* we are not including them into the eignesystem
			- and even then, don't add them back into the source (even tho they don't go in the eigensystem).  keep them separate.
	- while yoou're here, might as well separate the shift from non-shift components too?
--]]

printHeader'as a system:'

local function getdtlhs(eqn)
	return removeCommaDeriv(eqn:lhs(), 't')
end

local UijklWithShiftVars = table()

-- here's the flux vector from the 2008 Yano / 2005 Bona paper, irregardless of what state variable derivatives we find later
local FijklWithShiftTerms = table()
-- here's the other part of the ivp rhs, such that SijklWithShiftTerms - FijklWithShiftTerms makes up the ivp rhs
-- (TODO right now there's a lot of "S_ijkl" that pertains to the non-flux *AND* the flux's derivatives that get converted into 1st-deriv state-vars ...
--  the distinction is because the eigensystem dF/dU doesn't use any gauge var derivatives (alpha beta gamma)
-- so I'm thinking all that should be moved until *after* the flux codegen, and the rhs codegen ...
-- and maybe make that extra flux-source codegen separate of this SijklWithShiftTerms ...
local SijklWithShiftTerms = table()

-- technically beta^i is also a gauge var, but i'm disabling it via dontIncludeShiftVars
if flux_includeGaugeVars then
	UijklWithShiftVars:append{
		getdtlhs(dt_alpha_def),
		getdtlhs(dt_gamma_ll_def),
	}
	FijklWithShiftTerms:append{
		-removeCommaDeriv(dt_alpha_negflux or Constant(0), 'r'),
		-removeCommaDeriv(dt_gamma_ll_negflux or Constant(0), 'r'),
	}
	SijklWithShiftTerms:append{
		dt_alpha_rhs or Constant(0),
		dt_gamma_ll_rhs or Constant(0),
	}
end

UijklWithShiftVars:append{
	getdtlhs(dt_a_l_def),
	getdtlhs(dt_d_lll_def),
	getdtlhs(dt_K_ll_def),
}
FijklWithShiftTerms:append{
	-removeCommaDeriv(dt_a_l_negflux, 'r'),
	-removeCommaDeriv(dt_d_lll_negflux, 'r'),
	-removeCommaDeriv(dt_K_ll_negflux, 'r'),
}
SijklWithShiftTerms:append{
	dt_a_l_rhs,
	dt_d_lll_rhs,
	dt_K_ll_rhs,
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
if flux_includeZVars then
	UijklWithShiftVars:append{
		getdtlhs(dt_Theta_def),
		getdtlhs(dt_Z_l_def),
	}
	FijklWithShiftTerms:append{
		-removeCommaDeriv(dt_Theta_negflux, 'r'),
		-removeCommaDeriv(dt_Z_l_negflux, 'r'),
	}
	SijklWithShiftTerms:append{
		dt_Theta_rhs,
		dt_Z_l_rhs,
	}
end

-- TODO only exclude these if we have "shift" set to "none"
-- make this as close to the hydro/eqn/z4.lua flags as possible
if flux_includeShiftVars then
	for _,shift in ipairs(allShifts) do
		-- fix only the Uijklt vars because that is used to determine uniqueness ...
		-- but leave the rhs as the original shift vars
		local function fix(expr)
			expr = getdtlhs(expr)
			expr = expr:subst(shift.substs:unpack())
			return expr
		end
		if shift.beta_u.dt_def then
			UijklWithShiftVars:insert(fix(shift.beta_u.dt_def))
			FijklWithShiftTerms:insert(-removeCommaDeriv(shift.beta_u.dt_negflux, 'r'))
			SijklWithShiftTerms:insert(shift.beta_u.dt_rhs or Constant(0))
		end
		if shift.b_ul.dt_def then
			UijklWithShiftVars:insert(fix(shift.b_ul.dt_def))
			FijklWithShiftTerms:insert(-removeCommaDeriv(shift.b_ul.dt_negflux, 'r'))
			SijklWithShiftTerms:insert(shift.b_ul.dt_rhs or Constant(0))
		end
		if shift.B_u.dt_def then
			UijklWithShiftVars:insert(fix(shift.B_u.dt_def))
			FijklWithShiftTerms:insert(-removeCommaDeriv(shift.B_u.dt_negflux or Constant(0), 'r'))
			SijklWithShiftTerms:insert(shift.B_u.dt_rhs or Constant(0))
		end
	end
end

-- apply a few specific rules ...
FijklWithShiftTerms = FijklWithShiftTerms:mapi(function(expr)
	local checkorx
	local function check(x)
		-- --x => x
		if symmath.op.unm:isa(x)
		and symmath.op.unm:isa(x[1])
		then
			return x[1][1]
		end
		-- -0 => 0
		if symmath.op.unm:isa(x)
		and Constant.isValue(x[1], 0)
		then
			return 0
		end
		if symmath.op.unm:isa(x)
		and symmath.op.add:isa(x[1])
		then
			return symmath.op.add(table.mapi(x[1], function(xi)
				return checkorx(-xi)
			end):unpack())
		end
	end
	function checkorx(x) return check(x) or x end
	return expr:map(check)
end)

-- ijkl on the partial_t's
-- pqmn on the partial_x^r's

-- factor out the _,t from the lhs
local UijklWithShiftMat = Matrix(UijklWithShiftVars):T()
local FijklWithShiftMat = Matrix(FijklWithShiftTerms):T()
local SijklWithShiftMat = Matrix(SijklWithShiftTerms):T()


printbr'flux vector in index form:'
printbr((UijklWithShiftMat'_,t' + FijklWithShiftMat'_,r'):eq(SijklWithShiftMat))
printbr()

-- TODO do this replacing somewhere else?
local f_alpha = var('(f \\alpha)', alpha)
f_alpha:nameForExporter('C', 'f_alpha')
FijklWithShiftMat = FijklWithShiftMat:replace(f, f_alpha / alpha)	-- TODO here only simplify division
SijklWithShiftMat = SijklWithShiftMat:replace(f, f_alpha / alpha)
--[[
ok at this point I could just use whats in FijklWithShiftMat to calculate the flux jacobian
instead of the whole rhs, which has the flux jacobian terms, the flux gauge derivs-to-first-deriv-state-vars, and the rhs source vars
For now I'm going to simplify FijklWithShiftMat to the least number of vars for the purpose of generating flux code
--]]
-- [=[
for i=1,#FijklWithShiftMat do
	local term = FijklWithShiftMat[i][1]

	term = term:simplifyAddMulDiv()
	term = term:simplifyMetrics{
		Expression.simplifyMetricMulRules.delta,	-- only simplify deltas, don't raise/lower
	}:simplifyAddMulDiv()

	FijklWithShiftMat[i][1] = term
end
for i=1,#SijklWithShiftMat do
	local term = SijklWithShiftMat[i][1]

	term = term:simplifyMetrics():simplifyAddMulDiv()
	term = term:tidyIndexes():simplifyAddMulDiv()
	term = simplifyDAndKTraces(term):simplifyAddMulDiv()
	term = term:symmetrizeIndexes(d, {2,3}):simplifyAddMulDiv()
	term = term:replaceIndex(d'_a^b_c', d'_ac^b')
	
	SijklWithShiftMat[i][1] = term
end
printbr((UijklWithShiftMat'_,t' + FijklWithShiftMat'_,r'):eq(SijklWithShiftMat))
printbr()
--]=]

-- [=[
Tensor.Chart{coords=xs}

function expandMatrixIndexes(expr)
	-- the code prefers d_ij^k over d_i^k_j
	expr = expr:replaceIndex(d'_i^k_j', d'_ij^k')
	-- and K^i_j over K_i^j
	expr = expr:replaceIndex(K'_j^i', K'^i_j')

	-- now for everything else
--printbr('before replacing dense tensors', expr)
	return expr:replaceWithDense()
end


-- [[ same thing is done below on the non-flux-isolated dF/dU * U stuff
local dUdt_lhs_withShift_exprs = range(#UijklWithShiftMat):mapi(function(i)
	local expr = expandMatrixIndexes(UijklWithShiftMat[i][1])()
	-- TODO this or ... how about 'replaceWithDense' and then add a 'dt_' to the prefix or something?
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

local F_lhs_withShift_exprs = range(#FijklWithShiftMat):mapi(function(i) return FijklWithShiftMat[i][1] end)
F_lhs_withShift_exprs = F_lhs_withShift_exprs:mapi(function(expr) return expandMatrixIndexes(expr) end)

local S_withShift_exprs = range(#SijklWithShiftMat):mapi(function(i) return SijklWithShiftMat[i][1] end)
S_withShift_exprs = S_withShift_exprs:mapi(function(expr) return expandMatrixIndexes(expr) end)

--[[ show dense tensor form before iterating and expanding:
printbr'in dense-tensor form, before simplifying:'
for i=1,#F_lhs_withShift_exprs do
	printbr((dUdt_lhs_withShift_exprs[i]'_,t' + F_lhs_withShift_exprs[i]'_,r'):eq(S_withShift_exprs[i]))
end
printbr()
--]]

F_lhs_withShift_exprs = F_lhs_withShift_exprs:mapi(function(expr,i)
--print('expr['..i..'] flux before = ', expr)
	expr = expr()
--print('expr['..i..'] flux after = ', expr)
	if Constant.isValue(expr, 0) then return expr end
	assert(Tensor:isa(expr))
	-- use dUdt_lhs_withShift_exprs for tensor variance
	local dUdt_i = dUdt_lhs_withShift_exprs[i]
	if not Tensor:isa(dUdt_i) then
		assert(#expr.variance == 1)
	else
		-- put the '^r' *LAST*
		expr = expr:permute(table(dUdt_i.variance):append{Tensor.Index{symbol='r', lower=false}})
	end
	assert(expr.variance[#expr.variance].symbol == 'r')
	assert(not expr.variance[#expr.variance].lower)
	assert(not expr.variance[#expr.variance].derivative)
	return expr
end)

S_withShift_exprs = S_withShift_exprs:mapi(function(expr,i)
--printbr(dUdt_lhs_withShift_exprs[i], 'source before', expr)
	expr = expr()
--printbr(dUdt_lhs_withShift_exprs[i], 'source after', expr)
	if Constant.isValue(expr, 0) then return expr end
	local dUdt_i = dUdt_lhs_withShift_exprs[i]
	if not Tensor:isa(dUdt_i) then
		assert(not Tensor:isa(expr))
	else
		expr:permute(dUdt_i.variance)
	end
	return expr
end)


local rowsplits = table()
local dUdt_lhs_withShift_exprs_expanded = table()
local F_lhs_withShift_exprs_expanded = table()
local S_withShift_exprs_expanded = table()
assert(#dUdt_lhs_withShift_exprs_expanded == #F_lhs_withShift_exprs_expanded)
assert(#dUdt_lhs_withShift_exprs_expanded == #S_withShift_exprs_expanded)
for i=1,#F_lhs_withShift_exprs do
	local dUdt_i = assert(dUdt_lhs_withShift_exprs[i])
	local F_i = assert(F_lhs_withShift_exprs[i])
	local S_i = assert(S_withShift_exprs[i])
--printbr('unraveling dUdt:', dUdt_i, 'F:', F_i, 'S:', S_i)
	if Tensor:isa(dUdt_i) then
		for j,x in dUdt_i:iter() do
			local dUdt_i_j = assert(dUdt_i[j])
			
			-- this cond is to make sure symmetric terms aren't added twice
			-- but .. how about my multiple-shift terms?
			-- I guess I'll have to rename them before making them into dense vars
			if not dUdt_lhs_withShift_exprs_expanded:find(dUdt_i_j) then
				
				dUdt_lhs_withShift_exprs_expanded:insert(dUdt_i_j)
				local F_i_j_x = Constant.isValue(F_i, 0) and Constant(0) or assert(F_i[j][1])	-- extra [1] because _,x flux ...
				F_lhs_withShift_exprs_expanded:insert(F_i_j_x)
				local S_i_j = Constant.isValue(S_i, 0) and Constant(0) or assert(S_i[j])
				S_withShift_exprs_expanded:insert(S_i_j)
--printbr('inserting scalar dUdt:', dUdt_i_j, 'F:', F_i_j_x, 'S:', S_i_j)
			end
		end
	else
		assert(not Tensor:isa(dUdt_i))
		dUdt_lhs_withShift_exprs_expanded:insert(dUdt_i)
		assert(not Tensor:isa(F_i[1]))
		local F_i_x = Constant.isValue(F_i, 0) and Constant(0) or assert(F_i[1])
		F_lhs_withShift_exprs_expanded:insert(assert(F_i_x))
		assert(not Tensor:isa(S_i))
		S_withShift_exprs_expanded:insert(S_i)
--printbr('inserting scalar dUdt:', dUdt_i, 'F:', F_i_x, 'S:', S_i)
	end
end

-- [[
printbr'unraveling flux vector...'
for i=1,#dUdt_lhs_withShift_exprs_expanded do
	printbr((dUdt_lhs_withShift_exprs_expanded[i] + F_lhs_withShift_exprs_expanded[i]'_,r'):eq(S_withShift_exprs_expanded[i]))
end
printbr()
--]]

local U_vars_withShift_expanded = dUdt_lhs_withShift_exprs_expanded:mapi(function(v)
	v = v:clone()
	assert(Derivative:isa(v) and Variable:isa(v[1]) and v[2] == t)
	return v[1]
end)


local Uijkl_withShift_expanded = Matrix(U_vars_withShift_expanded):T()
-- this should match dF/dU * U ... if we have homogeneity
local Fijkl_withShift_expanded = Matrix(F_lhs_withShift_exprs_expanded):T()
Fijkl_withShift_expanded.rowsplits = rowsplits

local Sijkl_withShift_expanded = Matrix(S_withShift_exprs_expanded):T()
--Sijkl_withShift_expanded.rowsplits = rowsplits

local dUdt_lhs_withShift_exprs_expanded_mat = Matrix(dUdt_lhs_withShift_exprs_expanded):T()
dUdt_lhs_withShift_exprs_expanded_mat.rowsplits = rowsplits

--[[ do I really need this?
printbr'flux vector expanded:'
printbr((dUdt_lhs_withShift_exprs_expanded_mat + Fijkl_withShift_expanded'_,r'):eq(Sijkl_withShift_expanded))
printbr()
--]]
--]=]


-- TODO replace f with f_alpha / alpha and df/dalpha with alphaSq_dalpha_f / alpha^2
export.C.numberType = 'real const'
printHeader'generating code'
print'<pre>'

-- shift vars that don't belong to any particular shift ...
local shiftVarNames = {
	-- scalar vars:
	[tr_b.name] = true,
}
-- shift vars specific to a shift (usu their lhs)
for _,shift in ipairs(allShifts) do
	shift.denseVarNames = {}
end
for _,t in ipairs(Tensor.defaultDenseCache.cache) do
	if beta'^k':matchesDegreeWithoutDerivs(t[1])
	or b'^k_l':matchesDegreeWithoutDerivs(t[1])
	or B'^k':matchesDegreeWithoutDerivs(t[1])
	then
		local d = t[2]
		for i,x in d:iter() do
			shiftVarNames[x.name] = true
		end
	else
		for _,shift in ipairs(allShifts) do
			if shift.vars.beta'^k':matchesDegreeWithoutDerivs(t[1])
			or shift.vars.b'^k_l':matchesDegreeWithoutDerivs(t[1])
			or shift.vars.B'^k':matchesDegreeWithoutDerivs(t[1])
			then
				local d = t[2]
				for i,x in d:iter() do
					shift.denseVarNames[x.name] = true
				end
			end
		end
	end
end
-- TODO isolate flux terms that have shift components beta^l, b^l_k, or B^l in them
-- add them after the non-shift terms (how about codegen of += 's ?)
for _,info in ipairs{
	{name='flux:', structName='resultFlux', src=Fijkl_withShift_expanded, lineend='\\'},
	{name='source:', structName='deriv', src=Sijkl_withShift_expanded, lineend=''},
} do
	local name = info.name
	local structName = info.structName
	local src = info.src
	local lineend = info.lineend
	print(name)
	assert(#src == #Uijkl_withShift_expanded)


	local noShiftIndexes = table()
	for _,shift in ipairs(allShifts) do
		shift.codeGenIndexes = table()
	end

	local noShiftTerms = table()
	local shiftTerms = table()
	for i=1,#src do
		local Uijkl_t = Uijkl_withShift_expanded[i][1]
		local Fijkl = src[i][1]:simplifyAddMulDiv()
		local with, without
		local _, foundShift = allShifts:find(nil, function(shift) return shift.denseVarNames[Uijkl_t.name] end)
		if not shiftVarNames[Uijkl_t.name]
		and not foundShift
		then
			with, without = separateSum(
				Fijkl,
				function(x)
					return not not x:findLambda(function(x)
						return Variable:isa(x) and shiftVarNames[x.name]
					end)
				end
			)
			noShiftTerms[i] = without
			shiftTerms[i] = with
			noShiftIndexes:insert(i)
--print('adding line', i, 'with lhs', Uijkl_t, 'to shift none')
		elseif foundShift then
			-- don't write the shift vars to the noShift block, instead write them to the shift block (with a = instead of +=)
			noShiftTerms[i] = nil
			shiftTerms[i] = Fijkl
			foundShift.codeGenIndexes:insert(i)
--print('adding line', i, 'with name', Uijkl_t, 'to shift', foundShift.name)
		else
			error"you got some lhs shift vars that aren't part of the known lhs shift vars"
		end
	end
	print('\t{'..lineend)
	print('\t\t'..export.C:toCode{
			output = noShiftIndexes:mapi(function(i,_,t)
				local name = '('..structName..')->'..export.C(Uijkl_withShift_expanded[i][1])
				if structName == 'deriv' then
					name = name..' +'
					if Constant.isValue(noShiftTerms[i], 0) then return end	-- don't even output it
				end
				return {[name] = noShiftTerms[i]()}, #t+1
			end),
			assignOnly = true,
		}
		:gsub('%+ =', '+=')
		:gsub('\n', lineend..'\n\t\t')
		..lineend
	)
	print('\t}'..lineend)
	print('\t&lt;? if eqn.useShift ~= "none" then ?>'..lineend)
	print('\t{'..lineend)
	
	-- put all non-shift lhs vars in the main block
	-- then put each shift lhs vars in their distinct blocks
	local blocksAndShifts = table{
		{indexes=noShiftIndexes},
	}
	for _,shift in ipairs(allShifts) do
		blocksAndShifts:insert{indexes=shift.codeGenIndexes, shift=shift}
	end
	for _,block in ipairs(blocksAndShifts) do
		if block.shift then
			print('\t\t&lt;? if eqn.useShift == "'..block.shift.name..'" then ?>'..lineend)
		end
		print('\t\t{'..lineend)
		print('\t\t\t'..export.C:toCode{
				output = block.indexes:mapi(function(i,_,t)
					local Uijkl = Uijkl_withShift_expanded[i][1]
					local name = '('..structName..')->'..export.C(Uijkl)
					
					local _, foundShift = allShifts:find(nil, function(shift) return shift.denseVarNames[Uijkl.name] end)
					if shift and foundShift then assert(foundShift == shift) end
					
					if structName == 'deriv'
					or not shiftVarNames[Uijkl.name]
					or not foundShift
					then
						name = name..' +'
						if Constant.isValue(shiftTerms[i], 0) then return end	-- don't even output it
					end
					return {[name] = shiftTerms[i]()}, #t+1
				end),
				assignOnly = true,
			}
			:gsub('%+ =', '+=')
			:gsub('\n', lineend..'\n\t\t\t')
			..lineend
		)
		print('\t\t}'..lineend)
		if block.shift then
			print('\t\t&lt;? end ?>/* eqn.useShift == "'..block.shift.name..'" */'..lineend)
		end
	end
	print('\t}'..lineend)
	print('\t&lt;? end ?>/* eqn.useShift ~= "none" */'..lineend)
	print()
end
print'</pre>'



------------------------ OK FLUX AND SOURCE GENERATION IS FINISHED ------------------------
--------------------------- NOW ON TO EIGENSYSTEM CALCULATION -----------------------------

printHeader"analyzing flux jacobian:"
-- [===[ too many locals, so i'll just separate this out for now

--[[
for lapse f=2/α:
the matrix of {α, Δγ_ij, a_r, Δd_kij, K_ij, Θ, Z_k, β^l, b^l_k, B^l}  give us 0 x15, ±α√(γ^xx) x5
--]]
local UijkltEqns = table()

if eigensystem_includeGaugeVars then
	UijkltEqns:append{
		dt_alpha_def:lhs():eq(dt_alpha_negflux or Constant(0)),
		dt_gamma_ll_def:lhs():eq(dt_gamma_ll_negflux or Constant(0)),
	}
end
UijkltEqns:append{
	dt_a_l_def:lhs():eq(dt_a_l_negflux),
	dt_d_lll_def:lhs():eq(dt_d_lll_negflux),
	dt_K_ll_def:lhs():eq(dt_K_ll_negflux),
}
if eigensystem_includeZVars then
	UijkltEqns:append{
		dt_Theta_def:lhs():eq(dt_Theta_negflux),
		dt_Z_l_def:lhs():eq(dt_Z_l_negflux),
	}
end

local _, eigenShift = allShifts:find(nil, function(s) return s.name == useShift end)
if eigensystem_includeShiftVars and eigenShift then
	if eigenShift.beta_u.dt_def then
		UijkltEqns:insert(eigenShift.beta_u.dt_def:lhs():eq(eigenShift.beta_u.dt_negflux))
	end
	if eigenShift.b_ul.dt_def then
		UijkltEqns:insert(eigenShift.b_ul.dt_def:lhs():eq(eigenShift.b_ul.dt_negflux))
	end
	if eigenShift.B_u.dt_def then
		UijkltEqns:insert(eigenShift.B_u.dt_def:lhs():eq(eigenShift.B_u.dt_negflux))
	end
end

-- ok so I'm running out of symbols.
-- my "defaultSymbols" are currently letters a-z
-- so to fix this I'm going to insert some subscript letters a_1 ... z_1
-- but TODO do this automatically
for c=('a'):byte(),('z'):byte() do
	Tensor.defaultSymbols:insert('{'..string.char(c)..'_1}')
end

-- so as they are, the eqns look no different than they did when the flux/source code output printed it
-- so don't bother print them, instead do the simplfiications/rearrangement *here*
UijkltEqns = UijkltEqns:mapi(function(eqn,i)
	local lhs, rhs = eqn[1], eqn[2]

--printbr(lhs:eq(rhs))
	-- :replaceIndex(delta'^a_b,c', 0) will fail because the rhs doesn't have matching indexes, so the replaceIndex() will assume the indexes are all fixed
	-- however do this and itll insert a * 0, which will simplify to removing them all
	rhs = rhs:simplifyAddMulDiv()	-- distribute comma derivatives
--printbr(lhs:eq(rhs))
	rhs = rhs:replaceIndex(delta'^a_b,c', delta'^a_b,c' * 0)	-- replace delta comma derivs with 0*
--printbr(lhs:eq(rhs))
	rhs = rhs:simplifyAddMulDiv()	--simplify the 0*
--printbr(lhs:eq(rhs))

	-- before substiting derivs for state vars, make sure everything is in the correct valence
	-- (esp because that means inserting gamma^ij's, which when differentiated turn into -d_k^ij's)
	-- here convert *all* alpha_,i => a_i; beta^i_,j => b^i_j; gamma_ij,k => 1/2 d_kij
	rhs = rhs:replaceIndex(f'_,a', f:diff(alpha) * alpha'_,a')
--printbr(lhs:eq(rhs))

	
	rhs = rhs:splitOffDerivIndexes()
	rhs = rhs:substIndex(conn_ull_from_d_ull_d_llu)

	
	-- [[ for gamma driver
	rhs = rhs
		:insertMetricsToSetVariance(A'_ij', gamma)
		:insertMetricsToSetVariance(DBeta'^i_j', gamma)
		:substIndex(
			A'_ij':eq(K'_ij' - frac(1,3) * gamma'_ij' * tr_K),
			DBeta'^i_j':eq(b'^i_j' + (d'_jkm' + d'_kjm' - d'_mjk') * gamma'^mi' * beta'^k'),
			tr_DBeta:eq(tr_b - d'_m' * beta'^m'),
			mdeShiftEpsilon'_,a':eq(mdeShiftEpsilon'_,a' * 0),
			tr_b:eq(b'^m_m')
		)
	--]]

	-- insert traces (and their derivatives)
	rhs = rhs:splitOffDerivIndexes()
--printbr(lhs:eq(rhs))
	
	rhs = rhs:replace(tr_K^2, K'_mn' * gamma'^mn' * K'_pq' * gamma'^pq')	-- hmm,
--printbr(lhs:eq(rhs))
	
	rhs = rhs:replaceIndex(tr_K, K'_mn' * gamma'^mn')
--printbr(lhs:eq(rhs))
	rhs = rhs:insertMetricsToSetVariance(d'_i', gamma)
--printbr(lhs:eq(rhs))
	-- here we could have (d^i_,j) => (d_i γ^ik)_,j
	-- but if we use this next one (d_i γ^ik)_,j => (d_imn γ^mn γ^ik)_,j ... then we risk inserting bad sum indexes
	-- unless we distribute the derivative first, ... and then split it off gain
	rhs = rhs:simplifyAddMulDiv()
	rhs = rhs:splitOffDerivIndexes()
--printbr(lhs:eq(rhs))
	rhs = rhs:replaceIndex(d'_i', d'_imn' * gamma'^mn')
--printbr(lhs:eq(rhs))
	rhs = rhs:insertMetricsToSetVariance(e'_i', gamma)
--printbr(lhs:eq(rhs))
	-- here same as above, distribte comma derivs before substituting our d_kij's ... or we will get screwed up sum indexes
	rhs = rhs:simplifyAddMulDiv()
	rhs = rhs:splitOffDerivIndexes()
--printbr(lhs:eq(rhs))
	rhs = rhs:replaceIndex(e'_i', d'_mni' * gamma'^mn')
--printbr(lhs:eq(rhs))

	-- correct forms ...
	rhs = rhs:insertMetricsToSetVariance(a'_k', gamma)
	rhs = rhs:insertMetricsToSetVariance(d'_kij', gamma)
	rhs = rhs:insertMetricsToSetVariance(K'_ij', gamma)
	rhs = rhs:insertMetricsToSetVariance(Z'_k', gamma)
	rhs = rhs:insertMetricsToSetVariance(beta'^k', gamma)
	rhs = rhs:insertMetricsToSetVariance(b'^i_j', gamma)
	rhs = rhs:insertMetricsToSetVariance(B'^i', gamma)
--printbr(lhs:eq(rhs))
	
	-- simplify to distribute derivatives through the γ^ij's
	rhs = rhs:simplifyAddMulDiv()
--printbr(lhs:eq(rhs))

	-- convert γ^ij_,k's to -2 d_k^ij's
	--rhs = rhs:substIndex(d_gamma_uul_from_gamma_uu_d_lll)
	rhs = rhs:substIndex(d_gamma_uul_from_gamma_uu_d_gamma_lll)
	rhs = rhs:simplifyAddMulDiv()
--printbr(lhs:eq(rhs))

	--[[
	-- convert gauge derivs to state vars
	rhs = rhs
		:substIndex(d_alpha_l_from_a_l)
		:substIndex(d_beta_ul_from_b_ul)
		:substIndex(d_gamma_lll_from_d_lll)
	rhs = rhs:simplifyAddMulDiv()
--printbr(lhs:eq(rhs))
	--]]

	-- ok now that the derivs are distributed, replace all the non-derivs back to their shorter definitions:
	-- but this doesn't seem to be doing anything
	--rhs = simplifyDAndKTraces(rhs)

	return lhs:eq(rhs)
end)

local UijklVars = UijkltEqns:mapi(function(eqn) return removeCommaDeriv(eqn:lhs(), 't') end)
local UijklMat = Matrix(UijklVars):T()

-- TODO AT THIS POINT
-- we really don't need the source terms for the flux-jacobian
-- how about just pushing them off altogether?
-- then we can just deal with our *additional* source terms caused from converting flux gauge vars' derivatives into state vars (non-deriv)
-- and that'll simplify calculations a lot
-- heck, why even bother with source terms at this point?
-- other than what i just said -- is nice to see what terms should be in the flux (when excluding gauge vars from flux),
--  but instead are getting lost between the flux & source.
--  these are the terms that should prove our eqn doesn't satisfy homogeneity, right?
--  and in the case of a roe solver, these go extra in the source, right?
--  but not for hll right?

for _,eqn in ipairs(UijkltEqns) do
	printbr(eqn)
end
printbr()


printHeader'inserting deltas to help factor linear system'

local UpqmnVars = UijklVars:mapi(function(x) return x:reindex{ijkl='pqmn'} end)
local UpqmnrVars = UpqmnVars:mapi(function(x) return x'_,r'() end)

local rhsWithDeltas = UijkltEqns:mapi(function(eqn)
	return insertDeltasToSetIndexSymbols(eqn:rhs(), UpqmnrVars)
end)
printbr((UijklMat'_,t'):eq(Matrix(rhsWithDeltas):T()))
printbr()

printHeader'as a balance law system:'

local A, SijklMat = factorLinearSystem(rhsWithDeltas, UpqmnrVars)
local dFijkl_dUpqmn_mat = (-A)()

if not eigensystem_exportOnlyUs then
-- [[ simplify deltas 
-- if I do this then I get non-canonical index form of state vars 
-- if I don't do this then expanding goes really really slow
	dFijkl_dUpqmn_mat = dFijkl_dUpqmn_mat:simplifyMetrics()	
--]]
else
-- [[ so lets try doing this only for simplifying deltas ... idk if it makes a dif ... seems to still be taking a long long time
	dFijkl_dUpqmn_mat = dFijkl_dUpqmn_mat:simplifyMetrics{Expression.simplifyMetricMulRules.delta}
--]]
end
dFijkl_dUpqmn_mat = dFijkl_dUpqmn_mat:applySymmetries()
dFijkl_dUpqmn_mat = dFijkl_dUpqmn_mat:simplify()

-- [[ simplify terms in the matrix
if not eigensystem_exportOnlyUs then
	-- this lowers the # of terms
	dFijkl_dUpqmn_mat = simplifyDAndKTraces(dFijkl_dUpqmn_mat)
		:subst((-conn_u_from_d_ull_d_llu:switch())():reindex{i='l'})
		-- this one isn' working:
		--:subst((gamma'^pl' * conn_u_from_d_ull_d_llu:switch())():reindex{i='q'})
end
--]]

local UpqmnMat = Matrix(UpqmnVars):T()

printbr((UijklMat'_,t' + dFijkl_dUpqmn_mat * UpqmnMat'_,r'):eq(SijklMat))
printbr()

printHeader'expanding:'

--[[ only remove diagonal shift.  TODO this for the eigensystem, for acoustic matrix, but do it later after expanding.
dFijkl_dUpqmn_mat = dFijkl_dUpqmn_mat:replace(beta'^r', 0)()
--]]

--[[
TODO when considering shift, instead remove only shift along diagonal (for assumption of eigensystem with adjusted eigenvalues)
but this means, if there are no beta^x's along the diagonal of alpha_,t and gamma_ij,t, then we can't use this rule unless they also have zero rows (which they seem to)
--]]
-- [[
if eigensystem_removeShiftVars then
	dFijkl_dUpqmn_mat = dFijkl_dUpqmn_mat
		:replaceIndex(beta'^i', beta'^i' * 0)
		:replaceIndex(b'^i_j', b'^i_j' * 0)
		:replaceIndex(b'_j^i', b'_j^i' * 0)	-- TODO ... :applySymmetries() shouldn't be symmetrizing b^i_j into b_j^i
		:replaceIndex(B'^i', B'^i' * 0)
		:simplify()
end
--]]

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

-- [[ ok now that we've re-distributed the dFijkl_mnpq * dUmnpq ... gotta re-apply those deltas
dFdx_lhs = dFdx_lhs:simplifyMetrics{Expression.simplifyMetricMulRules.delta}
--]]

local dUdt_lhs = Matrix:lambda(UijklMat:dim(), function(...) return (UijklMat[{...}]:diff(t))() end)
printbr((dUdt_lhs + dFdx_lhs):eq(SijklMat))


-- ok i think this is what is doing me in ...
-- previous for simplifications
--d'_ijk,l':setSymmetries({2,3}, {1,4})
-- but now for expanding dense matrices, don't use the d_(k|ij,|l) symmetry:
d'_ijk,l':setSymmetries{2,3}
-- YUP -- without this the dU/dx vector gets /dy's in the d part ... so yeah push this symmetry *HERE*
-- SO HERE I have to remove all symmetries of flux state vars that span derivatives
--a'_i,j':setSymmetries()	-- ofc I don't use the symmetry of a_i,j anyways ...

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
--]]

-- replace the tensor index matrix form of _,t with _,x
local dUdx_lhs = Matrix:lambda(UijklMat:dim(), function(...)
	return UijklMat[{...}]'_,r'()
end)

-- convert it into a matrix of our dense-tensor derivative terms
local dUdx_lhs_exprs = range(dFdx_lhs_dim[1]):mapi(function(i) return dUdx_lhs[i][1] end)
dUdx_lhs_exprs = dUdx_lhs_exprs:mapi(function(expr) return expandMatrixIndexes(expr) end)

local S_rhs_exprs = range(dFdx_lhs_dim[1]):mapi(function(i) return SijklMat[i][1] end)
S_rhs_exprs = S_rhs_exprs:mapi(function(expr) return expandMatrixIndexes(expr) end)

-- make sure valence is correct
dUdx_lhs_exprs = dUdx_lhs_exprs:mapi(function(expr,i)
	expr = expr()
	if Constant.isValue(expr, 0) then return expr end
	assert(Tensor:isa(expr))	-- its always a tensor, since it always has a comma derivative
	-- use dUdt_lhs_exprs for tensor variance
	local dUdt_i = dUdt_lhs_exprs[i]
	if not Tensor:isa(dUdt_i) then
		assert(#expr.variance == 1)
	else
		-- put the '_r' *LAST*
		expr = expr:permute(table(
			dUdt_i.variance
		):append{Tensor.Index{symbol='r', lower=true}})
	end
	assert(expr.variance[#expr.variance].symbol == 'r')
	assert(expr.variance[#expr.variance].lower)
	assert(not expr.variance[#expr.variance].derivative)
	return expr
end)

--[[ show eqns in dense-tensor form
printbr'replaced dense tensors but before expanding:'
for i=1,#dFdx_lhs_exprs do
	printbr((dUdt_lhs_exprs[i] + dFdx_lhs_exprs[i]):eq(S_rhs_exprs[i]))
end
printbr()
--]]

-- NOTICE this can go slow if the dense tensors aren't replaced correctly
S_rhs_exprs = S_rhs_exprs:mapi(function(expr) return expr() end)

for i=1,#dFdx_lhs_exprs do
	local dUdt_i = dUdt_lhs_exprs[i]
	local dFdx_i = dFdx_lhs_exprs[i]
	-- simplify
	dFdx_i = dFdx_i()
	-- make sure the index storage between the two match up
	-- so that when i iterate between them i can match term for term
	if Tensor:isa(dUdt_i) then
		local dstvar = ' '..table.mapi(dUdt_i.variance, tostring):concat' '
		if Constant.isValue(dFdx_i, 0) then
			dFdx_i = Tensor(dstvar)
		else
			assert(Tensor:isa(dFdx_i))
			dFdx_i = dFdx_i:permute(dstvar)
		end
	else
		assert(not Tensor:isa(dFdx_i))
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
		and (node[2] == y or node[2] == z)
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
local dUdxs_lhs_exprs_expanded = table{table(), table(), table()}
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
				S_rhs_exprs_expanded:insert(S_i_j)
				for k=1,3 do
					dUdxs_lhs_exprs_expanded[k]:insert(dUdx_i[j][k])	-- dUdx_i has a last _,x
				end
			end
		end
	else
		dFdx_lhs_exprs_expanded:insert(dFdx_i)
		assert(not Tensor:isa(dUdt_i))
		dUdt_lhs_exprs_expanded:insert(dUdt_i)
		assert(not Tensor:isa(S_i))
		S_rhs_exprs_expanded:insert(assert(S_i))
		assert(Tensor:isa(dUdx_i))
		for k=1,3 do
			dUdxs_lhs_exprs_expanded[k]:insert(dUdx_i[k])	-- dUdx_i has a last _,x, so always assume its a Tensor
		end
	end
end

local n = #dFdx_lhs_exprs_expanded
-- [[
printbr'unraveling flux for eigensystem + source...'
for i=1,#dUdt_lhs_exprs_expanded do
	printbr((dUdt_lhs_exprs_expanded[i] + dFdx_lhs_exprs_expanded[i]):eq(S_rhs_exprs_expanded[i]))
end
--]]

printbr'as linear system...'
local U_vars_expanded = dUdt_lhs_exprs_expanded:mapi(function(v)
	v = v:clone()
	assert(Derivative:isa(v) and Variable:isa(v[1]) and v[2] == t)
	return v[1]
end)


local Sijkl_expanded = Matrix(S_rhs_exprs_expanded):T()
Sijkl_expanded.rowsplits = rowsplits

local Uijkl_expanded = Matrix(U_vars_expanded):T()
local Upqmn_expanded = Uijkl_expanded:clone()

local dUdt_lhs_exprs_expanded_mat = Matrix(dUdt_lhs_exprs_expanded):T()
dUdt_lhs_exprs_expanded_mat.rowsplits = rowsplits


local rest = table(dFdx_lhs_exprs_expanded)
local dUdxs_lhs_exprs_expanded_mat = table()
local dFijkl_dUpqmn_expanded_mats = table()
local betaUDense = beta'^i':replaceWithDense()()
for j=1,3 do
	dFijkl_dUpqmn_expanded_mats[j], rest = factorLinearSystem(rest, dUdxs_lhs_exprs_expanded[j])
	dFijkl_dUpqmn_expanded_mats[j].colsplits = rowsplits
	dFijkl_dUpqmn_expanded_mats[j].rowsplits = rowsplits
	
	rest = table(rest:T()[1])

	local dUdxi_lhs_exprs_expanded_mat = Matrix(dUdxs_lhs_exprs_expanded[j]):T()
	dUdxi_lhs_exprs_expanded_mat.rowsplits = rowsplits
	dUdxs_lhs_exprs_expanded_mat:insert(dUdxi_lhs_exprs_expanded_mat)

	-- somewhere in here I need to subtract out the diagonal -beta^x if I want to help the eigen solver
	--printbr('subtracting ', -betaUDense[j] * var'I', '...')
	dFijkl_dUpqmn_expanded_mats[j] = (dFijkl_dUpqmn_expanded_mats[j] + Matrix.identity(#dFijkl_dUpqmn_expanded_mats[j]) * betaUDense[j])()
	dFijkl_dUpqmn_expanded_mats[j].colsplits = rowsplits
	dFijkl_dUpqmn_expanded_mats[j].rowsplits = rowsplits
end

rest = Matrix(rest):T()
rest.rowsplits = rowsplits
-- TODO should I assert rest == 0? and if so then should I just leave it out?

printbr(
	(
		dUdt_lhs_exprs_expanded_mat
		+ (dFijkl_dUpqmn_expanded_mats[1] - betaUDense[1] * var'I') * dUdxs_lhs_exprs_expanded_mat[1]
		+ (dFijkl_dUpqmn_expanded_mats[2] - betaUDense[2] * var'I') * dUdxs_lhs_exprs_expanded_mat[2]
		+ (dFijkl_dUpqmn_expanded_mats[3] - betaUDense[3] * var'I') * dUdxs_lhs_exprs_expanded_mat[3]
		+ rest
	):eq(
		Sijkl_expanded
	)
)
printbr()


-- continue on just doing 1D x-dir stuff
local dFijkl_dUpqmn_expanded = dFijkl_dUpqmn_expanded_mats[1]
dUdx_lhs_exprs_expanded_mat, dUdy_lhs_exprs_expanded_mat, dUdz_lhs_exprs_expanded_mat = dUdxs_lhs_exprs_expanded_mat:unpack()


if eigensystem_removeZeroRows then
	printHeader'removing zero rows:'
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
			table.remove(dUdt_lhs_exprs_expanded_mat, i)
			-- alright, here, if we are removing a row from dUdt_lhs_exprs_expanded_mat
			-- then we should also remove the same a row from dUdx_lhs_exprs_expanded_mat
			table.remove(dUdx_lhs_exprs_expanded_mat, i)
			-- then we should also remove the matching col from dFijkl_dUpqmn_expanded
			for k=1,#dFijkl_dUpqmn_expanded do
				table.remove(dFijkl_dUpqmn_expanded[k], i)
			end
			table.remove(Sijkl_expanded, i)
			rowsplits:remove(i)
			m = m - 1
			n = n - 1
		end
	end
	--[=[
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
			table.remove(dUdx_lhs_exprs_expanded_mat, j)
			-- and TODO if we're removing cols from dFijkl_dUpqmn and rows from Upqmn
			-- then we should remove matching rows from Uijkl
			table.remove(dUdt_lhs_exprs_expanded_mat, j)
			-- and removing matching rows from dFijkl_dUpqmn
			table.remove(dFijkl_dUpqmn_expanded, j)
			table.remove(Sijkl_expanded, j)
			rowsplits:remove(j)
			m = m - 1
			n = n - 1
		end
	end
	--]=]
	printbr((dUdt_lhs_exprs_expanded_mat + dFijkl_dUpqmn_expanded * dUdx_lhs_exprs_expanded_mat):eq(Sijkl_expanded))
	-- TODO if this fails then that means we need find the removed rows from Upqmn and remove the associated columns from dFijkl_dUpqmn
	assert(m == n, "removed a different number of all-zero rows vs columns")
	printbr()
	--]]
end

-- [[ output the linear system in the x-direction, (removing source) to another SymMath .lua file
-- then load it somewhere else where I can load it and work on the eigenmodes / left-eigenvectors: 
-- w_,t + R Λ L w_,x = 0
-- L w_,t + Λ L w_,x = 0
-- l_i w_,t + λ l_i w_,x = 0
do
	-- leave off the source
	for i=1,#dUdt_lhs_exprs_expanded_mat do
		local v = dUdt_lhs_exprs_expanded_mat[i][1]
		assert(Derivative:isa(v))
		assert(Variable:isa(v[1]))
		-- make sure simplifying the derivative doesn't make it go away
		v[1]:setDependentVars(txs:unpack())
	end
	local sys = (dUdt_lhs_exprs_expanded_mat + dFijkl_dUpqmn_expanded * dUdx_lhs_exprs_expanded_mat)
	local dstfn = 'Z4 - flux PDE noSource'
	if eigensystem_exportOnlyUs then
		dstfn = dstfn .. ' usingOnlyUs'
	end
	dstfn = dstfn .. '.lua'
	path(dstfn):write(export.SymMath(sys))
end
--]]


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

--[[
-- this prints out the source terms, including the flux deriv converted to 1st-deriv-state-vars ....
-- whats left is the flux terms not converted to 1st-deriv-state-vars, which are the values used for the flux jacobian eigensystem ...
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
print'</pre>'
--]]

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


-- so my eigensystem solver goes slow.  let's try to fix it.
--[[ doesn't stop eigensystem solver from stalling...
printbr'replace sqrt vars with non-sqrt vars to help speed up the eigensystem solver:'
local gammaUxx = gamma'^ij':replaceWithDense()()[1][1]
local sqrtf = var'\\sqrt{f}'
local sqrt_gammaUxx = var'\\sqrt{\\gamma^{xx}}'
dFijkl_dUpqmn_expanded = dFijkl_dUpqmn_expanded
	:replace(f, sqrtf^2)
	:replace(gammaUxx, sqrt_gammaUxx^2)
	:simplify()
--]]
-- [[ does help performance? esp for Z4 block
printbr('dividing by', alpha)
dFijkl_dUpqmn_expanded = (dFijkl_dUpqmn_expanded / alpha)()
--]]
--[[ this might speed up the inverse calculation, but not necessarily further down the line
printbr('replacing', gamma'^ij', 'for', gamma'_ij')
local gammaUUDense = gamma'^ij':replaceWithDense()()
local gammaLLDense = gamma'_ij':replaceWithDense()()
dFijkl_dUpqmn_expanded = dFijkl_dUpqmn_expanded
	:replace(-gammaUUDense[1][2]^2 + gammaUUDense[1][1] * gammaUUDense[2][2], gammaLLDense[3][3] * det_gamma)
	:replace(gammaUUDense[1][1] * gammaUUDense[2][3] - gammaUUDense[1][2] * gammaUUDense[1][3], -gammaLLDense[2][3] * det_gamma)
	:replace(-gammaUUDense[1][3]^2 + gammaUUDense[1][1] * gammaUUDense[3][3], gammaLLDense[2][2] * det_gamma)
	:simplify()
--]]
printbr(dFijkl_dUpqmn_expanded)
printbr()

printHeader'calculating charpoly'

local charpoly = dFijkl_dUpqmn_expanded:charpoly(lambda)
printbr(charpoly)
assert(symmath.op.eq:isa(charpoly))
assert(Constant.isValue(charpoly:rhs(), 0))

printHeader'finding lambdas'
local lambdas = table()

-- TODO what if solve() fails?
for _,soln in ipairs{charpoly:solve(lambda)} do
	if soln:lhs() ~= lambda then
		-- TODO better display these
		printbr('failed to find root for charpoly term:', soln)
	else
		printbr('root', soln)
		lambdas:insert(soln:rhs())
	end
end

--[======[ eigensystem stuff is too slow  for now

-- [=[

-- ok so now these rules might come in handy:
assert(symmath.op.div:popRule'Prune/conjOfSqrtInDenom')
assert(symmath.op.div:popRule'Factor/polydiv')
--[[
symmath.op.mul:pushRule'Factor/negPowToDivPow'
symmath.op.mul:pushRule'Prune/combineMulOfLikePow_mulPowAdd'
symmath.op.div:pushRule'Prune/conjOfSqrtInDenom'
symmath.op.div:pushRule'Prune/prodOfSqrtOverProdOfSqrt'
symmath.op.div:pushRule'Prune/mulBySqrtConj'
symmath.op.pow:pushRule'Prune/sqrtFix2'
symmath.op.pow:pushRule'Prune/sqrtFix3'
symmath.op.pow:pushRule'Prune/sqrtFix4'
--]]


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
--]======] -- eigensystem stuff is too slow
--]===]

-- DONE
printHeader()
io.stderr:write('TOTAL: '..(timer() - startTime)..'\n')
io.stderr:flush()
print(MathJax.footer)
