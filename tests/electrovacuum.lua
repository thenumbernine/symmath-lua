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

local t,x,y,z = vars('t', 'x', 'y', 'z')
local q,m = vars('q', 'm')
local coords = {t,x,y,z}
local spatialCoords = {x,y,z}

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
printbr(var'A''_u':eq(A'_u'()))

local g = Tensor'_uv'
-- hmm, single-variable coordinate sets still need to be specified in what is being assigned ...
-- this is where special treatment for variables among indexes would come in handy
g['_tt'] = Tensor('_tt', function(t,t) return -1 + 2 * A[1] * q / m end)
g['_ti'] = (A'_i' * q / m)()
g['_it'] = (A'_i' * q / m)()
g['_ij'] = deltaL3'_ij'()
printbr(var'g''_uv':eq(g))

--[[ variable
local gU = Tensor('^uv', function(u,v)
	return var('g^{'..coords[u].name..coords[v].name..'}', coords)
end)
--]]
-- [[ eta (near-flat approximation)
local gU = Tensor('^ab', table.unpack(eta))
--]]
--[[ actual inverse.  explicitly specified since my inverse algorithm can't handle it.
local gU = Tensor('^uv', function(u,v)
	local denom = -1 + 2 * A[1] - A[2]^2 - A[3]^2 - A[4]^2
	if u == 1 then
		if v == 1 then
			return 1 / denom
		else
			return -A[v] * q/m / denom
		end
	else
		if v == 1 then
			return -A[u] * q/m / denom
		else
			local result = A[u] * A[v] * q^2/m^2 / denom
			if u == v then result = result - 1 end
			return result
		end
	end
end)
--]]
--	printbr(var'g''^uv':eq(gU))
--	printbr((var'g''_ac' * var'g''^cb'):eq( (g'_ac' * gU'^cb')() ))

local basis = Tensor.metric(g, gU)
--[[
local gU = basis.metricInverse
printbr(gU)
--]]
local GammaL = Tensor'_abc'
GammaL['_abc'] = ((g'_ab,c' + g'_ac,b' - g'_bc,a') / 2)()
printbr(var'\\Gamma''_abc':eq(GammaL'_abc'()))

local E = Tensor('_i', function(i) return var('E_'..spatialCoords[i].name, coords) end)
printbr(var'E''_i':eq(E'_i'()))

local B = Tensor('_i', function(i) return var('B_'..spatialCoords[i].name, coords) end)
printbr(var'B''_i':eq(B'_i'()))

local S = Tensor('_i', function(i) return var('S_'..spatialCoords[i].name, coords) end)
printbr(var'S''_i':eq(S'_i'()))

-- E_i = A_t,i - A_i,t
-- B_i = epsilon_ijk A_k,j
-- A_i,t = A_t,i - E_i
GammaL = GammaL
	:replace(A[2]:diff(t), A[1]:diff(x) - E[1])
	:replace(A[3]:diff(t), A[1]:diff(y) - E[2])
	:replace(A[4]:diff(t), A[1]:diff(z) - E[3])
	:replace(A[4]:diff(y), A[3]:diff(z) + B[1])
	:replace(A[2]:diff(z), A[4]:diff(x) + B[2])
	:replace(A[3]:diff(x), A[2]:diff(y) + B[3])
printbr(var'\\Gamma''_abc':eq(GammaL'_abc'()))

--[[
local Gamma = GammaL'^a_bc'()
printbr(var'\\Gamma''^a_bc':eq(Gamma'^a_bc'()))
--]]

local u = Tensor('^u', function(u)
	-- t approaches 1
	--return u == 1 and 1 or var('u^'..coords[u].name, coords)
	return var('u^'..coords[u].name, coords)
end)

local accel = -GammaL'_abc' * u'^b' * u'^c'
printbr(var'\\dot{u}''_a':eq( -var'\\Gamma''_abc' * var'u''^b' * var'u''^c' ):eq( -GammaL'_abc'() * u'^b'() * u'^c'() ):eq( accel() ))

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

printbr"<h3>electromagnetism stress-energy tensor</h3>"

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

printbr(var'F''_ab':eq(Faraday'_ab'()))
printbr(var'F''^a_b':eq(Faraday'^a_b'()))

local pi = var'\\pi'

local T_EM = Tensor'_ab'
T_EM['_ab'] = ((Faraday'_au' * Faraday'_b^u' - eta'_ab' * Faraday'_uv' * Faraday'^uv' / 4) / (4 * pi))()

printbr(var'T''_ab':eq(T_EM'_ab'()))
printbr(var'T''^a_a':eq( T_EM'^a_a'() ))

local frac = symmath.divOp
printbr(var'G''_ab':eq( 8 * pi * var'T''_ab')) -- G_ab = 8 pi T_ab
printbr(var'G''_ab':eq( var'R''_ab' - frac(1,2) * var'R''^c_c' * var'\\eta''_ab' )) -- G_ab = R_ab - 1/2 R^c_c eta_ab
printbr(var'R''_ab':eq( var'G''_ab' - frac(1,2) * var'G''^c_c' * var'\\eta''_ab' ))	-- R_ab = G_ab - 1/2 G^c_c eta_ab
printbr(var'R''_ab':eq( 8 * pi * var'T''_ab' - 4 * pi * var'T''^c_c' * var'\\eta''_ab'))	-- R_ab = 8 pi T_ab - 4 pi T^c_c eta_ab

local Ricci = Tensor'_ab'
Ricci['_ab'] = (8 * pi * T_EM'_ab' - 4 * pi * T_EM'^c_c' * eta'_ab')()

printbr"<h3>here's the Ricci curvature tensor that matches the Einstein field equations for the electromagnetic stress-energy tensor</h3>"

printbr(var'\\hat{R}''_ab'
	:eq( 8 * pi * var'T''_ab' - 4 * pi * var'T''^c_c' * var'\\eta''_ab')
	:eq(Ricci'_ab'()))

--[[
local ESq_plus_BSq = (E'_k'*E'_k' + B'_k'*B'_k')()

local Ricci = Tensor'_ab'
Ricci['_tt'] = Tensor('_tt', {ESq_plus_BSq})
Ricci['_ti'] = Tensor('_ti', (-2 * S'_i')())
Ricci['_it'] = Tensor('_ti', (-2 * S'_i')())
Ricci['_ij'] = (-2 * E'_i' * E'_j' - 2 * B'_i' * B'_j' + ESq_plus_BSq * deltaL3'_ij')()

printbr(var'\\hat{R}''_ab':eq(Ricci))
--]]

printbr"<h3>here's the constraints that have to be satisfied for the Riemann curvature tensor:</h3>"

local delta_ = var'\\delta'
local epsilon_ = var'\\epsilon'
local E_ = var'E'
local S_ = var'S'
local B_ = var'B'
local R_ = var'R'

printbr(( delta_'_ij' * (E_^2 + B_^2)  - 2 * (E_'_i' * E_'_j' + B_'_i' * B_'_j') ):eq( R_'_ij' ):eq( R_'^a_iaj' ):eq( R_'^t_itj' + R_'^k_ikj' ))
printbr(( E_^2 + B_^2 ):eq( R_'_tt' ):eq( R_'^a_tat' ):eq( R_'^j_tjt' ))
printbr(( -2 * S_'i' ):eq( -2 * epsilon_'_ijk' * E_'_j' * B_'_k' ):eq( R_'_it' ):eq( R_'^j_ijt' ), '$\\approx$', R_'_jijt' :eq( R_'_tjij') )

printbr"<h3>here's a Riemann curvature tensor that gives rise to that Ricci curvature tensor</h3>"

printbr(R_'_tijk':eq( delta_'_ij' * S_'_k' - delta_'_ik' * S_'_j' ))
printbr(R_'_titj':eq(E_'_i' * E_'_j' + B_'_i' * B_'_j'))
printbr(R_'_ijkl':eq(epsilon_'_ijm' * (E_'_m' + B_'_m') * epsilon_'_kln' * (E_'_n' + B_'_n')))

local dual_E_plus_B = Tensor'_ij'
dual_E_plus_B['_ij'] = (LeviCivita3'_ijk' * (E'_k' + B'_k'))()

local dual_E_times_B = (LeviCivita3'_kmn' * E'_m' * B'_n' / 2)()

local S = (LeviCivita3'_ijk' * E'_j' * B'_k')()

local Riemann_t = Tensor'_ijk'
Riemann_t['_ijk'] = (deltaL3'_ij' * S'_k' - deltaL3'_ik' * S'_j')()

local Riemann_tt = Tensor'_ij'
Riemann_tt['_ij'] = (E'_i' * E'_j' + B'_i' * B'_j'
	- E'_i' * B'_j' - B'_i' * E'_j')()

local Riemann = Tensor'_abcd'
-- R_ijkl -- zero 't's
Riemann['_ijkl'] = (
	dual_E_plus_B'_ij' * dual_E_plus_B'_kl' 
	-- + deltaL3'_ik' * (E'_j' * B'_l' + E'_l' * B'_j') / 3
)()
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

local Riemann = Riemann'^a_bcd'()

printbr"<h3>identities...</h3>"

-- should equal delta_ij (E^2 + B^2) - 2 (E_i E_j + B_i B_j)
printbr(R_'^a_iaj':eq(Riemann'^a_iaj'()))
printbr(R_'^a_tat':eq(Riemann'^a_tat'()))
printbr(R_'^a_iat':eq(Riemann'^a_iat'()))

printbr"<h3>building Ricci from Riemann...</h3>"

RicciNew = Riemann'^c_acb'()
printbr(R_'_ab':eq(RicciNew))

printbr"<h3>desired Ricci, once again:</h3>"
printbr(var'\\hat{R}''_ab':eq(Ricci)
	--:replace(B[2]*E[2], -B[1]*E[1]-B[3]*E[3])()
)

printbr"<h3>differences with the desired Ricci:</h3>"
printbr((var'\\hat{R}''_ab' - R_'_ab'):eq(
	(Ricci - RicciNew)()
))

printbr"<h3>Riemann tensor constraints that need to be fulfilled:</h3>"

printbr((R_'_abcd' + R_'_abdc'):eq( (Riemann'_abcd' + Riemann'_abdc')() ))
printbr((R_'_abcd' + R_'_bacd'):eq( (Riemann'_abcd' + Riemann'_bacd')() ))
printbr((R_'_abcd' - R_'_cdab'):eq( (Riemann'_abcd' - Riemann'_cdab')() ))

print(MathJax.footer)
