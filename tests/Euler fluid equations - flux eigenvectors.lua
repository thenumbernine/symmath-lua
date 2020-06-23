#!/usr/bin/env luajit
require 'ext'
op = nil	-- make way for _G.op = symmath.op
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='Euler Fluid Equations - flux eigenvectors'}}

local delta = Tensor:deltaSymbol()	-- Kronecher delta
local g = var'g'					-- metric

-- TODO tidyIndexes() is breaking on this worksheet
-- it seems like it does work if you are sure to :simplify():factorDivision() beforehand

-- TODO 
local function simplifyMetrics(expr, deltas)
	if Array.is(expr) then
		return getmetatable(expr):lambda(expr:dim(), function(...)
			return simplifyMetrics(expr:get{...}, deltas)
		end)
	end

	deltas = deltas or table{delta, g}
	expr = expr():factorDivision()	-- put it in add-mul-div order
	expr = expr:clone()
	local function checkMul(expr)
		if not op.mul.is(expr) then return expr end
		for i=#expr,1,-1 do
			local deltaTerm = expr[i]
			local found
			-- TODO also make sure there is no derivative or comma-derivative that is wrapping deltaTerm
			if TensorRef.is(deltaTerm) 
			and deltas:find(deltaTerm[1])
			and #deltaTerm == 3 
			-- TODO here, delta only simplifies with opposing index variance: delta^i_j
			--  and g only simplifies with identical index variance: g_ij
			--  (though if we are using the "g-raises-and-lowers" rule then g^i_j = delta^i_j)
			-- don't simplify a^i delta_ij => a_j ... because a_j = a^i g_ij, and we don't know if g_ij == delta_ij
			--and (not not deltaTerm[2].lower) = not (not not deltaTerm[3].lower)
			then
--printbr('found delta at', i)				
				for deltaI=2,3 do
					local deltaIndex = deltaTerm[deltaI]
--printbr('checking delta index', deltaIndex.symbol)
					for j,xj in ipairs(expr) do
						if i ~= j
						and TensorRef.is(xj) 
						then
--printbr('found non-delta at', j)
							local indexIndex = table.sub(xj, 2):find(nil, function(xjIndex)
--printbr("comparing symbols ",	xjIndex.symbol, deltaIndex.symbol, ' and comparing lowers', xjIndex.lower, deltaIndex.lower)
								return xjIndex.symbol == deltaIndex.symbol 
									and (not not xjIndex.lower) == not (not not deltaIndex.lower)
							end)
--printbr('found matching index at', indexIndex)							
							if indexIndex then
								local replDeltaIndex = deltaTerm[5 - deltaI]
--printbr('replacing with opposing delta index', replDeltaIndex.symbol)								
--printbr('replacing...', xj)
								xj[indexIndex+1].symbol = replDeltaIndex.symbol
								xj[indexIndex+1].lower = replDeltaIndex.lower
--printbr('removing delta')								
								table.remove(expr, i)
								-- if we just removed our last delta then return what's left
								
								found = true
								break
							end
						end
					end
					if found then break end
				end
			end
		end
		if #expr == 1 then expr = expr[1] end
		return expr
	end
	if op.add.is(expr) then
		for i=1,#expr do
			expr[i] = checkMul(expr[i])
		end
		if #expr == 1 then expr = expr[1] end
	else
		expr = checkMul(expr)
	end
	return expr
end

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
local tildeGamma_def = tildeGamma:eq(gamma - 1)
printbr(tildeGamma_def)

local P = var'P'		-- pressure
printbr(P, [[= pressure, in units of ]], kg / (m * s^2))

printbr(g'_ij', [[= metric tensor, in units of $[1]$]])

local vSq_var = var('(v)^2')
local vSq_wrt_v = v'^k' * v'^l' * g'_kl'
local vSq_def = vSq_var:eq(vSq_wrt_v)
printbr(vSq_def, [[= velocity norm squared, in units of]], m^2/s^2)
printbr()

local e_kin = var'e_{kin}'
local e_kin_def = e_kin:eq(frac(1,2) * vSq_wrt_v)					-- specific kinetic energy
printbr(e_kin_def, [[= specific kinetic energy, in units of]], m^2/s^2)
printbr()

local e_int = var'e_{int}'
local e_int_def = e_int:eq(P / (tildeGamma * rho))		-- specific internal energy 
printbr(e_int_def, [[= specific internal energy, in units of]], m^2/s^2)
printbr()

local E_total = var'E_{total}'
local E_total_def = E_total:eq(rho * (e_int + e_kin))	-- total energy
printbr(E_total_def, [[= densitized total energy, in units of]], kg / (m * s^2))

local E_total_wrt_W = E_total_def:subst(e_int_def, e_kin_def)
	:subst(vSq_def:switch())():factorDivision()
printbr(E_total_wrt_W)
printbr()

local H_total = var'H_{total}'
local H_total_def = H_total:eq(E_total + P)
printbr(H_total_def, [[= total enthalpy, in units of]], kg / (m * s^2))

local H_total_wrt_W = H_total_def:subst(E_total_wrt_W)
	:subst(vSq_def:switch())():factorDivision()
printbr(H_total_wrt_W)
printbr()


local c = var'c'		-- commutation
local Gamma = var'\\Gamma'
local B = var'B'	-- magnetic field
local S = var'S'		-- source terms



--[[ TODO fixme
printbr(m'^i' * E_total)
printbr((m'^i' * E_total):replace(E_total, vSq_wrt_v))
printbr((m'^i' * E_total):replaceIndex(E_total, vSq_wrt_v))
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

dU_dW_def = dU_dW_def():subst(vSq_def:switch()())

-- TODO move simplifyMetrics from numerical-relativity-codegen/show_flux_matrix.lua into Expression
-- TODO before that, rewrite that and replaceIndex in terms of wildcards
-- [[
dU_dW_def[3][2] = simplifyMetrics(dU_dW_def[3][2])()
--]]
printbr(U'^I':diff(W'^J'):eq(dU_dW_def))

-- this doesn't work with indexed elements of the matrix.  you'd have to either expand it, or ... do some math 
--local dW_dU_def = dU_dW_def:inverse()
local dW_dU_def = Matrix(
	{1, 0, 0},
	{-v'^i' / rho, delta'^i_j' / rho, 0},
	{frac(1,2) * tildeGamma * vSq_wrt_v, -tildeGamma * v'_j', tildeGamma}
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

F_def = F_def:subst(H_total_def, E_total_def, e_int_def, e_kin_def)():factorDivision()
printbr(F'^I':eq(F_def))
printbr()

printbr'Flux derivative wrt primitive variables:'
local dF_dW_def = Matrix:lambda({3,3}, function(i,j)
	return F_def[i][1]:reindex{jk='km'}:diff( W_def[j][1]:reindex{i='j'})
end)
printbr(F'^I':diff(W'^J'):eq(dF_dW_def))

dF_dW_def = simplifyMetrics(dF_dW_def)():factorDivision()
printbr(F'^I':diff(W'^J'):eq(dF_dW_def))

dF_dW_def = dF_dW_def:tidyIndexes()():factorDivision() 
printbr(F'^I':diff(W'^J'):eq(dF_dW_def))

-- doesn't work for all indexes, only 'a's
--dF_dW_def = dF_dW_def:replaceIndex(v'^a' * v'_a', vSq_var)
-- instead:
dF_dW_def = dF_dW_def
	:replace(v'^a' * v'_a', vSq_var)
	:replace(v'^b' * v'_b', vSq_var)
printbr(F'^I':diff(W'^J'):eq(dF_dW_def))

dF_dW_def = dF_dW_def 
	:subst(H_total_wrt_W:solve(P), tildeGamma_def)()
	:subst(tildeGamma_def:solve(gamma))
	:replace(vSq_var, v'^b' * v'_b')
	():factorDivision():tidyIndexes()():factorDivision()
printbr(F'^I':diff(W'^J'):eq(dF_dW_def))
printbr()


printbr'Flux derivative wrt conserved variables:'
printbr(F'^I':diff(U'^J'):eq(F'^I':diff(W'^L') * W'^L':diff(U'^J')))

local dF_dU_def = dF_dW_def:reindex{j='k'} * dW_dU_def:reindex{ik='km'}
printbr(F'^I':diff(U'^J'):eq(dF_dU_def))

dF_dU_def = dF_dU_def():factorDivision()
printbr(F'^I':diff(U'^J'):eq(dF_dU_def))

dF_dU_def = dF_dU_def:tidyIndexes()()
dF_dU_def = simplifyMetrics(dF_dU_def)():factorDivision():tidyIndexes()():factorDivision()
printbr(F'^I':diff(U'^J'):eq(dF_dU_def))
printbr()


printbr'Acoustic matrix:'

local A = var'A'
local A_lhs = A'^I_J' + n'_a' * v'^a' * delta'^I_J'

printbr(A_lhs:eq(W'^I':diff(U'^K') * F'^K':diff(W'^J')))

local A_plus_delta_def = dW_dU_def:reindex{jk='km'} * dF_dW_def:reindex{ik='kn'}
printbr(A_lhs:eq(A_plus_delta_def))

A_plus_delta_def = A_plus_delta_def()
printbr(A_lhs:eq(A_plus_delta_def))

-- TODO if you don't do :factorDivision() before :tidyIndexes() then you can get mismatching indexes, and the subsequent :simplify() will cause a stack overflow
A_plus_delta_def = simplifyMetrics(A_plus_delta_def)():factorDivision():tidyIndexes()()	
	:replace(n'^a' * v'_a', n'_a' * v'^a')
	:replace(v'^a' * v'_a', vSq_var)
	:subst(H_total_wrt_W, tildeGamma_def)()
printbr(A_lhs:eq(A_plus_delta_def))

local A_def = (A_plus_delta_def - Matrix.identity(3) * Matrix:lambda({3,3}, function(i,j)
	return i~=j and 0 or (n'_a' * v'^a' * (i==2 and delta'^i_j' or 1)) 
end))()
printbr(A'^I_J':eq(A_def))
printbr()

printbr'Acoustic matrix, expanded:'
local A_expanded = Matrix:lambda({5,5}, function(i,j)
	local remap = {1,2,2,2,3}
	local replace = {nil, 1,2,3, nil}
	return A_def[remap[i]][remap[j]]
		:replace(n'^i', n('^'..replace[i]))
		:replace(n'_j', n('_'..replace[j]))
end)

printbr(A'^I_J':eq(A_expanded))
printbr()

printbr'Acoustic matrix eigenvalues:'
local A_eig = A_expanded:eigen()
for k,v in pairs(A_eig) do
	printbr(k,'=',v)
end

printbr(A'^I_J':eq(
	A_eig.R * A_eig.Lambda * A_eig.L
))
