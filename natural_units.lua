-- this should go in a separate package or something
-- this and diffgeom as well -- both are extras
return function(verbose)
	local require = _G.require
	local print = _G.print
	local math = _G.math
	local symmath = require 'symmath'
	local env = setmetatable({}, {
		__index = function(t,k)
			local x
			-- t
			x = rawget(t,k)
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
	if setfenv then setfenv(1, env) else _ENV = env end

	local MathJax
	local printbr
	if verbose then
		MathJax = require 'symmath.tostring.MathJax'
		symmath.tostring = MathJax
		printbr = MathJax.print
		print(MathJax.header)
	else
		function printbr() end
	end
	symmath.simplifyConstantPowers = true 

	pi = var'\\pi'
	m = var'm'

	printbr'distance'
	printbr('meters:',m)

	in_ = var'in'
	in_in_m = in_:eq(.0254 * m)
	printbr('inches:',in_in_m)

	ft = var'ft'
	ft_in_in = ft:eq(12 * in_)
	ft_in_m = ft_in_in:subst(in_in_m)()
	printbr('feet:', ft_in_in:eq(ft_in_m:rhs()))

	printbr()
	printbr'speed of light'
	c = var'c'
	s = var's'
	c_in_m_s = c:eq(299792458 * (m / s))
	printbr(c_in_m_s)

	-- c = 1
	c_eq_1 = c:eq(1)
	printbr(c_eq_1)

	-- c = ~c~ m/s => solve for s
	s_in_m = c_in_m_s:subst(c_eq_1):solve(s)
	m_in_s = s_in_m:solve(m)
	printbr(s_in_m)
	printbr(m_in_s)

	-- gravity
	printbr()
	printbr'Gravitational constant'
	G = var'G'
	kg = var'kg'
	G_in_m_s_kg = G:eq(6.67384e-11 * (m^3 / (kg * s^2)))
	printbr(G_in_m_s_kg)

	-- G = 1
	G_eq_1 = G:eq(1)
	printbr(G_eq_1)

	-- solve for kg
	kg_in_m = G_in_m_s_kg:subst(G_eq_1):subst(s_in_m):solve(kg)
	m_in_kg = kg_in_m:solve(m)
	s_in_kg = s_in_m:subst(m_in_kg)()
	kg_in_s = s_in_kg:solve(kg)

	printbr(kg_in_m:eq(kg_in_s:rhs()))

	printbr(m_in_kg)
	printbr(s_in_kg)

	-- Newton
	N = symmath.var'N'
	N_in_m_s_kg = N:eq(kg * m / s^2)
	N_in_m = N_in_m_s_kg:subst(kg_in_m, s_in_m):solve(N):factorDivision()
	printbr('Newton',N_in_m_s_kg:eq(N_in_m:rhs()))

	-- Joule
	J = var'J'
	J_in_m_s_kg = J:eq((kg * m^2) / s^2)
	J_in_m = J_in_m_s_kg:subst(kg_in_m, s_in_m):solve(J)()
	printbr('Joule',J_in_m_s_kg:eq(J_in_m:rhs()))

	-- Coulomb constant
	printbr()
	printbr"Coulomb's constant"
	C = var'C'
	ke = var'k_e'
	ke_in_m_s_kg_C = ke:eq(8.9875517873681764e+9 * kg * m^3 / (s^2 * C^2)):factorDivision()
	printbr(ke_in_m_s_kg_C)

	-- ke = 1
	ke_eq_1 = ke:eq(1)
	printbr(ke_eq_1)

	-- Coulomb in terms of meter
	expr = ke_in_m_s_kg_C:subst(ke_eq_1, kg_in_m, s_in_m)():factorDivision()
	C_in_m = expr:solve(C)
	printbr('Coulomb',C_in_m)

	-- Amp
	A = var'A'
	A_in_s_C = A:eq(C / s)
	A_in_m = A_in_s_C:subst(s_in_m, C_in_m)()
	printbr('Amp',A_in_s_C:eq(A_in_m:rhs()))

	-- Volt
	V = var'V'
	V_in_m_N_C = V:eq(N * m / C)
	V_in_m = V_in_m_N_C:subst(N_in_m, C_in_m)():factorDivision()
	printbr('Volt',V_in_m_N_C:eq(V_in_m:rhs()))

	-- Ohm
	Ohm = var'\\Omega'
	Ohm_in_kg_s_C = Ohm:eq(kg * m^2 / (s * C^2))
	Ohm_in_m = Ohm_in_kg_s_C:subst(kg_in_m, s_in_m, C_in_m)():factorDivision()
	printbr('Ohm',Ohm_in_kg_s_C:eq(Ohm_in_m:rhs()))

	-- eps0
	printbr()
	printbr"permeability and permittivity of free space"
	eps0 = var'\\epsilon_0'
	ke_in_eps0 = ke:eq(1 / (4 * pi * eps0))
	printbr(ke_in_eps0)
	eps0_in_m = ke_in_eps0:subst(ke_eq_1):solve(eps0)
	printbr(eps0_in_m)

	-- mu0
	mu0 = var'\\mu_0'
	cSq_in_mu0_eps0 = (c^2):eq(1 / (mu0 * eps0))
	printbr(cSq_in_mu0_eps0)
	mu0_in_m = cSq_in_mu0_eps0:subst(c_eq_1, eps0_in_m):solve(mu0)
	printbr(mu0_in_m)

	-- e
	printbr()
	printbr"electron charge"
	e = var'e'
	C_in_e = C:eq(6.2415093414e+18 * e)
	printbr(C_in_e)
	e_in_C = C_in_e:factorDivision()():solve(e)
	e_in_m = e_in_C:subst(C_in_m)()
	printbr(e_in_C:eq(e_in_m:rhs()))

	-- m_e
	printbr()
	printbr"electron mass"
	me = var'm_e'
	me_in_kg = me:eq(9.1093835611e-31 * kg)
	printbr(me_in_kg)
	me_in_m = me_in_kg:subst(kg_in_m)()
	printbr(me_in_m)

	printbr()
	printbr"Boltzmann's constant"
	K = var'K'
	kB = var'k_B'
	kB_in_m_s_kg_K = kB:eq(1.3806488e-23 * ((m^2 * kg) / (K * s^2)))
	printbr(kB_in_m_s_kg_K)

	kB_eq_1 = kB:eq(1)
	printbr(kB_eq_1)

	K_in_m_s_kg = kB_in_m_s_kg_K:subst(kB_eq_1):solve(K):factorDivision()
	K_in_m = K_in_m_s_kg:subst(s_in_m):subst(kg_in_m)()
	printbr('Kelvin',K_in_m_s_kg:eq(K_in_m:rhs()))

	-- Planck constant 
	printbr()
	printbr"reduced Planck constant"
	hBar = var'\\hbar'
	hBar_in_s_J = hBar:eq(1.05457173e-34 * J * s)
	hBar_in_m = hBar_in_s_J:subst(s_in_m, J_in_m)()
	printbr(hBar_in_s_J:eq(hBar_in_m:rhs()))

	printbr()
	printbr'Planck units:'
	lP = var'l_P'
	lP_def = lP:eq(sqrt(hBar * G / c^3))
	lP_in_m = lP_def:subst(hBar_in_m, c_eq_1, G_eq_1)()
	printbr('length',lP_def:eq(lP_in_m:rhs()))

	mP = var'm_P'
	mP_def = mP:eq(sqrt(hBar * c / G))
	mP_in_kg = mP_def:subst(hBar_in_m, c_eq_1, G_eq_1)():subst(kg_in_m:solve(m))()
	printbr('mass',mP_def:eq(mP_in_kg:rhs()))

	tP = var't_P'
	tP_def = tP:eq(sqrt(hBar * G / c^5))
	tP_in_s = tP_def:subst(hBar_in_m, c_eq_1, G_eq_1)():subst(s_in_m:solve(m))()
	printbr('time',tP_def:eq(tP_in_s:rhs()))

	qP = var'q_P'
	qP_def = qP:eq(sqrt(4 * pi * eps0 * hBar * c))
	qP_in_C = qP_def:subst(hBar_in_m, c_eq_1, G_eq_1, eps0_in_m, pi:eq(math.pi)):subst(C_in_m:solve(m))()
	printbr('charge',qP_def:eq(qP_in_C:rhs()))

	TP = var'T_P'
	TP_def = TP:eq(sqrt(hBar * c^2 / kB))
	TP_in_K = TP_def:subst(hBar_in_m, c_eq_1, G_eq_1, kB_eq_1):subst(K_in_m:solve(m))()
	printbr('temperature',TP_def:eq(TP_in_K:rhs()))

	printbr()
	printbr'fine structure constant'
	alpha = var'\\alpha'
	alpha_def = alpha:eq((ke * e^2) / (hBar * c))
	alpha_in_m = alpha_def:subst(ke_eq_1, e_in_m, hBar_in_m, c_eq_1)()
	printbr(alpha_def:eq(alpha_in_m:rhs()))

	--[[ the following is from QFT notes, which relies on hBar = 1
	-- either this or G = 1 can be enforced to defined kg in terms of m and s
	-- but not both
	local hBar_eq_1 = hBar:eq(1)
	printbr()
	printbr('kg using',hBar_eq_1)
	local kg_in_m_s = hBar_in_s_J:subst(hBar_eq_1, J_in_m_s_kg):solve(kg)():factorDivision()
	printbr(kg_in_m_s)
	local kg_in_m = kg_in_m_s():subst(s_in_m)():factorDivision()
	printbr(kg_in_m)

	-- eV
	printbr()
	printbr'electronvolt'
	local eV = var'eV'
	local eV_in_J = eV:eq(1.60217653e-19 * J)
	printbr(eV_in_J)

	local eV_in_m_s_kg = eV_in_J:subst(J_in_m_s_kg)
	printbr(eV_in_m_s_kg)
	local eV_in_m = eV_in_m_s_kg:subst(kg_in_m, s_in_m):solve(eV)():factorDivision()
	printbr(eV_in_m)

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

	printbr()
	printbr'scale of units, in eV:'
	printbr(inv_s_in_eV)
	printbr(inv_m_in_eV)
	printbr(J_in_eV)
	printbr(inv_C_in_eV)
	printbr(kg_in_eV)
	printbr(inv_K_in_eV)

	printbr()
	printbr'...and clarification for the inverse units:'
	printbr(m_in_eV)
	printbr(s_in_eV)
	printbr(K_in_eV)
	printbr(C_in_eV)
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

	if verbose then
		print(MathJax.footer)
	end

	return env
end
