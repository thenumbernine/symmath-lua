#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup{implicitVars = true, MathJax=true}

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

-- this will work like :replace()
-- except I'm going to split off derivative TensorRef's so that substitution can properly work
local function indexExprReplace(expr, from, to)
	local TensorRef = require 'symmath.tensor.TensorRef'
	expr = expr:map(function(x)
		if TensorRef.is(x) then
--			x = x()	-- recombine indexes if possible ... but I don't want to simplify expressions yet ...
			x = x:replace(from, to)	-- replace if possible
			-- now split off any derivative indexes
			local derivIndex = table.sub(x, 2):find(nil, function(ref)
				return ref.derivative
			end) 
			if derivIndex and derivIndex > 1 then
				x = TensorRef(
					TensorRef(x[1], table.unpack(x, 2, derivIndex)),
					table.unpack(x, derivIndex+1)
				)
			end
			x = x:replace(from, to)	-- and replace if possible
			return x
		end
	end)
	return expr
end

-- this replaces sub-expressions
-- but only works if the indexes are all lined up
-- next feat:
-- combine all terms that have same non-summed indexes and same patterns of summed indexes
-- or for now manually replace them:
local function replaceSubExpr(expr, from, to)
	return expr:prune():replace(from:prune(), to)()
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
