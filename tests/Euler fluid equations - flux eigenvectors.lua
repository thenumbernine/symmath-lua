#!/usr/bin/env luajit
require 'ext'
op = nil	-- make way for _G.op = symmath.op
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='Euler Fluid Equations - flux eigenvectors'}}

-- TODO tidyIndexes() is breaking on this worksheet

local function sum(t)
	if #t == 1 then return t[1] end
	return op.add(table.unpack(t))
end


local kg = var'kg'
local m = var'm'
local s = var's'


printbr'variables:'

local n = var'n'
printbr(n'^i', '= flux surface normal, in units of $[1]$')

local rho = var'\\rho'	-- density
printbr(rho, [[= density, in units of ]], kg/m^3)

local v = var'v'	-- velocity
printbr(v'^i', [[= velocity, in units of ]], m/s)

--local m = var'm'	-- momentum
local m_from_v = m'^i':eq(rho * v'^i')
printbr(m_from_v, [[= momentum, in units of ]], kg/(m^2 * s))

local gamma = var'\\gamma'
printbr(gamma, [[= heat capacity ratio, in units of $[1]$]])

local tildeGamma = var'\\tilde{\\gamma}'	-- = gamma - 1
printbr(tildeGamma:eq(gamma - 1))

local P = var'P'		-- pressure
printbr(P, [[= pressure, in units of ]], kg / (m * s^2))

local g = var'g'			-- metric
printbr(g'_ij', [[= metric tensor, in units of $[1]$]])

local vSq = v'^k' * v'^l' * g'_kl'
local vSq_def = (v^2):eq(vSq)
printbr(vSq_def, [[= velocity norm squared, in units of]], m^2/s^2)
printbr()

local e_kin = var'e_{kin}'
local e_kin_def = e_kin:eq(frac(1,2) * vSq)					-- specific kinetic energy
printbr(e_kin_def, [[= specific kinetic energy, in units of]], m^2/s^2)
printbr()

local e_int = var'e_{int}'
local e_int_def = e_int:eq(P / (tildeGamma * rho))		-- specific internal energy 
printbr(e_int_def, [[= specific internal energy, in units of]], m^2/s^2)
printbr()

local E_total = var'E_{total}'
local E_total_def = E_total:eq(rho * (e_int + e_kin))	-- total energy
printbr(E_total_def, [[= densitized total energy, in units of]], kg / (m * s^2))
printbr()

local H_total = var'H_{total}'
local H_total_def = H_total:eq(E_total + P)
printbr(H_total_def, [[= total enthalpy, in units of]], kg / (m * s^2))
printbr()


local c = var'c'		-- commutation
local delta = var'\\delta'	-- Kronecher delta
local Gamma = var'\\Gamma'
local B = var'B'	-- magnetic field
local S = var'S'		-- source terms



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

printbr'Conservative and primitive variables:'

local W = var'W'
local W_def = Matrix{rho, v'^i', P}:T()
printbr(W'^I':eq(W_def))

local U = var'U'
local U_def = Matrix{rho, m'^i', E_total}:T()
printbr(U'^I':eq(U_def))

printbr'Partial of conservative quantities wrt primitives:'

local dU_dW_def = Matrix:lambda({3,3}, function(i,j)
	return U_def[i][1]:diff( W_def[j][1]:reindex{i='j'} )
end)
printbr(U'^I':diff(W'^J'):eq(dU_dW_def))

dU_dW_def = dU_dW_def:subst(m_from_v, E_total_def, e_kin_def, vSq_def, e_int_def)
printbr(U'^I':diff(W'^J'):eq(dU_dW_def))

dU_dW_def = dU_dW_def()
	:subst(vSq_def:switch()())

-- TODO move simplifyMetrics from numerical-relativity-codegen/show_flux_matrix.lua into Expression
-- TODO before that, get wildcards and expr:match() to work, and rewrite that and replaceIndex in terms of wildcards
-- TODO before that, create a Wildcard object, but make it able to substitute for Expressions and for TensorIndex's
-- TODO before that, make TensorIndex an Expression, for traversal's sake
-- [[
dU_dW_def[3][2] = dU_dW_def[3][2]:factorDivision()
	:replace((v'^k' * g'_kl' * delta'^l_j')(), v'_j')
	:replace((v'^l' * g'_kl' * delta'^k_j')(), v'_j')
	:simplify()
--]]
printbr(U'^I':diff(W'^J'):eq(dU_dW_def))

-- this doesn't work with indexed elements of the matrix.  you'd have to either expand it, or ... do some math 
--local dW_dU_def = dU_dW_def:inverse()
local dW_dU_def = Matrix(
	{1, 0, 0},
	{-v'^i' / rho, delta'^i_j' / rho, 0},
	{frac(1,2) * tildeGamma * vSq, -tildeGamma * v'_j', tildeGamma}
)
printbr(W'^I':diff(U'^J'):eq(dW_dU_def))

printbr()
printbr'Flux:'

local F = var'F'
local F_def = Matrix{
	rho * v'^j' * n'_j',
	rho * v'^i' * v'^j' * n'_j' + n'^i' * P,
	v'^j' * n'_j' * H_total
}:T()
printbr(F'^I':eq(F_def))


printbr'Flux derivative wrt primitive variables:'
local dF_dW_def = Matrix:lambda({3,3}, function(i,j)
	return F_def[i][1]:diff( W_def[j][1]:reindex{i='j'})
end)
printbr(F'^I':diff(W'^J'):eq(dF_dW_def))

dF_dW_def = dF_dW_def()
printbr(F'^I':diff(W'^J'):eq(dF_dW_def))
os.exit()


F_def = F_def:map(function(x)
	if not x.replace then return end
	x = x:subst(H_total_def)
	x = x:replaceIndex(P, tildeGamma * (E_total - frac(1,2) * rho * vSq))
	x = x:splitOffDerivIndexes():replaceIndex(v'^i', m'^i' / rho)
	x = x:splitOffDerivIndexes():replaceIndex(v'_i', m'_i' / rho)
	return x
end)
printbr(F'^I':eq(F_def))

F_def = F_def()
F_def = F_def:factorDivision()
printbr(F'^I':eq(F_def))

--local partial_dF_def = Matrix:lambda(F_def:dim(), function(x) return x'_,j' end)
local partial_dF_def = (Matrix{
	F_def[1][1]'_,m',
	F_def[2][1]'_,m',
	F_def[3][1]'_,m',
}:T() * n'^m')()
partial_dF_def = partial_dF_def:factorDivision()
printbr(F'^I_,n':eq(partial_dF_def))

partial_dF_def = partial_dF_def()

-- remove n, gamma, or delta derivatives
local TensorRef = require 'symmath.tensor.TensorRef'
local function removeConstantDerivatives(x)
	if TensorRef.is(x)
	and x[#x].derivative
	and (x[1] == gamma or x[1] == tildeGamma or x[1] == delta or x[1] == n)
	then
		return Constant(0)
	end
end

partial_dF_def = partial_dF_def:map(removeConstantDerivatives)

partial_dF_def = partial_dF_def()
partial_dF_def = partial_dF_def:factorDivision()
printbr(F'^I_,n':eq(partial_dF_def))

-- TODO here reindex so no one is using 'k'

printbr'distribute'
partial_dF_def = partial_dF_def:reindex{k='m'}	-- repurpose 'k' so I can replace all m^?_,j's with m^k_,j's
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
--partial_dF_def = partial_dF_def:tidyIndexes()
partial_dF_def = partial_dF_def:factorDivision()
partial_dF_def = partial_dF_def:reindex{mj='jm'} 

printbr(F'^I_,n':eq(partial_dF_def))

local factorLinearSystem = require 'symmath.factorLinearSystem'
local dU = {
	rho'_,j', 
	m'^k_,j', 
	--B'^k_,j', 
	E_total'_,j',
}
local A, b = factorLinearSystem(partial_dF_def:T()[1], dU)
A = A:replace((n'^j' * n'_m' * delta'^m_k')(), n'^j' * n'_k')
	:replace((n'_m' * delta'^m_k')(), n'_k')
	:replace((g'_jl' * delta'^l_k')(), g'_jk')
	:replace((g'_jl' * delta'^j_k')(), g'_lk')()
local partial_dF_matrix_def = A * Matrix(dU):T() + b


printbr(F'^I_,n':eq(partial_dF_matrix_def))

local covar_dF_matrix_def = partial_dF_matrix_def:clone()
covar_dF_matrix_def[2] = covar_dF_matrix_def[2]:replaceIndex(g'_ij,k', 0)()	-- only do the 'b' term in A x + b
if covar_dF_matrix_def[2] == Matrix{0,0,0}:T() then 
	covar_dF_matrix_def = covar_dF_matrix_def[1]	-- leave off the + 0
end
covar_dF_matrix_def = covar_dF_matrix_def
-- replace ,'s with ;'s
-- [[ or... just insert the Gammas manually?
	:replaceIndex(m'^i_,j', m'^i_,j' + Gamma'^i_jk' * m'^k')
--]]
--[[ or cancel out the partials manually as well?
	:replaceIndex(rho'_,j', 0)
	:replaceIndex(m'^i_,j', Gamma'^i_kj' * m'^k')
	:replaceIndex(E_total'_,j', 0)
	:simplify()
--]]
printbr(F'^I_;n':eq(covar_dF_matrix_def))

-- TODO clean up the covariant wrt n

-- Gamma^k_jk = e_j(log(sqrt(det(g_ab))))
-- TODO DON'T FORGET TO INTEGRATE THIS WRT VOLUME
-- the state variables may be immune, but the connections are not.
local S_def = Gamma'^k_jk' * F_def:reindex{k='m'} + partial_dF_matrix_def - covar_dF_matrix_def
printbr(S'^I':eq(S_def)) 

S_def = S_def()	-- multiply all matrices and combine all vectors

S_def = S_def:replaceIndex(g'_ij,k', Gamma'_ikj' + Gamma'_jki')

-- combine all deltas
-- TODO combine all g's as well
local function simplifyDeltasAndMetrics(expr)
	return expr:map(function(x)
		if op.mul.is(x) then
			local changed
			local found
			repeat
				found = false
				for i=1,#x do
					local origx = x
					if TensorRef.is(x[i])
					and (x[i][1] == delta
						or x[i][1] == g
					)
					and #x[i] == 3
					and not x[i][#x[i]].derivative
					then
	--printbr('found delta in',x,' at ',i)
						local syma = x[i][2].symbol
						local symb = x[i][3].symbol
						
						local exprsForSymbols = x:getExprsForIndexSymbols()
	--printbr(require 'ext.tolua'{exprsForSymbols=exprsForSymbols, syma=syma, symb=symb})
						if #exprsForSymbols[syma] > #exprsForSymbols[symb] then syma, symb = symb, syma end
						
						-- now go through the expressions and replace all of syma with symb
						x = table{table.unpack(x)}
						x:remove(i)
						if #x == 1 then x = x[1] else x = op.mul(x:unpack()) end
	--printbr('removed delta to get', x)
						-- I can't just reindex syma=>symb
						-- I have to find which the sum term is ...
						x = x:reindex({[symb] = syma} 
							, origx[i][2].lower and 'lower' or 'raise'
						)
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
S_def = simplifyDeltasAndMetrics(S_def)

--S_def = S_def:tidyIndexes()
--[[ TODO
S_def = Matrix:lambda(S_def:dim(), function(i,j)
	return S_def[i][j]:tidyIndexes()
end)
--]]

S_def = S_def:symmetrizeIndexes(g, {1,2})
S_def = S_def()

printbr(S'^I':eq(S_def)) 

-- symmetrize Gamma_i(jk)? nope, could be anholonomic
--S_def = S_def:symmetrizeIndexes(Gamma, {2,3})
S_def = S_def:replace(Gamma'^c_cb', Gamma'^c_bc' - c'_cb^c')()

printbr(S'^I':eq(S_def)) 
-- 1/sqrt(g) (sqrt(g) F^Ij)_,j = F^I_,n + Gamma^k_jk F^Ij
-- 
-- F^I_;n = F^I_,n + n^j Gamma^k_jk F^I - S^I
-- S^I = -F^Ij_;j + F^I_,n + Gamma^k_jk F^Ij
-- of course the difference of F^Ij_;j - F^Ij_,j is the A matrix times the connection terms alone ... with the partials set to zero ... 

printbr'as a matrix in Cartesian coordinates'

printbr(var'A':eq(A))

A = A
	:expand()
	:replace((m'^j' * g'_jl')(), m'_l')
	:replace((m'^j' * g'_jk')(), m'_k')
	:replace((m'^l' * g'_lk')(), m'_k')
	:simplify()
	:expand()
	:replace((n'_m' * delta'^m_k')(), n'_k')	-- hmm, not working
	:simplify()
printbr(var'A':eq(A))

local xs = {'x', 'y', 'z'}

local function replaceIndex(expr, a, b)
	return expr:map(function(x)
		if TensorRef.is(x) then
			x = x:clone()
			for i=2,#x do
				if x[i].symbol == a then 
					x[i].symbol = b 
				end
			end
			return x
		end
	end)
end

local Ac = Matrix:lambda({5,5}, function(i,k)
	local si = ({1,2,2,2,3})[i]
	local sk = ({1,2,2,2,3})[k]
	local expr = A[si][sk]
	if si == 2 then
		expr = replaceIndex(expr, 'i', xs[i-1])
	end
	if sk == 2 then
		expr = replaceIndex(expr, 'k', xs[k-1])
	end
	return expr
end):map(function(x)
	if TensorRef.is(x)
	and x[1] == delta
	and #x == 3
	then
		local ident = ({
			x = {x=1, y=0, z=0},
			y = {x=0, y=1, z=0},
			z = {x=0, y=0, z=1},
		})
		local xi = ident[x[2].symbol]
		if xi then
			local xj = xi[x[3].symbol]
			if xj then return xj end
		end
	end
end)()
printbr(var'A':eq(Ac))

--[[ this is taking too long
local lambda = var'\\lambda'
local charpoly = (Ac - Matrix.diagonal(table{lambda}:rep(5):unpack()))():determinant():eq(0)()
printbr(charpoly)
--]]
