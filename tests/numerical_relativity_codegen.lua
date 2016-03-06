#!/usr/bin/env luajit
--[[

    File: numerical_relativity_codegen.lua

    Copyright (C) 2015-2016 Christopher Moore (christopher.e.moore@gmail.com)
	  
    This software is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
  
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
  
    You should have received a copy of the GNU General Public License along
    with this program; if not, write the Free Software Foundation, Inc., 51
    Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

--]]

require 'ext'
local symmath = require 'symmath'

local Tensor = symmath.Tensor
local var = symmath.var

local outputMethod = ... or 'MathJax'
--local outputMethod = 'MathJax'		-- HTML
--local outputMethod = 'SingleLine'		-- pasting into Excel
--local outputMethod = 'Lua'			-- code generation
--local outputMethod = 'C'				-- code gen as well
--local outputMethod = 'GraphViz'		-- generate graphviz dot files

local MathJax
if outputMethod == 'MathJax' then
	MathJax = require 'symmath.tostring.MathJax'
	symmath.tostring = MathJax 
	print(MathJax.header)
elseif outputMethod == 'SingleLine' or outputMethod == 'GraphViz' then
	symmath.tostring = require 'symmath.tostring.SingleLine'
end

local outputCode = outputMethod == 'Lua' or outputMethod == 'C' 

local ToStringLua
if outputCode then 
	ToStringLua = require 'symmath.tostring.Lua'
end

local function comment(s)
	if outputMethod == 'Lua' then return '-- '..s end
	if outputMethod == 'C' then return '// '..s end
	return s
end

local function def(name, dims)
	local s = table()
	if outputMethod == 'Lua' then
		s:insert('local '..name..' = ')
	elseif outputMethod == 'C' then
		s:insert('real '..name)
		if dims then s:insert(table.map(dims,function(i) return '['..i..']' end):concat()) end
		s:insert(' = ')
	end
	if dims and #dims > 0 then s:insert('{') end
	return s:concat()
end

local function I(...)
	return table{...}:map(function(i)
		return '[' .. (outputMethod == 'Lua' and i or (i-1)) .. ']'
	end):concat()
end


local printbr
if outputCode or outputMethod == 'GraphViz' then
	printbr = print
else
	printbr = function(...)
		print(...)
		print'<br>'
	end
end

local function from3x3to6(i,j)
	return ({{1,2,3},
			 {2,4,5},
			 {3,5,6}})[i][j]
end

local function from6to3x3(i)
	return table.unpack(({{1,1},{1,2},{1,3},{2,2},{2,3},{3,3}})[i])
end


local f = var'f'

-- coordinates
local xNames = table{'x', 'y', 'z'}
local spatialCoords = xNames:map(function(x) return var(x) end)
Tensor.coords{{variables=spatialCoords}}

-- symmetric indexes: xx xy xz yy yz zz
local symNames = table()
for i=1,3 do
	for j=i,3 do
		symNames:insert(xNames[i]..xNames[j])
	end
end

local function codeVar(name)
	if outputCode then name = name:gsub('[{\\}]', ''):gsub('%^', 'U') end
	return var(name)
end




-- [=[ Bona-Masso
--[[

alpha
beta^k
gamma_ij

flux variables:
A_i = (ln alpha),i
B^k_i = 1/2 beta^k_,i
D_kij = 1/2 gamma_ij,k
K_ij
V_k = D_km^m - D^m_mk

from alcubierre's gauge paper:

	source alone:
alpha,t = -alpha^2 Q
gamma_ij,t = -2 alpha K_ij

	flux:
A_k,t + alpha f gamma^ij partial_k K_ij = -alpha tr K (f + alpha f') A_k + 2 alpha f K^ij D_kij
D_kij,t + alpha partial_k K_ij = -alpha A_k K_ij
K_ij,t + partial_k  = alpha S_ij
V_k,t = alpha P_k

... for variables:
Q = slicing condition = f trK
Q^i = shift condition = 0
S_ij = (g^km partial_k D_mij + 1/2 (delta^k_i partial_k A_j + delta^k_j partial_k A_i) + delta^k_i partial_k V_j + delta^k_j partial_k V_i) = alpha S_ij - alpha lambda^k_ij A_k + 2 alpha D_mij D_k^km
P_k = G^0_k + A_m * K^m_k  - A_k * trK + K^m_n * D_km^n - K^m_k * D_ma^a - 2 * K_mn * D^mn_k + 2 * K_mk * D_a^am

from the Bona Masso paper:
	A_k,t + (-beta^r A_k + alpha Q delta^r_k),r = (2 B^r_k - alpha tr s delta^r_k) A_r
	B^i_k,t + (-beta^r B^i_k + alpha Q^i delta^r_k),r = (2 B^r_k - alpha tr s delta^r_k) B^i_r
	D_kij,t + (-beta^r D_kij + alpha delta^r_k (K_ij - s_ij)),r = (2 B^r_k - alpha tr s delta^r_k) D_rij
	K_ij,t + (-beta^r K_ij + alpha lambda^r_ij),r = alpha S_ij
	V_k,t + (-beta^r V_k + alpha (s^r_k - tr s delta^r_k)),r = alpha P_k

...for the following variables...
Q, Q^i, s_ij
lambda^k_ij = D^k_ij + 1/2 delta^k_i (A_j + 2 V_j - D_jr^r) + 1/2 delta^k_j (A_i + 2 V_i - D_ir^r)
P_k = G^0_k + A_r (K^r_k - tr K delta^r_k) + alpha^-1 (D^s_kr - delta^s_k D_rj^j) K^r_s + (2 alpha^-1 B^r_k - tr s delta^r_k) V_r - 2 (D^s_rk - delta^s_k D^j_jr) (K^r_s - alpha^-1 B^r_s)
S_ij = -R4_ij - 2 K_i^k K^kj + tr K K_ij + 2/alpha (K_ir B^r_j + K_jr B^r_i) + 4 D_kri D^kr_j + Gamma^k_kr Gamma^r_ij - Gamma_ikr Gamma_j^kr - (2 D^kr_k - A^r) (D_ijr + D_jir) + A_i (V_j - 1/2 D_jk^k) + A_j (V_i - 1/2 D_ik^k)

expanding variables:
	A_k,t - beta^r,r A_k - beta^r A_k,r + (alpha,r Q + alpha Q,r) delta^r_k = (2 B^r_k - alpha tr s delta^r_k) A_r
	B^i_k,t + (-beta^r B^i_k + alpha Q^i delta^r_k),r = (2 B^r_k - alpha tr s delta^r_k) B^i_r
	D_kij,t + (-beta^r D_kij + alpha delta^r_k (K_ij - s_ij)),r = (2 B^r_k - alpha tr s delta^r_k) D_rij
	K_ij,t + (-beta^r K_ij + alpha lambda^r_ij),r = alpha S_ij
	V_k,t + (-beta^r V_k + alpha (s^r_k - tr s delta^r_k)),r = alpha P_k



eigenfields:

	source-alone eigenfields:
lambda = 0
w = alpha
w_ij = gamma_ij

	flux eigenfields:
lambda = 0:
w_x' = A_x'
w_x'ij = D_x'ij
w_i = V_i
w = A_x - f D_xm^m

lambda = +- alpha sqrt(gamma^xx):
w_ix'+- = K_ix' +- sqrt(gamma^xx) (D_xix' + delta^x_i V_x' / gamma^xx)

lambda = +- alpha sqrt(f gamma^xx):
w_+- = sqrt(f) K^m_m +- sqrt(gamma^xx) (A_x + 2 V_m gamma^mx / gamma^xx)

...for x' != x
--]]

local useADM = true
local useShift = true 

-- state variables:
local alpha = codeVar('\\alpha')
local betas = xNames:map(function(xi) return codeVar('\\beta^'..xi) end)
local As = xNames:map(function(xi) return codeVar('A_'..xi) end)
local Bs = xNames:map(function(xi)
	return xNames:map(function(xj) return codeVar('{B_'..xi..'}^'..xj) end)
end)
local BFlattened = table():append(table.unpack(Bs))
local gammaLsym = symNames:map(function(xij) return codeVar('\\gamma_{'..xij..'}') end)
	-- Dsym[i][jk]	for jk symmetric indexed from 1 thru 6
local Dsym = xNames:map(function(xi)
	return symNames:map(function(xjk) return codeVar('D_{'..xi..xjk..'}') end)
end)
	-- D_ijk unique symmetric, unraveled
local DFlattened = table():append(Dsym:unpack())
local Ksym = symNames:map(function(xij) return codeVar('K_{'..xij..'}') end)
local Vs = xNames:map(function(xi) return codeVar('V_'..xi) end)

-- other vars based on state vars
local gammaUsym = symNames:map(function(xij) return codeVar('\\gamma^{'..xij..'}') end)


-- tensors of variables:
local beta = Tensor('^i', function(i) return useShift and betas[i] or 0 end)
local gammaU = Tensor('^ij', function(i,j) return gammaUsym[from3x3to6(i,j)] end)
local gammaL = Tensor('_ij', function(i,j) return gammaLsym[from3x3to6(i,j)] end)
local A = Tensor('_i', function(i) return As[i] end)
local B = Tensor('_i^j', function(i,j) return useShift and Bs[i][j] or 0 end)
local D = Tensor('_ijk', function(i,j,k) return Dsym[i][from3x3to6(j,k)] end)
local K = Tensor('_ij', function(i,j) return Ksym[from3x3to6(i,j)] end)
local V = Tensor('_i', function(i) return Vs[i] end)

Tensor.metric(gammaL, gammaU)

local timeVars = table()
timeVars:insert({alpha})
if useShift then timeVars:insert(betas) end
timeVars:insert(gammaLsym)

local fieldVars = table()
fieldVars:insert(A)
if useShift then fieldVars:insert(BFlattened) end
fieldVars:append{DFlattened, Ksym, Vs}



-- helpful variables
local VU = V'^i'()
local trK = K'^i_i'()
local DULL = D'^k_ij'()
local D1L = D'_km^m'()
--local delta3 = symmath.Matrix.identity(3)
local delta3 = Tensor('^i_j', function(i,j) return i == j and 1 or 0 end)

local function getEigenfieldsForDir(dir)
	-- x's other than the current dir
	local oxIndexes = range(3)
	oxIndexes:remove(dir)

	-- symmetric, with 2nd index matching dir removed 
	local osymIndexes = range(6):filter(function(ij)
		local i,j = from6to3x3(ij)
		return i ~= dir or j ~= dir
	end)


	local eigenfields = table()
	
	-- timelike:
	--[[
	the alpha and gamma don't have to be part of the flux, but i'm lazy so i'm adding them in with the rest of the lambda=0 eigenfields
	however in doing so, it makes factoring the linear system a pain, because you're not supposed to factor out alphas or gammas
	...except with the alpha and gamma eigenfields when you have to ...
	--]]
		-- alpha
	eigenfields:insert{w=alpha, lambda=-beta[dir]}
	if useShift then
		eigenfields:append(betas:map(function(betaUi,i) return {w=betaUi, lambda=-beta[dir]} end))
	end
		-- gamma_ij
	eigenfields:append(gammaLsym:map(function(gamma_ij,ij) return {w=gamma_ij, lambda=-beta[dir]} end))
		-- A_x', x' != dir
	eigenfields:append(oxIndexes:map(function(p) return {w=A[p], lambda=-beta[dir]} end))
		-- B_x'^i
	if useShift then
		eigenfields:append(oxIndexes:map(function(p)
			return range(3):map(function(i)
				return {w=B[p][i], lambda=-beta[dir]}
			end)
		end):unpack())
	end
		-- D_x'ij, x' != dir
	eigenfields:append(oxIndexes:map(function(p)
		return Dsym[p]:map(function(D_pij)
			return {w=D_pij, lambda=-beta[dir]}
		end)
	end):unpack())
		-- V_i
	eigenfields:append(range(3):map(function(i) return {w=V[i], lambda=-beta[dir]} end))
		-- A_x - f D_xm^m, x = dir
	eigenfields:insert{w=A[dir] - f * D1L[dir], lambda=-beta[dir]}
	
	local sqrt = symmath.sqrt
	for sign=-1,1,2 do
		-- light cone -+
			-- K_ix' +- sqrt(gamma^xx) (D_xix' + delta^x_i V_x' / g^xx)
		local loc = sign == -1 and 1 or #eigenfields+1
		for _,ij in ipairs(osymIndexes) do
			local i,j = from6to3x3(ij)
			if j == dir then i,j = j,i end
			assert(j ~= dir)
			eigenfields:insert(loc, {
				-- Bona-Masso:
				-- gamma^xx (K_ix' - s_ix') + delta^x_i s^x_x' -+ sqrt(gamma^xx) lambda^x_ix'
				-- without shift: gamma^xx K_ix' -+ sqrt(gamma^xx) lambda^x_ix'
				-- scaled by 1/gamma^xx: K_ix' -+ lambda^x_ix' / sqrt(gamma^xx)
				-- lambda expanded: K_ix' -+ (gamma^xk D_kix' + 1/2 delta^x_i (A_x' + 2 V_x' - D_x'mn gamma^mn)) / sqrt(gamma^xx)
				--w = sqrt(gammaU[dir][dir]) * K[i][j] + sign * (DULL[dir][i][j] + delta3[dir][i] * (A[j] + 2 * V[j] - D1L[j]) / 2),
				-- Alcubierre's 1997 paper:
				-- K_ix' +- sqrt(gamma^xx) (D_xix' + delta^x_i V_x' / gamma^xx)
				w = K[i][j] + sign * sqrt(gammaU[dir][dir]) * (D[dir][i][j] + delta3[dir][i] * V[j] / gammaU[dir][dir]),
				lambda = -beta[dir] + sign * alpha * sqrt(gammaU[dir][dir]),
			})
			loc=loc+1
		end
		-- gauge -+
		local loc = sign == -1 and 1 or #eigenfields+1
		eigenfields:insert(loc, {
			-- f tr K gamma^xx + 2 (s^xx - tr(s) gamma^xx) -+ sqrt(f gamma^xx) lambda^xr_r
			w = sqrt(f) * trK + sign * sqrt(gammaU[dir][dir]) * (A[dir] + 2 * VU[dir] / gammaU[dir][dir]),
			lambda = -beta[dir] + sign * alpha * sqrt(f * gammaU[dir][dir]),
		})
	end

	return eigenfields
end

--]=]


--[[ FOBSSN
--[=[
	original desc:
... taking Bona-Masso lapse: partial_t alpha = -alpha^2 Q = -alpha^2 f K
... and no shift (hence why all the beta terms aren't there)

1: alpha,t = -alpha^2 f K
5: gammaTilde_ij,t = -2 alpha ATilde_ij
1: phi,t = -1/6 alpha K
3: a_i,t = -alpha (f' K alpha,i + f K,i)
3: Phi_i,t = -1/6 alpha K,i
15: dTilde_ijk,t = -alpha ATilde_jk,i
1: K,t = -alpha exp(-4 phi)  gammaTilde^mn a_n,m
5: ATilde_ij,t = -alpha exp(-4 phi) LambdaTilde^k_ij,k
3: Gamma^i_,t = alpha ((xi-2) ATilde^ik - 2/3 xi gammaTilde^ik K),k

total number of variables:
... 37 -- excluding those removed for traceless constraints
... 42 -- including those traceless terms

LambdaTilde^k_ij = (dTilde^k_ij + 1/2 delta^k_i (a_j - GammaTilde_j + 2 Phi_j) + 1/2 delta^k_j (a_i - GammaTilde_i + 2 Phi_i))

timelike variables:

alpha
gammaTilde_ij

flux variables (should be 30):
3: a_x, a_y, a_z
3: Phi_x, Phi_y, Phi_z
5: dTilde_xxx, dTilde_xxy, dTilde_xxz, dTilde_xyy, dTilde_xyz, dTilde_xzz: dTilde_kzz = -dTilde_kij gammaTilde^ij / gammaTilde^zz for ij all pairs except zz
5: dTilde_yxx, dTilde_yxy, dTilde_yxz, dTilde_yyy, dTilde_yyz, dTilde_yzz: same
5: dTilde_zxx, dTilde_zxy, dTilde_zxz, dTilde_zyy, dTilde_zyz, dTilde_zzz: same
1: K,
5: ATilde_xx, ATilde_xy, ATilde_xz, ATilde_yy, ATilde_yz ... ATilde_zz = -ATilde_ij gammaTilde^ij / gammaTilde^zz for ij all pairs except zz
3: GammaTilde^x, GammaTilde^y, GammaTilde^z


source terms:


eigenfields:

	timelike: (12)

1: alpha
6: gammaTilde_ij
2: dTilde_x'xx
3: dTilde_xij

	flux fields: (30)

lambda = -beta^x:
2: w_x' = a_x'
2: w_x' = Phi_x'
2*5: dTilde_x'ij, ij = xx, xy, xz, yy, yz, zz ... skip one as stated above, due to the dTilde_ijk being traceless on jk 
1: a_x - 6 f Phi_x
3: GammaTilde^i + (xi - 2) dTilde_m^mi - 4 xi gammaTilde^ik Phi_k

gauge:
lambda_+- = -beta^x +- alpha exp(-2 phi) sqrt(f gammaTilde^xx)
2: w_+- = exp(-2 phi) sqrt(f gammaTilde^xx) K -+ a^x

longitudinal:
lambda_+- = -beta^x +- alpha exp(-2 phi) sqrt(gammaTilde^xx xi/2)
2*2: w_q+- = exp(-2 phi) sqrt(gammaTilde^xx xi/2) ATilde^x_q -+ LambdaTilde^xx_q

light cones (transverse traceless):
lambda_+- = -beta^x +- alpha exp(-2 phi) sqrt(gammaTilde^xx)
8: w_+-pq = exp(2 phi) sqrt(gammaTilde^xx) (ATilde_pq + gammaTilde^pq ATilde^xx / (2 gammaTilde^xx)) -+ (LambdaTilde^x_pq + gammaTilde_pq LambdaTilde^xxx / (2 gammaTilde^xx))
...there's only supposed to be 4 of these, based on ... 5.6.16

trace:
lambda = -beta^x + alpha exp(-2 phi) sqrt(gammaTilde^xx (2 xi - 1) / 3)
2: w_+- = exp(2 phi) sqrt(gammaTilde^xx (2 xi - 1)/3) (ATilde^xx - 2/3 gammaTilde^xx K) -+ (LambdaTilde^xxx - 2/3 gammaTilde^xx gammaTilde^xm a_m)

BSSNOK <=> xi = 2

--]=]

local useBSSN = true

local alpha = codeVar'\\alpha'
local phi = codeVar'\\phi'
local K = codeVar'K'
local gammaTildeUSym = symNames:map(function(xij) return codeVar('\\tilde\\gamma^{'..xij..'}') end)
local gammaTildeLSym = symNames:map(function(xij) return codeVar('\\tilde\\gamma_{'..xij..'}') end)
local ATildeSym = symNames:map(function(xjk) return codeVar('\\tilde{A}_{'..xjk..'}') end)

local gammaTildeU = Tensor('^ij', function(i,j) return gammaTildeUSym[from3x3to6(i,j)] end)
local gammaTildeL = Tensor('_ij', function(i,j) return gammaTildeLSym[from3x3to6(i,j)] end)
local ATilde = Tensor('_ij', function(i,j) return ATildeSym[from3x3to6(i,j)] end)
local GammaTildeUs = xNames:map(function(xi) return codeVar('\\Gamma^'..xi) end)
local GammaTildeU = Tensor('^i', function(i) return GammaTildeUs[i] end)
local as = xNames:map(function(xi) return codeVar('a_'..xi) end)		-- a_i = (ln alpha),i
local a = Tensor('_i', function(i) return as[i] end)
local Phis = xNames:map(function(xi) return codeVar('\\Phi_'..xi) end)	-- Phi,i = (ln phi),i
local dTildeSym = xNames:map(function(xi)
	return symNames:map(function(xjk) return codeVar('\\tilde{D}_{'..xi..xjk..'}') end)
end)
local dTildeFlattened = table():append(dTildeSym:unpack())

Tensor.metric(gammaTildeL, gammaTildeU)

local timeVars = table{{alpha}, gammaTildeLSym, {phi}}
local fieldVars = table{ATildeSym, {K}, GammaTildeUs, as, Phis, dTildeFlattened}

local function getEigenfieldsForDir(dir)
	-- x's other than the current dir
	local oxIndexes = range(3)
	oxIndexes:remove(dir)

	-- symmetric, with 2nd index matching dir removed 
	local osymIndexes = range(6):filter(function(ij)
		local i,j = from6to3x3(ij)
		return i ~= dir or j ~= dir
	end)

	local eigenfields = table()

		-- non-flux vars:
	eigenfields:insert{lambda=0, w=alpha}
	for ij,xij in ipairs(symNames) do
		eigenfields:insert{lambda=0, w=gammaTildeLSym[ij]}
	end
	for i,xi in ipairs(xNames) do
		local ii = from3x3to6(i,i)
		eigenfields:insert{lambda=0, w=dTildeSym[i][ii]}
	end
	-- three more

		-- timelike:
	for _,i in ipairs(oxIndexes) do
		eigenfields:insert{lambda=0, w=as[i]}
	end
	for _,i in ipairs(oxIndexes) do
		eigenfields:insert{lambda=0, w=Phis[i]}
	end
	for _,p in ipairs(oxIndexes) do
		for _,ij in ipairs(osymIndexes) do	-- skip ij == dir,dir ... use those for constraint variables?
			eigenfields:insert{lambda=0, w=dTildeSym[p][ij]}
		end
	end
	eigenfields:insert{lambda=0, w=as[dir] - 6 * f * Phi[dir]}
	local xiVar = 2 	-- var'\\xi'
	for i=1,3 do 
		eigenfields:insert{lambda=0, w=(GammaTilde'^i' + (xiVar - 2) * gammaTilde'^mn' * dTilde'_mnj' * gammaTilde'^ji' - 4 * xiVar * gammaTilde'^ik' * Phi'_k')()[i]}
	end

	local gammaL = symmath.exp(-4 * phi) * gammaL'_ij'
	local gammaU = symmath.exp(4 * phi) * gammaU'^ij'
	local ATildeUL = (gammaTilde'^ik' * ATilde'_kj')()
	local ATildeUU = (ATildeUL'^i_k' * gammaTilde'^kj')()
	--TODO local LambdaTildeULL = gammaTildeU'^kl' * dTilde'_lij' + 
	for sign=-1,1,2 do
			-- gauge
		local loc = sign == -1 and 1 or #eigenfields+1
		eigenfields:insert(loc, {
			lambda = sign * alpha * symmath.exp(-2 * phi) * symmath.sqrt(f * gammaTildeU[dir][dir]),
			w = (symmath.exp(-2 * phi) * symmath.sqrt(f * gammaTildeU[dir][dir]) * K - sign * gammaU'^xm' a'_m')(),
		})
		loc=loc+1
			-- longitudinal
		for _,q in ipairs(oxIndexes) do
			eigenfields:insert(loc, {
				lambda = sign * alhpa * symmath.exp(-2 * phi) * symmath.sqrt(gammaTildeU[dir][dir] * xiVar/2),
				w = symmath.exp(-2 * phi) * symmath.sqrt(gammaTildeU[dir][dir] * xiVar/2) * ATildeUL[dir][q] - sign * LambdaTilde3L[dir],
			})
			loc=loc+1
		end
			-- light cones
		for _,p in ipairs(oxIndexes) do
			for _,q in ipairs(oxIndexes) do
				eigenfields:insert(loc, {
					lambda = sign * alpha * symmath.exp(-2 * phi) * symmath.sqrt(gammaTildeU[dir][dir]),
					w = symmath.exp(2 * phi) * symmath.sqrt(gammaTildeU[dir][dir]) * (ATilde[p][q] + gammaTildeU[p][q] * ATildeUU[dir][dir] / (2 * gammaTildeU[dir][dir])) - sign * (LambdaTildeULL[dir][p][q] + gammaTildeU[p][q] * (LambdaTildeULL'^k_ij' * gammaTildeU'^ij')()[dir] / (2 * gammaTildeU[dir][dir])),
				})
				loc=loc+1
			end
		end

		eigenfields:insert
lambda = -beta^x + alpha exp(-2 phi) sqrt(gammaTilde^xx (2 xi - 1) / 3)
2: w_+- = exp(2 phi) sqrt(gammaTilde^xx (2 xi - 1)/3) (ATilde^xx - 2/3 gammaTilde^xx K) -+ (LambdaTilde^xxx - 2/3 gammaTilde^xx gammaTilde^xm a_m)
	end

	return eigenfields
end

--]]




-- variables flattened and combined into one table
local timeVarsFlattened = table()
local fieldVarsFlattened = table()
for _,info in ipairs{
	{timeVars, timeVarsFlattened},
	{fieldVars, fieldVarsFlattened},
} do
	local infoVars, infoVarsFlattened = table.unpack(info)
	infoVarsFlattened:append(table.unpack(infoVars))
end

local varsFlattened = table():append(timeVarsFlattened, fieldVarsFlattened)
local expectedNumVars = useBSSN and 42 or (useShift and 49 or 37)
assert(#varsFlattened == expectedNumVars, "expected "..expectedNumVars.." but found "..#varsFlattened)

-- all symbolic variables for use with compiled functions
local compileVars = table():append(varsFlattened):append{f}:append(gammaUsym)

-- all variables combined into one vector
local U = symmath.Matrix(varsFlattened:map(function(Ui) return {Ui} end):unpack())


local sourceTerms
if useADM then

	--[=[ we don't need the source vector ... it's very complex ... should be computed on the spot
	-- R4 and G0 need to be provided ...

	-- assuming those gammas are of the spatial metric (and not the spacetime metric ...)
	local Gamma = Tensor('_ijk')
	Gamma['_ijk'] = (D'_kij' + D'_jik' - D'_ijk')()
	printbr('$\\Gamma_{ijk} = $'..Gamma'_ijk')

	local R4sym = symNames:map(function(xij,ij) return codeVar('R4_{'..xij..'}') end)
	local R4 = Tensor('_ij', function(i,j) return R4sym[from3x3to6(i,j)] end)
	local G0 = Tensor('_i', function(i) return codeVar('{G^0}_'..xNames[i]) end)
	printbr('$R4_{ij} = $'..R4'_ij')
	printbr('$G0_i = $'..G0'_i')

	--[[ takes a long time ...
	local S = Tensor('_ij')
	S['_ij'] = (
			-R4'_ij'
			+ trK * K'_ij' 
			- 2 * K'_ik' * K'^k_j'			-- -2 K_ik K^k_j = -2 K_ik gamma^kl K_lj 
			+ 4 * D'_kmi' * D'^km_j'		-- 4 D_kmi D^km_j = 4 D_kmi gamma^kl gamma^mn D_lnj
			+ Gamma'^k_km' * Gamma'^m_ij'	-- Gamma^k_km Gamma^m_ij = Gamma_klm gamma^kl gamma^mn Gamma_nij
			- Gamma'_ikm' * Gamma'_j^km'	-- Gamma_ikm Gamma_jln gamma^kl gamma^mn
			+ (A'^k' - 2 * D'_m^km') * (D'_ijk' + D'_jik') 
			+ A'_i' * (V'_j' - D'_jk^k'/2)
			+ A'_j' * (V'_i' - D'_ik^k'/2)
		)()
	printbr('$S_{ij} = $'..S'_ij')
	--]]
	local S = range(6):map(function(ij)
		local i,j = from6to3x3(ij)
		local sum = -R4[i][j] + trK * K[i][j] 
		for k=1,3 do
			for l=1,3 do
				sum = sum - 2 * K[i][k] * gammaU[k][l] * K[l][j]
				for m=1,3 do
					for n=1,3 do
						sum = sum + 4 * D[k][m][i] * gammaU[k][l] * gammaU[m][n] * D[l][n][j]
						sum = sum + Gamma[k][l][m] * gammaU[k][l] * gammaU[m][n] * Gamma[n][i][j]
						sum = sum + Gamma[i][k][m] * gammaU[k][l] * gammaU[m][n] * Gamma[j][l][n]
					end
				end
			end
		end
		return sum
	end)

	local P = Tensor('_i')
	P['_k'] = (
			G0'_k' 
	--[[
			+ A'_m' * K'^m_k' 
			- A'_k' * trK 
			+ K'^m_n' * D'_km^n'
			- K'^m_k' * D'_ma^a'
			- 2 * K'_mn' * D'^mn_k'
			+ 2 * K'_mk' * D'_a^am'
	--]]
		)()
	printbr('$P_i = $'..P'_i')
	--]=]
	-- [=[
	if outputCode then
		print(comment('source terms')) 

		-- K^i_j

		print(def('KUL', {3,3}))
		for i,xi in ipairs(xNames) do
			io.write('{')
			for j,xj in ipairs(xNames) do
				print(xNames:map(function(xk,k)
					return gammaU[i][k].name..' * '..K[k][j].name
				end):concat(' + ')..',')
			end
			io.write('},')
		end
		print('};')

		-- trK = K^i_i
		print(def('trK')..xNames:map(function(xi,i) return 'KUL'..I(i,i) end):concat(' + ')..';')

		-- KSq_ij = K_ik K^k_j
		print(def('KSqSymLL', {6}))
		for ij,xij in ipairs(symNames) do
			local i,j = from6to3x3(ij)
			local xj = xNames[j]
			print(xNames:map(function(xk,k)
				return K[i][k].name..' * KUL'..I(k,j)
			end):concat(' + ')..',')
		end
		print('};')

		-- D_i^j_k
		print(def('DLUL', {3,3,3}))
		for i,xi in ipairs(xNames) do
			io.write('{')
			for j,xj in ipairs(xNames) do
				io.write('{')
				for k,xk in ipairs(xNames) do
					print(xNames:map(function(xl,l)
						return D[i][l][k].name..' * '..gammaU[l][j].name
					end):concat(' + ')..',')
				end
				io.write('},')
			end
			io.write('},')
		end
		print('};')

		-- D1_i = D_i^j_j
		local D1L = table()
		print(def('D1L', {3}))
		for i,xi in ipairs(xNames) do
			print(xNames:map(function(xj,j)
				return 'DLUL'..I(i,j,j)
			end):concat(' + ')..',')
			D1L:insert(codeVar('D1L'..I(i)))
		end
		print('};')

		-- D3_i = D_j^j_i
		print(def('D3L', {3}))
		for i,xi in ipairs(xNames) do
			print(xNames:map(function(xj,j)
				return 'DLUL'..I(j,j,i)
			end):concat(' + ')..',')
		end
		print('};')

		-- D^ij_k
		print(def('DUUL', {3,3,3}))
		for i,xi in ipairs(xNames) do
			io.write('{')
			for j,xj in ipairs(xNames) do
				io.write('{')
				for k,xk in ipairs(xNames) do
					print(xNames:map(function(xl,l)
						return 'DLUL'..I(l,j,k)..' * '..gammaU[l][i].name
					end):concat(' + ')..',')
				end
				io.write('},')
			end
			io.write('},')
		end
		print('};')

		-- D12_ij = D_kmi D^km_j
		print(def('D12SymLL', {6}))
		for ij,xij in ipairs(symNames) do
			local i,j = from6to3x3(ij)
			local xi = xNames[i]
			print(xNames:map(function(xk,k)
				return xNames:map(function(xl,l)
					return D[k][l][j].name..' * DUUL'..I(k,l,i)
				end):concat(' + ')
			end):concat(' + ')..',')
		end
		print('};')

		-- Gamma_ijk = D_kij + D_jik - D_ijk
		print(def('GammaLSymLL', {3,6}))
		for i,xi in ipairs(xNames) do
			io.write('{')
			for jk,xjk in ipairs(symNames) do
				local j,k = from6to3x3(jk)
				print(ToStringLua((D[k][i][j] + D[j][i][k] - D[i][j][k])(), compileVars)..',')
			end
			io.write('},')
		end
		print('};')

		-- Gamma^i_jk = gamma^il Gamma_ljk
		print(def('GammaUSymLL',{3,6}))
		for i,xi in ipairs(xNames) do
			io.write('{')
			for jk,xjk in ipairs(symNames) do
				print(xNames:map(function(xl,l)
					return gammaU[i][l].name..' * GammaLSymLL'..I(l,jk)
				end):concat(' + ')..',')
			end
			io.write('},')
		end
		print('};')

		-- Gamma3_i = Gamma^j_ji
		print(def('Gamma3L',{3}))
		for i,xi in ipairs(xNames) do
			print(xNames:map(function(xj,j)
				return 'GammaUSymLL'..I(j, from3x3to6(i,j))
			end):concat(' + ')..',')
		end
		print('};')

		-- Gamma31_ij = Gamma3_k Gamma^k_ij
		print(def('Gamma31SymLL', {6}))
		for ij,xij in ipairs(symNames) do
			print(xNames:map(function(xk,k)
				return 'Gamma3L'..I(k)..' * GammaUSymLL'..I(k,ij)
			end):concat(' + ')..',')
		end
		print('};')

		-- Gamma_i^j_k = gamma^jl Gamma_ilk
		print(def('GammaLUL', {3,3,3}))
		for i,xi in ipairs(xNames) do
			io.write('{')
			for j,xj in ipairs(xNames) do
				io.write('{')
				for k,xk in ipairs(xNames) do
					print(xNames:map(function(xl,l)
						return gammaU[j][l].name..' * GammaLSymLL'..I(i,from3x3to6(l,k))
					end):concat(' + ')..',')
				end
				io.write('},')
			end
			io.write('},')
		end
		print('};')

		-- Gamma_i^jk = gamma^kl Gamma_i^j_l
		print(def('GammaLSymUU', {3,6}))
		for i,xi in ipairs(xNames) do
			io.write('{')
			for jk,xjk in ipairs(symNames) do
				local j,k = from6to3x3(jk)
				print(xNames:map(function(xl,l)
					return gammaU[k][l].name..' * GammaLUL'..I(i,j,l)
				end):concat(' + ')..',')
			end
			io.write('},')
		end
		print('};')

		-- Gamma11_ij = Gamma_ikl Gamma_j^kl
		print(def('Gamma11SymLL', {6}))
		for ij,xij in ipairs(symNames) do
			local i,j = from6to3x3(ij)
			print(xNames:map(function(xk,k)
				return xNames:map(function(xl,l)
					return 'GammaLSymLL'..I(i,from3x3to6(k,l))..' * GammaLSymUU'..I(j,from3x3to6(k,l))
				end):concat(' + ')
			end):concat(' + ')..',')
		end
		print('};')

		-- AD_i = A_i - 2 D_j^j_i = A_i - 2 D3_i
		print(def('ADL', {3}))
		for i,xi in ipairs(xNames) do
			print(As[i].name..' - 2 * D3L'..I(i)..',')
		end
		print('};')

		-- AD^i = gamma^ij AD_j
		print(def('ADU', {3}))
		for i,xi in ipairs(xNames) do
			print(xNames:map(function(xj,j)
				return gammaU[i][j].name..' * ADL'..I(j)
			end):concat(' + ')..',')
		end
		print('};')

		-- ADD_ij
		print(def('ADDSymLL', {6}))
		for ij,xij in ipairs(symNames) do
			local i,j = from6to3x3(ij)
			print(xNames:map(function(xk,k)
				return 'ADU'..I(k)..' * '..ToStringLua((D[i][j][k] + D[j][i][k])(), compileVars)
			end):concat(' + ')..',')
		end
		print('};')

		--[[
		here's the million dollar question:
		what is R4?
		it's supposed to "involve only the fields themselves and not their derivatives" cf the Alcubierre paper on gauge shock waves
		it's equal to R3 "up to a first derivative" according to the first-order BSSN analysis paper by Alcubierre
		neither of those look like they can be reconstructed with field variables themselves, without their derivatives
		Then there's the Gauss-Codazzi def, which gives R4 in terms of R3 and K's ... which we see here ...
		... which makes me think that if we removed the R4, we could remove the K's and Gammas as well ...
		(...which makes me think the Gammas aren't just spatial Gammas (based on D's, as above), but 4D Gammas, which also involve K's ...
		
		Bona Masso 1997 says R4_ij = G_ij - 1/2 (-alpha^2 G^00 + tr G) gamma_ij
		...and G_ij = 8 pi ((mu + p) u_i u_j + p gamma_ij) for p = pressure, mu = fluid total energy density, u_i = 3-velocity
		
		--]]
		print(def('R4SymLL', {6}))
		for ij,xij in ipairs(symNames) do
			print('0,')
		end
		print('};')

		-- define S_ij
		print(def('SSymLL', {6}))
		for ij,xij in ipairs(symNames) do
			local i,j = from6to3x3(ij)
			print('-R4SymLL'..I(ij)
				..' + trK * K_'..xij
				..' - 2 * KSqSymLL'..I(ij)
				..' + 4 * D12SymLL'..I(ij)
				..' + Gamma31SymLL'..I(ij)
				..' - Gamma11SymLL'..I(ij)
				..' + ADDSymLL'..I(ij)
				..' + '..ToStringLua(
					(A[i] * (V[j] - D1L[j] / 2) + A[j] * (V[i] - D1L[i] / 2))(),
				table():append(compileVars):append(D1L))
				..','
			)
		end
		print('};')

		--[[
		another million dollar question: what are the G0's?
		the BSSN analysis paper says they're related to the R4's (of course)
		--]]
		print(def('GU0L', {3}))
		for i,xi in ipairs(xNames) do
			print('0,')
		end
		print('};')

		-- AK_i = A_j K^j_i
		print(def('AKL', {3}))
		for i,xi in ipairs(xNames) do
			print(xNames:map(function(xj,j)
				return As[j].name .. ' * KUL'..I(j,i)
			end):concat(' + ')..',')
		end
		print('};')

		-- K12D23_i = K^j_k D_i^k_j
		print(def('K12D23L', {3}))
		for i,xi in ipairs(xNames) do
			print(xNames:map(function(xj,j)
				return xNames:map(function(xk,k)
					return 'KUL'..I(j,k)..' * DLUL'..I(i,k,j)
				end):concat(' +' )
			end):concat(' + ')..',')
		end
		print('};')
		
		-- KD23_i = K^j_i D1_j = K^j_i D_jk^k
		print(def('KD23L', {3}))
		for i,xi in ipairs(xNames) do
			print(xNames:map(function(xj,j)
				return 'KUL'..I(j,i)..' * D1L'..I(j)
			end):concat(' + ')..',')
		end
		print('};')

		-- K12D12L_i = K^j_k D_j^k_i
		print(def('K12D12L', {3}))
		for i,xi in ipairs(xNames) do
			print(xNames:map(function(xj,j)
				return xNames:map(function(xk,k)
					return 'KUL'..I(j,k)..' * DLUL'..I(j,k,i)
				end):concat(' + ')
			end):concat(' + ')..',')
		end
		print('};')

		-- KD12_i = K_ji D_k^kj = K^j_i D3_j
		print(def('KD12L', {3}))
		for i,xi in ipairs(xNames) do
			print(xNames:map(function(xj,j)
				return 'KUL'..I(j,i)..' * D3L'..I(j)
			end):concat(' + ')..',')
		end
		print('};')

		-- defined P_k
		print(def('PL', {3}))
		for k,xk in ipairs(xNames) do
			print('GU0L'..I(k)
				..' + AKL'..I(k)
				..' - '..As[k].name..' * trK'
				..' + K12D23L'..I(k)
				..' + KD23L'..I(k)
				..' - 2 * K12D12L'..I(k)
				..' + 2 * KD12L'..I(k)
				..','
			)
		end
		print('};')
	end

	local Ssym = symNames:map(function(xij) return codeVar('S_{'..xij..'}') end)
	local S = Tensor('_ij', function(i,j) return Ssym[from3x3to6(i,j)] end)
	local P = Tensor('_i', function(i) return codeVar('P_'..xNames[i]) end)

	--]=]

	local s = (B'_ij' + B'_ji')/alpha

	local Q = f * trK		-- lapse function 
	local QU = Tensor('^i')	-- shift function

	local alphaSource = (-alpha^2 * f * trK + 2 * beta'^k' * A'_k')()
	local betaUSource = (-2 * alpha^2 * QU + 2 * B'_k^i' * beta'^k')()
	local gammaLLSource = (-2 * alpha * (K'_ij' - s'_ij') + 2 * beta'^k' * D'_kij')()

	-- not much use for this at the moment
	-- going to display it alongside the matrix
	sourceTerms = symmath.Matrix(
	table():append{
		-- alpha: -alpha^2 Q + alpha beta^k A_k
		alphaSource,
		-- beta
	}:append(useShift and betaUSource or nil)
	:append{
		-- gamma_ij: -2 alpha (K_ij - s_ij) + 2 beta^r D_rij
		gammaLLSource[1][1],
		gammaLLSource[1][2],
		gammaLLSource[1][3],
		gammaLLSource[2][2],
		gammaLLSource[2][3],
		gammaLLSource[3][3],
		-- A_k: 1995 says ... (2 B_k^r - alpha s^k_k delta^r_k) A_r ... though 1997 says 0
		0, 0, 0
		-- B_k^i: (2 B_k^r - alpha s^k_k delta^r_k) B_r^i .. but does 1997 say 0?
	}:append(useShift and {
		0, 0, 0,
		0, 0, 0,
		0, 0, 0,
	} or nil)
	:append{
		-- D_kij: 1995 says a lot ... but 1997 says 0
		0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0,
		-- K_ij = alpha S_ij
		alpha * S[1][1],
		alpha * S[1][2],
		alpha * S[1][3],
		alpha * S[2][2],
		alpha * S[2][3],
		alpha * S[3][3],
		-- V_k = alpha P_k
		alpha * P[1],
		alpha * P[2],
		alpha * P[3],
	}:map(function(x) return {x} end):unpack())

	if outputCode then
		for i=1,#varsFlattened do
			local expr = sourceTerms[i][1]
			if expr ~= symmath.Constant(0) then
				local code = ToStringLua(expr, table():append(compileVars, Ssym, P))
				for ij,Sij in ipairs(Ssym) do
					code = code:gsub(Sij.name, 'SSymLL['..ij..']')
				end
				for i,Pi in ipairs(P) do
					code = code:gsub(Pi.name, 'PL['..i..']')
				end
				print('source[i]['..i..'] = '..code)
			end
		end

		if not outputCode and outputMethod ~= 'GraphViz' then
			printbr('V and D constraints:')
			printbr((V'_i':eq(D'_im^m' - D'^m_mi'))())
			printbr()
		elseif outputCode then
			print(comment('V and D constraint'))
			local VDs = V'_i':eq(D'_im^m' - D'^m_mi')
			print(ToStringLua(VDs(), compileVars))
			print(comment('V and D linear project'))
			-- linear factor out the V's and D's ... 
			local VDZeros = (V'_i' - (D'_ij^j' - D'^j_ji'))()
			for i=1,3 do
				local a,b = symmath.factorLinearSystem({VDZeros[i]}, varsFlattened)
				for j=1,#b do
					assert(b[j][1] == symmath.Constant(0))
				end
				print('	-- '..xNames[i])
				--print('local a = '..ToStringLua(a, compileVars))
				print('local aDotA = '..ToStringLua((a * a:transpose())()[1][1], compileVars))
				print('local vDotA = '..ToStringLua((a * U)()[1][1], compileVars))
				print('local v_a = vDotA / aDotA')
				local v_a = codeVar('v_a')
				-- because we're doing 3 linear projections of overlapping variables ... i'd say scale back by 1/3rd ... but chances are that won't even work.  newton would be best.
				local epsilon = codeVar('epsilon')
				--print('local epsilon = 1/3')
				print('local epsilon = 1/100')
				for i=1,#varsFlattened do
					if a[1][i] ~= symmath.Constant(0) then
						print('qs[i]['..i..'] = qs[i]['..i..'] + '..ToStringLua((-epsilon * v_a * a[1][i])(), compileVars:append{v_a, epsilon}))
					end
				end
			end
		end
	end
end

local QLs = table()
local QRs = table()

for dir=1,3 do
	local eigenfields = getEigenfieldsForDir(dir)
	
	assert(#eigenfields == #varsFlattened, "expected "..#varsFlattened.." eigenfields but found "..#eigenfields)

	if not outputCode and outputMethod ~= 'GraphViz' then
		printbr()
		printbr('eigenvalues')
		printbr()
		for _,field in ipairs(eigenfields) do
			printbr(symmath.simplify(field.lambda))
		end
		printbr()
		
		printbr('eigenfields')
		printbr()
		for _,field in ipairs(eigenfields) do
			printbr(symmath.simplify(field.w))
		end
		printbr()
	end

	-- now just do a matrix factor of the eigenfields on varsFlattened and viola.
	-- QL is the left eigenvector matrix
	local QL, b = symmath.factorLinearSystem(
		eigenfields:map(function(field) return field.w end),
		fieldVarsFlattened)

	-- now add in 0's for cols corresponding to the timelike vars (which aren't supposed to be in the linear system)
	-- [[ this asserts that the time vars go first and the field vars go second in the varsFlattened
	for i=1,#QL do
		for j=1,#timeVarsFlattened do
			table.insert(QL[i], 1, symmath.Constant(0))
		end
		assert(#QL[i] == #varsFlattened)
	end
	assert(#QL == #varsFlattened)
	--]]

	-- only for the eigenfields corresponding to the time vars ...
	-- I have to pick them out of the system
	-- I *should* be not including them to begin with
	assert(#b == #eigenfields)
	for _,var in ipairs(timeVarsFlattened) do
		local j = varsFlattened:find(var) 
		for i,field in ipairs(eigenfields) do
			-- if the eigenfield is the time var then ...
			if field.w == var then
				-- ... it shouldn't have been factored out.  and there shouldn't be anything else.
				assert(b[i][1] == var, "expected "..var.." but got "..b[i].." for row "..i)
				-- so manually insert it into the eigenvector inverse 
				QL[i][j] = symmath.Constant(1)
				-- and manually remove it from the source term
				b[i][1] = symmath.Constant(0)
			end
		end
	end
	
	-- make sure all source terms are gone
	for i=1,#b do
		assert(#b[i] == 1)
		assert(b[i][1] == symmath.Constant(0), "expected b["..i.."] to be 0 but found "..b[i][1])
	end

	-- get the right eigenvectors
	local QR = QL:inverse()

	-- verify orthogonality
	local delta = (QL * QR)()
	for i=1,delta:dim()[1].value do
		for j=1,delta:dim()[2].value do
			local Constant = require 'symmath.Constant'
			assert(Constant.is(delta[i][j]))
			assert(delta[i][j].value == (i == j and 1 or 0))
		end
	end

	-- save for later
	QLs:insert(QL)
	QRs:insert(QR)
end

local function processCode(code)
	code = code:gsub('v_(%d+)', function(i)
		if outputMethod == 'C' then return 'input['..(i-1)..']' end
		return 'v['..i..']'
	end)
	code = code:gsub('}, {', ',\n')
	-- replace variable names with array
	for i,var in ipairs(varsFlattened) do
		code = code:gsub(var.name, 'v['..(outputMethod == 'C' and (i-1) or i)..']')
	end
	if outputMethod == 'Lua' then
		-- separate lines
		code = code:gsub('^{{(.*)}}$', '{\n%1\n}')
		-- indent
		code = code:trim():split'\n'
		code = code:map(function(line,i)
			if i == 1 or i == #code then
				return '\t' .. line
			else
				return '\t\t' .. line
			end
		end):concat('\n')
	elseif outputMethod == 'C' then
		code = code:match('^{{(.*)}}$')
		code = code:gsub('math%.','')
		code = code:gsub('v%[', 'input%[')
		-- add in variables
		code = code:gsub('sqrt%(f%)', 'sqrt_f')
		for _,ii in ipairs{'xx', 'yy', 'zz'} do
			code = code:gsub('sqrt%(gammaU'..ii..'%)', 'sqrt_gammaU'..ii)
			code = code:gsub('%(gammaU'..ii..' %^ %(3 / 2%)%)', 'gammaU'..ii..'_toThe_3_2')
		end
		-- add assignments
		code = code:trim():split('\n'):map(function(line,i)
			line = line:gsub(',$','')..';'
			return '\t\tresults['..(i-1)..'] = '..line
		end):concat('\n')
		if code:find('sqrt%(') then error('found sqrt( at '..code) end
		if code:find('%^') then error('found ^ at '..code) end
		code = code:gsub('([^%[_])(%d+)([^%]_])', '%1%2%.f%3')
	end
	return code
end

local function processGraph(m,name)
	local f = io.open('output/adm_'..name..'.dot', 'w')
	f:write'digraph {\n'
	for i=1,#m do
		for j=1,#m[i] do
			if m[i][j] ~= symmath.Constant(0) then
				f:write('\t',('%q'):format(varsFlattened[j]), ' -> ', ('%q'):format('\\lambda_{'..i..'}'),'\n')
			end
		end
	end
	f:write'}\n'
	f:close()
end



if outputCode then 
	for lr,Qs in ipairs{QLs, QRs} do
		if outputMethod == 'C' then
			print('\t')
			print('\t')
		end
		-- generate the code for the linear function 
		for i,xi in ipairs(xNames) do
			print('\t'..comment((lr==1 and 'left' or 'right')..' eigenvectors in '..xi..':'))
			if outputMethod == 'C' then
				print('\t'..(i > 1 and '} else ' or '')..'if (side == '..(i-1)..') {')
				print('\t\treal sqrt_gammaU'..xi..xi..' = sqrt(gammaU'..xi..xi..');')
				print('\t\treal gammaU'..xi..xi..'_toThe_3_2 = sqrt_gammaU'..xi..xi..' * gammaU'..xi..xi..';')
				print('\t\t')
			end
			print(processCode(ToStringLua((Qs[i] * U)(), compileVars)))
		end
		if outputMethod == 'C' then
			print('\t}')
			print('\t')
			print('\t')
		end
	end	
else
	for dir=1,3 do
		local QL = QLs[dir]
		local QR = QRs[dir]

		-- TODO :eq(source terms) 

		if outputMethod == 'GraphViz' then
			processGraph(QL,xNames[dir])
			processGraph(QR,xNames[dir]..'inv')
		else
			printbr('inverse eigenvectors in '..xNames[dir]..' dir')
			printbr((tostring((QL * U):eq(sourceTerms)):gsub('0','\\cdot')))
			printbr()
			printbr('eigenvectors in '..xNames[dir]..' dir')
			printbr((tostring(QR * U):gsub('0','\\cdot')))
			printbr()
		end
	end
end

if outputMethod == 'MathJax' then 
	print(MathJax.footer)
end
