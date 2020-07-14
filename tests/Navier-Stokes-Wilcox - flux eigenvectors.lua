#!/usr/bin/env luajit
require 'ext'
op = nil	-- make way for _G.op = symmath.op
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='Navier-Stokes-Wilcox equations - flux eigenvectors'}}

local function betterSimplify(x)
	return x():factorDivision()
	:map(function(y)
		if symmath.op.add.is(y) then
			local newadd = table()
			for i=1,#y do
				newadd[i] = y[i]():factorDivision()
			end
			return #newadd == 1 and newadd[1] or symmath.op.add(newadd:unpack())
		end
	end)
end

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
	expr = betterSimplify(expr)	-- put it in add-mul-div order
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
							-- TODO here, only repace an index if ...
							-- 1) the index is not a derivative and we are replacing with delta^i_j g^ij g_ij or g^i_j
							-- 2) the index is a covariant derivative and we are replacing it with delta^i_j g^ij g_ij or g^i_j
							-- 3) the index is a partial derivative and we are replacing it with delta_ij delta^ij delta^i_j or g^i_j
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
local K = var'K'

printbr[[
From 2012 Petrova, "Finite Volume Methods- Powerful Means of Engineering Design"<br>
<br>

$\bar\phi = \frac{1}{\Delta t} \int_{t_0}^{t_0 + \Delta t} \phi dt = $ 
Reynolds averaging over time.<br>
<br>

$\tilde \phi = \frac{1}{\bar{\rho}} \frac{1}{\Delta t} \int_{t_0}^{t_0 + \Delta t} (\rho \phi) dt = $ 
Favre averaging.<br>
<br>

]]

printbr'variables:'

local n = var'n'
printbr(n'^i', '= flux surface normal, in units of $[1]$')

local rhoBar = var'\\bar{\\rho}'	-- Reynolds-averaged density
printbr(rhoBar, [[= Reynolds-averaged density, in units of ]], kg/m^3)

local vTilde = var'\\tilde{v}'	-- Favre-averaged velocity
printbr(vTilde'^i', [[= Favre-averaged velocity, in units of ]], m/s)

local mBar = var'\\bar{m}'	-- momentum
local mBar_from_vTilde = mBar'^i':eq(rhoBar * vTilde'^i')
printbr(mBar_from_vTilde, [[$= \overline{\rho v^i} =$  Reynolds-averaged momentum, in units of ]], kg/(m^2 * s))

local k = var'k'
printbr(k, [[= turbulent kinetic energy, in units of ]], m^2/s^2)

local omega = var'\\omega'
printbr(omega, [[= specific turbulent dissipation rate, in units of ???]])

local TTilde = var'\\tilde{T}'
printbr(TTilde, [[= Favre-averaged temperature, in units of ]], K)

local Cv = var'C_v'
printbr(Cv, [[= constant-volume heat capacity, in units of ]], (K * s^2) / m^2)

-- R = Cp - Cv
-- so R/Cv = Cp/Cv - 1 = gamma - 1
-- where gamma = Cp/Cv
-- Cv/R = 1/(gamma-1)
-- gamma is unitless, so Cv/R is unitless, so [Cv] = 1/[R]
local R = var'R'
printbr(R, [[= specific heat constant, in units of ]], m^2/(K * s^2))

local PBar = var'\\bar{P}'
local PBar_wrt_TTilde = PBar:eq(rhoBar * R * TTilde)
printbr(PBar_wrt_TTilde, [[= Reynolds-averaged pressure, in units of ]], kg / (m * s^2))

local PStar = var'P^*'		-- static pressure
local PStar_wrt_PBar = PStar:eq(PBar + frac(2,3) * rhoBar * k)
local PStar_wrt_TTilde = PStar_wrt_PBar:subst(PBar_wrt_TTilde)()
printbr(PStar,
	'=', PStar_wrt_PBar:rhs(), 
	'=', PStar_wrt_TTilde:rhs(),
	[[= static pressure, in units of ]], kg / (m * s^2))

--[=[
local Cs = var'c_s'
local Cs_def = Cs:eq(sqrt((gamma * P) / rho))
printbr(Cs_def, [[= speed of sound in units of ]], m / s)
--]=]

printbr(g'_ij', [[= metric tensor, in units of $[1]$]])

local vTildeSq_var = var('(\\tilde{v})^2')
local vTildeSq_wrt_vTilde = vTilde'^k' * vTilde'^l' * g'_kl'
local vTildeSq_def = vTildeSq_var:eq(vTildeSq_wrt_vTilde)
printbr(vTildeSq_def, [[= Favre-averaged velocity, norm squared, in units of]], m^2/s^2)
printbr()

local eTilde_kin = var'\\tilde{e}_{kin}'
local eTilde_kin_def = eTilde_kin:eq(frac(1,2) * vTildeSq_wrt_vTilde)					-- specific kinetic energy
printbr(eTilde_kin_def, [[= Favre-averaged specific kinetic energy, in units of]], m^2/s^2)
printbr()

local eTilde_int = var'\\tilde{e}_{int}'		-- specific internal energy 
local eTilde_int_wrt_Cv_TTilde = eTilde_int:eq(Cv * TTilde)
local eTilde_int_def = eTilde_int_wrt_Cv_TTilde:subst(PStar_wrt_TTilde:solve(TTilde))()
printbr(eTilde_int, 
	'=', eTilde_int_wrt_Cv_TTilde:rhs(),
	'=', eTilde_int_def:rhs(),
	[[= Favre-averaged specific internal energy, in units of]], m^2/s^2)
printbr()

local eTilde_total = var'\\tilde{e}_{total}'
local eTilde_total_def = eTilde_total:eq(eTilde_int + eTilde_kin)	-- total energy
printbr(eTilde_total_def, [[= Favre-averaged densitized total energy, in units of]], kg / (m * s^2))

local eTilde_total_wrt_W = betterSimplify(eTilde_total_def:subst(eTilde_int_def, eTilde_kin_def, vTildeSq_def:switch()))
printbr(eTilde_total_wrt_W)
printbr()

--[=[
local H_total = var'H_{total}'
local H_total_def = H_total:eq(E_total + P)
printbr(H_total_def, [[= total enthalpy, in units of]], kg / (m * s^2))

local H_total_wrt_W = betterSimplify(H_total_def:subst(E_total_wrt_W, vSq_def:switch()))
printbr(H_total_wrt_W)
printbr()
--]=]



local function expandMatrix5to7(A)
	return Matrix:lambda({7,7}, function(i,j)
		local remap = {1,2,2,2,3,4,5}
		local replace = {nil, 1,2,3, nil, nil}
		return A[remap[i]][remap[j]]:map(function(x)
			if x == delta'^i_j' then
				return i == j and 1 or 0
			end
		end):map(function(x)
			if TensorIndex.is(x) then
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
local W_def = Matrix{rhoBar, vTilde'^i', PStar, k, omega}:T()
printbr(W'^I':eq(W_def))

local U = var'U'
local U_def = Matrix{rhoBar, rhoBar * vTilde'^i', rhoBar * eTilde_total, rhoBar * k, rhoBar * omega}:T()
printbr(U'^I':eq(U_def))

printbr'Partial of conservative quantities wrt primitives:'

local dU_dW_def = Matrix:lambda({5,5}, function(i,j)
	return U_def[i][1]:diff( W_def[j][1]:reindex{i='j'} )
end)
printbr(U'^I':diff(W'^J'):eq(dU_dW_def))

dU_dW_def = dU_dW_def:subst(mBar_from_vTilde, eTilde_total_def, eTilde_kin_def, vTildeSq_def, eTilde_int_def)
printbr(U'^I':diff(W'^J'):eq(dU_dW_def))

dU_dW_def = betterSimplify(dU_dW_def)

-- TODO move simplifyMetrics from numerical-relativity-codegen/show_flux_matrix.lua into Expression
-- TODO before that, rewrite that and replaceIndex in terms of wildcards
dU_dW_def[3][2] = simplifyMetrics(dU_dW_def[3][2])()


dU_dW_def = dU_dW_def:subst(vTildeSq_def:switch()())
printbr(U'^I':diff(W'^J'):eq(dU_dW_def))


local dU_dW_expanded = expandMatrix5to7(dU_dW_def)
printbr'Expanded:'
printbr(U'^I':diff(W'^J'):eq(dU_dW_expanded))

local vTildeSq_wrt_vElem = vTildeSq_var:eq(vTilde'^1' * vTilde'_1' + vTilde'^2' * vTilde'_2' + vTilde'^3' * vTilde'_3')

local dW_dU_expanded = dU_dW_expanded:inv():subst(vTildeSq_wrt_vElem)():subst(vTildeSq_wrt_vElem:switch())
printbr(W'^I':diff(U'^J'):eq(dW_dU_expanded))

local dW_dU_def = Matrix(
	{1, 0, 0, 0, 0},
	{-vTilde'^i' / rhoBar, delta'^i_j' / rhoBar, 0, 0, 0},
	{frac(1,2) * frac(R, Cv) * vTildeSq_var, -frac(R, Cv) * vTilde'_j', R / Cv, frac(2,3), 0},
	{-k / rhoBar, 0, 0, 1/rhoBar, 0},
	{-omega / rhoBar, 0, 0, 0, 1/rhoBar}
)
printbr(W'^I':diff(U'^J'):eq(dW_dU_def))

printbr()
printbr'Flux:'

local F = var'F'
local F_def = Matrix{
	rhoBar * vTilde'^j' * n'_j',
	rhoBar * vTilde'^i' * vTilde'^j' * n'_j' + n'^i' * PStar,
	vTilde'^j' * n'_j' * (rhoBar * eTilde_total + PStar),
	rhoBar * vTilde'^j' * n'_j' * k,
	rhoBar * vTilde'^j' * n'_j' * omega
}:T()
printbr(F'^I':eq(F_def))

F_def = betterSimplify(F_def:subst(eTilde_total_wrt_W))
printbr(F'^I':eq(F_def))
printbr()


printbr'Flux derivative wrt primitive variables:'
local dF_dW_def = Matrix:lambda({5,5}, function(i,j)
	return F_def[i][1]:reindex{jk='km'}:diff( W_def[j][1]:reindex{i='j'})
end)
printbr(F'^I':diff(W'^J'):eq(dF_dW_def))

dF_dW_def = betterSimplify(simplifyMetrics(dF_dW_def))
printbr(F'^I':diff(W'^J'):eq(dF_dW_def))

dF_dW_def = betterSimplify(dF_dW_def:tidyIndexes())
printbr(F'^I':diff(W'^J'):eq(dF_dW_def))

-- doesn't work for all indexes, only 'a's
--dF_dW_def = dF_dW_def:replaceIndex(vTilde'^a' * vTilde'_a', vTildeSq_var)
-- instead:
dF_dW_def = dF_dW_def
	:replace(vTilde'^a' * vTilde'_a', vTildeSq_var)
	:replace(vTilde'^b' * vTilde'_b', vTildeSq_var)
printbr(F'^I':diff(W'^J'):eq(dF_dW_def))

dF_dW_def = dF_dW_def 
	--:subst(H_total_wrt_W:solve(P), tildeGamma_def)()
	--:subst(tildeGamma_def:solve(gamma))
	:replace(vTildeSq_var, vTilde'^b' * vTilde'_b')
dF_dW_def = betterSimplify(dF_dW_def):tidyIndexes()
dF_dW_def = betterSimplify(dF_dW_def)
printbr(F'^I':diff(W'^J'):eq(dF_dW_def))
printbr()


printbr'Flux derivative wrt conserved variables:'
printbr(F'^I':diff(U'^J'):eq(F'^I':diff(W'^L') * W'^L':diff(U'^J')))

local dF_dU_def = dF_dW_def:reindex{j='k'} * dW_dU_def:reindex{ik='km'}
printbr(F'^I':diff(U'^J'):eq(dF_dU_def))

dF_dU_def = betterSimplify(dF_dU_def)
printbr(F'^I':diff(U'^J'):eq(dF_dU_def))

dF_dU_def = dF_dU_def:tidyIndexes()()
dF_dU_def = betterSimplify(simplifyMetrics(dF_dU_def))
dF_dU_def = betterSimplify(dF_dU_def:tidyIndexes())
printbr(F'^I':diff(U'^J'):eq(dF_dU_def))
printbr()


printbr'Acoustic matrix:'

local A = var'A'
local A_lhs = A'^I_J' + n'_a' * vTilde'^a' * delta'^I_J'

printbr(A_lhs:eq(W'^I':diff(U'^K') * F'^K':diff(W'^J')))

local A_plus_delta_def = dW_dU_def:reindex{jk='km'} * dF_dW_def:reindex{ik='kn'}
printbr(A_lhs:eq(A_plus_delta_def))

A_plus_delta_def = betterSimplify(A_plus_delta_def)
printbr(A_lhs:eq(A_plus_delta_def))

-- TODO if you don't do :factorDivision() before :tidyIndexes() then you can get mismatching indexes, and the subsequent :simplify() will cause a stack overflow
A_plus_delta_def = betterSimplify(simplifyMetrics(A_plus_delta_def))
A_plus_delta_def = betterSimplify(A_plus_delta_def:tidyIndexes())
A_plus_delta_def = A_plus_delta_def  
	:replace(n'^a' * vTilde'_a', n'_a' * vTilde'^a')
	:replace(vTilde'^a' * vTilde'_a', vTildeSq_var)
	:replace(vTilde'^c' * vTilde'_c', vTildeSq_var)
	:replace(vTilde'^e' * vTilde'_e', vTildeSq_var)
--	:subst(H_total_wrt_W, tildeGamma_def)()
A_plus_delta_def = betterSimplify(A_plus_delta_def)
printbr(A_lhs:eq(A_plus_delta_def))

local A_def = (A_plus_delta_def - Matrix.identity(5) * Matrix:lambda({5,5}, function(i,j)
	return i~=j and 0 or (n'_a' * vTilde'^a' * (i==2 and delta'^i_j' or 1)) 
end))()
printbr(A'^I_J':eq(A_def))
printbr()

printbr'Acoustic matrix, expanded:'
local A_expanded = expandMatrix5to7(A_def)

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

--[[
local P_for_Cs = Cs_def:solve(P)
A_eig.R = A_eig.R:subst(nLenSq_def:switch(), P_for_Cs)()
A_eig.Lambda = A_eig.Lambda:subst(nLenSq_def:switch(), P_for_Cs)()
A_eig.L = A_eig.L:subst(nLenSq_def:switch(), P_for_Cs)()
--]]

for k,v in pairs(A_eig) do
	printbr(k, '=', v)
end

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
F_eig_R_def = betterSimplify(F_eig_R_def)
printbr(var'R_F':eq(F_eig_R_def))

local F_eig_L_def = A_eig.L * expandMatrix3to5(dW_dU_def:subst(vSq_def:switch()))
printbr(var'L_F':eq(F_eig_L_def))

F_eig_L_def = F_eig_L_def()
F_eig_L_def = F_eig_L_def
	:replace(n'_1' * v'^1', n'_k' * v'^k' - n'_2' * v'^2' - n'_3' * v'^3')
	:replace(n'^1' * v'_1', n'_k' * v'^k' - n'^2' * v'_2' - n'^3' * v'_3')
F_eig_L_def = betterSimplify(F_eig_L_def)
printbr(var'L_F':eq(F_eig_L_def))

printbr()
