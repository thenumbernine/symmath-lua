#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup()
require 'symmath.tostring.MathJax'.setup{usePartialLHSForDerivative = true}

local function sum(t)
	if #t == 1 then return t[1] end
	return op.add(table.unpack(t))
end

-- primitive variables
local rho = var'\\rho'	-- density

local g = var'g'			-- metric
local m = var'm'	-- momentum
local v = var'v'	-- velocity
local B = var'B'	-- magnetic field
local P = var'P'		-- total specific energy 
local S = var'S'		-- source terms
local delta = var'\\delta'	-- Kronecher delta
local gamma = var'\\gamma'
local Gamma = var'\\Gamma'

local vSq = v'^k' * v'^l' * g'_kl'

local e_int = var'e_{int}'
local e_int_def = e_int:eq(P / ((gamma - 1) * rho))		-- specific internal energy 

local e_kin = var'e_{kin}'
local e_kin_def = e_kin:eq(frac(1,2) * vSq)					-- specific kinetic energy

local E_total = var'E_{total}'
local E_total_def = E_total:eq(rho * (e_int + e_kin))	-- total energy

local H_total = var'H_{total}'
local H_total_def = H_total:eq(E_total + P)

--[[ TODO fixme
printbr(m'^i' * E_total)
printbr((m'^i' * E_total):replace(E_total, vSq))
printbr((m'^i' * E_total):replaceIndex(E_total, vSq))
os.exit()
--]]

--[[ another fixme ... this works fine as long as the find doesn't have sum indexes
printbr(g'^ij_,j')
-- fails
--printbr((g'^ij_,j'):replaceIndex(g'^ij_,j', -g'^ik' * g'_kl,j' * g'^lj'))
-- works
printbr((g'^ij_,j'):replaceIndex(g'^ij_,m', -g'^ik' * g'_kl,m' * g'^lj'))
os.exit()
--]]

-- equations 
printbr'equations:'

local U = var'U'
local U_def = Matrix{rho, m'^i', E_total}:T()
printbr(U'^I':eq(U_def))

local F = var'F'
local F_def = Matrix{
	rho * v'^j',
	rho * v'^i' * v'^j' + g'^ij' * P,
	v'^j' * H_total
}:T()
printbr(F'^Ij':eq(F_def))

F_def = F_def:map(function(x)
	if not x.replace then return end
	x = x:subst(H_total_def)
	x = x:replaceIndex(P, (gamma - 1) * (E_total - frac(1,2) * rho * vSq))
	x = x:splitOffDerivIndexes():replaceIndex(v'^i', m'^i' / rho)
	x = x:splitOffDerivIndexes():replaceIndex(v'_i', m'_i' / rho)
	return x
end)
printbr(F'^Ij':eq(F_def))

F_def = F_def()
printbr(F'^Ij':eq(F_def))

--local partial_dF_def = Matrix:lambda(F_def:dim(), function(x) return x'_,j' end)
local partial_dF_def = Matrix{F_def[1][1]'_,j', F_def[2][1]'_,j', F_def[3][1]'_,j'}:T()
printbr(F'^Ij_,j':eq(partial_dF_def))

partial_dF_def = partial_dF_def()

-- remove gamma or delta derivatives
local TensorRef = require 'symmath.tensor.TensorRef'
local function removeConstantDerivatives(x)
	if TensorRef.is(x)
	and x[#x].derivative
	and (x[1] == gamma or x[1] == delta)
	then
		return Constant(0)
	end
end

partial_dF_def = partial_dF_def:map(removeConstantDerivatives)

partial_dF_def = partial_dF_def()
printbr(F'^Ij_,j':eq(partial_dF_def))

-- TODO here reindex so no one is using 'k'

printbr'distribute'
partial_dF_def = partial_dF_def:reindex{m='k'}	-- repurpose 'k' so I can replace all m^?_,j's with m^k_,j's
partial_dF_def = partial_dF_def:map(function(x)
	if TensorRef.is(x)
	and x[#x].derivative
	then
		-- replace all partials with specific indexes, like m^j_,j -> delta^j_k m^k_,j
		if x[1] == m or x[1] == B then
			if x[2].symbol ~= 'k' then
				x = x:clone()
				local oldsymbol = x[2].symbol
				x[2].symbol = 'k'
				return x * delta('^'..oldsymbol..'_k')
			end
		end
	end
end)

partial_dF_def = partial_dF_def:replaceIndex(g'^ij_,m', -g'^ik' * g'_kl,m' * g'^lj')
partial_dF_def = partial_dF_def:tidyIndexes()
partial_dF_def = partial_dF_def:factorDivision()
printbr(F'^Ij_,j':eq(partial_dF_def))

local factorLinearSystem = require 'symmath.factorLinearSystem'
local dU = {
	rho'_,j', 
	m'^k_,j', 
	--B'^k_,j', 
	E_total'_,j',
}
local A, b = factorLinearSystem(partial_dF_def:T()[1], dU)
local partial_dF_matrix_def = A * Matrix(dU):T() + b
printbr(F'^Ij_,j':eq(partial_dF_matrix_def))

local covar_dF_matrix_def = partial_dF_matrix_def:clone()
covar_dF_matrix_def[2] = covar_dF_matrix_def[2]:replaceIndex(g'_ij,k', 0)()	-- only do the 'b' term in A x + b
if covar_dF_matrix_def[2] == Matrix{0,0,0}:T() then 
	covar_dF_matrix_def = covar_dF_matrix_def[1]	-- leave off the + 0
end
covar_dF_matrix_def = covar_dF_matrix_def
-- replace ,'s with ;'s
-- [[ or... just insert the Gammas manually?
	:replaceIndex(m'^i_,j', m'^i_,j' + Gamma'^i_kj' * m'^k')
--]]
--[[ or cancel out the partials manually as well?
	:replaceIndex(rho'_,j', 0)
	:replaceIndex(m'^i_,j', Gamma'^i_kj' * m'^k')
	:replaceIndex(E_total'_,j', 0)
	:simplify()
--]]
printbr(F'^Ij_;j':eq(covar_dF_matrix_def))

local S_def = Gamma'^k_jk' * F_def + partial_dF_matrix_def - covar_dF_matrix_def
printbr(S'^I':eq(S_def)) 

S_def = S_def()	-- multiply all matrices and combine all vectors

-- combine all deltas
-- TODO combine all g's as well
local function simplifyKronecherDeltas(expr)
	return expr:map(function(x)
		if op.mul.is(x) then
			local changed
			local found
			repeat
				found = false
				for i=1,#x do
					if TensorRef.is(x[i])
					and x[i][1] == delta
					and #x[i] == 3
					and not x[i][#x[i]].derivative
					then
	--printbr('found delta in',x,' at ',i)
						local syma = x[i][2].symbol
						local symb = x[i][3].symbol
						
						local symbolCounts = x:getIndexCounts()
	--printbr(require 'ext.tolua'{symbolCounts=symbolCounts, syma=syma, symb=symb})
						if symbolCounts[syma] > symbolCounts[symb] then syma, symb = symb, syma end
						
						-- now go through the expressions and replace all of syma with symb
						x = table{table.unpack(x)}
						x:remove(i)
						if #x == 1 then x = x[1] else x = op.mul(x:unpack()) end
	--printbr('removed delta to get', x)
						-- I can't just reindex syma=>symb
						-- I have to find which the sum term is ...
						x = x:reindex{[syma] = symb}
	--printbr('reindexed to get', x)
						changed = true
						found = true
						break
					end
				end
			until not found 
			if changed then return x end
		end
	end)

end
S_def = simplifyKronecherDeltas(S_def)

S_def = S_def:replaceIndex(g'_ij,k', Gamma'_ijk' + Gamma'_jik')

S_def = Matrix{
	S_def[1][1]:tidyIndexes(),
	S_def[2][1]:tidyIndexes(),
	S_def[3][1]:tidyIndexes(),
}:T()

--S_def = S_def:symmetrizeIndexes(g, {1,2})
--S_def = S_def:symmetrizeIndexes(Gamma, {2,3})
S_def = S_def()

printbr(S'^I':eq(S_def)) 
-- 1/sqrt(g) (sqrt(g) F^Ij)_,j = F^Ij_,j + Gamma^k_jk F^Ij
-- 
-- F^Ij_;j = F^Ij_,j + Gamma^k_jk F^Ij - S^I
-- S^I = -F^Ij_;j + F^Ij_,j + Gamma^k_jk F^Ij
-- of course the difference of F^Ij_;j - F^Ij_,j is the A matrix times the connection terms alone ... with the partials set to zero ... 

