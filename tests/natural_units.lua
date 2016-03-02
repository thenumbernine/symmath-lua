#!/usr/bin/env luajit
local symmath = require 'symmath'
symmath.simplifyConstantPowers = true
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
print(MathJax.header)

local var = symmath.var

local function printbr(...) print(...) print'<br>' end 

local m = var'm'
local s = var's'
local kg = var'kg'
local K = var'K'
local eV = var'eV'

-- speed of light
local c = var'c'
local c_from_m_s = c:eq(299792458 * (m / s))
printbr(c_from_m_s)

-- c = 1
local c_normalized = c:eq(1)
printbr(c_normalized)

-- solve for s
local s_from_m = c_from_m_s:subst(c_normalized):solve(s)
printbr(s_from_m)

-- Planck's constant
local hBar = var'\\hbar'
local hBar_from_m_s_kg = hBar:eq(1.05457173e-34 * (m^2 * kg / s))
printbr(hBar_from_m_s_kg)

-- hBar = 1
local hBar_normalized = hBar:eq(1)
printbr(hBar_normalized)

-- kg in terms of m
local kg_from_m_s = hBar_from_m_s_kg:subst(hBar_normalized):solve(kg)
printbr(kg_from_m_s)

-- substitute s
local kg_from_m = kg_from_m_s:subst(s_from_m)()
kg_from_m = ((kg_from_m * m)() / m)() 
printbr(kg_from_m)

-- Boltzmann's constant
local kB = var'k_B'
local kB_from_kg_m_s_K = kB:eq(1.3806488e-23 * ((m^2 * kg) / (K * s^2)))
printbr(kB_from_kg_m_s_K)

-- kB = 1
local kB_normalized = kB:eq(1)
printbr(kB_normalized)

local K_from_kg_m_s = kB_from_kg_m_s_K:subst(kB_normalized):solve(K)
printbr(K_from_kg_m_s)

local K_from_m = K_from_kg_m_s:subst(s_from_m):subst(kg_from_m)()
K_from_m = ((K_from_m * m)() / m)() 
printbr(K_from_m)

-- J
local J = var'J'
local J_from_kg_m_s = J:eq((kg * m^2) / s^2)
printbr(J_from_kg_m_s)

-- eV
local eV_from_J = eV:eq(1.60217653e-19 * J)
eV_from_J:solve(J)

local eV_from_kg_m_s = eV_from_J:subst(J_from_kg_m_s)
printbr(eV_from_kg_m_s)

local eV_from_m = eV_from_kg_m_s:subst(kg_from_m):subst(s_from_m)()
eV_from_m = ((eV_from_m * m)() / m)() 
printbr(eV_from_m)

-- and all units in terms of eV
local m_from_eV = ((eV_from_m * m)() / eV)()

printbr(kg_from_m:subst(m_from_eV)())
printbr(m_from_eV)
printbr(K_from_m:subst(m_from_eV)())
printbr(s_from_m:subst(m_from_eV)())

--[[
-- gravity
local G = var'G'
local G_from_m_s_kg = G:eq(6.67384e-11 * m^3 / (kg * s^2))()
printbr('G_from_m_s_kg:',G_from_m_s_kg)

-- G = 1
local G_normalized = G:eq(1)
printbr('G_normalized:',G_normalized)

-- solve for kg
local kg_from_m = G_from_m_s_kg:subst(G_normalized):subst(s_from_m):solve(kg)
printbr(kg_from_m)

-- local m_from_kg = kg_from_m:solve(m)
local m_from_kg = kg_from_m:solve(m)
printbr(m_from_kg)

--local s_from_kg = s_from_m:subst(kg_from_m:solve(kg))
local s_from_kg = s_from_m:subst(m_from_kg)()
printbr(s_from_kg)
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
