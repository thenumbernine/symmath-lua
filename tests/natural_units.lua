#!/usr/bin/env luajit
local symmath = require 'symmath'
symmath.simplifyConstantPowers = true
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
print(MathJax.header)
local printbr = MathJax.print

for k,v in pairs(symmath) do
	if k ~= 'tostring' then _G[k] = v end
end

local pi = var'\\pi'

printbr'<h3>distance</h3>'

local m = var'm'
printbr('meters:',m)

local in_ = var'in'
local in_in_m = in_:eq(.0254 * m)
printbr('inches:',in_in_m)

local ft = var'ft'
local ft_in_in = ft:eq(12 * in_)
local ft_in_m = ft_in_in:subst(in_in_m)()
printbr('feet:', ft_in_in:eq(ft_in_m:rhs()))

printbr()
printbr'speed of light'
local c = var'c'
local s = var's'
local c_in_m_s = c:eq(299792458 * (m / s))
printbr(c_in_m_s)

-- c = 1
local c_eq_1 = c:eq(1)
printbr(c_eq_1)

-- c = ~c~ m/s => solve for s
local s_in_m = c_in_m_s:subst(c_eq_1):solve(s)
local m_in_s = s_in_m:solve(m)
printbr(s_in_m)
printbr(m_in_s)

-- gravity
printbr()
printbr'Gravitational constant'
local G = var'G'
local kg = var'kg'
local G_in_m_s_kg = G:eq(6.67384e-11 * m^3 / (kg * s^2))():factorDivision()
printbr(G_in_m_s_kg)

-- G = 1
local G_eq_1 = G:eq(1)
printbr(G_eq_1)

-- solve for kg
local kg_in_m = G_in_m_s_kg:subst(G_eq_1):subst(s_in_m):solve(kg)
local m_in_kg = kg_in_m:solve(m)
local s_in_kg = s_in_m:subst(m_in_kg)()
local kg_in_s = s_in_kg:solve(kg)

printbr(kg_in_m)
printbr(kg_in_s)

printbr(m_in_kg)
printbr(s_in_kg)

-- Newton
local N = var'N'
local N_in_m_s = N:eq(kg / s^2)
printbr(N_in_m_s)
local N_in_m = N_in_m_s:subst(kg_in_m, s_in_m)():factorDivision():solve(N):factorDivision()
printbr(N_in_m)

-- Joule
local J = var'J'
local J_in_m_s_kg = J:eq((kg * m^2) / s^2)
printbr(J_in_m_s_kg)
local J_in_m = J_in_m_s_kg:subst(kg_in_m, s_in_m):solve(J)()
printbr(J_in_m)

-- Coulomb constant
printbr()
printbr"Coulomb's constant"
local C = var'C'
local ke = var'k_e'
local ke_in_m_s_kg_C = ke:eq(8.9875517873681764e+9 * kg * m^3 / (s^2 * C^2)):factorDivision()
printbr(ke_in_m_s_kg_C)

-- ke = 1
local ke_eq_1 = ke:eq(1)
printbr(ke_eq_1)

-- Coulomb in terms of meter
local expr = ke_in_m_s_kg_C:subst(ke_eq_1, kg_in_m, s_in_m)():factorDivision()
--printbr(expr) -- TODO solve sqrts automatically
local C_in_m = sqrt(expr)():solve(C)
printbr(C_in_m)

-- Amp
local A = var'A'
local A_in_s_C = A:eq(C / s)
local A_in_m = A_in_s_C:subst(s_in_m, C_in_m)()
printbr('Amp',A_in_s_C:eq(A_in_m:rhs()))

-- Volt
local V = var'V'
local V_in_N_C = V:eq(N / C)
local V_in_m = V_in_N_C:subst(N_in_m, C_in_m)():factorDivision()():factorDivision()
printbr('Volt',V_in_N_C:eq(V_in_m:rhs()))

-- Ohm
local Ohm = var'\\Omega'
local Ohm_in_kg_s_C = Ohm:eq(kg / (s * C^2))
local Ohm_in_m = Ohm_in_kg_s_C:subst(kg_in_m, s_in_m, C_in_m)():factorDivision()():factorDivision()
printbr('Ohm',Ohm_in_kg_s_C:eq(Ohm_in_m:rhs()))

-- eps0
printbr()
printbr"permeability and permittivity of free space"
local eps0 = var'\\epsilon_0'
local ke_in_eps0 = ke:eq(1 / (4 * pi * eps0))
printbr(ke_in_eps0)
local eps0_in_m = ke_in_eps0:subst(ke_eq_1):solve(eps0)
printbr(eps0_in_m)

-- mu0
local mu0 = var'\\mu_0'
local cSq_in_mu0_eps0 = (c^2):eq(1 / (mu0 * eps0))
printbr(cSq_in_mu0_eps0)
local mu0_in_m = cSq_in_mu0_eps0:subst(c_eq_1, eps0_in_m):solve(mu0)
printbr(mu0_in_m)

-- e
printbr()
printbr"electron charge"
local e = var'e'
local C_in_e = C:eq(6.2415093414e+18 * e)
printbr(C_in_e)
local e_in_C = C_in_e:factorDivision()():solve(e)
printbr(e_in_C)
local e_in_m = e_in_C:subst(C_in_m)()
printbr(e_in_m)

printbr()
printbr"Boltzmann's constant"
local K = var'K'
local kB = var'k_B'
local kB_in_m_s_kg_K = kB:eq(1.3806488e-23 * ((m^2 * kg) / (K * s^2)))
printbr(kB_in_m_s_kg_K)

local kB_eq_1 = kB:eq(1)
printbr(kB_eq_1)

local K_in_m_s_kg = kB_in_m_s_kg_K:subst(kB_eq_1):solve(K):factorDivision()
printbr(K_in_m_s_kg)

local K_in_m = K_in_m_s_kg:subst(s_in_m):subst(kg_in_m)()
K_in_m = ((K_in_m * m)() / m)():factorDivision()
printbr(K_in_m)

-- Planck constant 
printbr()
printbr"reduced Planck constant"
local hBar = var'\\hbar'
local hBar_in_s_J = hBar:eq(1.05457173e-34 * J * s)
printbr(hBar_in_s_J)
local hBar_in_m = hBar_in_s_J:subst(s_in_m, J_in_m)()
printbr(hBar_in_m)

printbr()
printbr'Planck units:'
local lP = var'l_P'
local lP_def = lP:eq(sqrt(hBar * G / c^3))
local lP_in_m = lP_def:subst(hBar_in_m, c_eq_1, G_eq_1)()
printbr('length',lP_def:eq(lP_in_m:rhs()))

local mP = var'm_P'
local mP_def = mP:eq(sqrt(hBar * c / G))
local mP_in_kg = mP_def:subst(hBar_in_m, c_eq_1, G_eq_1)():subst(kg_in_m:solve(m))()
printbr('mass',mP_def:eq(mP_in_kg:rhs()))

local tP = var't_P'
local tP_def = tP:eq(sqrt(hBar * G / c^5))
local tP_in_s = tP_def:subst(hBar_in_m, c_eq_1, G_eq_1)():subst(s_in_m:solve(m))()
printbr('time',tP_def:eq(tP_in_s:rhs()))

local qP = var'q_P'
local qP_def = qP:eq(sqrt(4 * pi * eps0 * hBar * c))
local qP_in_C = qP_def:subst(hBar_in_m, c_eq_1, G_eq_1, eps0_in_m, pi:eq(math.pi)):subst(C_in_m:solve(m))()
printbr('charge',qP_def:eq(qP_in_C:rhs()))

local TP = var'T_P'
local TP_def = TP:eq(sqrt(hBar * c^2 / kB))
local TP_in_K = TP_def:subst(hBar_in_m, c_eq_1, G_eq_1, kB_eq_1):subst(K_in_m:solve(m))()
printbr('temperature',TP_def:eq(TP_in_K:rhs()))


printbr()
printbr'fine structure constant'
local alpha = var'\\alpha'
local alpha_def = alpha:eq((ke * e^2) / (hBar * c))
printbr(alpha_def)
local alpha_in_m = alpha_def:subst(ke_eq_1, e_in_m, hBar_in_m, c_eq_1)()
printbr(alpha_in_m)

--[[ the following is from QFT notes, which relies on hBar = 1
-- either this or G = 1 can be enforced to defined kg in terms of m and s
-- but not both
local hBar_eq_1 = hBar:eq(1)
printbr()
printbr('kg using',hBar_eq_1)
local kg_in_m_s = hBar_in_s_J:subst(hBar_eq_1, J_in_m_s_kg)():factorDivision():solve(kg)():factorDivision()
printbr(kg_in_m_s)
local kg_in_m = kg_in_m_s:factorDivision()():subst(s_in_m)():factorDivision()
printbr(kg_in_m)

-- eV
printbr()
printbr'electronvolt'
local eV = var'eV'
local eV_in_J = eV:eq(1.60217653e-19 * J)
printbr(eV_in_J)

local eV_in_m_s_kg = eV_in_J:subst(J_in_m_s_kg)
printbr(eV_in_m_s_kg)
local eV_in_m = eV_in_m_s_kg:subst(kg_in_m, s_in_m):solve(eV)():factorDivision()():factorDivision()
printbr(eV_in_m)

-- these are eV^-1
local m_in_eV = eV_in_m:solve(m)():factorDivision()
local s_in_eV = s_in_m:subst(m_in_eV) ():factorDivision()
local K_in_eV = K_in_m:subst(m_in_eV)():factorDivision()
local C_in_eV = C_in_m:subst(m_in_eV)():factorDivision()

-- these are eV
local inv_m_in_eV = (1 / m_in_eV)():factorDivision()():factorDivision()
local inv_s_in_eV = (1 / s_in_eV)():factorDivision()():factorDivision()
local inv_K_in_eV = (1 / K_in_eV)():factorDivision()():factorDivision()
local inv_C_in_eV = (1 / C_in_eV)():factorDivision()():factorDivision()
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

print(MathJax.footer)
