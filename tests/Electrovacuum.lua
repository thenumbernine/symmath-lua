#! /usr/bin/env luajit
require 'ext'
require 'symmath'.setup() --{implicitVars=true}
require 'symmath.tostring.MathJax'.setup{title='Electrovacuum solutions', usePartialLHSForDerivative=true}

local showLorentzMetric = false
local showFlatSpaceApproximationRiemannSolution = true

--local flatSpace = 'cartesian'
--local flatSpace = 'spherical'
local flatSpace = 'cylindrical'

local t = var't'
local q,m = vars('q', 'm')
local x,y,z = vars('x', 'y', 'z')
local r,theta,phi = vars('r', '\\theta', '\\phi')

local spatialCoords
if flatSpace == 'cartesian' then
	spatialCoords = {x,y,z}
elseif flatSpace == 'spherical' then
	spatialCoords = {r,theta,phi}
elseif flatSpace == 'cylindrical' then
	spatialCoords = {r,phi,z}
end

local coords = table{t}:append(spatialCoords)

local pi = var'\\pi'

-- used for output
local A_ = var'A'
local B_ = var'B'
local E_ = var'E'
local F_ = var'F'
local G_ = var'G'
local J_ = var'J'
local P_ = var'P'
local R_ = var'R'
local S_ = var'S'
local T_ = var'T'
local c_ = var'c'
local g_ = var'g'
local u_ = var'u'
local Gamma_ = var'\\Gamma'
local gamma_ = var'\\gamma'
local delta_ = var'\\delta'
local eta_ = var'\\eta'
local epsilon_ = var'\\epsilon'
local RHat_ = var'\\hat{R}'

local A
local E
local B
local S
local g, gU
local Faraday
local Connection
local Commutation
local GammaL
local Riemann
local RiemannFromConnection
local Ricci
local gamma, gammaU
local deltaL3
local LeviCivita3
local LeviCivita4
local eta

local function pretty(expr)
	return expr
		:replace(A,A_)
		:replace(E,E_)
		:replace(B,B_)
		:replace(P,P_)
		:replace(S,S_)
		:replace(g,g_)
		:replace(gU,g_)
		:replace(Faraday,F_)
		:replace(Connection,Gamma_)
		:replace(Commutation,c_)
		:replace(GammaL, Gamma_)	
		:replace(Riemann,R_)
		:replace(RiemannFromConnection,R_)
		:replace(Ricci,R_)
		:replace(gamma,gamma_)
		:replace(gammaU,gamma_)
		:replace(deltaL3,delta_)
		:replace(LeviCivita3,epsilon_)
		:replace(LeviCivita4,epsilon_)
		:replace(eta,eta_)
end


Tensor.coords{
	{variables=coords},
	{symbols='ijklmn', variables=spatialCoords},
	{symbols='t', variables={t}},
	{symbols='x', variables={x}},
	{symbols='y', variables={y}},
	{symbols='z', variables={z}},
}
	
g = Tensor'_uv'
gU = Tensor'^uv'
gamma = Tensor'_ij'
gammaU = Tensor'^ij'

--[[
TODO 
- get the basis of the index
- get the rank and determinant of basis metric
--]]
local function makeLeviCivita(index, sqrt_det_g)
	return Tensor('_abcd', function(a,b,c,d)
		local indexes = {a,b,c,d}
		-- duplicates mean 0
		for i=1,#indexes-1 do
			for j=i+1,#indexes do
				if indexes[i] == indexes[j] then return 0 end
			end
		end
		-- bubble sort, count the flips
		local parity = 1
		for i=1,#indexes-1 do
			for j=1,#indexes-i do
				if indexes[j] > indexes[j+1] then
					indexes[j], indexes[j+1] = indexes[j+1], indexes[j]
					parity = -parity
				end
			end
		end
		return (parity * clone(sqrt_det_g))()
	end)
end

eta = Tensor('_uv', function(u,v)
	return u == v and (u == 1 and -1 or 1) or 0
end)

deltaL3 = Tensor('_ij', function(i,j) return i == j and 1 or 0 end)

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
A = Tensor('_u', function(u) return var('A_'..coords[u].name, coords) end)
printbr(A_'_u':eq(A'_u'()))

E = Tensor('_i', function(i) return var('E_'..spatialCoords[i].name, coords) end)
printbr(E_'_i':eq(E'_i'()))

B = Tensor('_i', function(i) return var('B_'..spatialCoords[i].name, coords) end)
printbr(B_'_i':eq(B'_i'()))

S = Tensor('_i', function(i) return var('S_'..spatialCoords[i].name, coords) end)
printbr(S_'_i':eq(S'_i'()))

if showLorentzMetric then
	
	-- E_i = A_t,i - A_i,t
	-- B_i = epsilon_i^jk A_k,j
	-- A_i,t = A_t,i - E_i
	-- should there be components of g_uv in here too?  
	-- yes, because epsilon_ijk = sqrt|g| epsilon_IJK
	-- therefore this definition is incorrect
	local function replacePotentialsWithFields(expr)
		local x1,x2,x3 = table.unpack(spatialCoords)
		return expr	
			:replace(A[2]:diff(t), A[1]:diff(x1) - E[1])
			:replace(A[3]:diff(t), A[1]:diff(x2) - E[2])
			:replace(A[4]:diff(t), A[1]:diff(x3) - E[3])
			
			:replace(A[1]:diff(x1), A[2]:diff(t) + E[1])
			:replace(A[1]:diff(x2), A[3]:diff(t) + E[2])
			:replace(A[1]:diff(x3), A[4]:diff(t) + E[3])
			
			:replace(A[4]:diff(x2), A[3]:diff(x3) + B[1])
			:replace(A[2]:diff(x3), A[4]:diff(x1) + B[2])
			:replace(A[3]:diff(x1), A[2]:diff(x2) + B[3])

			:replace(A[3]:diff(x3), A[4]:diff(x2) - B[1])
			:replace(A[4]:diff(x1), A[2]:diff(x3) - B[2])
			:replace(A[2]:diff(x2), A[3]:diff(x1) - B[3])
	end
	
	printbr"<h3>here's a metric that gives rise to geodesics equal to the Lorentz force law, up to a scalar</h3>"

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

	GammaL = Tensor'_abc'
	GammaL['_abc'] = ((g'_ab,c' + g'_ac,b' - g'_bc,a') / 2)()
	printbr(Gamma_'_abc':eq(GammaL'_abc'()))

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

	--[[
	printbr"<h3>Connection coefficients</h3>"

	local Gamma = GammaL'^a_bc'()
	printbr(Gamma_'^a_bc':eq(Gamma'^a_bc'()))

	local props = require 'symmath.physics.diffgeom'(g)
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
end
if showFlatSpaceApproximationRiemannSolution then
	printbr"<h3>Looking for a Riemann (and then a Christoffel) that gives rise to the electromagnetism stress-energy tensor</h3>"

	if flatSpace == 'cartesian' then
		g['_ab'] = eta'_ab'()	-- cartesian
	elseif flatSpace == 'spherical' then
		g['_ab'] = Tensor('_ab', table.unpack(Matrix.diagonal(-1, 1, r^2, r^2 * sin(theta)^2)))
	elseif flatSpace == 'cylindrical' then
		g['_ab'] = Tensor('_ab', table.unpack(Matrix.diagonal(-1, 1, r^2, 1))) 
	end
	printbr('using ', g_'_ab':eq(g'_ab'()))

	gamma['_ij'] = g'_ij'()
	printbr(gamma_'_ij':eq(gamma'_ij'()))

	local sqrt_det_g = sqrt(-Matrix.determinant(g))()
	printbr('$\\sqrt{-g} =$ '..sqrt_det_g)

	local sqrt_det_gamma = sqrt(Matrix.determinant(gamma))()
	printbr('$\\sqrt{\\gamma} =$ '..sqrt_det_gamma)

	Tensor.metric(g)
	Tensor.metric(gamma, nil, 'i')

	LeviCivita3 = Tensor('_ijk', function(i,j,k)
		if i%3+1 == j and j%3+1 == k then return sqrt_det_gamma end
		if k%3+1 == j and j%3+1 == i then return -sqrt_det_gamma end
		return 0
	end)
	printbr(epsilon_'_ijk':eq(LeviCivita3))

	LeviCivita4 = makeLeviCivita('a', sqrt_det_g)
	printbr(epsilon_'_abcd':eq(LeviCivita4))


	Faraday = Tensor'_ab'
	--[[ defined piecewise, which looks to give it the correct del operator
	printbr"Faraday defined from explicit E's and B's"
	Faraday['_ti'] = Tensor('_ti', (-E'_i')())
	Faraday['_it'] = Tensor('_ti', E'_i'())
	Faraday['_ij'] = (LeviCivita3'_ij^k' * B'_k')()
	printbr(F_'_ab':eq(Faraday'_ab'()))
	printbr"Faraday defined from A's"
	--]]

	-- [[ define by F_uv = 2 A_[v,u]
	-- works for curved space: A_[v;u] = A_[v,u]
	local Faraday_potential_expr = A'_b,a' - A'_a,b'
	Faraday['_ab'] = Faraday_potential_expr()
	printbr(F_'_ab':eq(pretty(Faraday_potential_expr)))
	printbr(F_'_ab':eq(Faraday'_ab'()))

	do
		--[[ TODO FIXME error on the second *identical* line ... something must be changing state ...
		local expr = A'_k,j'
		expr()
		expr()	--error
		--]]

		local B_from_A_expr = LeviCivita3'_i^jk' * A'_k,j'
		printbr(B_'_i':eq(pretty(B_from_A_expr)))
		B_from_A_expr = B_from_A_expr()
		local eqn = (B'_i'()):eq(B_from_A_expr)
		printbr(eqn)
		local eqns = range(#B):map(function(i)
			-- TODO solve eqn:lhs()[i]:eq(eqn:rhs()[i]) for A[3]:diff(spatialCoords[2])
			local lhs = B[i]	-- B_i
			local rhs = eqn:rhs()[i]
			-- hack in the mean time ...
			local eqn = lhs:eq(rhs)
			if op.div.is(rhs) then
				eqn = (eqn * rhs[2]:clone())()
			elseif op.mul.is(rhs) then
				eqn = (eqn / rhs[1]:clone())()
			end
			eqn = (eqn + A[i%3+2]:diff(spatialCoords[(i+1)%3+1]))()
			eqn = eqn:switch()
			assert(Derivative.is(eqn:lhs()))
			printbr(eqn)
			return eqn
		end)

		local function replacePotentialsWithFields(expr)
			local x1,x2,x3 = table.unpack(spatialCoords)
			return expr
				:replace(A[2]:diff(t), A[1]:diff(x1) - E[1])
				:replace(A[3]:diff(t), A[1]:diff(x2) - E[2])
				:replace(A[4]:diff(t), A[1]:diff(x3) - E[3])
				
				:replace(A[1]:diff(x1), A[2]:diff(t) + E[1])
				:replace(A[1]:diff(x2), A[3]:diff(t) + E[2])
				:replace(A[1]:diff(x3), A[4]:diff(t) + E[3])
				
				:subst(eqns[1])
				:subst(eqns[2])
				:subst(eqns[3])
		end

		Faraday = replacePotentialsWithFields(Faraday)
		printbr(F_'_ab':eq(Faraday'_ab'()))
	end
	--]]

	printbr()
	printbr'raising:'
	printbr(F_'_a^b':eq(Faraday'_a^b'()))
	printbr(F_'^ab':eq(Faraday'^ab'()))

	printbr()
	printbr'dual:'
	local dualFaraday = Tensor'_uv'
	local dualFaraday_expr = frac(1,2) * Faraday'^ab' * LeviCivita4'_abuv'
	dualFaraday['_uv'] = dualFaraday_expr()	-- does simplify() modifies the expr?
	printbr(var'\\star F''_uv'
		-- why isn't pretty() producing this from expr?
		:eq(frac(1,2) * var'F''^ab' * var'\\epsilon''_abuv')
		:eq(dualFaraday'_uv'()))

	-- make sure the identities form the Maxwell equations 
	local J = Tensor('^u', function(u) 
		if u == 1 then return var'\\rho' end	
		return var('j^'..coords[u].name) 
	end)

	printbr()
	printbr"Maxwell's laws in flat space (i.e. excluding connection terms) in covariant form:"
	printbr(F_'_uv^,v':eq(4*pi*J_'_u'))
	printbr(var'\\star F''_uv^,v':eq(0))
	printbr(F_'_uv^,v':eq( Faraday'_uv^,v'():factorDivision():tidy()):eq( (4*pi*J'_u')() ))
	printbr(var'\\star F''_uv^,v':eq( dualFaraday'_uv^,v'():factorDivision():tidy()):eq( Tensor'_u'() ))

	printbr()
	printbr"Maxwell's laws in flat space (i.e. excluding connection terms) contravariant form:"
	printbr(F_'^uv_,v':eq(4*pi*J_'^u'))
	printbr(var'\\star F''^uv_,v':eq(0))

	printbr()
	printbr"Maxwell's laws in curved space in contravariant form:"
	local divLnG = Tensor('_a', function(a) return log(sqrt_det_g):diff(coords[a]) end)
	printbr(F_'^uv_;v'
		:eq( F_'^uv_,v' + F_'^uv' * Gamma_'^a_va')
		:eq( F_'^uv_,v' + F_'^uv' * sqrt(log(-g_))',v')
		:eq( (Faraday'^uv_,v' + Faraday'^uv' * divLnG'_v')():factorDivision():tidy() )
		:eq( 4 * pi * J_'^u' )
	)
	printbr(var'\\star F''^uv_;v'
		:eq( (dualFaraday'^uv_,v' + dualFaraday'^uv' * divLnG'_v')():factorDivision():tidy() )
		:eq( Tensor'^u' )
	)

	-- contracted terms of the stress-energy tensor
	printbr((F_'_au' * F_'_b^u'):eq( (Faraday'_au' * Faraday'_b^u')() ))
	printbr(( F_'_uv' * F_'^uv' ):eq( (Faraday'_uv' * Faraday'^uv')() ))

	local T_EM = Tensor'_ab'
	local T_EM_expr = frac(1, 4 * pi) * (Faraday'_au' * Faraday'_b^u' - frac(1,4) * g'_ab' * Faraday'_uv' * Faraday'^uv')
	T_EM['_ab'] = T_EM_expr()

	printbr(T_'_ab':eq(pretty(T_EM_expr)))
	printbr(T_'_ab':eq(T_EM'_ab'()))
	printbr(T_'^a_a':eq( T_EM'^a_a'()))

	printbr(G_'_ab':eq( 8 * pi * T_'_ab')) -- G_ab = 8 pi T_ab
	printbr(G_'_ab':eq( R_'_ab' - frac(1,2) * R_'^c_c' * g_'_ab' )) -- G_ab = R_ab - 1/2 R^c_c g_ab
	printbr(R_'_ab':eq( G_'_ab' - frac(1,2) * G_'^c_c' * g_'_ab' ))	-- R_ab = G_ab - 1/2 G^c_c g_ab
	printbr(R_'_ab':eq( 8 * pi * T_'_ab' - 4 * pi * T_'^c_c' * g_'_ab'))	-- R_ab = 8 pi T_ab - 4 pi T^c_c g_ab

	Ricci = Tensor'_ab'
	Ricci['_ab'] = (8 * pi * T_EM'_ab' - 4 * pi * T_EM'^c_c' * g'_ab')()
	printbr(var'R''_ab':eq(Ricci'_ab'()))

	printbr"<h3>here's the Ricci curvature tensor that matches the Einstein field equations for the electromagnetic stress-energy tensor (in Cartesian coordinates)</h3>"

	printbr(( R_'_tt' ):eq( E_^2 + B_^2 ))
	printbr(( R_'_it' ):eq( -2 * S_'_i' ):eq( -2 * epsilon_'_i^jk' * E_'_j' * B_'_k' ))
	printbr(( R_'_ij' ):eq( gamma_'_ij' * (E_^2 + B_^2)  - 2 * (E_'_i' * E_'_j' + B_'_i' * B_'_j') ))

	printbr(RHat_'_ab'
		:eq( 8 * pi * T_'_ab' - 4 * pi * T_'^c_c' * g_'_ab')
		:eq( Ricci'_ab'():factorDivision():tidy() ))

	--[[
	local ESq_plus_BSq = (E'_k'*E'_k' + B'_k'*B'_k')()

	local Ricci = Tensor'_ab'
	Ricci['_tt'] = Tensor('_tt', {ESq_plus_BSq})
	Ricci['_ti'] = Tensor('_ti', (-2 * S'_i')())
	Ricci['_it'] = Tensor('_ti', (-2 * S'_i')())
	Ricci['_ij'] = (-2 * E'_i' * E'_j' - 2 * B'_i' * B'_j' + ESq_plus_BSq * gamma'_ij')()

	printbr(RHat_'_ab':eq(Ricci))
	--]]

	printbr"<h3>here's the constraints that have to be satisfied for the Riemann curvature tensor:</h3>"

	S = (LeviCivita3'_i^jk' * E'_j' * B'_k')()

	printbr(( R_'_tt' ):eq( E_^2 + B_^2 ):eq( R_'^a_tat' ):eq( R_'^t_ttt' + R_'^j_tjt' ):eq( R_'^j_tjt' ):eq( g_'^jt' * R_'_ttjt' + g_'^jk' * R_'_ktjt' ):eq( g_'^jk' * R_'_ktjt' ))
	printbr(( R_'_it' ):eq( -2 * S_'_i' ):eq( -2 * epsilon_'_i^jk' * E_'_j' * B_'_k' ):eq( R_'^a_iat' ):eq( R_'^t_itt' + R_'^j_ijt' ):eq( R_'^j_ijt' ):eq( g_'^jt' * R_'_tijt' + g_'^jk' * R_'_kijt' ))
	printbr(( R_'_ij' ):eq( gamma_'_ij' * (E_^2 + B_^2)  - 2 * (E_'_i' * E_'_j' + B_'_i' * B_'_j') ):eq( R_'^a_iaj' ):eq( R_'^t_itj' + R_'^k_ikj' )
		:eq( g_'^tt' * R_'_titj' + g_'^tk' * R_'_kitj' + g_'^kt' * R_'_tikj' + g_'^kl' * R_'_likj' )
		:eq( g_'^tt' * R_'_titj' + g_'^kl' * R_'_likj' + g_'^tk' * (R_'_tjki' + R_'_tikj') ))

	printbr"<h3>here's a Riemann curvature tensor that gives rise to that Ricci curvature tensor, subject to $g^{ab} \\approx \\eta^{ab}$ </h3>"

	-- the last "2/3 E dot B" is used to eliminate the "-2 E dot B" difference left between R_tt and Rhat_tt ... need to divide by 3 because the tensor is traced
	--[[
	options for R_titj:
	E_i E_j + B_i B_j - E_i B_j B_i E_j gives a difference of R_ab += -2 E dot B eta_ab
	... - 2/3 delta_ij E dot B ... R_ii += -4/3 E dot B
	... + 2 delta_ij E dot B ... R_tt += -4 E dot B 
	--]]

	--[[ option #1 -- leaves Rhat_tt - R_tt = -4 E dot b
	local Riemann_titj_expr = E'_i' * E'_j' + B'_i' * B'_j' - E'_i' * B'_j' - B'_i' * E'_j' + 2 * gamma'_ij' * E'_k' * B'_k'
	local Riemann_tijk_expr = gamma'_ij' * S'_k' - gamma'_ik' * S'_j'
	local Riemann_ijkl_expr = LeviCivita3'_ijm' * (E'_m' + B'_m') * LeviCivita3'_kln' * (E'_n' + B'_n')
	--]]
	--[[ option #2 -- leaves Rhat_ii - R_ii = -4/3 E dot B
	local Riemann_titj_expr = E'_i' * E'_j' + B'_i' * B'_j' - E'_i' * B'_j' - B'_i' * E'_j' + frac(2,3) * gamma'_ij' * E'_k' * B'_k'
	local Riemann_tijk_expr = gamma'_ij' * S'_k' - gamma'_ik' * S'_j'
	local Riemann_ijkl_expr = LeviCivita3'_ijm' * (E'_m' + B'_m') * LeviCivita3'_kln' * (E'_n' + B'_n')
	--]]
	--[[ option #3 -- leaves Rhat_ab - R_ab = -2 eta E dot B
	local Riemann_titj_expr = E'_i' * E'_j' + B'_i' * B'_j' - E'_i' * B'_j' - B'_i' * E'_j'
	local Riemann_tijk_expr = gamma'_ij' * S'_k' - gamma'_ik' * S'_j'
	local Riemann_ijkl_expr = LeviCivita3'_ijm' * (E'_m' + B'_m') * LeviCivita3'_kln' * (E'_n' + B'_n')
	--]]
	-- [[ option #4 -- works -- Rhat_ab - R_ab = 0 
	local Riemann_titj_expr = E'_i' * E'_j' + B'_i' * B'_j'
	local Riemann_tijk_expr = gamma'_ij' * S'_k' - gamma'_ik' * S'_j'	-- = (delta_ij delta_lk - delta_ik delta_lj) epsilon_lmn E_m B_n = delta^il_jk epsilon_lmn E_m B_n = epsilon_ilw epsilon_jkw epsilon_lpq E_p B_q
	local Riemann_ijkl_expr = LeviCivita3'_ij^m' * LeviCivita3'_kl^n' * (E'_m' * E'_n' + B'_m' * B'_n')
	--]]
	--[[ option #5
	local Riemann_titj_expr = E'_i' * E'_j' + B'_i' * B'_j' - E'_i' * B'_j' - B'_i' * E'_j'
	local Riemann_tijk_expr = gamma'_ij' * S'_k' - gamma'_ik' * S'_j'
	local Riemann_ijkl_expr = (gamma'_ij' * gamma'_km' * gamma'_ln' - frac(2,3) * gamma'_kl' * gamma'_im' * gamma'_jn') * (E'_m' * E'_n' + B'_m' * B'_n')
	--]]
	--[[ option #6 - spinoff of option #4 which works, but switches j & l so the Levi-Civita symbols line up with the connection coefficients of R^a_bcd
	-- RHat_ab - R_ab = eta_ab (E^2 + B^2) and the Riemann constraints are not fulfilled
	local Riemann_titj_expr = 3 * (E'_i' * E'_j' + B'_i' * B'_j')
	local Riemann_tijk_expr = gamma'_ij' * S'_k' - gamma'_ik' * S'_j'	-- = (delta_ij delta_lk - delta_ik delta_lj) epsilon_lmn E_m B_n = delta^il_jk epsilon_lmn E_m B_n = epsilon_ilw epsilon_jkw epsilon_lpq E_p B_q
	local Riemann_ijkl_expr = LeviCivita3'_ilm' * LeviCivita3'_jkn' * (E'_m' * E'_n' + B'_m' * B'_n')
	--]]

	local Riemann_tt = Tensor'_ij'
	Riemann_tt['_ij'] = Riemann_titj_expr()

	local Riemann_t = Tensor'_ijk'
	Riemann_t['_ijk'] = Riemann_tijk_expr()
	
	printbr(R_'_titj':eq( pretty(Riemann_titj_expr) ))
	printbr(R_'_tijk':eq( pretty(Riemann_tijk_expr) ))
	printbr(R_'_ijkl':eq( pretty(Riemann_ijkl_expr) ))

	-- R_ijkl -- zero 't's
	Riemann = Tensor'_abcd'
	Riemann['_ijkl'] = Riemann_ijkl_expr()

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

	printbr(R_'^a_tat':eq( Riemann'^a_tat'():factorDivision():tidy() ))
	printbr(R_'^a_iat':eq( Riemann'^a_iat'():factorDivision():tidy() ))
	printbr(R_'^a_iaj':eq( Riemann'^a_iaj'():factorDivision():tidy() ))

	local function isZero(t)
		for k,v in t:iter() do
			if not Constant.is(v) then return false end
			if v.value ~= 0 then return false end
		end
		return true
	end

	local function conciseZero(x)
		return isZero(x) and 0 or x
	end

	printbr"<h3>building Ricci from Riemann...</h3>"

	RicciFromRiemann = Riemann'^c_acb'()
	printbr(R_'_ab':eq(RicciFromRiemann))

	printbr"<h3>differences with the desired Ricci:</h3>"

	printbr((RHat_'_ab' - R_'_ab'):eq( conciseZero( (Ricci - RicciFromRiemann)() ) ))

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
	printbr((R_'_abcd' + R_'_abdc'):eq( conciseZero( (Riemann'_abcd' + Riemann'_abdc')() ) ))
	printbr((R_'_abcd' + R_'_bacd'):eq( conciseZero( (Riemann'_abcd' + Riemann'_bacd')() ) ))
	printbr((R_'_abcd' - R_'_cdab'):eq( conciseZero( (Riemann'_abcd' - Riemann'_cdab')() ) ))
	--]]

	-- TODO this makes more sense in curved space
	--printbr( (R_'^a_bcd;e' + R_'^a_bec;d' + R_'^a_bde;c'):eq( (Riemann'^a_bcd;e' + Riemann'^a_bec;d' + Riemann'^a_bde;c')() ) )

	printbr"<h3>removing $g^{ab} \\approx \\eta^{ab}$</h3>"

	printbr(( R_'^t_itj' ):eq( pretty(-E'_i' * E'_j' - B'_i' * B'_j') ))
	printbr(( R_'^t_ijk' ):eq( pretty(gamma'_ik' * S'_j' - gamma'_ij' * S'_k' ) ))
	printbr(( R_'^i_jkl' ):eq( pretty(LeviCivita3'^i_j^m' * LeviCivita3'_kl^n' * (E'_m' * E'_n' + B'_m' * B'_n')) ))

	--[[
	printbr"<h3>...in terms of four-potential</h3>"

	-- TODO replace E's and B's to get A's
	printbr(( R_'^t_itj' ):eq( pretty(-(A'_t,i' - A'_i,t') * (A'_t,j' - A'_j,t') - LeviCivita3'_i^mn' * A'_n,m' * LeviCivita3'_j^pq' * A'_q,p') ))
	printbr(( R_'^t_ijk' ):eq( pretty(gamma'_ik' * S'_j' - gamma'_ij' * S'_k' ) ))
	printbr(( R_'^i_jkl' ):eq( pretty(LeviCivita3'^i_j^m' * LeviCivita3'_kl^n' * (E'_m' * E'_n' + B'_m' * B'_n')) ))	-- and replace E's and B's with A's 
	--]]

	printbr"<h3>Rewriting sum of norms as a product of tensor</h3>"

	--global
	P = Tensor('_ij', function(i,j)
		if j==1 then return E[i] end
		if j==2 then return B[i] end
		return 0
	end)
	printbr(var'P''_ij':eq(P'_ij'()))

	printbr((var'P''_i^k' * var'P''_jk'):eq( (P'_i^k'*P'_jk')() ))

	printbr(( R_'^t_itj' ):eq( pretty(-P'_i^k' * P'_jk') ))
	printbr(( R_'^t_ijk' ):eq( pretty(gamma'_ik' * S'_j' - gamma'_ij' * S'_k' ) ))
	printbr(( R_'^i_jkl' ):eq( pretty(LeviCivita3'^i_jm' * LeviCivita3'_kln' * P'^mr' * P'^n_r') ))



	printbr"<h3>connections that give rise to Riemann tensor</h3>"

	printbr(R_'^t_itj':eq( 
		-E_'_i' * E_'_j' - B_'_i' * B_'_j'
	):eq(
		Gamma_'^t_ij,t' - Gamma_'^t_it,j' + Gamma_'^t_at' * Gamma_'^a_ij' - Gamma_'^t_aj' * Gamma_'^a_it' - Gamma_'^t_ia' * c_'_tj^a'
	):eq(
		Gamma_'^t_ij,t' - Gamma_'^t_it,j' 
		+ Gamma_'^t_tt' * Gamma_'^t_ij' 
		+ Gamma_'^t_kt' * Gamma_'^k_ij' 
		- Gamma_'^t_tj' * Gamma_'^t_it'
		- Gamma_'^t_kj' * Gamma_'^k_it'
		- Gamma_'^t_it' * c_'_tj^t'
		- Gamma_'^t_ik' * c_'_tj^k'
	))
	printbr(R_'^t_ijk':eq( 
		gamma_'_ik' * S_'_j' - gamma_'_ij' * S_'_k' 
	):eq(
		-epsilon_'_i^nm' * epsilon_'_jkm' * epsilon_'_n^pq' * E_'_p' * B_'_q'
	):eq(
		Gamma_'^t_ik,j' - Gamma_'^t_ij,k' + Gamma_'^t_aj' * Gamma_'^a_ik' - Gamma_'^t_ak' * Gamma_'^a_ij' - Gamma_'^t_ia' * c_'_jk^a'
	):eq(
		Gamma_'^t_ik,j' - Gamma_'^t_ij,k' 
		+ Gamma_'^t_tj' * Gamma_'^t_ik' 
		+ Gamma_'^t_lj' * Gamma_'^l_ik' 
		- Gamma_'^t_tk' * Gamma_'^t_ij'
		- Gamma_'^t_lk' * Gamma_'^l_ij'
		- Gamma_'^t_it' * c_'_jk^t'
		- Gamma_'^t_il' * c_'_jk^l'
	))
	printbr(R_'^i_jkl':eq( 
		epsilon_'^i_j^m' * epsilon_'_kl^n' * (E_'_m' * E_'_n' + B_'_m' * B_'_n')
	):eq(
		Gamma_'^i_jl,k' - Gamma_'^i_jk,l' + Gamma_'^i_ak' * Gamma_'^a_jl' - Gamma_'^i_al' * Gamma_'^a_jk' - Gamma_'^i_ja' * c_'_kl^a'
	):eq(
		Gamma_'^i_jl,k' - Gamma_'^i_jk,l' 
		+ Gamma_'^i_tk' * Gamma_'^t_jl' 
		+ Gamma_'^i_mk' * Gamma_'^m_jl' 
		- Gamma_'^i_tl' * Gamma_'^t_jk'
		- Gamma_'^i_ml' * Gamma_'^m_jk'
		- Gamma_'^i_jt' * c_'_kl^t'
		- Gamma_'^i_jm' * c_'_kl^m'
	))
end

if false then
	printbr[[<h3>Riemann curvature for $E=\hat{x}$ and $B=\hat{y}$</h3>]]

	-- local, not global, so I don't overwrite the vars
	-- this means pretty will ignore this E
	-- to fix that, push and pop the old, and replace it (don't use local)
	local E = Tensor('_i', var'E_x',0,0)
	local B = Tensor('_i', 0,var'B_y',0)
	local S = Tensor('_i', 0,0,var'S_z')

	--global
	P = Tensor('_ij', function(i,j)
		if j==1 then return E[i] end
		if j==2 then return B[i] end
		return 0
	end)
	printbr(var'P''_ij':eq(P'_ij'()))
	printbr((var'P''_i^k' * var'P''_jk'):eq( (P'_i^k'*P'_jk')() ))

	printbr(( R_'^t_itj' ):eq( -P_'_i^k' * P_'_jk') )
	printbr(( R_'^t_ijk' ):eq( gamma_'_ik' * S_'_j' - gamma_'_ij' * S_'_k' ))
	printbr(( R_'^i_jkl' ):eq( epsilon_'^i_jm' * epsilon_'_kln' * P_'^mr' * P_'^n_r' ))

	local Riemann_Ut_itj_expr = -E'_i' * E'_j' - B'_i' * B'_j'
	local Riemann_Ut_ijk_expr = gamma'_ik' * S'_j' - gamma'_ij' * S'_k'	-- = -(delta_ij delta_lk - delta_ik delta_lj) epsilon_lmn E_m B_n = delta^il_jk epsilon_lmn E_m B_n = epsilon_ilw epsilon_jkw epsilon_lpq E_p B_q
	local Riemann_Ui_jkl_expr = LeviCivita3'_ij^m' * LeviCivita3'_kl^n' * (E'_m' * E'_n' + B'_m' * B'_n')
		
	local Riemann_Ut_t = Tensor'_ij'
	Riemann_Ut_t['_ij'] = Riemann_Ut_itj_expr()
	
	local Riemann_Ut = Tensor'_ijk'
	Riemann_Ut['_ijk'] = Riemann_Ut_ijk_expr()
	
	Riemann = Tensor'^a_bcd'
	Riemann['^i_jkl'] = Riemann_Ui_jkl_expr()

	-- R_tijk -- one 't's
	Riemann['^t_ijk'] = Tensor('^t_ijk', function(t,i,j,k) return Riemann_Ut[i][j][k] end)
	Riemann['^i_tjk'] = Tensor('^i_tjk', function(i,t,j,k) return -Riemann_Ut[i][j][k] end)
	Riemann['^j_kti'] = Tensor('^j_kti', function(j,k,t,i) return Riemann_Ut[i][j][k] end)
	Riemann['^j_kit'] = Tensor('^j_kit', function(j,k,i,t) return -Riemann_Ut[i][j][k] end)
	-- R_titj -- two 't's
	Riemann['^t_itj'] = Tensor('^t_itj', function(t,i,t,j) return Riemann_Ut_t[i][j] end)
	Riemann['^t_ijt'] = Tensor('^t_ijt', function(t,i,j,t) return -Riemann_Ut_t[i][j] end)
	Riemann['^i_ttj'] = Tensor('^i_ttj', function(i,t,t,j) return -Riemann_Ut_t[i][j] end)
	Riemann['^i_tjt'] = Tensor('^i_tjt', function(i,t,j,t) return Riemann_Ut_t[i][j] end)
	-- ... and 3 't's and 4 't's is always zero ...

	printbr(R_'^a_bcd':eq(Riemann))
	
	printbr'...compared to SO(3) connection...'

	printbr'versus Riemann curvature of a SO(3) group'
	
	--local CommSO3 = Tensor'_ab^c'
	--CommSO3['_ij^k'] = (2 * LeviCivita3'_ijk')()
	--printbr(c_'_ij^k':eq(2 * epsilon_'_ijk'))
	local CommSO3 = Tensor('_ab^c', function(a,b,c)
		-- if a==1 or b==1 or c==1 or d==1 then return 0 end	-- skipping timelike
		if a == b then return 0 end
		local sign = 1
		if a > b then a,b,sign = b,a,-1 end
		return sign * var('{c_{'..coords[a].name..coords[b].name..'}}^{'..coords[c].name..'}')
	end)
-- [[ timelike zero
CommSO3['_ta^b'] = Tensor'_ta^b'
CommSO3['_at^b'] = Tensor'_at^b'
CommSO3['_ab^t'] = Tensor'_ab^t'
--]]
--[[ square zero
CommSO3['_xy^x'] = Tensor'_xy^x'
CommSO3['_yx^x'] = Tensor'_yx^x'
CommSO3['_xz^x'] = Tensor'_xz^x'
CommSO3['_zx^x'] = Tensor'_zx^x'
CommSO3['_yz^y'] = Tensor'_yz^y'
CommSO3['_zy^y'] = Tensor'_zy^y'
--]]
-- timelike zero + square zero leaves us with c_yz^x c_xz^y = -4 Ex^2 = -4 By^2 ...
-- if it's not c_yz^x c_xz^y then it has to be the time components ...
--[[
CommSO3['_tz^x'] = Tensor('_tz^x', function() return 2 * B[2] end)
CommSO3['_zt^x'] = Tensor('_zt^x', function() return 2 * -B[2] end)
CommSO3['_xz^t'] = Tensor('_xz^t', function() return -2 * B[2] end)
CommSO3['_zx^t'] = Tensor('_zx^t', function() return 2 * B[2] end)
CommSO3['_tz^y'] = Tensor('_tz^y', function() return 2 * E[1] end)
CommSO3['_zt^y'] = Tensor('_zt^y', function() return -2 * E[1] end)
CommSO3['_yz^t'] = Tensor('_yz^t', function() return -2 * E[1] end)
CommSO3['_zy^t'] = Tensor('_zy^t', function() return 2 * E[1] end)
--]]	
-- but these can't be used because they cause the 0= constraints to be nonzero ...
--[[
CommSO3['_xy^z'] = Tensor'_xy^z'
CommSO3['_yx^z'] = Tensor'_yx^z'
CommSO3['_xz^y'] = Tensor'_xz^y'
CommSO3['_zx^y'] = Tensor'_zx^y'
CommSO3['_yz^x'] = Tensor'_yz^x'
CommSO3['_zy^x'] = Tensor'_zy^x'
--]]
--[[
CommSO3['_xz^z'] = Tensor'_xz^z'
CommSO3['_zx^z'] = Tensor'_zx^z'
CommSO3['_yz^z'] = Tensor'_yz^z'
CommSO3['_zy^z'] = Tensor'_zy^z'
CommSO3['_xy^x'] = Tensor'_xy^x'
CommSO3['_yx^x'] = Tensor'_yx^x'
CommSO3['_xy^y'] = Tensor'_xy^y'
CommSO3['_yx^y'] = Tensor'_yx^y'
--[[ 
local _i_ = var'i'
CommSO3['_xz^x'] = Tensor('_xz^x', function() return _i_ * B[2] end)
CommSO3['_zx^x'] = Tensor('_zx^x', function() return -_i_ * B[2] end)
CommSO3['_yz^y'] = Tensor('_yz^y', function() return _i_ * E[1] end)
CommSO3['_zy^y'] = Tensor('_zy^y', function() return -_i_ * E[1] end)
--]]

	printbr(c_'_ab^c':eq(CommSO3'_ab^c'()))

	local GammaSO3 = Tensor'^a_bc'
	GammaSO3['^a_bc'] = (frac(1,2) * CommSO3'_cb^a')()
	printbr'for purely antisymmetric connections:'
	printbr(Gamma_'^a_bc':eq(frac(1,2) * c_'_cb^a'))
	printbr(Gamma_'^a_bc':eq(GammaSO3'^a_bc'()))
	
	local RiemannSO3 = Tensor'^a_bcd'
	RiemannSO3['^a_bcd'] = (GammaSO3'^a_bd,c' - GammaSO3'^a_bc,d' + GammaSO3'^a_ec' * GammaSO3'^e_bd' - GammaSO3'^a_ed' * GammaSO3'^e_bc' - GammaSO3'^a_be' * CommSO3'_cd^e')() 
	printbr(R_'^a_bcd':eq(RiemannSO3))

	printbr'spatial constraints to fulfill:'
	local constraints = table()
	for is,value in RiemannSO3:iter() do
		local a,b,c,d = table.unpack(is)
		if a>1 and b>1 and c>1 and d>1 then -- skipping timelike
			do --if a<b and c<d then
				local lhs = Riemann[{a,b,c,d}]
				local rhs = RiemannSO3[{a,b,c,d}]
				if lhs ~= rhs then
					constraints:insert( (clone(lhs):eq(clone(rhs))*4)() )
				end
			end
		end
	end

	for _,eq in ipairs(constraints) do
		printbr(eq)
	end
end

if false then
	--printbr"<h3>generating Riemann curvature from connection coefficients</h3>"
	-- but then we have the same problem coming up with the metric for the connection, esp with the dependency on the Levi-Civita tensor
	-- so let's just try metrics...
	printbr"<h3>testing metrics and comparing Riemann metric tensors...</h3>"

	printbr'experimental metric:'
	g['_tt'] = Tensor('_tt', function() return -1 end)
	g['_ti'] = Tensor('_ti', function(i) return 0 end)
	g['_it'] = g'_ti'()
	g['_ij'] = Tensor('_ij', function(i,j) 
		return (i == j and 1 or 0) + E[i] * E[j] + B[i] * B[j]
	end)
	printbr(g_'_ab':eq(g'_ab'()))

	-- courtesy of maxima:
	local ESq = (E'_i'*E'_i')()
	local BSq = (B'_i'*B'_i')()
	local SSq = (S'_i'*S'_i')()
	local det_g = SSq + ESq + BSq + 1
	local sqrt_det_g = sqrt(det_g)
	local sqrt_det_gamma = sqrt_det_g:clone()
	gU['^tt'] = Tensor('^tt', function() return -1 end)
	gU['^ti'] = Tensor('^ti', function(i) return 0 end)
	gU['^ij'] = Tensor('^ij', function(i,j)
		local gUij = S[i] * S[j] - E[i] * E[j] - B[i] * B[j]
		if i == j then gUij = gUij + 1 + 2 * (ESq + BSq) end
		return gUij / g_
	end)

	printbr'spatial metric:'
	gamma['_ij'] = g'_ij'()
	gammaU['^ij'] = gU'^ij'()	-- TODO lapse and shift vector
	printbr(gamma_'_ij':eq(gamma'_ij'()))

	printbr('$\\sqrt{-g} =$ '..sqrt_det_g)

	printbr('$\\sqrt{\\gamma} =$ '..sqrt_det_gamma)

	Tensor.metric(g, gU)
	Tensor.metric(gamma, gammaU, 'i')

	LeviCivita3 = Tensor('_ijk', function(i,j,k)
		if i%3+1 == j and j%3+1 == k then return sqrt_det_gamma end
		if k%3+1 == j and j%3+1 == i then return -sqrt_det_gamma end
		return 0
	end)
	printbr(epsilon_'_ijk':eq(LeviCivita3))

	LeviCivita4 = makeLeviCivita('a', sqrt_det_g)
	printbr(epsilon_'_abcd':eq(LeviCivita4))

	printbr'connection from metric:'
	GammaL = Tensor'_abc'
	GammaL['_abc'] = ((g'_ab,c' + g'_ac,b' - g'_bc,a') / 2)()
	printbr(Gamma_'_abc':eq(GammaL'_abc'()))

	Connection = Tensor'^a_bc'
	Connection['^a_bc'] = GammaL'^a_bc'()
	printbr(Gamma_'^a_bc':eq(Connection'^a_bc'()))

	printbr'Levi-Civita tensor from metric:'

	local RiemannFromConnection_expr = Connection'^a_bd,c' 
		- Connection'^a_bc,d' 
		+ Connection'^a_ec' * Connection'^e_bd' 
		- Connection'^a_ed' * Connection'^e_bc' 

	RiemannFromConnection = Tensor'^a_bcd'
	RiemannFromConnection['^a_bcd'] = RiemannFromConnection_expr()
	printbr((R_'^a_bcd'):eq(RiemannFromConnection'^a_bcd'()))


	--[[ finding the connections without the metric
	local Connection_ijk_expr = LeviCivita3'^i_jm' * P'^m_k' / r^2
	local Connection_itj_expr = P'^i_j' / r^2
	--local Commutation_ijk_expr = P'^km' * LeviCivita3'_mij'

	printbr( Gamma_'^i_jk' :eq( pretty(Connection_ijk_expr) ) )
	printbr( Gamma_'^i_tj' :eq( pretty(Connection_itj_expr) ) )
	--printbr( c_'_ij^k':eq( pretty(Commutation_ijk_expr) ) )

	Connection = Tensor'^a_bc'
	Connection['^i_jk'] = Connection_ijk_expr()
	Connection['^i_tj'] = Connection_itj_expr()

	--Commutation = Tensor'_ab^c'
	--Commutation['_ij^k'] = Commutation_ijk_expr()

	local RiemannFromConnection_expr = Connection'^a_bd,c' 
		- Connection'^a_bc,d' 
		+ Connection'^a_ec' * Connection'^e_bd' 
		- Connection'^a_ed' * Connection'^e_bc' 
	--	- Connection'^a_be' * Commutation'_cd^e'

	RiemannFromConnection = Tensor'^a_bcd'
	RiemannFromConnection['^a_bcd'] = RiemannFromConnection_expr()

	printbr((Gamma_'^a_bc'):eq(Connection'^a_bc'()))
	--printbr((c_'_ab^c'):eq(Commutation'_ab^c'()))
	printbr((R_'^a_bcd'):eq(RiemannFromConnection'^a_bcd'()))
	--]]

	printbr"<h3>differences with desired Riemann</h3>"

	printbr((RHat_'^a_bcd' - R_'^a_bcd'):eq( (Riemann - RiemannFromConnection)() ))

	printbr"<h3>Bianchi constraints:</h3>"

	printbr( (R_'^a_bcd;e' + R_'^a_bec;d' + R_'^a_bde;c' ):eq(0))
	printbr'expanded covariant derivatives:'
	printbr( (
		R_'^a_bcd,e' 
			+ R_'^u_bcd' * Gamma_'^a_ue' 
			- R_'^a_ucd' * Gamma_'^u_be'
			- R_'^a_bud' * Gamma_'^u_ce'
			- R_'^a_bcu' * Gamma_'^u_de'
		+ R_'^a_bec,d' 
			+ R_'^u_bec' * Gamma_'^a_ud'
			- R_'^a_uec' * Gamma_'^u_bd'
			- R_'^a_buc' * Gamma_'^u_ed'
			- R_'^a_beu' * Gamma_'^u_cd'
		+ R_'^a_bde,c'
			+ R_'^u_bde' * Gamma_'^a_uc'
			- R_'^a_ude' * Gamma_'^u_bc'
			- R_'^a_bue' * Gamma_'^u_dc'
			- R_'^a_bdu' * Gamma_'^u_ec'
	):eq(0))
	--printbr'expanded Riemann tensors:'
end

printbr[[

<h3>two-form as matrix, as seen in Misner, Thorne, and Wheeler problem 14.14</h3>

${R^{ti}}_{tj} = -(E^i E_j + B^i B_j)$<br>
${R^{ti}}_{jk} = 2 \delta^i_{[k} S_{j]}$<br>
${R^{ij}}_{kl} = {\epsilon^{ij}}_m (E^m E_n + B^m B_n) {\epsilon^n}_{kl}$<br>
<Br>

Assuming ${R_{ti}}^{ij} = -{R^{ti}}_{jk}$<br>
and $S_i = {\epsilon_{ij}}^k E^j B_k$<br>
$S = E \wedge B$ in 3D.<br>
<br>

${R^{ab}}_{cd} = ab\downarrow \overset{cd\rightarrow}{
\left[\matrix{
		& tx & ty & tz & yz & zx & xy \\
	tx & -E^x E_x - B^x B_x & -E^x E_y - B^x B_y & -E^x E_z - B^x B_z & 0 & -S_z & S_y \\
	ty & -E^y E_x - B^y B_x & -E^y E_y - B^y B_y & -E^y E_z - B^y B_z & S_z & 0 & -S_x \\
	tz & -E^z E_x - B^z B_x & -E^z E_y - B^z B_y & -E^z E_z - B^z B_z & -S_y & S_x & 0 \\
	yz & 0 & -S_z & S_y & E^x E_x + B^x B_x & E^x E_y + B^x B_y & E^x E_z + B^x B_z \\
	zx & S_z & 0 & -S_x & E^y E_x + B^y B_x & E^y E_y + B^y B_y & E^y E_z + B^y B_z \\
	xy & -S_y & S_x & 0 & E^z E_x + B^z B_x & E^z E_y + B^z B_y & E^z E_z + B^z B_z \\
}\right]
}$<br>
$= ab\downarrow \overset{cd\rightarrow}{
\left[\matrix{
		& tx & ty & tz & yz & zx & xy \\
	tx & -E^x E_x - B^x B_x & -E^x E_y - B^x B_y & -E^x E_z - B^x B_z & 0 & E^y B_x - E^x B_y & E^z B_x - E^x B_z \\
	ty & -E^y E_x - B^y B_x & -E^y E_y - B^y B_y & -E^y E_z - B^y B_z & E^x B_y - E^y B_x & 0 & E^z B_y - E^y B_z \\
	tz & -E^z E_x - B^z B_x & -E^z E_y - B^z B_y & -E^z E_z - B^z B_z & E^x B_z - E^z B_x & E^y B_z - E^z B_y & 0 \\
	yz & 0 & E^y B_x - E^x B_y & E^z B_x - E^x B_z & E^x E_x + B^x B_x & E^x E_y + B^x B_y & E^x E_z + B^x B_z \\
	zx & E^x B_y - E^y B_x & 0 & E^z B_y - E^y B_z & E^y E_x + B^y B_x & E^y E_y + B^y B_y & E^y E_z + B^y B_z \\
	xy & E^x B_x - E^z B_x & E^y B_z - E^z B_y & 0 & E^z E_x + B^z B_x & E^z E_y + B^z B_y & E^z E_z + B^z B_z \\
}\right]
}$<br>

<br>
${R^a}_b = d {w^a}_b + {w^a}_c \wedge {w^c}_b$<br>
${R^t}_i = d {w^t}_i + {w^t}_t \wedge {w^t}_i + {w^t}_k \wedge {w^k}_i$<br>
${R^i}_j = d {w^i}_j + {w^i}_t \wedge {w^t}_j + {w^i}_k \wedge {w^k}_j$<br>
<br>

${R^t}_i = -(E_i E_j + B_i B_j) dt \wedge dx^j + 2 \gamma_{i[k} S_{j]} dx^j \wedge dx^k$<br>
${R^i}_j = {\epsilon^i}_{jm} (E^m E_n + B^m B_n) {\epsilon^n}_{kl} dx^k \wedge dx^l$<br>
<br>

]]
