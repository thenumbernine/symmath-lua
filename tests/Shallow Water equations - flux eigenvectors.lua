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

local c = var'c'
local c_def = c:eq(sqrt(gravity * h))
printbr(c_def, [[= speed of sound in units of ]], m / s)

printbr(g'_ij', [[= metric tensor, in units of $[1]$]])



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
printbr()


printbr'Acoustic matrix, expanded:'
local A_expanded = expandMatrix2to4(A_def)

printbr(A'^I_J':eq(A_expanded))
printbr()

printbr'Acoustic matrix eigen-decomposition:'

local A_eig = A_expanded:eigen()

-- TODO if you want, (a) consider when n_1 = 0 or n_2 = 0
-- and/or (b) just replace all the e_x, e_y cross n with a basis {n, n2, n3}

-- upper and lower column and row coefficients
local nU = Matrix:lambda({3,1}, function(i,j) return n('^'..i) end)
local nL = Matrix:lambda({1,3}, function(i,j) return n('_'..j) end)

local nLen = var'|n|'
local nLenSq_def = (nLen^2):eq( (nL * nU)()[1][1] )
printbr(nLenSq_def)
printbr()

printbr(A'^I_J':eq(var'(R_A)''^I_M' * var'(\\Lambda_A)''^M_N' * var'(L_A)''^N_J'))

local gravity_for_c = c_def:solve(gravity)


A_eig.R = A_eig.R:subst(nLenSq_def:switch(), gravity_for_c)()
A_eig.Lambda = A_eig.Lambda:subst(nLenSq_def:switch(), gravity_for_c)()
A_eig.L = A_eig.L:subst(nLenSq_def:switch(), gravity_for_c)()

local tmp = (nLenSq_def:switch() * (n'^1' * n'_1' + n'^2' * n'_2'))()
A_eig.L[1][2] = A_eig.L[1][2]:subst(tmp)
A_eig.L[2][2] = A_eig.L[2][2]:subst(tmp)
A_eig.L[3][2] = A_eig.L[3][2]:subst(tmp)
A_eig.L[1][3] = A_eig.L[1][3]:subst(tmp)
A_eig.L[2][3] = A_eig.L[2][3]:subst(tmp)
A_eig.L[3][3] = A_eig.L[3][3]:subst(tmp)
A_eig.L[3][3] = A_eig.L[3][3]:replace(
	((n'^1' * n'_1' + n'^2' * n'_2') * (n'^1' * n'_1' + n'^3' * n'_3'))(),
	(n'^1' * n'_1' + n'^2' * n'_2') * (n'^1' * n'_1' + n'^3' * n'_3') )()
A_eig.L[3][3] = A_eig.L[3][3]:replace(
	n'^1' * n'_1' + n'^3' * n'_3',
	nLen^2 - n'^2' * n'_2')
A_eig.L[4][4] = A_eig.L[4][4]:replace(
	n'^1' * n'_1' + n'^2' * n'_2',
	nLen^2 - n'^3' * n'_3')
A_eig.L = A_eig.L()

printbr(A'^I_J':eq(A_eig.R * A_eig.Lambda * A_eig.L))

local P = Matrix.permutation(4,1,2,3):T()
local S = Matrix.diagonal(
	n'^3',
	n'^3',
	n'_1',
	n'_1'
)
local SInv = S:inv()

printbr('scale by:', S, ', permute by:', P)

A_eig.R = (A_eig.R * S * P)()
A_eig.Lambda = (P:T() * SInv * A_eig.Lambda * S * P)()
A_eig.L = (P:T() * SInv * A_eig.L)()

printbr(A'^I_J':eq(A_eig.R * A_eig.Lambda * A_eig.L))
printbr()

--[[
we get [-n_2, n_1, 0] and [-n_3, 0, n_1]
for [-n_2, n_1, 0] = [0,0,1] cross [n_1, n_2, n_3]
and [-n_3, 0, n_1] = [0,-1,0] cross [n_1, n_2, n_3]
--]]
printbr[[Replace $n \times e_x$ and $n \times e_y$ with $n_2, n_3$:]]

local n2 = var'(n_2)'
local n3 = var'(n_3)'

local n2U = Matrix:lambda({3,1}, function(i,j) return n2('^'..i) end)
local n2L = Matrix:lambda({1,3}, function(i,j) return n2('_'..j) end)
local n3U = Matrix:lambda({3,1}, function(i,j) return n3('^'..i) end)
local n3L = Matrix:lambda({1,3}, function(i,j) return n3('_'..j) end)

local nLs = table{nL, n2L, n3L}
local nUs = table{nU, n2U, n3U}
-- TODO derive this from the matrix mul that comes next
local nDotN_defs = table()
for i=1,3 do
	for j=1,3 do
		local ni_dot_nj_def = (nLs[i] * nUs[j])()[1][1]:eq( i == j and nLen^2 or 0)
		nDotN_defs:insert(ni_dot_nj_def)
	end
end

-- TODO all of the above as this:
printbr(
	(Matrix:lambda({3,3}, function(i,j)
		return nLs[i][1][j]
	end) * Matrix:lambda({3,3}, function(i,j)
		return nUs[j][i][1]
	end)):eq(
		(Matrix.identity(3) * nLen^2)()
	))


--[[
n2_i = epsilon_ijk n^j (e_x)^k
n3_i = epsilon_ijk n^j (e_y)^k
well, 
epsilon_ijk n^i n2^j n3^k 
= epsilon^ijk n_i n2_j n3_k  by raising and lowering by the metric
mind  you, epsilon^ijk = 1/g epsilonBar^ijk n_i n_j n_k
and if n_i = grad_n (sum x^j) in a coordinate basis then it will have coefficients of 1 coinciding with the coordinate along which the normal points
in that case the determinant of the column matrix of normal coefficients would be 1 ... i.e. epsilonBar^ijk n1_i n2_j n3_k = 1
and in that case, after raising, we find epsilonBar_ijk n1^i n2^j n3^k = |g|
this might be the motivation behind Nakahara choosing |epsilon_ijk| = 1 and |epsilon^ijk| = 1/|g|
but I'm more a fan of |epsilon_ijk| = sqrt|g| and |epsilon^ijk| = 1/sqrt|g|, because the permutation weight always coincides with the magnitude of the tensor component's basis
--]]
for i=1,3 do
	A_eig.R[i+1][2] = n2('^'..i)
	A_eig.R[i+1][3] = n3('^'..i)
	
	A_eig.L[2][i+1] = n2('_'..i) / nLen^2
	A_eig.L[3][i+1] = n3('_'..i) / nLen^2
end
--A_eig.L = A_eig.R:inverse()

printbr(A'^I_J':eq(A_eig.R * A_eig.Lambda * A_eig.L))
printbr()

printbr'Acoustic matrix, reconstructed from eigen-decomposition:'
printbr(A'^I_J':eq( (A_eig.R * A_eig.Lambda * A_eig.L)() ))
printbr()


printbr'Orthogonality of left and right eigenvectors:'
printbr(
	(A_eig.L * A_eig.R)()
		:subst(
			nDotN_defs:unpack()
		)()
)
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

local F_eig_R_def = dU_dW_expanded_def * A_eig.R
printbr(var'R_F':eq(F_eig_R_def))

F_eig_R_def = F_eig_R_def()
F_eig_R_def = F_eig_R_def
	:replace(n'_1' * v'^1', n'_k' * v'^k' - n'_2' * v'^2' - n'_3' * v'^3')
	:replace(n'^1' * v'_1', n'_k' * v'^k' - n'^2' * v'_2' - n'^3' * v'_3')
F_eig_R_def = F_eig_R_def:simplifyAddMulDiv()
printbr(var'R_F':eq(F_eig_R_def))

local F_eig_L_def = A_eig.L * dW_dU_expanded_def
printbr(var'L_F':eq(F_eig_L_def))

F_eig_L_def = F_eig_L_def()
F_eig_L_def = F_eig_L_def
	:replace(n'_1' * v'^1', n'_k' * v'^k' - n'_2' * v'^2' - n'_3' * v'^3')
	:replace(n'^1' * v'_1', n'_k' * v'^k' - n'^2' * v'_2' - n'^3' * v'_3')
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

local LF_scale = 2 * h * nLen^2
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

local xs = table{'x', 'y', 'z'}
local function replaceVars(expr)
	expr = expr
	:replace(n'_k' * v'^k', var'v_n')
	:replace(nLen, var'nLen')
	:replace(gravity, var'solver->gravity')
	:replace(h, var'(eig)->h')
	:replace(c, var'(eig)->C')
	:map(function(x)
		for i,xi in ipairs(xs) do
			if x == n('^'..i) then return var('nU.'..xi) end
			if x == n('_'..i) then return var('nL.'..xi) end
			if x == n2('^'..i) then return var('n2U.'..xi) end
			if x == n2('_'..i) then return var('n2L.'..xi) end
			if x == n3('^'..i) then return var('n3U.'..xi) end
			if x == n3('_'..i) then return var('n3L.'..xi) end
			if x == v('^'..i) then return var('(eig)->v.'..xi) end
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
print((symmath.export.C(
	replaceVars(var'invDenom':eq(1 / LF_scale))
))..';')
print(symmath.export.C:toCode{
	output = range(4):mapi(function(i)
		return {['(result)->ptr['..(i-1)..']'] = replaceVars(scaled_F_eig_L_times_X_def[i][1] * var'invDenom')}
	end),
})
printbr'</pre>'
printbr()

printbr(var'R_F' * var'X', 'as code:')
print'<pre>'
print((symmath.export.C(
	replaceVars(var'invDenom':eq(1 / RF_scale))
))..';')
print(symmath.export.C:toCode{
	output = range(4):mapi(function(i)
		return {['(result)->ptr['..(i-1)..']'] = replaceVars(scaled_F_eig_R_times_X_def[i][1] * var'invDenom')}
	end),
})
printbr'</pre>'
printbr()

printbr(F'^I':diff(U'^J') * var'X', 'as code:')
print'<pre>'
print(symmath.export.C:toCode{
	output = range(4):mapi(function(i)
		return {['(result)->ptr['..(i-1)..']'] = replaceVars(dF_dU_times_X_def[i][1])}
	end),
})
printbr'</pre>'
printbr()
