#!/usr/bin/env luajit
require 'ext'
op = nil	-- make way for _G.op = symmath.op
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='Shallow Water Equations - flux eigenvectors'}}

local delta = Tensor:deltaSymbol()	-- Kronecher delta
local g = var'g'					-- metric

-- TODO tidyIndexes() is breaking on this worksheet
-- it seems like it does work if you are sure to :simplify():simplifyAddMulDiv() beforehand

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

local h = var'h'	-- wave height
printbr(h, [[= wave height, in units of ]], m)

local v = var'v'	-- velocity
printbr(v'^i', [[= velocity, in units of ]], m/s)

--local m = var'm'	-- momentum
local m_from_v = m'^i':eq(h * v'^i')
printbr(m_from_v, [[= momentum, in units of ]], kg/(m^2 * s))

local gravity = var'\\gamma'
printbr(gravity, [[= pull of gravitation, in units of ]], m/s^2)

local H = var'H'	-- bathymetry
printbr(H, [[= seafloor depth, in units of ]], m)

local extraTermInFlux = false

local eta, eta_def
if extraTermInFlux then
	eta = var'\\eta'
	eta_def = eta:eq(h - H)
	printbr(eta_def, [[= difference in wave height above resting height in units of ]], m)
end

local c = var'c'
local c_def = c:eq(sqrt(gravity * (extraTermInFlux and eta or h)))
printbr(c_def, [[= speed of sound in units of ]], m / s)

printbr(g'_ij', [[= metric tensor, in units of $[1]$]])


local t, x, y, z = vars('t', 'x', 'y', 'z')
local xs = table{x, y, z}
local txs = table{t, x, y, z}
local chart = Tensor.Chart{coords=xs}


local function expandMatrix2to4(A)
	return Matrix:lambda({4,4}, function(i,j)
		local remap = {1,2,2,2}
		local replace = {nil, x,y,z}
		return A[remap[i]][remap[j]]:map(function(x)
			if x == delta'^i_j' then
				return i == j and 1 or 0
			end
		end):map(function(x)
			if Tensor.Index:isa(x) then
				if x.symbol == 'i' then
					x = x:clone()
					x.symbol = assert(replace[i].name)
					return x
				elseif x.symbol == 'j' then
					x = x:clone()
					x.symbol = assert(replace[j].name)
					return x
				end
			end
		end)()
	end)
end


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

dU_dW_def = dU_dW_def()
printbr(U'^I':diff(W'^J'):eq(dU_dW_def))

local dU_dW_expanded_def = expandMatrix2to4(dU_dW_def)
printbr(U'^I':diff(W'^J'):eq(dU_dW_expanded_def))


-- this doesn't work with indexed elements of the matrix.  you'd have to either expand it, or ... do some math 
--local dW_dU_def = dU_dW_def:inverse()
local dW_dU_expanded_def = dU_dW_expanded_def:inverse()
printbr(W'^I':diff(U'^J'):eq(dW_dU_expanded_def))

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
	h * v'^i' * v'^j' * n'_j' + frac(1,2) * gravity * (h^2 
		- (extraTermInFlux and (2 * h * H) or 0)		-- some papers like 2018 Turchetto et al add this, but the worksheet needs extra tweaking to get it to work
	) * n'^i'
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


printbr'Flux derivative matrix times state'

local dF_dU_times_U_def = dF_dU_def * U_def:reindex{i='j'}
printbr((F'^I':diff(U'^J') * U):eq(dF_dU_times_U_def))

dF_dU_times_U_def = dF_dU_times_U_def:subst(m_from_v:reindex{i='j'})
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

-- does the system have the Homogeneity property (2009 Toro book, proposition 3.4)? ... for shallow water? NO.
printbr[[As you can see, the shallow water equations' $\frac{\partial F}{\partial U} \cdot U \ne F$.  This statement happens to be true for the Euler fluid equations, and lots of literature of solvers based on the Euler fluid equations depend on this equality, which is simply not always true.]]
printbr()

printbr'Flux derivative wrt conserved variables, expanded:'
local dF_dU_expanded_def = expandMatrix2to4(dF_dU_def):replace(n'_a' * v'^a', n'_k' * v'^k')
printbr(F'^I':diff(U'^J'):eq(dF_dU_expanded_def))
printbr()

printbr'Acoustic matrix:'

local A = var'A'
local A_lhs = A'^I_J' + n'_a' * v'^a' * delta'^I_J'

printbr(A_lhs:eq(W'^I':diff(U'^K') * F'^K':diff(W'^J')))

local A_plus_delta_def = dW_dU_def:reindex{jk='km'} * dF_dW_def:reindex{ik='kn'}
printbr(A_lhs:eq(A_plus_delta_def))

A_plus_delta_def = A_plus_delta_def()
printbr(A_lhs:eq(A_plus_delta_def))

-- TODO if you don't do :simplifyAddMulDiv() before :tidyIndexes() then you can get mismatching indexes, and the subsequent :simplify() will cause a stack overflow
A_plus_delta_def = A_plus_delta_def:simplifyMetrics():simplifyAddMulDiv()
A_plus_delta_def = A_plus_delta_def:tidyIndexes():simplifyAddMulDiv()
A_plus_delta_def = A_plus_delta_def:replace(n'^a' * v'_a', n'_a' * v'^a')()
printbr(A_lhs:eq(A_plus_delta_def))

local A_def = (A_plus_delta_def - Matrix.identity(2) * Matrix:lambda({2,2}, function(i,j)
	return i~=j and 0 or (n'_a' * v'^a' * (i==2 and delta'^i_j' or 1)) 
end))()
printbr(A'^I_J':eq(A_def))

if extraTermInFlux then
	A_def = A_def:subst(eta_def:solve(H))()
	printbr(A'^I_J':eq(A_def))
end

printbr()


printbr'Normal basis orthogonality:'

local nl_dense = Tensor('_i', function(i) return n('_'..xs[i].name) end)
local nu_dense = Tensor('^i', function(i) return n('^'..xs[i].name) end)
local n2 = var'(n_2)'
local n2l_dense = Tensor('_i', function(i) return n2('_'..xs[i].name) end)
local n2u_dense = Tensor('^i', function(i) return n2('^'..xs[i].name) end)
local n3 = var'(n_3)'
local n3l_dense = Tensor('_i', function(i) return n3('_'..xs[i].name) end)
local n3u_dense = Tensor('^i', function(i) return n3('^'..xs[i].name) end)

local nls = {nl_dense, n2l_dense, n3l_dense}
local nus = {nu_dense, n2u_dense, n3u_dense}

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
printbr()

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

local NSharp3x3Var = var'N^\\sharp_{3x3}'
local NFlat3x3Var = var'N^\\flat_{3x3}'
local NLen3x3Var = var'N^\\parallel_{3x3}'
local NSharpOverLen3x3Var = var'N^{\\sharp/\\parallel}_{3x3}'

printbr((NFlat3x3Var'^T' * NSharp3x3Var):eq(NLen3x3Var))
printbr()

printbr((
	Nl_3x3mat:T() * Nu_3x3mat
):eq(
	(Nl_3x3mat:T() * Nu_3x3mat)()
):eq(
	Matrix.diagonal(n1Len^2, n2Len^2, n3Len^2)
))
printbr()

printbr('In terms of identity:')


printbr((NFlat3x3Var'^T' * NSharp3x3Var * NLen3x3Var^-1):eq(var'I'))
printbr()

printbr((NFlat3x3Var'^T' * NSharpOverLen3x3Var):eq(var'I'))
printbr()

printbr((
	Nl_3x3mat:T() * (
		Nu_3x3mat * Matrix.diagonal(1/n1Len^2, 1/n2Len^2, 1/n3Len^2)
	)()
):eq(
	Matrix.identity(3)
))
printbr()


printbr'Acoustic matrix, expanded:'
local A_expanded = expandMatrix2to4(A_def)

printbr(A'^I_J':eq(A_expanded))
printbr()

printbr'Acoustic matrix in Cartesian basis in x-direction'
A_expanded = A_expanded
	:replace(n'_x', 1)
	:replace(n'_y', 0)
	:replace(n'_z', 0)
	-- TODO instead, nk^i = g^ij nk_j = g^ij delta_jk = g^ik for direction k ?
	-- or is good enough since multiplying by our N's gives us the original flux jacobian acoustic matrix back?
	:replace(n'^x', 1)
	:replace(n'^y', 0)
	:replace(n'^z', 0)
	:simplify()
printbr(A'^I_J':eq(A_expanded))
printbr()


printbr'Realigned, using the normal basis, which is inverses of one another, so that I can just apply it to the left and right eigenvector transforms.'
printbr()

local Nl = Matrix(
	{1, 0, 0, 0},
	{0, nl_dense[1], nl_dense[2], nl_dense[3]},
	{0, n2l_dense[1], n2l_dense[2], n2l_dense[3]},
	{0, n3l_dense[1], n3l_dense[2], n3l_dense[3]}
):T()
local Nu = Matrix(
	{1, 0, 0, 0},
	{0, nu_dense[1], nu_dense[2], nu_dense[3]},
	{0, n2u_dense[1], n2u_dense[2], n2u_dense[3]},
	{0, n3u_dense[1], n3u_dense[2], n3u_dense[3]}
):T()

local simN_R = (
	Nu * Matrix.diagonal(1, 1/n1Len^2, 1/n2Len^2, 1/n3Len^2)
)()

local simN_L = Nl:T()

-- we know (or are about to show) the extra normal similiarity transform applied to our acoustic matrix will scale some terms by |n1| in order to reproduce our flux in any direction
-- so now eigen-decompose the acoustic times |n1|
A_expanded = (
	Matrix.diagonal(1, n1Len^2, n2Len^2, n3Len^2) * A_expanded
)() 

local Axvar = var'(A^x)'
local NUOverLenVar = var'N^{\\sharp/\\parallel}'
local NLVar = var'N^\\flat'
printbr(A'^I_J':eq(NUOverLenVar * Axvar * NLVar))
printbr()

local A_expanded_with_Ns = simN_R * A_expanded * simN_L
local A_expanded_with_Ns_simplified = A_expanded_with_Ns()
printbr(A'^I_J':eq(A_expanded_with_Ns):eq(A_expanded_with_Ns_simplified))
printbr()

printbr'Now we see how this similarity transform by the normal basis reproduces the original acoustic matrix with regards to any normal basis.' 
printbr'The Cartesian x-direction acoustic matrix is now replaced with one that is normal-length-weighted.'
printbr'Lets continue to find the eigensystem of the normal-length-weighted Cartesian x-direction acoustic matrix.'
printbr()

printbr'Acoustic matrix eigen-decomposition for Cartesian x-direction:'

local A_eig = A_expanded:eigen()

-- TODO if you want, (a) consider when n_1 = 0 or n_2 = 0
-- and/or (b) just replace all the e_x, e_y cross n with a basis {n, n2, n3}

-- variables for Cartesian x-direction acoustic right and left eigenvectors
local RxAvar = var'(R^x_A)'
local LxAvar = var'(L^x_A)'
local LambdaAvar = var'(\\Lambda_A)'
printbr(Axvar'^I_J':eq(RxAvar'^I_M' * LambdaAvar'^M_N' * LxAvar'^N_J'))
printbr()

local gravity_for_c = c_def:solve(gravity)

A_eig.R = A_eig.R:subst(gravity_for_c)()
A_eig.Lambda = A_eig.Lambda:subst(gravity_for_c)()
A_eig.L = A_eig.L:subst(gravity_for_c)()
printbr(Axvar'^I_J':eq(A_eig.R * A_eig.Lambda * A_eig.L))

local P = Matrix.permutation(2,3,4,1):T()
local S = Matrix.diagonal(c * n1Len, 1, 1, c * n1Len)
local SInv = S:inv()

printbr('scale by:', S, ', permute by:', P)

A_eig.R = (A_eig.R * P * S)()
A_eig.Lambda = (SInv * P:T() * A_eig.Lambda * P * S)()
A_eig.L = (SInv * P:T() * A_eig.L)()

printbr(Axvar'^I_J':eq(A_eig.R * A_eig.Lambda * A_eig.L))
printbr()

printbr(RxAvar:eq(A_eig.R))
printbr(LxAvar:eq(A_eig.L))
printbr(LambdaAvar:eq(A_eig.Lambda))
printbr()


printbr'Acoustic matrix, reconstructed from eigen-decomposition:'
printbr(Axvar'^I_J':eq( 
	(A_eig.R * A_eig.Lambda * A_eig.L)():subst(c_def)()
))
printbr()


printbr'Orthogonality of left and right eigenvectors:'
printbr()
printbr( (RxAvar * LxAvar):eq( (A_eig.L * A_eig.R)() ) )
printbr()

printbr"Now transform the left and right eigenvectors by the normal basis"
printbr()

local N_Aeig_R = simN_R * A_eig.R
local N_Aeig_L = A_eig.L * simN_L

printbr(
	(
		NUOverLenVar * RxAvar * var'\\Lambda_A' * LxAvar * NLVar
	):eq(
		A
	)
)
printbr()

printbr(N_Aeig_R * A_eig.Lambda * N_Aeig_L)
N_Aeig_R = N_Aeig_R()
N_Aeig_L = N_Aeig_L()
printbr('=', N_Aeig_R * A_eig.Lambda * N_Aeig_L)
printbr('=', 
	(N_Aeig_R * A_eig.Lambda * N_Aeig_L)()
		:subst(c_def)()
)
printbr()

printbr('Let', var'R_A':eq(NUOverLenVar * RxAvar), ',', var'L_A':eq(LxAvar * NLVar) )
printbr()

printbr(var'R_A':eq(N_Aeig_R))
printbr(var'L_A':eq(N_Aeig_L))
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

local F_eig_R_def = dU_dW_expanded_def * N_Aeig_R
printbr(var'R_F':eq(F_eig_R_def))

F_eig_R_def = F_eig_R_def()
F_eig_R_def = F_eig_R_def
	:replace(n'_x' * v'^x', n'_k' * v'^k' - n'_y' * v'^y' - n'_z' * v'^z')
	:replace(n'^x' * v'_x', n'_k' * v'^k' - n'^y' * v'_y' - n'^z' * v'_z')
F_eig_R_def = F_eig_R_def:simplifyAddMulDiv()
printbr(var'R_F':eq(F_eig_R_def))

local F_eig_L_def = N_Aeig_L * dW_dU_expanded_def
printbr(var'L_F':eq(F_eig_L_def))

F_eig_L_def = F_eig_L_def()
F_eig_L_def = F_eig_L_def
	:replace(n'_x' * v'^x', n'_k' * v'^k' - n'_y' * v'^y' - n'_z' * v'^z')
	:replace(n'^x' * v'_x', n'_k' * v'^k' - n'^y' * v'_y' - n'^z' * v'_z')
F_eig_L_def = F_eig_L_def:simplifyAddMulDiv()
printbr(var'L_F':eq(F_eig_L_def))

printbr()

printbr'eigensystem transforms applied to vectors:'

local X = Matrix:lambda({4,1}, function(i) return var('X^'..(i-1)) end)

local F_eig_L_times_X_def = (F_eig_L_def * X)()
printbr((var'L_F' * var'X'):eq(F_eig_L_times_X_def))
printbr()

local F_eig_R_times_X_def = (F_eig_R_def * X)()
printbr((var'R_F' * var'X'):eq(F_eig_R_times_X_def))
printbr()

local LF_scale = 2 * c * h * n1Len
local scaled_F_eig_L_times_X_def = (LF_scale * F_eig_L_def * X)()
printbr((LF_scale * var'L_F' * var'X'):eq(scaled_F_eig_L_times_X_def))
printbr()

local RF_scale = c
local scaled_F_eig_R_times_X_def = (RF_scale * F_eig_R_def * X)()
printbr((RF_scale * var'R_F' * var'X'):eq(scaled_F_eig_R_times_X_def))
printbr()

local dF_dU_times_X_def = (dF_dU_expanded_def * X)()
printbr((F'^I':diff(U'^J') * var'X'):eq(dF_dU_times_X_def))
printbr()

local function replaceVars(expr)
	expr = expr
	:replace(n'_k' * v'^k', var'v_n')
	:replace(n1Len, var'nLen')
	:replace(n2Len, var'n2Len')
	:replace(n3Len, var'n3Len')
	:replace(gravity, var'solver->gravity')
	:replace(h, var'(eig)->h')
	:replace(c, var'(eig)->C')
	:map(function(x)
		for i,xi in ipairs(xs:mapi(function(x) return x.name end)) do
			if x == n('^'..xi) then return var('nU.'..xi) end
			if x == n('_'..xi) then return var('nL.'..xi) end
			if x == n2('^'..xi) then return var('n2U.'..xi) end
			if x == n2('_'..xi) then return var('n2L.'..xi) end
			if x == n3('^'..xi) then return var('n3U.'..xi) end
			if x == n3('_'..xi) then return var('n3L.'..xi) end
			if x == v('^'..xi) then return var('(eig)->v.'..xi) end
		end
	end)
	for i=1,4 do
		expr = expr:replace(X[i][1], var('(X)->ptr['..(i-1)..']'))
	end
	return expr
end

symmath.export.C.numberType = 'real const'

printbr(LF_scale * var'L_F' * var'X', 'as code:')
print'<pre>'
print(symmath.export.C:toCode{
	output = {
		{invDenom = 1 / replaceVars(LF_scale)},
	},
})
print(symmath.export.C:toCode{
	output = range(4):mapi(function(i)
		return {['(result)->ptr['..(i-1)..']'] = replaceVars(scaled_F_eig_L_times_X_def[i][1] * var'invDenom')}
	end),
	assignOnly = true,
})
printbr'</pre>'
printbr()

printbr(var'R_F' * var'X', 'as code:')
print'<pre>'
print(symmath.export.C:toCode{
	output = {
		{invDenom = 1 / replaceVars(RF_scale)},
	},
})
print(symmath.export.C:toCode{
	output = range(4):mapi(function(i)
		return {['(result)->ptr['..(i-1)..']'] = replaceVars(scaled_F_eig_R_times_X_def[i][1] * var'invDenom')}
	end),
	assignOnly = true,
})
printbr'</pre>'
printbr()

printbr(F'^I':diff(U'^J') * var'X', 'as code:')
print'<pre>'
print(symmath.export.C:toCode{
	output = range(4):mapi(function(i)
		return {['(result)->ptr['..(i-1)..']'] = replaceVars(dF_dU_times_X_def[i][1])}
	end),
	assignOnly = true,
})
printbr'</pre>'
printbr()
