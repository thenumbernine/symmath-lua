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

local indexes = table{
	'^t_tt',
	'^t_ti',
	--Gamma^t_it = Gamma^t_ti
	'^i_tt',
	'^i_mt',
	--Gamma^i_tm = Gamma^i_mt
	'^t_im',
	'^i_mn',
}
local GammasForIndexes = table()

for _,index in ipairs(indexes) do
	local indexLetters = index:gsub('[^%a]', '')
	
	print'<hr>'
	
	local expr = Gamma(index)
	printbr(expr)

	printbr'factor out index raise'
	-- what this function will have to do:
	-- 1) keep track of which indexes in the 'to' are summation indexes
	-- 2) replace the summation indexes in 'from' with unused summation indexes
	-- 3) replace the non-summation indexes in 'from' with whatever indexes we match them to
	-- 3.5) replace non-summation indexes in this index set and all index sets that are a subset of it...?
	-- 4) don't replace single-variable indexes.  specificially: only replace indexes within their same subset of indexes (spatial, etc, etc).
	--		If a subset only has one coordinate _t _x _y _z then duplicates are fine.
	--		But if a subset has multiple coordinates (i.e. the defaults spanning txyz, or ijklmn represents indexes spanning xyz but not t) then make sure we don't use more indexes than the subset allows
	--		...or complain when we pass that limit.
	--expr = indexExprReplace(expr, Gamma'^a_bc', g'^ad' * Gamma'_dbc')
	expr = expr:replace(
		Gamma'^a_bc':reindex{[indexLetters] = 'abc'}, 
		(g'^ad' * Gamma'_dbc'):reindex{[indexLetters] = 'abc'})
	printbr(expr)

	printbr'substitute definition of connection'
	-- same as above
	-- expr = indexExprReplace(expr, Gamma'_abc', frac(1,2) * (g'_ab,c' + g'_ac,b' - g'_bc,a'))
	expr = expr:replace(
		Gamma'_abc':reindex{[indexLetters..'d'] = 'dbca'},
		(frac(1,2) * (g'_ab,c' + g'_ac,b' - g'_bc,a')):reindex{[indexLetters..'d'] = 'dbca'})

	expr = expr()
	printbr(expr)

	printbr'split the index a into t and j'
	expr = splitIndex(expr, 'd', {'t', 'j'})
	expr = expr()
	printbr(expr)

	printbr'replace ADM metric definitions'
	--[[ 
	-- this should only take 4 statements (3 if symmetries are stored)
	expr = indexExprReplace(expr, g'_tt', -alpha^2 + beta'^i' * beta'^j' * gamma'_ij')
	expr = indexExprReplace(expr, g'_ti', beta'_i')
	expr = indexExprReplace(expr, g'_it', beta'_i')
	expr = indexExprReplace(expr, g'_ij', gamma'_ij')
	
	expr = indexExprReplace(expr, g'^tt', -1/alpha^2)
	expr = indexExprReplace(expr, g'^ti', beta'_i' / alpha^2)
	expr = indexExprReplace(expr, g'^it', beta'_i' / alpha^2)
	expr = indexExprReplace(expr, g'^ij', gamma'^ij' - beta'^i' * beta'^j' / alpha^2)
	--]]
	expr = indexExprReplace(expr, g'_tt', -alpha^2 + beta^2)
	expr = indexExprReplace(expr, g'_jt', gamma'_jk' * beta'^k')
	expr = indexExprReplace(expr, g'_mt', gamma'_mk' * beta'^k')
	expr = indexExprReplace(expr, g'_ti', gamma'_ik' * beta'^k')
	expr = indexExprReplace(expr, g'_tm', gamma'_mk' * beta'^k')
	expr = indexExprReplace(expr, g'_tn', gamma'_nk' * beta'^k')
	expr = indexExprReplace(expr, g'_im', gamma'_im')
	expr = indexExprReplace(expr, g'_mn', gamma'_mn')
	expr = indexExprReplace(expr, g'_jm', gamma'_jm')
	expr = indexExprReplace(expr, g'_jn', gamma'_jn')
	expr = indexExprReplace(expr, g'^tt', -1/alpha^2)
	expr = indexExprReplace(expr, g'^it', beta'^i' / alpha^2)
	expr = indexExprReplace(expr, g'^tj', beta'^j' / alpha^2)
	expr = indexExprReplace(expr, g'^ij', gamma'^ij' - beta'^i' * beta'^j' / alpha^2)
	expr = indexExprReplace(expr, beta^2, gamma'_kl' * beta'^k' * beta'^l')
	printbr(expr)

	printbr'simplify...'
	expr = expr()
	printbr(expr)

	-- TODO some kind of tensor-friendly :prune() or :simplify()
	-- that keeps track of sum terms, and relabels them in some canonical form, and simplifies accordingly ?
	printbr'relabel...'

	expr = replaceSubExpr(expr, -beta'^i' * gamma'_kl,t' * beta'^k' * beta'^l',
								-beta'^i' * beta'^j' * beta'^k' * gamma'_jk,t')()
	printbr(expr)

	expr = replaceSubExpr(expr, -beta'^i' * beta'^j' * gamma'_kl' * beta'^k' * beta'^l_,j',
								-beta'^i' * beta'^j' * gamma'_kl' * beta'^k_,j' * beta'^l')()
	printbr(expr)

	expr = replaceSubExpr(expr, -beta'^i' * gamma'_kl' * beta'^k_,t' * beta'^l',
								-beta'^i' * beta'^j' * gamma'_jk' * beta'^k_,t')()
	printbr(expr)

	expr = replaceSubExpr(expr, -beta'^i' * gamma'_kl' * beta'^k' * beta'^l_,t',
								-beta'^i' * beta'^j' * gamma'_jk' * beta'^k_,t')()
	printbr(expr)

	expr = replaceSubExpr(expr, -2 * gamma'^ij' * alpha^2 * gamma'_jk' * beta'^k_,t',
								-2 * alpha^2 * beta'^i_,t')()
	printbr(expr)

	expr = replaceSubExpr(expr, gamma'^ij' * alpha^2 * gamma'_kl' * beta'^k' * beta'^l_,j',
								gamma'^ij' * alpha^2 * gamma'_kl' * beta'^k_,j' * beta'^l')()
	printbr(expr)
	
	GammasForIndexes[index] = expr

	printbr('for ', beta'^i':eq(0))

	expr = replaceForAnyIndex(expr, beta'^i', 0)()
	printbr(expr)
end

-- ok now Riemann
local indexes = table{
	--R^t_ttt = 0
	'^t_tti',
	--R^t_tit = -R^t_tti
	--R^t_itt = 0
	--R^i_ttt = 0
	'^t_tij',
	'^t_itj',
	'^i_ttj',
	--R^t_ijt = -R^t_itj
	--R^i_tjt = -R^i_ttj
	--R^i_jtt = 0
	'^t_ijk',
	'^i_tjk',
	'^i_jtk',
	--R^i_jkt = -R^i_jtk
	'^i_jkl',
}

for _,index in ipairs(indexes) do
	local indexLetters = index:gsub('[^%a]', '')
	
	print'<hr>'
	
	local expr = R(index)
	printbr(expr)

	printbr'substitute definition of Riemann curvature'
	expr = expr:replace(
		R'^a_bcd':reindex{[indexLetters] = 'abcd'}, 
		(Gamma'^a_bd'',c' - Gamma'^a_bc'',d' + Gamma'^a_ec' * Gamma'^e_bd' - Gamma'^a_ed' * Gamma'^e_bc'):reindex{[indexLetters] = 'abcd'})
	printbr(expr)

	printbr'split the index e into t and m'
	-- TODO FIXME splitIndex just duplicates whole expressions.
	expr = expr:replace(
		Gamma'^a_ec':reindex{[indexLetters] = 'abcd'}, 
		(Gamma'^a_tc' + Gamma'^a_mc'):reindex{[indexLetters] = 'abcd'})
	expr = expr:replace(
		Gamma'^e_bd':reindex{[indexLetters] = 'abcd'}, 
		(Gamma'^t_bd' + Gamma'^m_bd'):reindex{[indexLetters] = 'abcd'})
	expr = expr:replace(
		Gamma'^a_ed':reindex{[indexLetters] = 'abcd'}, 
		(Gamma'^a_td' + Gamma'^a_nd'):reindex{[indexLetters] = 'abcd'})
	expr = expr:replace(
		Gamma'^e_bc':reindex{[indexLetters] = 'abcd'}, 
		(Gamma'^t_bc' + Gamma'^n_bc'):reindex{[indexLetters] = 'abcd'})
	printbr(expr)
	expr = expr()
	printbr(expr)
end

