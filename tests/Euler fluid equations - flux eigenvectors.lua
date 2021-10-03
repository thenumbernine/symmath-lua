#!/usr/bin/env luajit
require 'ext'
op = nil	-- make way for _G.op = symmath.op
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='Euler Fluid Equations - flux eigenvectors'}}

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

local t, x, y, z = vars('t', 'x', 'y', 'z')
local xs = table{x, y, z}
local txs = table{t, x, y, z}

printbr'variables:'

local n = var'(n_1)'
printbr(n'^i', '= flux surface normal, in units of $[1]$')

local rho = var('\\rho', txs)	-- density
printbr(rho, [[= density, in units of ]], kg/m^3)

local v = var'v'	-- velocity
printbr(v'^i', [[= velocity, in units of ]], m/s)
-- because i'm now tracking variable dependency based on its tensor degree
v'^i':setDependentVars(txs:unpack())

--local m = var'm'	-- momentum
local m_from_v = m'^i':eq(rho * v'^i')
printbr(m_from_v, [[= momentum, in units of ]], kg/(m^2 * s))

local gamma = var'\\gamma'
printbr(gamma, [[= heat capacity ratio, in units of $[1]$]])

local gammaMinusOne = var'(\\gamma_{-1})'	-- = gamma - 1
--local gammaMinusOne = var'\\tilde{\\gamma}'
local gammaMinusOne_def = gammaMinusOne:eq(gamma - 1)
printbr(gammaMinusOne_def)

local P = var('P', txs)		-- pressure
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

local A = var'A'
local W = var'W'
local U = var'U'

printbr'Finite volume form:'
printbr()

printbr((U'^I_,t' + var'F(n^j)''^I_;j'):eq(0))
printbr()

printbr"This is ideal because we have the option of working with the flux vector, or working with its jacobian wrt conserved quantities, or working with its eigensystem."
printbr()

printbr'As flux Jacobian:'
printbr()

printbr((U'^I_,t' 
		+ var'F(n^j)''^I':diff(U'^J') * U'^J_;j'
	):eq(0))
printbr()

printbr'As eigensystem of jacobian:'
printbr()

printbr((U'_,t'
		+ var'R_F(n^j)' * var'\\Lambda_F(n^j)' * var'L_F(n^j)' * U'_;j'
	):eq(0))
printbr()

printbr'As characteristic variables:'
printbr()

printbr((
		
		var'L_F(n^j)'
		* U'_,t'
		+ 
		var'L_F(n^j)' 
		* var'R_F(n^j)' 
		* var'\\Lambda_F(n^j)' 
		* var'L_F(n^j)' 
		* var'R_F(n^j)' 
		* var'L_F(n^j)' 
		* U'_;j'
	
	):eq(0))
printbr()

printbr((
		
		var'L_F(n^j)'
		* U'_,t'
		+ 
		var'\\Lambda_F(n^j)' 
		* var'L_F(n^j)' 
		* U'_;j'
	
	):eq(0))
printbr()

printbr('Now you have 3 separate PDEs to solve, however they are dependent on flux normal, and not easily solvable.')
printbr()

printbr'As a PDE of primitive variables:'
printbr()

-- dU/dt + dF(n)/dU dU/dx = 0
printbr((U'_,t' 
		+ var'F(n^j)':diff(U) 
		* U'_;j'
	):eq(0))
printbr()

-- dW/dU dU/dt + dW/dU dF(n)/dU dU/dx = 0
printbr(
	(
		W:diff(U) 
		* U'_,t' 
		+ 
		W:diff(U)
		* var'F(n^j)':diff(U) 
		* U'_;j'
	):eq(0))
printbr()


-- dW/dU dU/dt + dW/dU dF(n)/dU dU/dW dW/dU dU/dx = 0
printbr(
	(
		W:diff(U) 
		* U'_,t' 
		+ 
		W:diff(U)
		* var'F(n^j)':diff(U) 
		* U:diff(W)
		* W:diff(U)
		* U'_;j'
	):eq(0))
printbr()

--dW/dt + dW/dU dF(n)/dU dU/dW dW/dx = 0
printbr(
	(
		W'_,t' 
		+ 
		W:diff(U)
		* var'F(n^j)':diff(U) 
		* U:diff(W)
		* W'_;j'
	):eq(0))
printbr()

-- dW/dt + dW/dU dF(n)/dW dW/dx = 0 
printbr(
	(
		W'_,t' 
		+ 
		W:diff(U)
		* var'F(n^j)':diff(W) 
		* W'_;j'
	):eq(0))
printbr()

--[[ in theory ... but hard / impossible? to solve
--dW/dt + dFW(n)/dW dW/dx = 0
printbr(
	(
		W'_,t' 
		+ 
		var'FU(n^j)':diff(W) 
		* W'_;j'
	):eq(0))
printbr()
--]]

printbr('...where ', W:diff(U) * var'F(n^j)':diff(W) , 'is equal to the acoustic matrix plus a diagonal of the velocity along the flux normal, as we will see below.')
printbr()

printbr(( W'_,t' + (A + var'I' * v'^j') * W'_;j' ):eq(0))
printbr()
printbr"Now, even though the flux vector doesn't look so solvable as it does with conserved quantities, this system's eigendecomposition is much much more simple."
printbr()

--[[
so the primitive flux jacobian wrt primitive vars dFW(n)/dW is related to the conservative flux wrt conservative vars jacobian dF/dU by dFW(n)/dW = dW/dU dF(n)/dU dU/dW 
does this mean that flux is not flux in every situation?  that conservative state variable flux is different from primitive state variable flux?
also, looks like the "acoustic plus velocity" is equal to the primitive flux wrt primitive jacobian ... 
... which means that it is probably the simplest change-of-variables such that the characteristic variables are not dependent on the surface normals.
so can the "acoustic plus velocity" dFW(n)/dW times the derivative of primitive wrt x be re-integrated?
--]]

printbr'If you could find some flux vector such that the derivative of this flux vector wrt the primitive vector produced our "acoustic-plus-velocity-diagonal" then we could use flux-based numerical solvers...'
printbr()

printbr(
	(
		W'_,t' 
		+ 
		var'F_W(n^j)':diff(W) 
		* W'_;j'
	):eq(0))
printbr()

printbr((W'_,t' + var'F_W(n^j)''_;j'):eq(0))
printbr()

printbr'...but idk if this is possible.'
printbr()

printbr[[
So...<br>
- The conserved form is able to be expressed as a flux vector: $\partial_t U + \partial_x F_U(n) = 0$. 
	From that, also as a linear relation of PDEs times x derivative $\partial_t U + \frac{\partial F_U(n)}{\partial U} \cdot \partial_x U = 0$, 
	and from that as an eigensystem $\partial_t U + R_U(n) \cdot \Lambda(n) \cdot L_U(n) \cdot \partial_x U = 0$.<br>
- The primitive form is the simplest form of the linear relation of the PDEs $\partial_t W + B(n) \cdot \partial_x W = 0$ 
	such that the state variables $W$ are independent of flux direction,
	though the flux vector $F_W(n)$ may not be solvable from integrating the linear system times the state variable x derivative $B(n) \cdot \partial_x W$,
	i.e. $\partial_t W + \partial_x F_W(n) = 0$ may not be a possible form to deduce.
	<br>
- The characteristic form are completely separated PDEs, with diagonal flux and identity eigenvectors $\partial_t C(n) + \Lambda(n) \cdot \partial_x C(n) = 0$, 
	however the state variables $C(n)$ may be dependent on flux direction and may not be solvable.<br>
<br>
]]

printbr'<hr>'
printbr()

printbr'Conserved and primitive variables:'

local W_def = Matrix{rho, v'^i', P}:T()
printbr(W'^I':eq(W_def))

local U_def = Matrix{rho, m'^i', E_total}:T()
printbr(U'^I':eq(U_def))

printbr'Partial of conserved quantities wrt primitives:'

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
		local replace = {nil, 'x','y','z', nil}
		return A[remap[i]][remap[j]]:map(function(x)
			if x == delta'^i_j' then
				return i == j and 1 or 0
			end
		end):map(function(x)
			if Tensor.Index:isa(x) then
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
	:replace(n'_x', 1)
	:replace(n'_y', 0)
	:replace(n'_z', 0)
	:replace(n'^x', 1)
	:replace(n'^y', 0)
	:replace(n'^z', 0)
	:simplify()
printbr(A'^I_J':eq(A_expanded))
printbr()

local A_expanded_wrt_W = A_expanded:subst(Cs_def)()
printbr(A'^I_J':eq(A_expanded_wrt_W))
printbr()

printbr((W'^I_,t' + (A'^I_J' + delta'^I_J' * v'^k') * W'^J_,k'):eq(0))
printbr()

local W_dense = Matrix{rho, v'^x', v'^y', v'^z', P}:T()

-- hmm, do the comma derivatives not distribute through matrices, or do they simply not distribute before matrix add/mul operations are evaluated?
-- looks like comma derivatives do not distribute through matrices ...
-- makes sense.  i still haven't done any matching between index symbols and variable names, like I plan to.
-- for now symbols are as unique as their strings, and separate of variables.
--local eqn = (W_dense'_,t' + (A_expanded_wrt_W + v'^x' * Matrix.identity(5)) * W_dense'_,x'):eq(Matrix:zeros{5, 1})
local eqn = (W_dense:diff(t) + (A_expanded_wrt_W + v'^x' * Matrix.identity(5)) * W_dense:diff(x)):eq(Matrix:zeros{5, 1})
printbr(eqn)
printbr()

eqn = eqn()
local dt_W_eqns = eqn:unravel()
for _,eqn in ipairs(dt_W_eqns) do
	printbr(eqn:simplifyAddMulDiv())
end
printbr()

local chart = Tensor.Chart{coords=xs}

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
eig.R[2][2] = eig.R[2][2]:replace(-n'_y' / n'_x', n2'_x')
eig.R[3][2] = eig.R[3][2]:replace(1, n2'_y')
eig.R[4][2] = eig.R[4][2]:replace(0, n2'_z')
eig.R[2][3] = eig.R[2][3]:replace(-n'_z' / n'_x', n3'_x')
eig.R[3][3] = eig.R[3][3]:replace(0, n3'_y')
eig.R[4][3] = eig.R[4][3]:replace(1, n3'_z')
eig.L = eig.R:inverse()
--]]

printbr(A'^I_J':eq(eig.R * eig.Lambda * eig.L))
printbr()

local P = Matrix.permutation(5,1,2,3,4)
local S = Matrix.diagonal(Cs^2 * n1Len, 1, n'_x' / rho, n'_x' / rho, Cs^2 * n1Len)
local SInv = S:inv()

printbr('permute by:', P, ', scale by:', S)

eig.R = (eig.R * P * S)()
eig.Lambda = (SInv * P:T() * eig.Lambda * P * S)()
eig.L = (SInv * P:T() * eig.L)()

--eig.L[3][3] = (eig.L[3][3] + (n1LenSq_def[1] - n1LenSq_def[2]) * rho / (n'_x' * n1Len^2))()
--eig.L[4][4] = (eig.L[4][4] + (n1LenSq_def[1] - n1LenSq_def[2]) * rho / (n'_x' * n1Len^2))()
eig.L = eig.L:subst(
	(n1LenSq_def - n'_y' * n'^y')():switch()
):subst(
	(n1LenSq_def - n'_z' * n'^z')():switch()
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
	:replace(n'_x' * v'^x', n'_k' * v'^k' - n'_y' * v'^y' - n'_z' * v'^z')
	:replace(n'^x' * v'_x', n'_k' * v'^k' - n'^y' * v'_y' - n'^z' * v'_z')
F_eig_R_def = F_eig_R_def:simplifyAddMulDiv()
printbr(var'R_F':eq(F_eig_R_def))

local F_eig_L_def = 
	eig.L 
--	* Nl:T()
	* expandMatrix3to5(dW_dU_def:subst(vSq_def:switch()))
printbr(var'L_F':eq(F_eig_L_def))

F_eig_L_def = F_eig_L_def()
F_eig_L_def = F_eig_L_def
	:replace(n'_x' * v'^x', n'_k' * v'^k' - n'_y' * v'^y' - n'_z' * v'^z')
	:replace(n'^x' * v'_x', n'_k' * v'^k' - n'^y' * v'_y' - n'^z' * v'_z')
F_eig_L_def = F_eig_L_def:simplifyAddMulDiv()
printbr(var'L_F':eq(F_eig_L_def))
printbr()

print(MathJax.footer)
