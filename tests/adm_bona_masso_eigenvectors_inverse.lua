#!/usr/bin/env luajit

--[[
timelike variables (no need for flux integration): 
alpha
gamma_ij

flux variables:
A_i = (ln alpha),i
D_ijk = 
K_ij
V_i

constraints:

hyperbolic system:
alpha,t = -alpha^2 f tr K
gamma_ij,t = -2 alpha K_ij
A_k,t + alpha f g^ij partial_k K_ij = -alpha tr K (f + alpha f') A_k + 2 alpha f K^ij D_kij
D_kij,t + alpha partial_k K_ij = -alpha A_k K_ij
K_ij,t + alpha (g^km partial_k D_mij + 1/2 (delta^k_i partial_k A_j + delta^k_j partial_k A_i) + delta^k_i partial_k V_j + delta^k_j partial_k V_i) = alpha S_ij - alpha lambda^k_ij A_k + 2 alpha D_mij D_k^km
V_k,t = alpha P_k

source-only eigenfields:
alpha, gamma_ij

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


require 'ext'
local symmath = require 'symmath'
local Tensor = symmath.Tensor

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


local f = symmath.var('f')

-- coordinates
local xNames = table{'x', 'y', 'z'}
local spatialCoords = xNames:map(function(x) return symmath.var(x) end)
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
	return symmath.var(name)
end


-- [[ Bona-Masso

-- state variables:
local alpha = codeVar('\\alpha')
local As = xNames:map(function(xi) return codeVar('A_'..xi) end)
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
local gammaU = Tensor('^ij', function(i,j) return gammaUsym[from3x3to6(i,j)] end)
local gammaL = Tensor('_ij', function(i,j) return gammaLsym[from3x3to6(i,j)] end)
local A = Tensor('_i', function(i) return As[i] end)
local D = Tensor('_ijk', function(i,j,k) return Dsym[i][from3x3to6(j,k)] end)
local K = Tensor('_ij', function(i,j) return Ksym[from3x3to6(i,j)] end)
local V = Tensor('_i', function(i) return Vs[i] end)

Tensor.metric(gammaL, gammaU)

-- lookup of variables to their flattened lists and other associated information 
local vars = table{
	{name='\\alpha', flattened={alpha}},
	{name='\\gamma', flattened=gammaLsym},
	{name='A', flattened=A},
	{name='D', flattened=DFlattened},
	{name='K', flattened=Ksym},
	{name='V', flattened=V},
}
for _,var in ipairs(vars) do
	local name = var.name:match('\\?(.*)')	-- remove leading \\ for greek characters
	vars[name] = var
end

local timeVars = table{vars.alpha, vars.gamma}
local fieldVars = table{vars.A, vars.D, vars.K, vars.V}

--]]
--[[ FOBSSN
--[=[
	original desc:
... taking Bona-Masso lapse: partial_t alpha = -alpha^2 f K
... and no shift (hence why all the beta terms aren't there)
partial_t gammaTilde_ij = -2 alpha ATilde_ij
partial_t phi = -1/6 alpha K
partial_t ATilde_ij = exp(-4 phi) ( -D_i D_j alpha + alpha R_ij + 4 pi alpha (gamma_ij (S - rho) - 2 S_ij))^TF + alpha (K ATilde_ij - 2 ATilde_ik ATilde^k_j)
partial_t K = -D_i D^i alpha + alpha (ATilde_ij ATilde^ij + 1/3 K^2) + 4 pi alpha (rho + S)
partial_t Gamma^i = -2 ATilde^ij partial_j alpha + 2 alpha (GammaTilde^i_jk ATilde^jk + 6 ATilde^ij partial_j phi - 2/3 gammaTilde^ij partial_j K - 8 pi jTilde^i)
	hyperbolic variables:
a_i = partial_i ln alpha = partial_i alpha / alpha
Phi_i = partial_i phi
dTilde_ijk = 1/2 partial_k gammaTilde_ij
--]=]

local gammaTildeUSym = symNames:map(function(xij) return codeVar('\\tilde\\gamma^{'..xij..'}') end)
local gammaTildeU = Tensor('_ij', function(i,j) return gammaTildeUSym[from3x3to6(i,j)] end)

local alpha = codeVar('\\alpha')
local gammaTildeLSym = symNames:map(function(xij) return codeVar('\\tilde\\gamma_{'..xij..'}') end)
local gammaTildeL = Tensor('_ij', function(i,j) return gammaTildeLSym[from3x3to6(i,j)] end)
local phi = codeVar('\\phi')
local ATildeSym = symNames:map(function(xjk) return codeVar('\\tilde{A}_{'..xjk..'}') end)
local ATilde = Tensor('_ij', function(i,j) return ATildeSym[from3x3to6(i,j)] end)
local K = codeVar('K')
local GammaUs = xNames:map(function(xi) return codeVar('\\Gamma^'..xi) end)
local as = xNames:map(function(xi) return codeVar('a_'..xi) end)		-- a_i = (ln alpha),i
local Phis = xNames:map(function(xi) return codeVar('\\Phi_'..xi) end)	-- Phi,i = (ln phi),i
local DTildeSym = xNames:map(function(xi)
	return symNames:map(function(xjk) return codeVar('\\tilde{D}_{'..xi..xjk..'}') end)
end)
local DTildeFlattened = table():append(DTildeSym:unpack())

Tensor.metric(gammaTildeL, gammaTildeU)

-- lookup of variables to their flattened lists and other associated information 
local vars = table{
	{name='\\alpha', flattened={alpha}},
	{name='\\gamma', flattened=gammaTildeLSym},
	{name='\\phi', flattened={phi}},
	{name='\\tilde{A}', flattened=ATildeSym},
	{name='K', flattened={K}},
	{name='\\Gamma', flattened=GammaUs},
	{name='a', flattened=as},
	{name='\\Phi', flattened=Phis},
	{name='\\tilde{D}', flattened=DTildeFlattened},
}
for _,var in ipairs(vars) do
	local name = var.name:match('\\?(.*)')	-- remove leading \\ for greek characters
	vars[name] = var
end

local timeVars = table{vars.alpha, vars.gamma}
local fieldVars = table{vars.A, vars.D, vars.K, vars.V}

--]]




-- variables flattened and combined into one table
local timeVarsFlattened = table()
local fieldVarsFlattened = table()
for _,info in ipairs{
	{timeVars, timeVarsFlattened},
	{fieldVars, fieldVarsFlattened},
} do
	local infoVars, infoVarsFlattened = table.unpack(info)
	for _,var in ipairs(infoVars) do
		infoVarsFlattened:append(var.flattened)
	end
end

local varsFlattened = table():append(timeVarsFlattened, fieldVarsFlattened)
assert(#varsFlattened == 37, "expected 37 but found "..#varsFlattened)

-- all symbolic variables for use with compiled functions
local compileVars = table():append(varsFlattened):append{f}:append(gammaUsym)

-- all variables combined into one vector
local v = symmath.Matrix(varsFlattened:map(function(v) return {v} end):unpack())

local VU = V'^i':simplify()
local trK = K'^i_i':simplify()
local trDk = D'_km^m':simplify()
--local delta3 = symmath.Matrix.identity(3)
local delta3 = Tensor('^i_j', function(i,j) return i == j and 1 or 0 end)

--[=[ we don't need the source vector ... it's very complex ... should be computed on the spot
-- R4 and G0 need to be provided ...

-- assuming those gammas are of the spatial metric (and not the spacetime metric ...)
local Gamma = Tensor('_ijk')
Gamma['_ijk'] = (D'_kij' + D'_jik' - D'_ijk'):simplify()
printbr('$\\Gamma_{ijk} = $'..Gamma'_ijk')
io.stdout:flush()

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
	):simplify()
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
	):simplify()
printbr('$P_i = $'..P'_i')
io.stdout:flush()
--]=]
-- [=[
if outputCode then
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
			print(ToStringLua((D[k][i][j] + D[j][i][k] - D[i][j][k]):simplify(), compileVars)..',')
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
			return 'ADU'..I(k)..' * '..ToStringLua((D[i][j][k] + D[j][i][k]):simplify(), compileVars)
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
				(A[i] * (V[j] - D1L[j] / 2) + A[j] * (V[i] - D1L[i] / 2)):simplify(),
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
local P = Tensor('_i', function(i) return codeVar('P_'..i) end)

--]=]

-- not much use for this at the moment
-- going to display it alongside the matrix
local sourceTerms = symmath.Matrix(table{
	-- alpha
	-alpha^2 * f * trK,
	-- gamma_ij
	-2 * alpha * K[1][1],
	-2 * alpha * K[1][2],
	-2 * alpha * K[1][3],
	-2 * alpha * K[2][2],
	-2 * alpha * K[2][3],
	-2 * alpha * K[3][3],
	-- A_k
	0, 0, 0,
	-- D_kij
	0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0,
	-- K_ij
	alpha * S[1][1],
	alpha * S[1][2],
	alpha * S[1][3],
	alpha * S[2][2],
	alpha * S[2][3],
	alpha * S[3][3],
	-- V_k
	alpha * P[1],
	alpha * P[2],
	alpha * P[3],
}:map(function(x) return {x} end):unpack())

local function processCode(code)
	code = code:gsub('v_(%d+)', function(i)
		if outputMethod == 'C' then return 'input['..(i-1)..']' end
		return 'v['..i..']'
	end)
	code = code:gsub('}, {', ',\n')
	-- replace variable names with array
	for i,var in ipairs(varsFlattened) do
		code = code:gsub(var.name, 'v['..i..']')
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
			code = code:gsub('sqrt%(gammaUsym'..ii..'%)', 'sqrt_gammaU'..ii)
			code = code:gsub('%(gammaUsym'..ii..' %^ %(3 / 2%)%)', 'gammaUsym'..ii..'_toThe_3_2')
		end
		-- add assignments
		code = code:trim():split('\n'):map(function(line,i)
			line = line:gsub(',$','')..';'
			return 'results['..(i-1)..'] = '..line
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

if not outputCode and outputMethod ~= 'GraphViz' then
	printbr('V and D constraints:')
	printbr((V'_i':equals(D'_im^m' - D'^m_mi')):simplify())
	printbr()
elseif outputCode then
	print('-- V and D constraint')
	local VDs = V'_i':equals(D'_im^m' - D'^m_mi')
	print(ToStringLua(VDs:simplify(), compileVars))
	print('-- V and D linear project')
	-- linear factor out the V's and D's ... 
	local VDZeros = (V'_i' - (D'_ij^j' - D'^j_ji')):simplify()
	for i=1,3 do
		local a,b = symmath.factorLinearSystem({VDZeros[i]}, varsFlattened)
		for j=1,#b do
			assert(b[j][1] == symmath.Constant(0))
		end
		print('	-- '..xNames[i])
		--print('local a = '..ToStringLua(a, compileVars))
		print('local aDotA = '..ToStringLua((a * a:transpose()):simplify()[1][1], compileVars))
		print('local vDotA = '..ToStringLua((a * v):simplify()[1][1], compileVars))
		print('local v_a = vDotA / aDotA')
		local v_a = codeVar('v_a')
		-- because we're doing 3 linear projections of overlapping variables ... i'd say scale back by 1/3rd ... but chances are that won't even work.  newton would be best.
		local epsilon = codeVar('epsilon')
		--print('local epsilon = 1/3')
		print('local epsilon = 1/100')
		for i,var in ipairs(varsFlattened) do
			if a[1][i] ~= symmath.Constant(0) then
				print('qs[i]['..i..'] = qs[i]['..i..'] + '..ToStringLua((-epsilon * v_a * a[1][i]):simplify(), compileVars:append{v_a, epsilon}))
			end
		end
	end
end

local ms = range(3):map(function(dir)

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
	eigenfields:insert{w=alpha, lambda=0}
		-- gamma_ij
	eigenfields:append(gammaLsym:map(function(gamma_ij,ij) return {w=gamma_ij, lambda=0} end))
		-- A_x', x' != dir
	eigenfields:append(oxIndexes:map(function(p) return {w=A[p], lambda=0} end))
		-- D_x'ij, x' != dir
	eigenfields:append(oxIndexes:map(function(p)
		return Dsym[p]:map(function(D_pij)
			return {w=D_pij, lambda=0}
		end)
	end):unpack())
		-- V_i
	eigenfields:append(range(3):map(function(i) return {w=V[i], lambda=0} end))
		-- A_x - f D_xm^m, x = dir
	eigenfields:insert{w=A[dir] - f * trDk[dir], lambda=0}
	
	local sqrt = symmath.sqrt
	for sign=-1,1,2 do
		-- light cone -+
			-- K_ix'
		local loc = sign == -1 and 1 or #eigenfields+1
		for _,ij in ipairs(osymIndexes) do
			local i,j = from6to3x3(ij)
			if j == dir then i,j = j,i end
			assert(j ~= dir)
			eigenfields:insert(loc, {
				w = K[i][j] + sign * sqrt(gammaU[dir][dir]) * (D[dir][i][j] + delta3[dir][i] * V[j] / gammaU[dir][dir]),
				lambda = sign * alpha * sqrt(gammaU[dir][dir]),
			})
			loc=loc+1
		end
		-- gauge -+
		local loc = sign == -1 and 1 or #eigenfields+1
		eigenfields:insert(loc, {
			w = sqrt(f) * trK + sign * sqrt(gammaU[dir][dir]) * (A[dir] + 2 * VU[dir] / gammaU[dir][dir]),
			lambda = sign * alpha * sqrt(f * gammaU[dir][dir]),
		})
	end
	
	assert(#eigenfields == #varsFlattened)

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

	local QR = QL:inverse()
	
	-- TODO :equals(source terms) 

	if outputMethod == 'GraphViz' then
		processGraph(QL,xNames[dir])
		processGraph(QR,xNames[dir]..'inv')
	elseif not outputCode then 
		printbr('inverse eigenvectors in '..dir..' dir')
		printbr((tostring((QL * v):equals(sourceTerms)):gsub('0','\\cdot')))
		printbr()
		printbr('eigenvectors in '..dir..' dir')
		printbr((tostring(QR * v):gsub('0','\\cdot')))
		printbr()
	else
		-- generate the code for the linear function 
		print('-- inverse eigenvectors in '..dir..' dir:')
		print(processCode(ToStringLua((QL*v):simplify(), compileVars)))
		print('-- eigenvectors in '..dir..' dir:')
		print(processCode(ToStringLua((QR*v):simplify(), compileVars)))
	end
	io.stdout:flush()
	
	-- verify orthogonality
	local delta = (QL * QR):simplify()
	for i=1,delta:dim()[1].value do
		for j=1,delta:dim()[2].value do
			local Constant = require 'symmath.Constant'
			assert(Constant.is(delta[i][j]))
			assert(delta[i][j].value == (i == j and 1 or 0))
		end
	end
io.stdout:flush()
end)

if outputMethod == 'MathJax' then 
	print(MathJax.footer)
end
