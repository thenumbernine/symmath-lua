--[[
this should go in a separate package or something
this and diffgeom as well -- both are extras

args:
	verbose = print the contents as a MathJax html page
	valuesAsVars = replace constant values with variables similar to their associated defined vars (with extra tildes to distinguish them)
--]]
return function(args)
	args = args or {}
	local table = require 'ext.table'
	local SI_in_m = table()

	local rawget = _G.rawget
	local ipairs = _G.ipairs
	local setmetatable = _G.setmetatable
	local setfenv = rawget(_G, 'setfenv')	-- might not be there in Lua >5.1
	local require = _G.require
	local Gprint = _G.print	-- global print
	local math = _G.math
	local symmath = require 'symmath'
	local env = setmetatable({}, {
		__index = function(env,k)
			local x
			-- env
			x = rawget(env,k)
			if x ~= nil then return x end
			-- symmath
			if k ~= 'tostring' then	
				x = rawget(symmath,k)
				if x ~= nil then return x end
			end
			-- _G	
			--x = rawget(_G,k)
			--if x ~= nil then return x end
			return nil
		end,
	})
	-- if implicitVars is set then I can't test things in _G ... 
	-- which might make implicitVars a bad idea ...
	-- TODO have setup() take an _ENV and only apply the meta index to that env ...
	if setfenv ~= nil then 
		setfenv(1, env) 
	else
		_ENV = env 
	end

	local MathJax
	local lprint	-- local print, specific to symmath.tostring
	if args.verbose then
		symmath.tostring = symmath.export.MathJax
		lprint = MathJax.print
		Gprint(MathJax.Header('Natural Units'))
	else
		function lprint() end
	end
	symmath.simplifyConstantPowers = true 

	-- TODO always use the variables, then subst at the end / let the user subst ?
	if args.valuesAsVars then
		c_value = var'{\\tilde{c}}'
		G_value = var'{\\tilde{G}}'
		k_e_value = var'{\\tilde{k}_e}'
		e_value = var'{\\tilde{e}}'
		m_e_value = var'{\\tilde{m}_e}'
		k_B_value = var'{\\tilde{k}_B}'
		hBar_value = var'{\\tilde{h}}'	-- '{\\tilde{\\hBar}}' ... gives MathJax errors
	else
		c_value = 299792458 
		G_value = 6.67384e-11
		k_e_value = 8.9875517873681764e+9
		e_value = 6.2415093414e+18
		m_e_value = 9.1093835611e-31
		k_B_value = 1.3806488e-23
		hBar_value = 1.05457173e-34
	end

	-- grab from symmath, put in units (courtesy of the metatable)
	pi = pi

	m = var'm'

	lprint('meter:',m)

	in_ = var'in'
	in_in_m = in_:eq(.0254 * m)
	lprint('inch:',in_in_m)

	ft = var'ft'
	ft_in_in = ft:eq(12 * in_)
	in_in_ft = ft_in_in:solve(in_)
	ft_in_m = ft_in_in:subst(in_in_m)()
	in_in_m = in_in_ft:subst(ft_in_m)()
	lprint('foot:', ft_in_in:eq(ft_in_m:rhs()))

	s = var's'

	c = var'c'
	c_in_m_s = c:eq(c_value * (m / s))
	c_eq_1 = c:eq(1)
	lprint()
	lprint('speed of light:',c_in_m_s:eq(c_eq_1:rhs()))

	-- c = ~c~ m/s => solve for s
	s_in_m = c_in_m_s:subst(c_eq_1):solve(s)
	m_in_s = s_in_m:solve(m)
	lprint('second:',s_in_m)
	lprint(m_in_s)
	SI_in_m:insert(s_in_m)

	Hz = var'Hz'
	Hz_in_s = Hz:eq(1/s)
	Hz_in_m = Hz_in_s:subst(s_in_m)():factorDivision()
	lprint('hertz:', Hz_in_s:eq(Hz_in_m:rhs()))

	-- gravity
	G = var'G'
	kg = var'kg'
	G_in_SI = G:eq(G_value * (m^3 / (kg * s^2)))
	G_eq_1 = G:eq(1)
	lprint()
	lprint('gravitational constant:',G_in_SI:eq(G_eq_1:rhs()))

	-- solve for kg
	kg_in_m = G_in_SI:subst(G_eq_1):subst(SI_in_m:unpack()):solve(kg)
	m_in_kg = kg_in_m:solve(m)
	s_in_kg = s_in_m:subst(m_in_kg)()
	kg_in_s = s_in_kg:solve(kg)
	lprint('kilogram:',kg_in_m:eq(kg_in_s:rhs()))
	SI_in_m:insert(kg_in_m)

	lprint(m_in_kg)
	lprint(s_in_kg)

	lb = var'lb'	-- pounds
	lb_in_kg = lb:eq(0.45359237 * kg)

	g_n = var'g_n'
	g_n_def = g_n:eq(9.80665 * frac(m,s^2))

	lbf = var'lbf'
	lbf_def = lbf:eq(lb * g_n)
	lbf_in_SI = lbf_def:subst(lb_in_kg, g_n_def)

	-- 'pound-force' per inch^2
	psi = var'psi'
	psi_def = psi:eq(lbf / (in_^2))
	psi_in_SI = psi_def:subst(lbf_in_SI, in_in_m)

	local function addunits(units)
		for _,info in ipairs(units) do
			local name, symbol, SI = table.unpack(info)
			local v = var(symbol)
			-- Should I rename this variable to Omega to coincide with all other unit variables?
			if symbol == '\\Omega' then symbol = 'Ohm' end
			local v_in_SI = v:eq(SI)
			local v_in_m = v_in_SI:subst(SI_in_m:unpack())():factorDivision()
			env[symbol] = v
			env[symbol..'_in_SI'] = v_in_SI
			env[symbol..'_in_m'] = v_in_m
			lprint(name..': '..v_in_SI:eq(v_in_m:rhs()))	
		end
	end

	addunits{
		{'newton', 'N', kg * m / s^2},
		{'pascal', 'Pa', kg / (m * s^2)},
		{'joule', 'J', kg * m^2 / s^2},
		{'watt', 'W', kg * m^2 / s^3},
	}
	
	psi_in_Pa = psi_in_SI:subst(Pa_in_SI:solve(kg))()

	-- ampere
	-- Things would be more simple if coulomb was a SI unit instead of ampere.
	-- As it is, I have to first define ampere, then define coulomb in terms of amperes and seconds,
	-- then define coulombs in terms of Coulomb's constant, then substitute to solve for coulombs in terms of amperes and meters,
	-- then substitute this back to solve for amperes in terms of meters.
	-- If coulombs were the SI unit then all I would have to do is solve Coulomb's constant
	--  (just as the gravitation constant solves for kg and the speed of light solves for m).
	A = var'A'

	-- Coulomb's constant
	C = var'C'
	k_e = var'k_e'
	k_e_in_SI_and_C = k_e:eq(k_e_value * kg * m^3 / (s^2 * C^2)):factorDivision()
	k_e_eq_1 = k_e:eq(1)
	lprint()
	lprint("Coulomb's constant:", k_e_in_SI_and_C:eq(k_e_eq_1:rhs()))

	C_in_m = k_e_in_SI_and_C:subst(k_e_eq_1, SI_in_m:unpack())():solve(C)
	C_in_SI = C:eq(s * A)
	lprint('coulomb:',C_in_SI:eq(C_in_m:rhs()))

	A_in_SI_and_C = C_in_SI:solve(A)
	A_in_m = A_in_SI_and_C:subst(C_in_m, SI_in_m:unpack())()
	lprint('ampere:',A_in_SI_and_C:eq(A_in_m:rhs()))
	SI_in_m:insert(A_in_m)

	addunits{
		{'volt', 'V', kg * m^2 / (s^3 * A)},
		{'farad', 'F', s^4 * A^2 / (kg * m^2)},
		{'ohm', '\\Omega', kg * m^2 / (s^3 * A^2)},
		{'siemens', 'S', s^3 * A^2 / (m^2 * kg)},
		{'weber', 'Wb', kg * m^2 / (s^2 * A)},
		{'tesla', 'T', kg / (s^2 * A)},
		{'henry', 'H', kg * m^2 / (s^2 * A^2)},
	}

	-- and some useful constants:

	lprint()
	lprint"permeability and permittivity of free space"
	epsilon_0 = var'\\epsilon_0'
	k_e_in_epsilon_0 = k_e:eq(frac(1, 4 * pi * epsilon_0))
	lprint(k_e_in_epsilon_0)
	epsilon_0_in_SI_and_C = k_e_in_epsilon_0:subst(k_e_in_SI_and_C):solve(epsilon_0):factorDivision()
	lprint(epsilon_0_in_SI_and_C)
	epsilon_0_in_m = k_e_in_epsilon_0:subst(k_e_eq_1):solve(epsilon_0)
	lprint('in natural units:',epsilon_0_in_m)

	mu_0 = var'\\mu_0'
	cSq_in_mu_0_epsilon_0 = (c^2):eq(1 / (mu_0 * epsilon_0))
	lprint(cSq_in_mu_0_epsilon_0)
	mu_0_in_SI_and_C = cSq_in_mu_0_epsilon_0:subst(epsilon_0_in_SI_and_C):subst(c_in_m_s):solve(mu_0):factorDivision()
	lprint(mu_0_in_SI_and_C)	
	mu_0_in_m = cSq_in_mu_0_epsilon_0:subst(c_eq_1, epsilon_0_in_m):solve(mu_0)
	lprint('in natural units:',mu_0_in_m)

	-- e
	lprint()
	lprint"electron charge:"
	e = var'e'
	C_in_e = C:eq(e_value * e)
	lprint(C_in_e)
	e_in_C = C_in_e:factorDivision()():solve(e)
	e_in_m = e_in_C:subst(C_in_m)()
	lprint(e_in_C:eq(e_in_m:rhs()))

	-- m_e
	m_e = var'm_e'
	m_e_in_kg = m_e:eq(m_e_value * kg)
	m_e_in_m = m_e_in_kg:subst(kg_in_m)()
	lprint()
	lprint("electron mass:", m_e_in_kg:eq(m_e_in_m:rhs()))

	K = var'K'
	k_B = var'k_B'
	k_B_in_SI = k_B:eq(k_B_value * ((m^2 * kg) / (K * s^2)))
	k_B_eq_1 = k_B:eq(1)
	lprint("Boltzmann's constant:", k_B_in_SI:eq(k_B_eq_1:rhs()))

	K_in_SI = k_B_in_SI:subst(k_B_eq_1):solve(K):factorDivision()
	K_in_m = K_in_SI:subst(SI_in_m:unpack())()
	lprint('Kelvin:', K_in_SI:eq(K_in_m:rhs()))

	-- Planck constant 
	hBar = var'\\hbar'
	hBar_in_s_J = hBar:eq(hBar_value * J * s)
	hBar_in_m = hBar_in_s_J:subst(s_in_m, J_in_m)()
	lprint("reduced Planck constant:", hBar_in_s_J:eq(hBar_in_m:rhs()))

	-- Planck units

	lprint()
	lprint'Planck units:'
	l_P = var'l_P'
	l_P_def = l_P:eq(sqrt(hBar * G / c^3))
	l_P_in_m = l_P_def:subst(hBar_in_m, c_eq_1, G_eq_1)()
	lprint('length',l_P_def:eq(l_P_in_m:rhs()))

	m_P = var'm_P'
	m_P_def = m_P:eq(sqrt(hBar * c / G))
	m_P_in_kg = m_P_def:subst(hBar_in_m, c_eq_1, G_eq_1)():subst(kg_in_m:solve(m))()
	lprint('mass',m_P_def:eq(m_P_in_kg:rhs()))

	t_P = var't_P'
	t_P_def = t_P:eq(sqrt(hBar * G / c^5))
	t_P_in_s = t_P_def:subst(hBar_in_m, c_eq_1, G_eq_1)():subst(s_in_m:solve(m))()
	lprint('time',t_P_def:eq(t_P_in_s:rhs()))

	q_P = var'q_P'
	q_P_def = q_P:eq(sqrt(4 * pi * epsilon_0 * hBar * c))
	q_P_in_C = q_P_def:subst(hBar_in_m, c_eq_1, G_eq_1, epsilon_0_in_m, pi:eq(math.pi)):subst(C_in_m:solve(m))()
	lprint('charge',q_P_def:eq(q_P_in_C:rhs()))

	T_P = var'T_P'
	T_P_def = T_P:eq(sqrt(hBar * c^2 / k_B))
	T_P_in_K = T_P_def:subst(hBar_in_m, c_eq_1, G_eq_1, k_B_eq_1):subst(K_in_m:solve(m))()
	lprint('temperature',T_P_def:eq(T_P_in_K:rhs()))

	lprint()
	lprint'fine structure constant'
	alpha = var'\\alpha'
	alpha_def = alpha:eq((k_e * e^2) / (hBar * c))
	alpha_in_m = alpha_def:subst(k_e_eq_1, e_in_m, hBar_in_m, c_eq_1)()
	lprint(alpha_def:eq(alpha_in_m:rhs()))

	--[[ the following is from QFT notes, which relies on hBar = 1
	-- either this or G = 1 can be enforced to defined kg in terms of m and s
	-- but not both
	local hBar_eq_1 = hBar:eq(1)
	lprint()
	lprint('kg using',hBar_eq_1)
	local kg_in_m_s = hBar_in_s_J:subst(hBar_eq_1, J_in_m_s_kg):solve(kg)():factorDivision()
	lprint(kg_in_m_s)
	local kg_in_m = kg_in_m_s():subst(s_in_m)():factorDivision()
	lprint(kg_in_m)

	-- eV
	lprint()
	lprint'electronvolt'
	local eV = var'eV'
	local eV_in_J = eV:eq(1.60217653e-19 * J)
	lprint(eV_in_J)

	local eV_in_m_s_kg = eV_in_J:subst(J_in_m_s_kg)
	lprint(eV_in_m_s_kg)
	local eV_in_m = eV_in_m_s_kg:subst(kg_in_m, s_in_m):solve(eV)():factorDivision()
	lprint(eV_in_m)

	-- these are eV^-1
	local m_in_eV = eV_in_m:solve(m)():factorDivision()
	local s_in_eV = s_in_m:subst(m_in_eV) ():factorDivision()
	local K_in_eV = K_in_m:subst(m_in_eV)():factorDivision()
	local C_in_eV = C_in_m:subst(m_in_eV)():factorDivision()

	-- these are eV
	local inv_m_in_eV = (1 / m_in_eV)():factorDivision()
	local inv_s_in_eV = (1 / s_in_eV)():factorDivision()
	local inv_K_in_eV = (1 / K_in_eV)():factorDivision()
	local inv_C_in_eV = (1 / C_in_eV)():factorDivision()
	local kg_in_eV = kg_in_m:subst(m_in_eV)():factorDivision()
	local J_in_eV = eV_in_J:solve(J)

	lprint()
	lprint'scale of units, in eV:'
	lprint(inv_s_in_eV)
	lprint(inv_m_in_eV)
	lprint(J_in_eV)
	lprint(inv_C_in_eV)
	lprint(kg_in_eV)
	lprint(inv_K_in_eV)

	lprint()
	lprint'...and clarification for the inverse units:'
	lprint(m_in_eV)
	lprint(s_in_eV)
	lprint(K_in_eV)
	lprint(C_in_eV)
	--]]

	--[[

	c = 1 = 299792458 * m * s^-1
	G = 1 = 6.67384e-11 * m^3 * kg^-1 * s^-2
	hBar = 1 = 1.05457173e-34 * m^2 * kg * s^-1
	kB = 1 = 1.3806488e-23 * m^2 * kg * s^-2 * K-1
	 
	c relates m to s:
		1 = 299792458 * m * s^-1
		s = 299792458 * m
		...
		substitute G's m
		s = 299792458 * 6.187355886101e+34
		s = 1.854922629615e+43
	G relates kg to m and s
		1 = 6.67384e-11 * m^3 * kg^-1 * s^-2
		kg = 6.67384e-11 * m^3 * s^-2
		kg = 6.67384e-11 / 299792458^2 * m
		kg = 7.4256484500929e-28 * m
		...
		substitute hBar's kg
		m = 45945129.645799 / 7.4256484500929e-28
		m = 45945129.645799 / 7.4256484500929e-28
		m = 6.187355886101e+34
	hBar relates kg to m^-1 and s
		1 = 1.05457173e-34 * m^2 * s^-1 * kg
		kg = 1.05457173e-34^-1 * (m/s)^-1 * m^-1
		kg = 299792458 / 1.05457173e-34 * m^-1
		kg = 2.8427886835161e+42 * m^-1
		...
		substitute G's m in terms of kg...
		m^-1 = 7.4256484500929e-28 * kg^-1
		substitute hBar's m^-1 in terms of kg...
		kg = 2.8427886835161e+42 * 7.4256484500929e-28 * kg^-1
		kg^2 = 2.1109549381693e+15
		kg = 45945129.645799
	...and combining G and hBar relates kg to constants...
	kB relates K to kg and m/s
		1 = 1.3806488e-23 * m^2 * kg * s^-2 * K-1
		K = 1.3806488e-23 / 299792458^2 * kg
		K = 1.5361789647104e-40 * kg
		...
		substitute hBar's kg...
		K = 1.5361789647104e-40 * 45945129.645799
		K = 7.0579941692769e-33
	 
	... what relates V or A?
	V = kg * m^2 * s^-3 * A^-1
	V * A = (kg * m^2 * s^-1) * s^-2
	V * A = 1/1.05457173e-34 * s^-2
	V * A = 9.4825223505659e+033 * s^-2
	V * A = 9.4825223505659e+033 / 1.854922629615e+43^2
	V * A = 2.7559559767945e-053
	... they at least relate to one another ...
	 
	 
	Energy is measured in Joules = kg m^2 / s^2
		hBar says
		1 / 1.05457173e-34 = kg * m^2 * s^-1
		c says
		1 = 299792458 * m * s^-1
		combine to get
		1.05457173e-34^-1 * 299792458^-1 = (kg * m^2 * s^-2) * m
		1.05457173e-34^-1 * 299792458^-1 = J * m
		J = 1.05457173e-34^-1 * 299792458^-1 * m^-1
		J = 3.1630289880628e+025 * m^-1 
		m = 3.1630289880628e+025 * J^-1 
		... there's distance in units of inverse energy
		c says
		m = 3.1630289880628e+025 * J^-1 * (299792458 * m * s^-1)
		s = 3.1630289880628e+025 * 299792458 * J^-1
		s = 3.1630289880628e+025 * 299792458 * J^-1
		s = 9.482522350566e+033 * J^-1
		... there's time in units of inverse energy
		hBar says
		kg = 1.05457173e-34^-1 * s * m^-2
		kg = 1.05457173e-34^-1 * (9.482522350566e+033 * J^-1) * (3.1630289880628e+025 * J^-1)^-2
		kg = 1.05457173e-34^-1 * 9.482522350566e+033 * 3.1630289880628e+025^-2 * J
		kg = 8.9875517873681e+016 * J
	 
	 
	new unit! electronvolt (eV)
		... must be in terms of ratios of V and A
	eV = 1.60217653e-19 * J
	J = 6.2415094796077e+18 * eV
	J = 6.2415094796077e+9 * GeV
	 
	result:
		m = 3.1630289880628e+025 / 6.2415094796077e+9 * GeV^-1
		s = 9.482522350566e+033 / 6.2415094796077e+9 * GeV^-1
		kg = 8.9875517873681e+016 * 6.2415094796077e+9 * GeV
		...
		m = 5.0677308083839e+015 * GeV^-1
		s = 1.5192674755277e+024 * GeV^-1
		kg = 5.6095889679323e+026 * GeV
		...
		µb = 1e-34 * m^2
		µb = 1e-34 * (5.0677308083839e+015 * GeV^-1)^2
		µb = 1e-34 * 5.0677308083839e+15^2 * GeV^-2
		µb = 0.0025681895546243 * GeV^-2
		µb / 0.0025681895546243 = GeV^-2
		GeV^-2 = 389.37935799925 µb

	--]]
	
	if args.verbose then
		Gprint(MathJax.footer)		
	end

	-- by here we're done with the operations, 
	-- so we no longer need the lookup tables in the environment which point back to the global namespace
	setmetatable(env, nil)

	return env
end
