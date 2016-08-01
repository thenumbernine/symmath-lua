#! /usr/bin/env luajit
require 'ext'
local symmath = require 'symmath'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
MathJax.usePartialLHSForDerivative = true
print(MathJax.header)
do
	local print = MathJax.print 
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

	print"<h3>here's a metric that gives rise to geodesics equal to the Lorentz force law, up to a scalar</h3>"

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
	local g = Tensor'_uv'
	-- hmm, single-variable coordinate sets still need to be specified in what is being assigned ...
	-- this is where special treatment for variables among indexes would come in handy
	g['_tt'] = -1 + 2 * A[1] * q / m
	g['_ti'] = (A'_i' * q / m)()
	g['_it'] = (A'_i' * q / m)()
	g['_ij'] = deltaL3'_ij'
	print(var'g''_uv':eq(g))

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
--	print(var'g''^uv':eq(gU))
--	print((var'g''_ac' * var'g''^cb'):eq( (g'_ac' * gU'^cb')() ))

	local basis = Tensor.metric(g, gU)
--[[
local gU = basis.metricInverse
print(gU)
--]]
	local GammaL = Tensor'_abc'
	GammaL['_abc'] = ((g'_ab,c' + g'_ac,b' - g'_bc,a') / 2)()
	print(var'\\Gamma''_abc':eq(GammaL'_abc'()))

	local E = Tensor('_i', function(i) return var('E_'..spatialCoords[i].name, coords) end)
	print(var'E''_i':eq(E'_i'()))
	
	local B = Tensor('_i', function(i) return var('B_'..spatialCoords[i].name, coords) end)
	print(var'B''_i':eq(B'_i'()))
	
	local S = Tensor('_i', function(i) return var('S_'..spatialCoords[i].name, coords) end)
	print(var'S''_i':eq(S'_i'()))
	
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
	print(var'\\Gamma''_abc':eq(GammaL'_abc'()))

--[[
	local Gamma = GammaL'^a_bc'()
	print(var'\\Gamma''^a_bc':eq(Gamma'^a_bc'()))
--]]

	local u = Tensor('^u', function(u)
		-- t approaches 1
		--return u == 1 and 1 or var('u^'..coords[u].name, coords)
		return var('u^'..coords[u].name, coords)
	end)

	local accel = -GammaL'_abc' * u'^b' * u'^c'
	print(var'\\ddot{u}''_a':eq( -GammaL'_abc'() * u'^b'() * u'^c'() ):eq( accel() ))

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

	props:print(print)
--]]

	print"<h3>electromagnetism stress-energy tensor</h3>"
	
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

	print(var'F''_ab':eq(Faraday'_ab'()))
	print(var'F''^a_b':eq(Faraday'^a_b'()))

	local pi = var'\\pi'

	local T_EM = Tensor'_ab'
	T_EM['_ab'] = ((Faraday'_au' * Faraday'_b^u' - eta'_ab' * Faraday'_uv' * Faraday'^uv' / 4) / (4 * pi))()

	print(var'T''_ab':eq(T_EM'_ab'()))
	print(var'T''^a_a':eq( T_EM'^a_a'() ))

	local frac = symmath.divOp
	print(var'G''_ab':eq( 8 * pi * var'T''_ab')) -- G_ab = 8 pi T_ab
	print(var'G''_ab':eq( var'R''_ab' - frac(1,2) * var'R''^c_c' * var'\\eta''_ab' )) -- G_ab = R_ab - 1/2 R^c_c eta_ab
	print(var'R''_ab':eq( var'G''_ab' - frac(1,2) * var'G''^c_c' * var'\\eta''_ab' ))	-- R_ab = G_ab - 1/2 G^c_c eta_ab
	print(var'R''_ab':eq( 8 * pi * var'T''_ab' - 4 * pi * var'T''^c_c' * var'\\eta''_ab'))	-- R_ab = 8 pi T_ab - 4 pi T^c_c eta_ab
	
	local Ricci = Tensor'_ab'
	Ricci['_ab'] = (8 * pi * T_EM'_ab' - 4 * pi * T_EM'^c_c' * eta'_ab')()
	
	print"<h3>here's the Ricci curvature tensor that matches the Einstein field equations for the electromagnetic stress-energy tensor</h3>"

	print(var'\\hat{R}''_ab'
		:eq( 8 * pi * var'T''_ab' - 4 * pi * var'T''^c_c' * var'\\eta''_ab')
		:eq(Ricci'_ab'()))
	
	--[[
	local ESq_plus_BSq = (E'_k'*E'_k' + B'_k'*B'_k')()
	
	local Ricci = Tensor'_ab'
	Ricci['_tt'] = Tensor('_tt', {ESq_plus_BSq})
	Ricci['_ti'] = Tensor('_ti', (-2 * S'_i')())
	Ricci['_it'] = Tensor('_ti', (-2 * S'_i')())
	Ricci['_ij'] = (-2 * E'_i' * E'_j' - 2 * B'_i' * B'_j' + ESq_plus_BSq * deltaL3'_ij')()

	print(var'\\hat{R}''_ab':eq(Ricci))
	--]]

	print"<h3>here's a Riemann curvature tensor that gives rise to that Ricci curvature tensor</h3>"
	
	local dual_E_plus_B = Tensor'_ij'
	dual_E_plus_B['_ij'] = (LeviCivita3'_ijk' * (E'_k' + B'_k'))()

	local dual_E_times_B = (LeviCivita3'_kmn' * E'_m' * B'_n' / 2)()

	local Riemann = Tensor'_abcd'
	-- R_ijkl
	Riemann['_ijkl'] = (dual_E_plus_B'_ij' * dual_E_plus_B'_kl' / 2)() 	
	-- R_tijk
	Riemann['_tijk'] = (deltaL3'_ik' * -dual_E_times_B'_j')()
	Riemann['_itjk'] = (-deltaL3'_ik' * -dual_E_times_B'_j')()
	Riemann['_jkti'] = (deltaL3'_ik' * -dual_E_times_B'_j')()
	Riemann['_jkit'] = (-deltaL3'_ik' * -dual_E_times_B'_j')()
	Riemann['_titj'] = (-2 * (E'_i' * E'_j' + B'_i' + B'_j'))()
	Riemann['_tijt'] = (2 * (E'_i' * E'_j' + B'_i' + B'_j'))()
	Riemann['_ittj'] = (2 * (E'_i' * E'_j' + B'_i' + B'_j'))()
	Riemann['_itjt'] = (-2 * (E'_i' * E'_j' + B'_i' + B'_j'))()
	
	print(var'R''_abcd':eq(Riemann))

	local Riemann = Riemann'^a_bcd'()
	
	print"<h3>building Ricci from Riemann...</h3>"

	RicciNew = Riemann'^c_acb'()
	print(var'R''_ab':eq(RicciNew))
	
	print"<h3>desired Ricci, once again:</h3>"
	print(var'\\hat{R}''_ab':eq(Ricci))

	print"<h3>differences with the desired Ricci:</h3>"
	print((var'\\hat{R}''_ab' - var'R''_ab'):eq(
		(Ricci - RicciNew)()
	))

	print"<h3>Riemann tensor constraints that need to be fulfilled:</h3>"
	for a=1,4 do
		for b=1,4 do
			for c=1,4 do
				for d=1,4 do
					local function index(...) return '{'..table{...}:map(function(i) return coords[i].name end):concat()..'}' end
					local x = (Riemann[a][b][c][d] + Riemann[a][b][d][c])() if x ~= symmath.Constant(0) then print('$R_'..index(a,b,c,d)..' + R_'..index(a,b,d,c)..' = $'..x)	end -- R_abcd == -R_abdc
					local x = (Riemann[a][b][c][d] - Riemann[c][d][a][b])() if x ~= symmath.Constant(0) then print('$R_'..index(a,b,c,d)..' - R_'..index(c,d,a,b)..' = $'..x)	end -- R_abcd == R_cdab
					local x = (Riemann[a][b][c][d] + Riemann[b][a][c][d])() if x ~= symmath.Constant(0) then print('$R_'..index(a,b,c,d)..' + R_'..index(b,a,c,d)..' = $'..x)	end -- R_abcd == -R_bacd
				end	
				-- R_a[bcd] = 0
				-- R_ab[cd;e] = 0
			end
		end
	end
end
print(MathJax.footer)
