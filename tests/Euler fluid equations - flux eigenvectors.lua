#!/usr/bin/env luajit
require 'ext'
op = nil	-- make way for _G.op = symmath.op
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='Euler Fluid Equations - flux eigenvectors', showDivConstAsMulFrac=true}}

local MathJax = symmath.export.MathJax

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

local n = var'(n_1)'
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

local gammaMinusOne = var'(\\gamma_{-1})'	-- = gamma - 1
--local gammaMinusOne = var'\\tilde{\\gamma}'
local gammaMinusOne_def = gammaMinusOne:eq(gamma - 1)
printbr(gammaMinusOne_def)

local P = var'P'		-- pressure
printbr(P, [[= pressure, in units of ]], kg / (m * s^2))

local Cs = var'c_s'
local Cs_def = Cs:eq(sqrt((gamma * P) / rho))
printbr(Cs_def, [[= speed of sound in units of ]], m / s)

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
local e_int_def = e_int:eq(P / (gammaMinusOne * rho))		-- specific internal energy 
printbr(e_int_def, [[= specific internal energy, in units of]], m^2/s^2)
printbr()

local E_total = var'E_{total}'
local E_total_def = E_total:eq(rho * (e_int + e_kin))	-- total energy
printbr(E_total_def, [[= densitized total energy, in units of]], kg / (m * s^2))

local E_total_wrt_W = E_total_def:subst(e_int_def, e_kin_def, vSq_def:switch()):simplifyAddMulDiv()
printbr(E_total_wrt_W)
printbr()

local H_total = var'H_{total}'
local H_total_def = H_total:eq(E_total + P)
printbr(H_total_def, [[= total enthalpy, in units of]], kg / (m * s^2))

local H_total_wrt_W = H_total_def:subst(E_total_wrt_W, vSq_def:switch()):simplifyAddMulDiv()
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

dU_dW_def[3][2] = dU_dW_def[3][2]:simplifyMetrics()()
printbr(U'^I':diff(W'^J'):eq(dU_dW_def))

-- this doesn't work with indexed elements of the matrix.  you'd have to either expand it, or ... do some math 
--local dW_dU_def = dU_dW_def:inverse()
local dW_dU_def = Matrix(
	{1, 0, 0},
	{-v'^i' / rho, delta'^i_j' / rho, 0},
	{frac(1,2) * gammaMinusOne * vSq_wrt_v, -gammaMinusOne * v'_j', gammaMinusOne}
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

F_def = F_def:subst(H_total_def, E_total_def, e_int_def, e_kin_def):simplifyAddMulDiv()
printbr(F'^I':eq(F_def))
printbr()


printbr'Flux derivative wrt primitive variables:'
local dF_dW_def = Matrix:lambda({3,3}, function(i,j)
	return F_def[i][1]:reindex{jk='km'}:diff( W_def[j][1]:reindex{i='j'})
end)
printbr(F'^I':diff(W'^J'):eq(dF_dW_def))

dF_dW_def = dF_dW_def:simplifyMetrics():simplifyAddMulDiv()
printbr(F'^I':diff(W'^J'):eq(dF_dW_def))

dF_dW_def = dF_dW_def:tidyIndexes():simplifyAddMulDiv()
printbr(F'^I':diff(W'^J'):eq(dF_dW_def))

-- doesn't work for all indexes, only 'a's
--dF_dW_def = dF_dW_def:replaceIndex(v'^a' * v'_a', vSq_var)
-- instead:
dF_dW_def = dF_dW_def
	:replace(v'^a' * v'_a', vSq_var)
	:replace(v'^b' * v'_b', vSq_var)
printbr(F'^I':diff(W'^J'):eq(dF_dW_def))

dF_dW_def = dF_dW_def 
	:subst(H_total_wrt_W:solve(P), gammaMinusOne_def)()
	:subst(gammaMinusOne_def:solve(gamma))
	:replace(vSq_var, v'^b' * v'_b')
dF_dW_def = dF_dW_def:simplifyAddMulDiv():tidyIndexes()
dF_dW_def = dF_dW_def:simplifyAddMulDiv()
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

printbr[[Flux derivative matrix times state.  If $\frac{\partial F}{\partial U} \cdot U = F$ then the equation is said to have the Homogeneity property (Toro proposition 3.4).]]

local dF_dU_times_U_def = dF_dU_def * U_def:reindex{i='j'}

printbr((F'^I':diff(U'^J') * U):eq(dF_dU_times_U_def))

dF_dU_times_U_def = dF_dU_times_U_def:subst(H_total_wrt_W, m_from_v:reindex{i='j'}, E_total_def, e_kin_def, vSq_def, e_int_def)

printbr((F'^I':diff(U'^J') * U):eq(dF_dU_times_U_def))

dF_dU_times_U_def = dF_dU_times_U_def()
printbr((F'^I':diff(U'^J') * U):eq(dF_dU_times_U_def))

dF_dU_times_U_def = dF_dU_times_U_def
	:simplifyMetrics()
	:tidyIndexes()
	:reindex{ab='jk'}
	:replace(v'_k', g'_kl' * v'^l')
	:simplifyAddMulDiv()
printbr((F'^I':diff(U'^J') * U):eq(dF_dU_times_U_def))

printbr(F'^I':eq(F_def))
printbr()
printbr[[Looks like for the Euler fluid equations, $\frac{\partial F}{\partial U} \cdot U = F$.]]
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
A_plus_delta_def = A_plus_delta_def:simplifyMetrics()
A_plus_delta_def = A_plus_delta_def:simplifyAddMulDiv()
A_plus_delta_def = A_plus_delta_def:tidyIndexes()
A_plus_delta_def = A_plus_delta_def:simplifyAddMulDiv()
A_plus_delta_def = A_plus_delta_def  
	:replace(n'^a' * v'_a', n'_a' * v'^a')
	:replace(v'^a' * v'_a', vSq_var)
	:subst(H_total_wrt_W, gammaMinusOne_def)()
printbr(A_lhs:eq(A_plus_delta_def))

local A_def = (A_plus_delta_def - Matrix.identity(3) * Matrix:lambda({3,3}, function(i,j)
	return i~=j and 0 or (n'_a' * v'^a' * (i==2 and delta'^i_j' or 1)) 
end))()
printbr(A'^I_J':eq(A_def))
printbr()


local function expandMatrix3to5(A)
	return Matrix:lambda({5,5}, function(i,j)
		local remap = {1,2,2,2,3}
		local replace = {nil, 1,2,3, nil}
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
local A_expanded = expandMatrix3to5(A_def)

printbr(A'^I_J':eq(A_expanded))
printbr()

local P_for_Cs = Cs_def:solve(P)
A_expanded = A_expanded:subst(P_for_Cs)()
printbr(A'^I_J':eq(A_expanded))
printbr()

printbr'...in just the Cartesian x-axis...'
A_expanded = A_expanded
	:replace(n'_1', 1)
	:replace(n'_2', 0)
	:replace(n'_3', 0)
	:replace(n'^1', 1)
	:replace(n'^2', 0)
	:replace(n'^3', 0)
	:simplify()
printbr(A'^I_J':eq(A_expanded))
printbr()

local xs = table{'x', 'y', 'z'}
Tensor.coords{{variables=xs}}

local nl_dense = Tensor('_i', function(i) return n('_'..i) end)
local nu_dense = Tensor('^i', function(i) return n('^'..i) end)
local n2 = var'(n_2)'
local n2l_dense = Tensor('_i', function(i) return n2('_'..i) end)
local n2u_dense = Tensor('^i', function(i) return n2('^'..i) end)
local n3 = var'(n_3)'
local n3l_dense = Tensor('_i', function(i) return n3('_'..i) end)
local n3u_dense = Tensor('^i', function(i) return n3('^'..i) end)

local nls = {nl_dense, n2l_dense, n3l_dense}
local nus = {nu_dense, n2u_dense, n3u_dense}

-- TODO this is just |n_1|, but in non-Cartesian metric |n_1| != |n_2| != |n_3|
-- for example, in a coordinate basis, n_i = d/dx^i, so (n_i)_j = delta_ij, so |(n_i) lowered|L2 = 1
-- and (n_i)^j = g^ij ... in a diagonal metric ... g^ii delta^ij ... so |(n_i) raised|L2 = sqrt(g^ii)
-- and the metric weighted length: |n_i| = sqrt((n_i)_j (n_i)^j) = sqrt(g^ii)
-- so as you can see, each separate normal basis has a separate length.  
-- so much for orthonormalizing.
local n1Len = var'|n_1|'
local n2Len = var'|n_2|'
local n3Len = var'|n_3|'
local n1LenSq_def = (n1Len^2):eq((nl_dense'_i' * nu_dense'^i')())
local n2LenSq_def = (n2Len^2):eq((n2l_dense'_i' * n2u_dense'^i')())
local n3LenSq_def = (n3Len^2):eq((n3l_dense'_i' * n3u_dense'^i')())
printbr(n1LenSq_def)
printbr(n2LenSq_def)
printbr(n3LenSq_def)
printbr()


printbr[[ $(n_m)_i (n_n)^i = (n_m)_i (n_n)_j g^{ij} = \delta_{mn} |n_m|^2$ ]]
printbr[[ For $|n_i|$ is the metric-weighted norm. ]]
printbr()


local Nl_3x3mat = Matrix(
	{nl_dense[1], nl_dense[2], nl_dense[3]},
	{n2l_dense[1], n2l_dense[2], n2l_dense[3]},
	{n3l_dense[1], n3l_dense[2], n3l_dense[3]}
):T()
local Nu_3x3mat = Matrix(
	{nu_dense[1], nu_dense[2], nu_dense[3]},
	{n2u_dense[1], n2u_dense[2], n2u_dense[3]},
	{n3u_dense[1], n3u_dense[2], n3u_dense[3]}
):T()

printbr((var'N^\\flat_{3x3}''^T' * var'N^\\sharp_{3x3}'):eq(
	Nl_3x3mat:T() * Nu_3x3mat
):eq(
	(Nl_3x3mat:T() * Nu_3x3mat)()
):eq(
	Matrix.diagonal(n1Len^2, n2Len^2, n3Len^2)
))
printbr()

printbr('In terms of identity:')
printbr((var'N^\\flat_{3x3}''^T' * (var'N^\\sharp_{3x3}' * var'N^\\parallel_{3x3}'^-1)):eq(
	Nl_3x3mat:T() * (
		Nu_3x3mat * Matrix.diagonal(1/n1Len^2, 1/n2Len^2, 1/n3Len^2)
	)()
):eq(
	Matrix.identity(3)
))
printbr()

printbr'Now if $A A^{-1} = I$ then $A^{-1} A = I$:'
printbr()

printbr((
	(var'N^\\sharp_{3x3}' * var'N^\\parallel_{3x3}'^-1) * var'N^\\flat_{3x3}''^T'
):eq(
	(Nu_3x3mat * Matrix.diagonal(1/n1Len^2, 1/n2Len^2, 1/n3Len^2))() * Nl_3x3mat:T()
):eq(
	(
		Nu_3x3mat * Matrix.diagonal(1/n1Len^2, 1/n2Len^2, 1/n3Len^2) * Nl_3x3mat:T()
	):simplifyAddMulDiv()
):eq(
	Matrix.identity(3)
))
printbr()


local Nl = Matrix(
	{1, 0, 0, 0, 0},
	{0, nl_dense[1], nl_dense[2], nl_dense[3], 0},
	{0, n2l_dense[1], n2l_dense[2], n2l_dense[3], 0},
	{0, n3l_dense[1], n3l_dense[2], n3l_dense[3], 0},
	{0, 0, 0, 0, 1}
):T()
local Nu = Matrix(
	{1, 0, 0, 0, 0},
	{0, nu_dense[1], nu_dense[2], nu_dense[3], 0},
	{0, n2u_dense[1], n2u_dense[2], n2u_dense[3], 0},
	{0, n3u_dense[1], n3u_dense[2], n3u_dense[3], 0},
	{0, 0, 0, 0, 1}
):T()

printbr'Realigned, using the normal basis, which is inverses of one another, so that I can just apply it to the left and right eigenvector transforms.'
printbr()

local A_expanded_with_Ns = (
		Nu * Matrix.diagonal(1, 1/n1Len^2, 1/n2Len^2, 1/n3Len^2, 1)
	)() 
	* (
		Matrix.diagonal(1, n1Len^2, n2Len^2, n3Len^2, 1) * A_expanded
	)() 
	* Nl:T()
A_expanded = A_expanded_with_Ns()
printbr(A'^I_J':eq(A_expanded_with_Ns):eq(A_expanded))
printbr()
-- if this reproduces the original then just factor out Nl and Nu from both sides and do the eigen-decomposition of the x-axis version
-- since it is easier to do

printbr'So now we know the left and right transforms to apply to our right and left eigennvector matrices to align them into an arbitrary normal frame, even with an arbitrary metric.'
printbr'Now to eigen-decompose the normal magnitude diagonal matrix multiplied with the acoustic matrix.'
printbr()

printbr'Acoustic matrix eigen-decomposition:'

local eig = A_expanded:eigen{lambdaVar=var'\\lambda'}

-- TODO if you want, (a) consider when n_1 = 0 or n_2 = 0
-- and/or (b) just replace all the e_x, e_y cross n with a basis {n, n2, n3}
-- (just like the MathWorksheets "Euler Fluid Equations - Curved Geometry - Contravariant" worksheet already does).

printbr(A'^I_J':eq(var'(R_A)''^I_M' * var'(\\Lambda_A)''^M_N' * var'(L_A)''^N_J'))

eig.R = eig.R:subst(n1LenSq_def:switch())()
eig.Lambda = eig.Lambda:subst(n1LenSq_def:switch())()
eig.L = eig.L:subst(n1LenSq_def:switch())()

printbr(A'^I_J':eq(eig.R * eig.Lambda * eig.L))
printbr()

--[[
printbr('insert the normal basis')
printbr()

-- use replace instead of assign just in case i forget this is here some day
-- but this won't invert ...
eig.R[2][2] = eig.R[2][2]:replace(-n'_2' / n'_1', n2'_1')
eig.R[3][2] = eig.R[3][2]:replace(1, n2'_2')
eig.R[4][2] = eig.R[4][2]:replace(0, n2'_3')
eig.R[2][3] = eig.R[2][3]:replace(-n'_3' / n'_1', n3'_1')
eig.R[3][3] = eig.R[3][3]:replace(0, n3'_2')
eig.R[4][3] = eig.R[4][3]:replace(1, n3'_3')
eig.L = eig.R:inverse()
--]]

printbr(A'^I_J':eq(eig.R * eig.Lambda * eig.L))
printbr()

local P = Matrix.permutation(5,1,2,3,4)
local S = Matrix.diagonal(Cs^2 * n1Len, 1, n'_1' / rho, n'_1' / rho, Cs^2 * n1Len)
local SInv = S:inv()

printbr('permute by:', P, ', scale by:', S)

eig.R = (eig.R * P * S)()
eig.Lambda = (SInv * P:T() * eig.Lambda * P * S)()
eig.L = (SInv * P:T() * eig.L)()

--eig.L[3][3] = (eig.L[3][3] + (n1LenSq_def[1] - n1LenSq_def[2]) * rho / (n'_1' * n1Len^2))()
--eig.L[4][4] = (eig.L[4][4] + (n1LenSq_def[1] - n1LenSq_def[2]) * rho / (n'_1' * n1Len^2))()
eig.L = eig.L:subst(
	(n1LenSq_def - n'_2' * n'^2')():switch()
):subst(
	(n1LenSq_def - n'_3' * n'^3')():switch()
)

printbr(A'^I_J':eq(eig.R * eig.Lambda * eig.L))
printbr()

printbr'Acoustic matrix, reconstructed from eigen-decomposition:'
printbr()
printbr(A'^I_J':eq( (eig.R * eig.Lambda * eig.L)() ))
printbr()

printbr'Orthogonality of left and right eigenvectors:'
printbr()
printbr((eig.L * eig.R)():subst(n1LenSq_def)())
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

local F_eig_R_def = 
	expandMatrix3to5(dU_dW_def) 
--	(Nu * Matrix.diagonal(1, 1/n1Len^2, 1/n2Len^2, 1/n3Len^2, 1))()
	* eig.R
printbr(var'R_F':eq(F_eig_R_def))

F_eig_R_def = F_eig_R_def()
F_eig_R_def = F_eig_R_def
	:replace(n'_1' * v'^1', n'_k' * v'^k' - n'_2' * v'^2' - n'_3' * v'^3')
	:replace(n'^1' * v'_1', n'_k' * v'^k' - n'^2' * v'_2' - n'^3' * v'_3')
F_eig_R_def = F_eig_R_def:simplifyAddMulDiv()
printbr(var'R_F':eq(F_eig_R_def))

local F_eig_L_def = 
	eig.L 
--	* Nl:T()
	* expandMatrix3to5(dW_dU_def:subst(vSq_def:switch()))
printbr(var'L_F':eq(F_eig_L_def))

F_eig_L_def = F_eig_L_def()
F_eig_L_def = F_eig_L_def
	:replace(n'_1' * v'^1', n'_k' * v'^k' - n'_2' * v'^2' - n'_3' * v'^3')
	:replace(n'^1' * v'_1', n'_k' * v'^k' - n'^2' * v'_2' - n'^3' * v'_3')
F_eig_L_def = F_eig_L_def:simplifyAddMulDiv()
printbr(var'L_F':eq(F_eig_L_def))
printbr()

print(MathJax.footer)
