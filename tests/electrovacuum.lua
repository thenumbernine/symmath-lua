#! /usr/bin/env luajit
require 'ext'
local symmath = require 'symmath'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
MathJax.usePartialLHSForDerivative = true
print(MathJax.header)
local printbr = MathJax.print
local Tensor = symmath.Tensor
local var = symmath.var
local vars = symmath.vars
local frac = symmath.divOp

local t,x,y,z = vars('t', 'x', 'y', 'z')
local q,m = vars('q', 'm')
local coords = {t,x,y,z}
local spatialCoords = {x,y,z}

local pi = var'\\pi'

-- used for output
local A_ = var'A'
local B_ = var'B'
local E_ = var'E'
local F_ = var'F'
local G_ = var'G'
local R_ = var'R'
local S_ = var'S'
local T_ = var'T'
local c_ = var'c'
local g_ = var'g'
local u_ = var'u'
local Gamma_ = var'\\Gamma'
local delta_ = var'\\delta'
local eta_ = var'\\eta'
local epsilon_ = var'\\epsilon'
local RHat_ = var'\\hat{R}'

Tensor.coords{
	{variables=coords},
	{symbols='ijklmn', variables=spatialCoords},
	{symbols='t', variables={t}},
	{symbols='x', variables={x}},
	{symbols='y', variables={y}},
	{symbols='z', variables={z}},
}

local eta = Tensor('_uv', function(u,v)
	return u == v and (u == 1 and -1 or 1) or 0
end)

local deltaL3 = Tensor('_ij', function(i,j) return i == j and 1 or 0 end)

printbr"<h3>here's a metric that gives rise to geodesics equal to the Lorentz force law, up to a scalar</h3>"

--[[
wiki https://en.wikipedia.org/wiki/Electromagnetic_four-potential
says that the 4-potential units of A^i are V s / m
... and the timelike A^t = phi/\tilde{c} V s / m,
and natural units say c = 1 = \tilde{c} m/s <=> 1 s = \tilde{c} m
so A^t = phi / (s / m) V s / m is in V, which fits what everyone else says

if we were to convert these to meters, what would the magnitude be? 

A^t = V
A^i = V s/m = \tilde{c} V
--]]
local A = Tensor('_u', function(u) return var('A_'..coords[u].name, coords) end)
printbr('electromagnetic four-potential')
printbr(A_'_u':eq(A'_u'()))

local g = Tensor'_uv'
-- hmm, single-variable coordinate sets still need to be specified in what is being assigned ...
-- this is where special treatment for variables among indexes would come in handy
g['_tt'] = Tensor('_tt', function(t,t) return -1 + 2 * A[1] end)
g['_ti'] = (A'_i')()
g['_it'] = (A'_i')()
g['_ij'] = deltaL3'_ij'()
printbr(g_'_uv':eq(g))

--[[ variable
local gU = Tensor('^uv', function(u,v)
	return var('g^{'..coords[u].name..coords[v].name..'}', coords)
end)
--]]
--[[ eta (near-flat approximation)
printbr"using $g^{ab} \\approx \\eta^{ab}$"
local gU = Tensor('^ab', table.unpack(eta))
--]]
-- [[ actual inverse.  explicitly specified since my inverse algorithm can't handle it.
local denom = -1 + 2 * A[1] - A[2]^2 - A[3]^2 - A[4]^2
local gU = Tensor'^uv'
gU['^tt'] = Tensor('^tt', function() return 1 / denom end)
gU['^ti'] = (-A'_i' / denom)()
gU['^it'] = (-A'_i' / denom)()
gU['^ij'] = (A'_i' * A'_j' / denom + deltaL3'_ij')()
--]]

printbr(g_'^uv':eq(gU))
printbr((g_'_ac' * g_'^cb'):eq( (g'_ac' * gU'^cb')() ))

local basis = Tensor.metric(g, gU)
--[[
local gU = basis.metricInverse
printbr(gU)
--]]

local GammaL = Tensor'_abc'
GammaL['_abc'] = ((g'_ab,c' + g'_ac,b' - g'_bc,a') / 2)()
printbr(Gamma_'_abc':eq(GammaL'_abc'()))

local E = Tensor('_i', function(i) return var('E_'..spatialCoords[i].name, coords) end)
printbr(E_'_i':eq(E'_i'()))

local B = Tensor('_i', function(i) return var('B_'..spatialCoords[i].name, coords) end)
printbr(B_'_i':eq(B'_i'()))

local S = Tensor('_i', function(i) return var('S_'..spatialCoords[i].name, coords) end)
printbr(S_'_i':eq(S'_i'()))

-- E_i = A_t,i - A_i,t
-- B_i = epsilon_ijk A_k,j
-- A_i,t = A_t,i - E_i
local function replacePotentialsWithFields(expr)
	return expr	
		:replace(A[2]:diff(t), A[1]:diff(x) - E[1])
		:replace(A[3]:diff(t), A[1]:diff(y) - E[2])
		:replace(A[4]:diff(t), A[1]:diff(z) - E[3])
		
		:replace(A[1]:diff(x), A[2]:diff(t) + E[1])
		:replace(A[1]:diff(y), A[3]:diff(t) + E[2])
		:replace(A[1]:diff(z), A[4]:diff(t) + E[3])
		
		:replace(A[4]:diff(y), A[3]:diff(z) + B[1])
		:replace(A[2]:diff(z), A[4]:diff(x) + B[2])
		:replace(A[3]:diff(x), A[2]:diff(y) + B[3])

		:replace(A[3]:diff(z), A[4]:diff(y) - B[1])
		:replace(A[4]:diff(x), A[2]:diff(z) - B[2])
		:replace(A[2]:diff(y), A[3]:diff(x) - B[3])
end

GammaL = replacePotentialsWithFields(GammaL)

printbr(Gamma_'_abc':eq(GammaL'_abc'()))

printbr"<h3>Lorentz force as a geodesic</h3>"

local u = Tensor('^u', function(u)
	-- t approaches 1
	--return u == 1 and 1 or var('u^'..coords[u].name, coords)
	return var('u^'..coords[u].name, coords)
end)

local accel = -GammaL'_abc' * u'^b' * u'^c'
printbr(( frac(1, q) * u[1] * m * var'\\dot{u}''_a' ):eq( -Gamma_'_abc' * u_'^b' * u_'^c' ):eq( -GammaL'_abc'() * u'^b'() * u'^c'() ):eq( 
	--replacePotentialsWithFields(
		accel()
	--)()
))

printbr(( frac(1,q) * u[1] * m * var'\\dot{u}''_i' ):eq( -Gamma_'_ibc' * u_'^b' * u_'^c' ):eq( accel()'_i'() ))

printbr"<h3>Connection coefficients</h3>"

local Gamma = GammaL'^a_bc'()
printbr(Gamma_'^a_bc':eq(Gamma'^a_bc'()))

--[[
local props = require 'symmath.diffgeom'(g)
for k,eqn in ipairs(props.eqns) do
	for i,x in ipairs(spatialCoords) do
		props[k] = props[k]
			:replace(A[2]:diff(t), A[1]:diff(x) - E[1])
			:replace(A[3]:diff(t), A[1]:diff(y) - E[2])
			:replace(A[4]:diff(t), A[1]:diff(z) - E[3])
			:replace(A[4]:diff(y), A[3]:diff(z) + B[1])
			:replace(A[2]:diff(z), A[4]:diff(x) + B[2])
			:replace(A[3]:diff(x), A[2]:diff(y) + B[3])
	end
end
props:calcEqns()

props:printbr(printbr)
--]]

printbr"<h3>now I'm looking for a Riemann (and then a Christoffel) that gives rise to the electromagnetism stress-energy tensor</h3>"

Tensor.metric(eta, eta)

local LeviCivita3 = Tensor('_ijk', function(i,j,k)
	if i%3+1 == j and j%3+1 == k then return 1 end
	if k%3+1 == j and j%3+1 == i then return -1 end
	return 0
end)

local Faraday = Tensor'_ab'
Faraday['_ti'] = Tensor('_ti', (-E'_i')())
Faraday['_it'] = Tensor('_ti', E'_i'())
Faraday['_ij'] = (LeviCivita3'_ijk' * B'_k')()

printbr(F_'_ab':eq(Faraday'_ab'()))
printbr(F_'^a_b':eq(Faraday'^a_b'()))

local T_EM = Tensor'_ab'
T_EM['_ab'] = ((Faraday'_au' * Faraday'_b^u' - eta'_ab' * Faraday'_uv' * Faraday'^uv' / 4) / (4 * pi))()

printbr(T_'_ab':eq(T_EM'_ab'()))
printbr(T_'^a_a':eq( T_EM'^a_a'() ))

printbr(G_'_ab':eq( 8 * pi * T_'_ab')) -- G_ab = 8 pi T_ab
printbr(G_'_ab':eq( R_'_ab' - frac(1,2) * R_'^c_c' * eta_'_ab' )) -- G_ab = R_ab - 1/2 R^c_c eta_ab
printbr(R_'_ab':eq( G_'_ab' - frac(1,2) * G_'^c_c' * eta_'_ab' ))	-- R_ab = G_ab - 1/2 G^c_c eta_ab
printbr(R_'_ab':eq( 8 * pi * T_'_ab' - 4 * pi * T_'^c_c' * eta_'_ab'))	-- R_ab = 8 pi T_ab - 4 pi T^c_c eta_ab

local Ricci = Tensor'_ab'
Ricci['_ab'] = (8 * pi * T_EM'_ab' - 4 * pi * T_EM'^c_c' * eta'_ab')()

printbr"<h3>here's the Ricci curvature tensor that matches the Einstein field equations for the electromagnetic stress-energy tensor</h3>"

printbr(( R_'_tt' ):eq( E_^2 + B_^2 ))
printbr(( R_'_it' ):eq( -2 * S_'i' ):eq( -2 * epsilon_'_ijk' * E_'_j' * B_'_k' ))
printbr(( R_'_ij' ):eq( delta_'_ij' * (E_^2 + B_^2)  - 2 * (E_'_i' * E_'_j' + B_'_i' * B_'_j') ))

printbr(RHat_'_ab'
	:eq( 8 * pi * T_'_ab' - 4 * pi * T_'^c_c' * eta_'_ab')
	:eq(Ricci'_ab'()))

--[[
local ESq_plus_BSq = (E'_k'*E'_k' + B'_k'*B'_k')()

local Ricci = Tensor'_ab'
Ricci['_tt'] = Tensor('_tt', {ESq_plus_BSq})
Ricci['_ti'] = Tensor('_ti', (-2 * S'_i')())
Ricci['_it'] = Tensor('_ti', (-2 * S'_i')())
Ricci['_ij'] = (-2 * E'_i' * E'_j' - 2 * B'_i' * B'_j' + ESq_plus_BSq * deltaL3'_ij')()

printbr(RHat_'_ab':eq(Ricci))
--]]

printbr"<h3>here's the constraints that have to be satisfied for the Riemann curvature tensor:</h3>"

printbr(( R_'_tt' ):eq( E_^2 + B_^2 ):eq( R_'^a_tat' ):eq( R_'^t_ttt' + R_'^j_tjt' ):eq( R_'^j_tjt' ):eq( g_'^jt' * R_'_ttjt' + g_'^jk' * R_'_ktjt' ):eq( g_'^jk' * R_'_ktjt' ))
printbr(( R_'_it' ):eq( -2 * S_'i' ):eq( -2 * epsilon_'_ijk' * E_'_j' * B_'_k' ):eq( R_'^a_iat' ):eq( R_'^t_itt' + R_'^j_ijt' ):eq( R_'^j_ijt' ):eq( g_'^jt' * R_'_tijt' + g_'^jk' * R_'_kijt' ))
printbr(( R_'_ij' ):eq( delta_'_ij' * (E_^2 + B_^2)  - 2 * (E_'_i' * E_'_j' + B_'_i' * B_'_j') ):eq( R_'^a_iaj' ):eq( R_'^t_itj' + R_'^k_ikj' )
	:eq( g_'^tt' * R_'_titj' + g_'^tk' * R_'_kitj' + g_'^kt' * R_'_tikj' + g_'^kl' * R_'_likj' )
	:eq( g_'^tt' * R_'_titj' + g_'^kl' * R_'_likj' + g_'^tk' * (R_'_tjki' + R_'_tikj') ))

printbr"<h3>here's a Riemann curvature tensor that gives rise to that Ricci curvature tensor, subject to $g^{ab} \\approx \\eta^{ab}$ </h3>"


local S = (LeviCivita3'_ijk' * E'_j' * B'_k')()


-- the last "2/3 E dot B" is used to eliminate the "-2 E dot B" difference left between R_tt and Rhat_tt ... need to divide by 3 because the tensor is traced
--[[
options for R_titj:
E_i E_j + B_i B_j - E_i B_j B_i E_j gives a difference of R_ab += -2 E dot B eta_ab
... - 2/3 delta_ij E dot B ... R_ii += -4/3 E dot B
... + 2 delta_ij E dot B ... R_tt += -4 E dot B 
--]]

--[[ option #1 -- leaves Rhat_tt - R_tt = -4 E dot b
local Riemann_titj_expr = E'_i' * E'_j' + B'_i' * B'_j' - E'_i' * B'_j' - B'_i' * E'_j' + 2 * deltaL3'_ij' * E'_k' * B'_k'
local Riemann_tijk_expr = deltaL3'_ij' * S'_k' - deltaL3'_ik' * S'_j'
local Riemann_ijkl_expr = LeviCivita3'_ijm' * (E'_m' + B'_m') * LeviCivita3'_kln' * (E'_n' + B'_n')
--]]
--[[ option #2 -- leaves Rhat_ii - R_ii = -4/3 E dot B
local Riemann_titj_expr = E'_i' * E'_j' + B'_i' * B'_j' - E'_i' * B'_j' - B'_i' * E'_j' + frac(2,3) * deltaL3'_ij' * E'_k' * B'_k'
local Riemann_tijk_expr = deltaL3'_ij' * S'_k' - deltaL3'_ik' * S'_j'
local Riemann_ijkl_expr = LeviCivita3'_ijm' * (E'_m' + B'_m') * LeviCivita3'_kln' * (E'_n' + B'_n')
--]]
--[[ option #3 -- leaves Rhat_ab - R_ab = -2 eta E dot B
local Riemann_titj_expr = E'_i' * E'_j' + B'_i' * B'_j' - E'_i' * B'_j' - B'_i' * E'_j'
local Riemann_tijk_expr = deltaL3'_ij' * S'_k' - deltaL3'_ik' * S'_j'
local Riemann_ijkl_expr = LeviCivita3'_ijm' * (E'_m' + B'_m') * LeviCivita3'_kln' * (E'_n' + B'_n')
--]]
-- [[ option #4 -- works -- Rhat_ab - R_ab = 0 
local Riemann_titj_expr = E'_i' * E'_j' + B'_i' * B'_j'
local Riemann_tijk_expr = deltaL3'_ij' * S'_k' - deltaL3'_ik' * S'_j'	-- = (delta_ij delta_lk - delta_ik delta_lj) epsilon_lmn E_m B_n = delta^il_jk epsilon_lmn E_m B_n = epsilon_ilw epsilon_jkw epsilon_lpq E_p B_q
local Riemann_ijkl_expr = LeviCivita3'_ijm' * LeviCivita3'_kln' * (E'_m' * E'_n' + B'_m' * B'_n')
--]]
--[[ option #5
local Riemann_titj_expr = E'_i' * E'_j' + B'_i' * B'_j' - E'_i' * B'_j' - B'_i' * E'_j'
local Riemann_tijk_expr = deltaL3'_ij' * S'_k' - deltaL3'_ik' * S'_j'
local Riemann_ijkl_expr = (deltaL3'_ij' * deltaL3'_km' * deltaL3'_ln' - frac(2,3) * deltaL3'_kl' * deltaL3'_im' * deltaL3'_jn') * (E'_m' * E'_n' + B'_m' * B'_n')
--]]
--[[ option #6 - spinoff of option #4 which works, but switches j & l so the Levi-Civita symbols line up with the connection coefficients of R^a_bcd
-- RHat_ab - R_ab = eta_ab (E^2 + B^2) and the Riemann constraints are not fulfilled
local Riemann_titj_expr = 3 * (E'_i' * E'_j' + B'_i' * B'_j')
local Riemann_tijk_expr = deltaL3'_ij' * S'_k' - deltaL3'_ik' * S'_j'	-- = (delta_ij delta_lk - delta_ik delta_lj) epsilon_lmn E_m B_n = delta^il_jk epsilon_lmn E_m B_n = epsilon_ilw epsilon_jkw epsilon_lpq E_p B_q
local Riemann_ijkl_expr = LeviCivita3'_ilm' * LeviCivita3'_jkn' * (E'_m' * E'_n' + B'_m' * B'_n')
--]]

local Riemann_tt = Tensor'_ij'
Riemann_tt['_ij'] = Riemann_titj_expr()

local Riemann_t = Tensor'_ijk'
Riemann_t['_ijk'] = Riemann_tijk_expr()

-- R_ijkl -- zero 't's
local Riemann = Tensor'_abcd'
Riemann['_ijkl'] = Riemann_ijkl_expr()

local Connection
local Commutation
local RiemannFromConnection

local function pretty(expr)
	return expr
		:replace(E,E_)
		:replace(B,B_)
		:replace(S,S_)
		:replace(Connection,Gamma_)
		:replace(Commutation,c_)
		:replace(Riemann,R_)
		:replace(RiemannFromConnection,R_)
		:replace(deltaL3,delta_)
		:replace(LeviCivita3,epsilon_)
end

printbr(R_'_titj':eq( pretty(Riemann_titj_expr) ))
printbr(R_'_tijk':eq( pretty(Riemann_tijk_expr) ))
printbr(R_'_ijkl':eq( pretty(Riemann_ijkl_expr) ))

-- R_tijk -- one 't's
Riemann['_tijk'] = Tensor('_tijk', function(t,i,j,k) return Riemann_t[i][j][k] end)
Riemann['_itjk'] = Tensor('_itjk', function(i,t,j,k) return -Riemann_t[i][j][k] end)
Riemann['_jkti'] = Tensor('_jkti', function(j,k,t,i) return Riemann_t[i][j][k] end)
Riemann['_jkit'] = Tensor('_jkit', function(j,k,i,t) return -Riemann_t[i][j][k] end)
-- R_titj -- two 't's
Riemann['_titj'] = Tensor('_titj', function(t,i,t,j) return Riemann_tt[i][j] end)
Riemann['_tijt'] = Tensor('_tijt', function(t,i,j,t) return -Riemann_tt[i][j] end)
Riemann['_ittj'] = Tensor('_ittj', function(i,t,t,j) return -Riemann_tt[i][j] end)
Riemann['_itjt'] = Tensor('_itjt', function(i,t,j,t) return Riemann_tt[i][j] end)
-- ... and 3 't's and 4 't's is always zero ...

printbr(R_'_abcd':eq(Riemann))

Riemann = Riemann'^a_bcd'()

printbr"<h3>identities...</h3>"

printbr(R_'^a_tat':eq(Riemann'^a_tat'()))
printbr(R_'^a_iat':eq(Riemann'^a_iat'()))
printbr(R_'^a_iaj':eq(Riemann'^a_iaj'()))

printbr"<h3>building Ricci from Riemann...</h3>"

RicciFromRiemann = Riemann'^c_acb'()
printbr(R_'_ab':eq(RicciFromRiemann))

printbr"<h3>differences with the desired Ricci:</h3>"
printbr((RHat_'_ab' - R_'_ab'):eq( (Ricci - RicciFromRiemann)() ))

printbr"<h3>Riemann tensor constraints that need to be fulfilled:</h3>"

--[[ doesn't show zeros
for _,expr in ipairs{
	{R_'_abcd' + R_'_abdc', (Riemann'_abcd' + Riemann'_abdc')()},
	{R_'_abcd' + R_'_bacd', (Riemann'_abcd' + Riemann'_bacd')()},
	{R_'_abcd' - R_'_cdab', (Riemann'_abcd' - Riemann'_cdab')()},
} do
	printbr(( expr[1] ):eq( expr[2] ))
end
--]]
-- [[ shows zeros
printbr((R_'_abcd' + R_'_abdc'):eq( (Riemann'_abcd' + Riemann'_abdc')() ))
printbr((R_'_abcd' + R_'_bacd'):eq( (Riemann'_abcd' + Riemann'_bacd')() ))
printbr((R_'_abcd' - R_'_cdab'):eq( (Riemann'_abcd' - Riemann'_cdab')() ))
--]]

printbr"<h3>removing $g^{ab} \\approx \\eta^{ab}$</h3>"

printbr(( R_'^t_itj' ):eq( pretty(-E'_i' * E'_j' - B'_i' * B'_j') ))
printbr(( R_'^t_ijk' ):eq( pretty(deltaL3'_ik' * S'_j' - deltaL3'_ij' * S'_k' ) ))
printbr(( R_'^i_jkl' ):eq( pretty(LeviCivita3'^i_jm' * LeviCivita3'_kln' * (E'^m' * E'^n' + B'^m' * B'^n')) ))

printbr"<h3>connections that give rise to Riemann tensor</h3>"

printbr(R_'^t_itj':eq( 
	-E_'_i' * E_'_j' - B_'_i' * B_'_j'
):eq(
	Gamma_'^t_ij,t' - Gamma_'^t_it,j' + Gamma_'^t_at' * Gamma_'^a_ij' - Gamma_'^t_aj' * Gamma_'^a_it'
):eq(
	Gamma_'^t_ij,t' - Gamma_'^t_ti,j' 
	+ Gamma_'^t_tt' * Gamma_'^t_ij' 
	+ Gamma_'^t_tm' * Gamma_'^m_ij' 
	- Gamma_'^t_ti' * Gamma_'^t_tj'
	- Gamma_'^t_mj' * Gamma_'^m_ti'
))
printbr(R_'^t_ijk':eq( 
	delta_'_ik' * S_'_j' - delta_'_ij' * S_'_k' 
):eq(
	-epsilon_'_inm' * epsilon_'_jkm' * epsilon_'_npq' * E_'_p' * B_'_q'
):eq(
	Gamma_'^t_ik,j' - Gamma_'^t_ij,k' + Gamma_'^t_aj' * Gamma_'^a_ik' - Gamma_'^t_ak' * Gamma_'^a_ij'
):eq(
	Gamma_'^t_ik,j' - Gamma_'^t_ij,k' 
	+ Gamma_'^t_tj' * Gamma_'^t_ik' 
	+ Gamma_'^t_mj' * Gamma_'^m_ik' 
	- Gamma_'^t_tk' * Gamma_'^t_ij'
	- Gamma_'^t_mk' * Gamma_'^m_ij'
))
printbr(R_'^i_jkl':eq( 
	epsilon_'^i_jm' * epsilon_'_kln' * (E_'^m' * E_'^n' + B_'^m' * B_'^n')
):eq(
	Gamma_'^i_jl,k' - Gamma_'^i_jk,l' + Gamma_'^i_ak' * Gamma_'^a_jl' - Gamma_'^i_al' * Gamma_'^a_jk'
):eq(
	Gamma_'^i_jl,k' - Gamma_'^i_jk,l' 
	+ Gamma_'^i_tk' * Gamma_'^t_jl' 
	+ Gamma_'^i_mk' * Gamma_'^m_jl' 
	- Gamma_'^i_tl' * Gamma_'^t_jk'
	- Gamma_'^i_ml' * Gamma_'^m_jk'
))

printbr"<h3>generating Riemann curvature from connection coefficients</h3>"

Tensor.metric(deltaL3, deltaL3, 'i')

local Connection_ijk_expr = LeviCivita3'^i_jl' * (E'^l' * E'_k' + B'^l' * B'_k')
local Commutation_ijk_expr = LeviCivita3'_ij^k'

printbr( Gamma_'^i_jk' :eq( pretty(Connection_ijk_expr) ) )
printbr( c_'_ij^k':eq( pretty(Commutation_ijk_expr) ) )

Connection = Tensor'^a_bc'
Connection['^i_jk'] = Connection_ijk_expr()

Commutation = Tensor'_ab^c'
Commutation['_ij^k'] = Commutation_ijk_expr()

local RiemannFromConnection_expr = Connection'^a_bd,c' 
	- Connection'^a_bc,d' 
	+ Connection'^a_ec' * Connection'^e_bd' 
	- Connection'^a_ed' * Connection'^e_bc' 
	- Connection'^a_be' * Commutation'_cd^e'

RiemannFromConnection = Tensor'^a_bcd'
RiemannFromConnection['^a_bcd'] = RiemannFromConnection_expr()

printbr((Gamma_'^a_bc'):eq(Connection'^a_bc'()))
printbr((c_'_ab^c'):eq(Commutation'_ab^c'()))
printbr((R_'^a_bcd'):eq(RiemannFromConnection'^a_bcd'()))

printbr"<h3>differences with desired Riemann</h3>"

printbr((RHat_'^a_bcd' - R_'^a_bcd'):eq( (Riemann - RiemannFromConnection)() ))

print(MathJax.footer)
