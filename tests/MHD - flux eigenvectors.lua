#!/usr/bin/env luajit
require 'ext'

op = nil	-- make way for _G.op = symmath.op
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='Ideal Magnetohydrodynamics - flux eigenvectors'}}

local delta = Tensor:deltaSymbol()	-- Kronecher delta
local g = var'g'					-- metric

-- TODO tidyIndexes() is breaking on this worksheet
-- it seems like it does work if you are sure to :simplify():factorDivision() beforehand

printbr'units of measurement:'

local units = require 'symmath.physics.units'()

local m = units.m
printbr(m, [[= meter]])

local s = units.s
printbr(s, [[= second]])

local kg = units.kg
printbr(kg, [[= kilogram]])

local C = units.C
printbr(C, [[= coulomb]])

printbr()

printbr'constants:'

local mu_0 = units.mu_0
printbr(mu_0, [[= magnetic permeability, in units of]], (kg * m) / (C^2))

local gamma = var'\\gamma'
printbr(gamma, [[= heat capacity ratio, in units of $[1]$]])

local tildeGamma = var'\\tilde{\\gamma}'	-- = gamma - 1
local tildeGamma_def = tildeGamma:eq(gamma - 1)
printbr(tildeGamma_def)
printbr()


printbr'variables:'

printbr(g'_ij', [[= metric tensor, in units of $[1]$]])

local n = var'n'
printbr(n'^i', '= flux surface normal, in units of $[1]$')

local rho = var'\\rho'	-- density
printbr(rho, [[= density, in units of ]], kg/m^3)

local v = var'v'	-- velocity
printbr(v'^i', [[= velocity, in units of ]], m/s)

local vSq_var = var('(v)^2')
local vSq_wrt_v = v'^k' * v'^l' * g'_kl'
local vSq_def = vSq_var:eq(vSq_wrt_v)
printbr(vSq_def, [[= velocity norm squared, in units of]], m^2/s^2)

--local m = var'm'	-- momentum
local m_from_v = m'^i':eq(rho * v'^i')
printbr(m_from_v, [[= momentum, in units of ]], kg/(m^2 * s))

local B = var'B'
printbr(B'^i', [[= magnetic field, in units of]], kg/(C*s))

local BSq_var = var('(B)^2')
local BSq_wrt_B = B'^k' * B'^l' * g'_kl'
local BSq_def = BSq_var:eq(BSq_wrt_B)
printbr(BSq_def, [[= magnetic field norm squared, in units of]], kg^2/(C*s)^2)

local P = var'P'		-- pressure
printbr(P, [[= pressure from fluid, in units of ]], kg / (m * s^2))

local P_mag = var'P_{mag}'
local P_mag_def = P_mag:eq(frac(1,2) * BSq_var / mu_0)
printbr(P_mag_def, [[= pressure due to magnetic field, in units of]], kg / (m * s^2))

local P_total_with_mag = var'P_{total with mag}'
local P_total_with_mag_def = P_total_with_mag:eq(P + P_mag)
printbr(P_total_with_mag_def, [[= total pressure, in units of]], kg/(m*s^2))

local P_total_with_mag_wrt_W =  P_total_with_mag_def:subst(P_mag_def)
printbr(P_total_with_mag_wrt_W)

local e_kin = var'e_{kin}'
local e_kin_def = e_kin:eq(frac(1,2) * vSq_wrt_v)					-- specific kinetic energy
printbr(e_kin_def, [[= specific kinetic energy, in units of]], m^2/s^2)

local e_int = var'e_{int}'
local e_int_def = e_int:eq(P / (tildeGamma * rho))		-- specific internal energy 
printbr(e_int_def, [[= specific internal energy, in units of]], m^2/s^2)

local E_hydro = var'E_{hydro}'
local E_hydro_def = E_hydro:eq(rho * (e_int + e_kin))	-- hydro energy
printbr(E_hydro_def, [[= densitized hydro energy, in units of]], kg / (m * s^2))

local E_hydro_wrt_W = E_hydro_def:subst(e_int_def, e_kin_def, vSq_def:switch()):simplifyAddMulDiv()
printbr(E_hydro_wrt_W)

local E_mag = var'E_{mag}'
local E_mag_def = E_mag:eq(P_mag_def:rhs())	-- same def
printbr(E_mag_def, [[= energy from magnetic field, in units of]], kg/(m*s^2))

-- don't use E_total until I'm done porting all code
local E_total_with_mag = var'E_{total with mag}'
local E_total_with_mag_def = E_total_with_mag:eq(rho * (e_int + e_kin) + E_mag)
printbr(E_total_with_mag_def, [[= total energy, in units of]], kg/(m*s^2))

local E_total_with_mag_wrt_W = E_total_with_mag_def:subst(e_int_def, e_kin_def, vSq_def:switch(), E_mag_def):simplifyAddMulDiv()
printbr(E_total_with_mag_wrt_W)

local H_total_with_mag = var'H_{total with mag}'
local H_total_with_mag_def = H_total_with_mag:eq(E_total_with_mag + P_total_with_mag)
printbr(H_total_with_mag_def, [[= total enthalpy, in units of]], kg / (m * s^2))

local H_total_with_mag_wrt_W = H_total_with_mag_def:subst(E_total_with_mag_wrt_W, P_total_with_mag_wrt_W, vSq_def:switch()):simplifyAddMulDiv()
printbr(H_total_with_mag_wrt_W)

local Cs = var'c_s'
local Cs_def = Cs:eq(sqrt((gamma * P) / rho))
printbr(Cs_def, [[= speed of sound in units of ]], m / s)



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


local function expandMatrix4to8(A)
	return Matrix:lambda({8,8}, function(i,j)
		local remap = {1,2,2,2,3,4,4,4}
		local replace = {nil, 1,2,3, nil, 1,2,3}
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



-- equations 

printbr'Conservative and primitive variables:'

local W = var'W'
local W_def = Matrix{rho, v'^i', P, B'^i'}:T()
printbr(W'^I':eq(W_def))

local U = var'U'
local U_def = Matrix{rho, m'^i', E_total_with_mag, B'^i'}:T()
printbr(U'^I':eq(U_def))

printbr'Partial of conservative quantities wrt primitives:'

local dU_dW_def = Matrix:lambda({#U_def,#W_def}, function(i,j)
	return U_def[i][1]:diff( W_def[j][1]:reindex{i='j'} )
end)
printbr(U'^I':diff(W'^J'):eq(dU_dW_def))

dU_dW_def = dU_dW_def:subst(m_from_v, E_total_with_mag_wrt_W, vSq_def, BSq_def)
printbr(U'^I':diff(W'^J'):eq(dU_dW_def))

dU_dW_def = dU_dW_def():subst(vSq_def:switch()())
dU_dW_def = dU_dW_def:simplifyMetrics():simplifyAddMulDiv()

printbr(U'^I':diff(W'^J'):eq(dU_dW_def))


local dU_dW_expanded = expandMatrix4to8(dU_dW_def)
printbr'Expanded:'
printbr(U'^I':diff(W'^J'):eq(dU_dW_expanded))

local vSq_wrt_vElem = vSq_var:eq(v'^1' * v'_1' + v'^2' * v'_2' + v'^3' * v'_3')

local dW_dU_expanded = dU_dW_expanded:inv():subst(vSq_wrt_vElem)():subst(vSq_wrt_vElem:switch())
printbr(W'^I':diff(U'^J'):eq(dW_dU_expanded))

-- Alright next goal: infer tensor definition from an expanded block matrix.  Until then ... manually specify: 
local dW_dU_def = Matrix(
	{1, 0, 0, 0},
	{-v'^i' / rho, delta'^i_j' / rho, 0, 0},
	{frac(1,2) * tildeGamma * vSq_wrt_v, -tildeGamma * v'_j', tildeGamma, -tildeGamma * B'_j' / mu_0},
	{0, 0, 0, delta'^i_j'}
)
printbr(W'^I':diff(U'^J'):eq(dW_dU_def))


printbr()
printbr'Flux:'

local F = var'F'
local F_def = Matrix{
	rho * v'^j' * n'_j',
	rho * v'^i' * v'^j' * n'_j' + n'^i' * P_total_with_mag - B'^i' * B'^j' * n'_j' / mu_0,
	v'^j' * n'_j' * H_total_with_mag - v'^k' * B'^l' * g'_kl' * n'_j' * B'^j' / mu_0,
	(B'^i' * v'^j' - B'^j' * v'^i') * n'_j',
}:T()
printbr(F'^I':eq(F_def))

F_def = F_def:subst(H_total_with_mag_wrt_W, P_total_with_mag_wrt_W, vSq_def, BSq_def):simplifyAddMulDiv()
printbr(F'^I':eq(F_def))
printbr()

printbr'Flux derivative wrt primitive variables:'
local dF_dW_def = Matrix:lambda({#F_def,#W_def}, function(i,j)
	return F_def[i][1]:reindex{jk='km'}:diff( W_def[j][1]:reindex{i='j'})
end)
printbr(F'^I':diff(W'^J'):eq(dF_dW_def))

dF_dW_def = dF_dW_def:simplifyMetrics():simplifyAddMulDiv()
printbr(F'^I':diff(W'^J'):eq(dF_dW_def))

-- tidyIndexes doesn't do anything except relabel.  it doesn't aid in simplification at all.
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
	:subst(H_total_with_mag_wrt_W:solve(P), tildeGamma_def)()
	:subst(tildeGamma_def:solve(gamma))
	:replace(BSq_var, B'^b' * B'_b')
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


printbr'Acoustic matrix:'

local A = var'A'
local A_lhs = A'^I_J' + n'_a' * v'^a' * delta'^I_J'

printbr(A_lhs:eq(W'^I':diff(U'^K') * F'^K':diff(W'^J')))

local A_plus_delta_def = dW_dU_def:reindex{jk='km'} * dF_dW_def:reindex{ik='kn'}
printbr(A_lhs:eq(A_plus_delta_def))

-- hmm, the wrong combination of these didn't allow simplifyMetrics() to work 
-- TODO if you don't do :factorDivision() before :tidyIndexes() then you can get mismatching indexes, and the subsequent :simplify() will cause a stack overflow
A_plus_delta_def = A_plus_delta_def:tidyIndexes()()
A_plus_delta_def = A_plus_delta_def:simplifyMetrics():simplifyAddMulDiv()
A_plus_delta_def = A_plus_delta_def:tidyIndexes():simplifyAddMulDiv()
printbr(A_lhs:eq(A_plus_delta_def))

A_plus_delta_def = A_plus_delta_def:subst(H_total_with_mag_wrt_W)
	:replace(v'^a' * v'_a', vSq_var)
	:replace(v'^c' * v'_c', vSq_var)
	:replace(B'^a' * B'_a', BSq_var)
	:replace(n'^a' * v'_a', n'_a' * v'^a')
	

-- only substitute gamma on (A+I)_3,2, but leave tildeGamma on (A+I)_3,4
A_plus_delta_def[3][2] = A_plus_delta_def[3][2]:subst(tildeGamma_def)

A_plus_delta_def = A_plus_delta_def:simplifyAddMulDiv()
printbr(A_lhs:eq(A_plus_delta_def))

local A_def = (A_plus_delta_def - Matrix.identity(#A_plus_delta_def) * Matrix:lambda({#A_plus_delta_def,#A_plus_delta_def}, function(i,j)
	return i~=j and 0 or (n'_a' * v'^a' * ((i==2 or i==4) and delta'^i_j' or 1)) 
end)):replace(B'_a' * v'^a', B'_1' * v'^1' + B'_2' * v'^2' + B'_3' * v'^3')()
printbr(A'^I_J':eq(A_def))
printbr()

printbr'Acoustic matrix, expanded:'
local A_expanded = expandMatrix4to8(A_def)

printbr(A'^I_J':eq(A_expanded))
printbr()

printbr'Acoustic matrix eigen-decomposition:'

-- debugging:
Matrix.eigenVerbose = true

-- TODO this is as far as we are.
-- it looks like the solver gets stuck on a cubic poly
local A_eig = A_expanded:eigen()

-- TODO if you want, (a) consider when n_1 = 0 or n_2 = 0
-- and/or (b) just replace all the e_x, e_y cross n with a basis {n, n2, n3}
-- (just like the MathWorksheets "Euler Fluid Equations - Curved Geometry - Contravariant" worksheet already does).

local nLen = var'|n|'
local nLenSq_def = (nLen^2):eq(n'^1' * n'_1' + n'^2' * n'_2' + n'^3' * n'_3')

printbr(A'^I_J':eq(var'(R_A)''^I_M' * var'(\\Lambda_A)''^M_N' * var'(L_A)''^N_J'))

local P_for_Cs = Cs_def:solve(P)

A_eig.R = A_eig.R:subst(nLenSq_def:switch(), P_for_Cs)()
A_eig.Lambda = A_eig.Lambda:subst(nLenSq_def:switch(), P_for_Cs)()
A_eig.L = A_eig.L:subst(nLenSq_def:switch(), P_for_Cs)()

printbr(A'^I_J':eq(A_eig.R * A_eig.Lambda * A_eig.L))

os.exit()


local P = Matrix.permutation(5,1,2,3,4)
local S = Matrix.diagonal(Cs^2, 1, n'_1' / rho, n'_1' / rho, Cs^2)
local SInv = S:inv()

printbr('permute by:', P, ', scale by:', S)

A_eig.R = (A_eig.R * P * S)()
A_eig.Lambda = (SInv * P:T() * A_eig.Lambda * P * S)()
A_eig.L = (SInv * P:T() * A_eig.L)()

A_eig.L[3][3] = (A_eig.L[3][3] + (nLenSq_def[1] - nLenSq_def[2]) * rho / (n'_1' * nLen^2))()
A_eig.L[4][4] = (A_eig.L[4][4] + (nLenSq_def[1] - nLenSq_def[2]) * rho / (n'_1' * nLen^2))()

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

local F_eig_R_def = expandMatrix3to5(dU_dW_def) * A_eig.R
printbr(var'R_F':eq(F_eig_R_def))

F_eig_R_def = F_eig_R_def()
F_eig_R_def = F_eig_R_def
	:replace(n'_1' * v'^1', n'_k' * v'^k' - n'_2' * v'^2' - n'_3' * v'^3')
	:replace(n'^1' * v'_1', n'_k' * v'^k' - n'^2' * v'_2' - n'^3' * v'_3')
F_eig_R_def = F_eig_R_def:simplifyAddMulDiv()
printbr(var'R_F':eq(F_eig_R_def))

local F_eig_L_def = A_eig.L * expandMatrix3to5(dW_dU_def:subst(vSq_def:switch()))
printbr(var'L_F':eq(F_eig_L_def))

F_eig_L_def = F_eig_L_def()
F_eig_L_def = F_eig_L_def
	:replace(n'_1' * v'^1', n'_k' * v'^k' - n'_2' * v'^2' - n'_3' * v'^3')
	:replace(n'^1' * v'_1', n'_k' * v'^k' - n'^2' * v'_2' - n'^3' * v'_3')
F_eig_L_def = F_eig_L_def:simplifyAddMulDiv()
printbr(var'L_F':eq(F_eig_L_def))

printbr()
