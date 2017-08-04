#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup{implicitVars = true, MathJax=true}
	
local TensorRef = require 'symmath.tensor.TensorRef'

-- I should be coding up some tensor index expression substitution functions ...
-- TODO instead of 'toSet', provide basis to split indexes into
-- and then automatically pick the indexes
local function splitIndex(expr, from, toSet)
	local result
	for _,to in ipairs(toSet) do
		local nextTerm = expr:reindex{[to]=from}
		result = result and result + nextTerm or nextTerm
	end
	return result
end

-- this takes the combined comma derivative references and splits off the comma parts into separate references
-- it is very helpful for replacing tensors
local function splitOffDerivRefs(expr)
	return expr:map(function(x)
		if TensorRef.is(x) then
			local derivIndex = table.sub(x, 2):find(nil, function(ref)
				return ref.derivative
			end) 
			if derivIndex and derivIndex > 1 then
				return TensorRef(
					TensorRef(x[1], table.unpack(x, 2, derivIndex)),
					table.unpack(x, derivIndex+1)
				)
			end
		end
	end)
end

-- this will work like :replace()
-- except I'm going to split off derivative TensorRef's so that substitution can properly work 
-- TODO check all combinations of to's indexes against from's indexes
local function indexExprReplace(expr, from, to)
	expr = splitOffDerivRefs(expr)
	return expr:replace(from, to)
end

-- this replaces sub-expressions
-- but only works if the indexes are all lined up
-- next feat:
-- combine all terms that have same non-summed indexes and same patterns of summed indexes
-- or for now manually replace them:
local function replaceSubExpr(expr, from, to)
	return expr:prune():replace(from:prune(), to)()
end


-- tensor replace for any indexes
-- for 'x' each tensor we find (TODO whole expressions)
-- look at its indexes
-- compare them to the 'from's indexes
-- if the pattern matches up
-- then replace it with the 'to' tensor with 'x's index pattern
local function replaceForAnyIndex(expr, from, to)
	assert(TensorRef.is(from))
	-- no substituting derivatives just yet (right?)
	-- but if you were, an easy fix would be to just call splitOffDerivRefs on 'from' to get it into 'canonical form'
	assert(not table.find( table.sub(from, 2), nil, function(x) return x.derivative end))	
	-- separate deriv references so substitutions can be performed on the original tensor
	expr = splitOffDerivRefs(expr)
	return expr:map(function(x)
		-- if we find a tensor 
		if TensorRef.is(x) 
		-- whose name matches what we're searching for
		and from[1] == x[1] 
		-- and which contains the same number of indexes
		and #from == #x
		then
			local fromForTo = {}
			local failed
			for i=2,#x do
				if x[i].derivative then -- ~= x[j].derivative then
					failed = true
					break
				end
				if not fromForTo[x[i].symbol] then
					fromForTo[x[i].symbol] = from[i].symbol
				else
					-- symbols don't match ... A^iji=1 can't substitute correctly for expression B^ijk.
					if fromForTo[x[i].symbol] ~= from[i].symbol then
						failed = true
						break
					end
				end
			end
			if not failed then
				-- TODO reindex 'to' according to 'fromForTo'
				return to
			end
		end
	end)
end



local grav = -Gamma'^i_tt'
printbr(grav)

grav = grav:replace(Gamma'^i_tt', g'^ia' * Gamma'_att')
printbr(grav)

grav = grav:replace(Gamma'^_att', frac(1,2) * (g'_at'',t' + g'_at'',t' - g'_tt'',a'))
grav = grav()
printbr(grav)

-- split the index a into t and j
grav = splitIndex(grav, 'a', {'t', 'j'})
grav = grav()
printbr(grav)

-- replace ADM metric definition
grav = indexExprReplace(grav, g'_tt', -alpha^2 + beta^2)
grav = indexExprReplace(grav, g'_jt', gamma'_jk' * beta'^k')
grav = indexExprReplace(grav, g'^it', beta'^i' / alpha^2)
grav = indexExprReplace(grav, g'^ij', gamma'^ij' - beta'^i' * beta'^j' / alpha^2)
grav = indexExprReplace(grav, beta^2, gamma'_kl' * beta'^k' * beta'^l')
printbr(grav)

grav = grav()
printbr(grav)

-- TODO some kind of tensor-friendly :prune() or :simplify()
-- that keeps track of sum terms, and relabels them in some canonical form, and simplifies accordingly ?

grav = replaceSubExpr(grav, -beta'^i' * gamma'_kl,t' * beta'^k' * beta'^l',
							-beta'^i' * beta'^j' * beta'^k' * gamma'_jk,t')()
printbr(grav)

grav = replaceSubExpr(grav, -beta'^i' * beta'^j' * gamma'_kl' * beta'^k' * beta'^l_,j',
							-beta'^i' * beta'^j' * gamma'_kl' * beta'^k_,j' * beta'^l')()
printbr(grav)

grav = replaceSubExpr(grav, -beta'^i' * gamma'_kl' * beta'^k_,t' * beta'^l',
							-beta'^i' * beta'^j' * gamma'_jk' * beta'^k_,t')()
printbr(grav)

grav = replaceSubExpr(grav, -beta'^i' * gamma'_kl' * beta'^k' * beta'^l_,t',
							-beta'^i' * beta'^j' * gamma'_jk' * beta'^k_,t')()
printbr(grav)

grav = replaceSubExpr(grav, -2 * gamma'^ij' * alpha^2 * gamma'_jk' * beta'^k_,t',
							-2 * alpha^2 * beta'^i_,t')()
printbr(grav)

grav = replaceSubExpr(grav, gamma'^ij' * alpha^2 * gamma'_kl' * beta'^k' * beta'^l_,j',
							gamma'^ij' * alpha^2 * gamma'_kl' * beta'^k_,j' * beta'^l')()
printbr(grav)

printbr('for ', beta'^i':eq(0))

grav = replaceForAnyIndex(grav, beta'^i', 0)()
printbr(grav)
