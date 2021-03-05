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

local h = var'h'	-- density
printbr(h, [[= wave height, in units of ]], m)

local v = var'v'	-- velocity
printbr(v'^i', [[= velocity, in units of ]], m/s)

--local m = var'm'	-- momentum
local m_from_v = m'^i':eq(h * v'^i')
printbr(m_from_v, [[= momentum, in units of ]], kg/(m^2 * s))

local gravity = var'\\gamma'
printbr(gravity, [[= pull of gravitation, in units of ]], m/s^2)

local Cs = var'c_s'
local Cs_def = Cs:eq(sqrt(gravity * h))
printbr(Cs_def, [[= speed of sound in units of ]], m / s)

printbr(g'_ij', [[= metric tensor, in units of $[1]$]])



local c = var'c'		-- commutation
local Gamma = var'\\Gamma'
local B = var'B'	-- magnetic field
local S = var'S'		-- source terms

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
local W_def = Matrix{h, v'^i'}:T()
printbr(W'^I':eq(W_def))

local U = var'U'
local U_def = Matrix{h, m'^i'}:T()
printbr(U'^I':eq(U_def))

printbr'Partial of conservative quantities wrt primitives:'

local dU_dW_def = Matrix:lambda({2,2}, function(i,j)
	return U_def[i][1]:diff( W_def[j][1]:reindex{i='j'} )
end)
printbr(U'^I':diff(W'^J'):eq(dU_dW_def))

dU_dW_def = dU_dW_def:subst(m_from_v)
printbr(U'^I':diff(W'^J'):eq(dU_dW_def))

printbr(U'^I':diff(W'^J'):eq(dU_dW_def))

-- this doesn't work with indexed elements of the matrix.  you'd have to either expand it, or ... do some math 
--local dW_dU_def = dU_dW_def:inverse()
local dW_dU_def = Matrix(
	{1, 0},
	{-v'^i' / h, delta'^i_j' / h}
)
printbr(W'^I':diff(U'^J'):eq(dW_dU_def))

printbr()
printbr'Flux:'

local F = var'F'
local F_def = Matrix{
	h * v'^j' * n'_j',
	h * v'^i' * v'^j' * n'_j' + frac(1,2) * gravity * h^2 * n'^i'
}:T()
printbr(F'^I':eq(F_def))

F_def = F_def:simplifyAddMulDiv()
printbr(F'^I':eq(F_def))
printbr()

printbr'Flux derivative wrt primitive variables:'
local dF_dW_def = Matrix:lambda({2,2}, function(i,j)
	return F_def[i][1]:reindex{jk='km'}:diff( W_def[j][1]:reindex{i='j'})
end)
printbr(F'^I':diff(W'^J'):eq(dF_dW_def))

dF_dW_def = dF_dW_def:simplifyMetrics():simplifyAddMulDiv()
printbr(F'^I':diff(W'^J'):eq(dF_dW_def))

dF_dW_def = dF_dW_def:tidyIndexes():simplifyAddMulDiv()
printbr(F'^I':diff(W'^J'):eq(dF_dW_def))
printbr()


printbr'Flux derivative wrt conserved variables:'
printbr(F'^I':diff(U'^J'):eq(F'^I':diff(W'^L') * W'^L':diff(U'^J')))

local dF_dU_def = dF_dW_def:reindex{j='k'} * dW_dU_def:reindex{ik='km'}
printbr(F'^I':diff(U'^J'):eq(dF_dU_def))

dF_dU_def = dF_dU_def:simplifyAddMulDiv()
printbr(F'^I':diff(U'^J'):eq(dF_dU_def))

dF_dU_def = dF_dU_def:tidyIndexes()()
dF_dU_def = dF_dU_def:simplifyMetrics():simplifyAddMulDiv()
dF_dU_def = dF_dU_def:tidyIndexes():simplifyAddMulDiv()
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
A_plus_delta_def = A_plus_delta_def:simplifyMetrics():simplifyAddMulDiv()
A_plus_delta_def = A_plus_delta_def:tidyIndexes():simplifyAddMulDiv()
A_plus_delta_def = A_plus_delta_def:replace(n'^a' * v'_a', n'_a' * v'^a')()
printbr(A_lhs:eq(A_plus_delta_def))

local A_def = (A_plus_delta_def - Matrix.identity(2) * Matrix:lambda({2,2}, function(i,j)
	return i~=j and 0 or (n'_a' * v'^a' * (i==2 and delta'^i_j' or 1)) 
end))()
printbr(A'^I_J':eq(A_def))
printbr()


local function expandMatrix2to4(A)
	return Matrix:lambda({4,4}, function(i,j)
		local remap = {1,2,2,2}
		local replace = {nil, 1,2,3}
		return A[remap[i]][remap[j]]:map(function(x)
			if x == delta'^i_j' then
				return i == j and 1 or 0
			end
		end):map(function(x)
			if TensorIndex:isa(x) then
				if x.symbol == 'i' then
					x = x:clone()
					x.symbol = assert(replace[i])
					return x
				elseif x.symbol == 'j' then
					x = x:clone()
					x.symbol = assert(replace[j])
					return x
				end
			end
		end)()
	end)
end

printbr'Acoustic matrix, expanded:'
local A_expanded = expandMatrix2to4(A_def)

printbr(A'^I_J':eq(A_expanded))
printbr()

printbr'Acoustic matrix eigen-decomposition:'

local A_eig = A_expanded:eigen()

-- TODO if you want, (a) consider when n_1 = 0 or n_2 = 0
-- and/or (b) just replace all the e_x, e_y cross n with a basis {n, n2, n3}
-- (just like the MathWorksheets "Euler Fluid Equations - Curved Geometry - Contravariant" worksheet already does).

local nLen = var'|n|'
local nLenSq_def = (nLen^2):eq(n'^1' * n'_1' + n'^2' * n'_2' + n'^3' * n'_3')

printbr(A'^I_J':eq(var'(R_A)''^I_M' * var'(\\Lambda_A)''^M_N' * var'(L_A)''^N_J'))

local gravity_for_Cs = Cs_def:solve(gravity)


A_eig.R = A_eig.R:subst(nLenSq_def:switch(), gravity_for_Cs)()
A_eig.Lambda = A_eig.Lambda:subst(nLenSq_def:switch(), gravity_for_Cs)()
A_eig.L = A_eig.L:subst(nLenSq_def:switch(), gravity_for_Cs)()

local tmp = (nLenSq_def:switch() * (n'^1' * n'_1' + n'^2' * n'_2'))()
A_eig.L[1][2] = A_eig.L[1][2]:subst(tmp)
A_eig.L[2][2] = A_eig.L[2][2]:subst(tmp)
A_eig.L[3][2] = A_eig.L[3][2]:subst(tmp)
A_eig.L[1][3] = A_eig.L[1][3]:subst(tmp)
A_eig.L[2][3] = A_eig.L[2][3]:subst(tmp)
A_eig.L[3][3] = A_eig.L[3][3]:subst(tmp)
A_eig.L[3][3] = A_eig.L[3][3]:replace(
	((n'^1' * n'_1' + n'^2' * n'_2') * (n'^1' * n'_1' + n'^3' * n'_3'))(),
	(n'^1' * n'_1' + n'^2' * n'_2') * (n'^1' * n'_1' + n'^3' * n'_3') )
A_eig.L = A_eig.L()

printbr(A'^I_J':eq(A_eig.R * A_eig.Lambda * A_eig.L))

local P = Matrix.permutation(4,1,2,3):T()
local S = Matrix.diagonal(Cs * n'^3', Cs * n'^3', n'_1', n'_1')
local SInv = S:inv()

printbr('scale by:', S, ', permute by:', P)

A_eig.R = (A_eig.R * S * P)()
A_eig.Lambda = (P:T() * SInv * A_eig.Lambda * S * P)()
A_eig.L = (P:T() * SInv * A_eig.L)()

printbr(A'^I_J':eq(A_eig.R * A_eig.Lambda * A_eig.L))
printbr()

printbr'Acoustic matrix, reconstructed from eigen-decomposition:'
printbr(A'^I_J':eq( (A_eig.R * A_eig.Lambda * A_eig.L)() ))
printbr()

printbr'Orthogonality of left and right eigenvectors:'
printbr((A_eig.L * A_eig.R)():subst(nLenSq_def)())
printbr()

printbr[[
$A$'s eigensystem is $R_A \Lambda_A L_A$.<br>
$A + v I$'s eigensystem is $R_A \Lambda_A L_A + v I 
	= R_A \Lambda_A L_A + v R_A L_A 
	= R_A (\Lambda_A + v I) L_A$
.<br>
$\frac{\partial W}{\partial U} \cdot \frac{\partial F}{\partial W} = A + v I$<br>
$\frac{\partial F}{\partial U} = \frac{\partial U}{\partial W} \cdot \frac{\partial W}{\partial U} \cdot \frac{\partial F}{\partial W} \cdot \frac{\partial W}{\partial U} 
	= \frac{\partial U}{\partial W} \cdot (A + v I) \cdot \frac{\partial W}{\partial U}
	= \frac{\partial U}{\partial W} \cdot R_A (\Lambda_A + v I) L_A \cdot \frac{\partial W}{\partial U}$.<br>
Let $R_F = \frac{\partial U}{\partial W} \cdot R_A,
	\Lambda_F = \Lambda_A + v I,
	L_F = L_A \cdot \frac{\partial W}{\partial U}$.<br>
$\frac{\partial F}{\partial U} = R_F \Lambda_F L_F$.<br>

]]

printbr'Flux Jacobian with respect to conserved variables:'
printbr(F'^I':diff(U'^J'):eq( U'^I':diff(W'^K') * W'^K':diff(U'^L') * F'^L':diff(W'^M') * W'^M':diff(U'^J') ))
printbr()

local F_eig_R_def = expandMatrix2to4(dU_dW_def) * A_eig.R
printbr(var'R_F':eq(F_eig_R_def))

F_eig_R_def = F_eig_R_def()
F_eig_R_def = F_eig_R_def
	:replace(n'_1' * v'^1', n'_k' * v'^k' - n'_2' * v'^2' - n'_3' * v'^3')
	:replace(n'^1' * v'_1', n'_k' * v'^k' - n'^2' * v'_2' - n'^3' * v'_3')
F_eig_R_def = F_eig_R_def:simplifyAddMulDiv()
printbr(var'R_F':eq(F_eig_R_def))

local F_eig_L_def = A_eig.L * expandMatrix2to4(dW_dU_def)
printbr(var'L_F':eq(F_eig_L_def))

F_eig_L_def = F_eig_L_def()
F_eig_L_def = F_eig_L_def
	:replace(n'_1' * v'^1', n'_k' * v'^k' - n'_2' * v'^2' - n'_3' * v'^3')
	:replace(n'^1' * v'_1', n'_k' * v'^k' - n'^2' * v'_2' - n'^3' * v'_3')
F_eig_L_def = F_eig_L_def:simplifyAddMulDiv()
printbr(var'L_F':eq(F_eig_L_def))

printbr()
