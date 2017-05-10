#! /usr/bin/env luajit
require 'ext'
require 'symmath'.setup{env=_ENV or getfenv()}
require 'symmath.tostring.MathJax'.setup{usePartialLHSForDerivative=true}

local t,r,phi,z = vars('t', 'r', '\\phi', 'z')
local pi = var'\\pi'

--[[
local eps0 = var'\\epsilon_0'
local mu0 = var'\\mu_0'
--]]
-- [[
local mu0 = 4 * pi
local eps0 = 1 / mu0
--]]

local spatialCoords = {r,phi,z}
local coords = table{t}:append(spatialCoords)

Tensor.coords{
	{variables=coords},
	{symbols='ijklmn', variables=spatialCoords},
	{symbols='t', variables={t}},
	{symbols='x', variables={x}},
	{symbols='y', variables={y}},
	{symbols='z', variables={z}},
}

local g = Tensor'_ab'
g['_ab'] = Tensor('_ab', table.unpack(Matrix.diagonal(-1, 1, r^2, 1))) 

local gU = Tensor'^ab'
gU['^ab'] = Tensor('^ab', table.unpack(Matrix.diagonal(-1, 1, r^-2, 1))) 

local gamma = Tensor('_ij', {1,0,0}, {0,r^2,0}, {0,0,1})
--printbr(var'\\gamma''_ij':eq(gamma'_ij'()))

local gammaU = Tensor('^ij', table.unpack((Matrix.inverse(gamma))))
--printbr(var'\\gamma''^ij':eq(gammaU'^ij'()))

Tensor.metric(g, gU)
Tensor.metric(gamma, gammaU, 'i')

local sqrt_det_gamma = sqrt(Matrix.determinant(gamma))()
--printbr(sqrt(var'\\gamma'):eq(sqrt_det_gamma))

local makeLeviCivita = require 'symmath.tensor.LeviCivita'
--local LeviCivita4 = makeLeviCivita()
--printbr(var'\\epsilon''_abcd':eq(LeviCivita4'_abcd'()))
local LeviCivita3 = makeLeviCivita('i')
--printbr(var'\\epsilon''_ijk':eq(LeviCivita3'_ijk'()))

local E = Tensor('_i', function(i) return var('E_'..spatialCoords[i].name, coords) end)
local Er, Ephi, Ez = table.unpack(E)

local B = Tensor('_i', function(i) return var('B_'..spatialCoords[i].name, coords) end)
local Br, Bphi, Bz = table.unpack(B)

local S = (LeviCivita3'_i^jk' * E'_j' * B'_k')()

--printbr(var'E''_i':eq(E))
--printbr(var'B''_i':eq(B))
--printbr(var'S''_i':eq(S))

local ESq_plus_BSq = (E'_i' * E'_j' * gammaU'^ij' + B'_i' * B'_j' * gammaU'^ij')()

-- taken from my electrovacuum.lua script
local Ricci_EM = Tensor'_ab'
Ricci_EM['_tt'] = Tensor('_tt', {ESq_plus_BSq})
Ricci_EM['_ti'] = Tensor('_ti', (-2 * S'_i')())
Ricci_EM['_it'] = Tensor('_ti', (-2 * S'_i')())
Ricci_EM['_ij'] = (-2 * E'_i' * E'_j' - 2 * B'_i' * B'_j' + ESq_plus_BSq * gamma'_ij')()

local lambda = var'\\lambda'
local I = var'I'
printbr'for a uniformly charged wire...'
-- TODO http://www.physicspages.com/2013/11/18/electric-field-outside-an-infinite-wire/
Ricci_EM = Ricci_EM
	-- http://farside.ph.utexas.edu/teaching/302l/lectures/node26.html
	:replace(Er, lambda / (2 * pi * eps0 * r))
	:replace(Ephi, 0)
	:replace(Ez, 0)
	-- http://hyperphysics.phy-astr.gsu.edu/hbase/magnetic/magcur.html
	:replace(Br, 0)
	:replace(Bphi, mu0 * I / (2 * pi * r))
	:replace(Bz, 0)
	:simplify()
--printbr(var'R''_ab':eq(Ricci_EM'_ab'()))

local Conn = Tensor'^a_bc'

-- [[ 
Conn[2][1][1] = var('a',{r})
Conn[1][2][1] = var('d',{r}) * I / r^2
Conn[1][1][2] = var('g',{r})

Conn[2][1][4] = var('b',{r})
Conn[2][4][1] = var('c',{r})
Conn[2][2][2] = lambda -- var('h',{r})

Conn[2][3][3] = var('e',{r})
Conn[2][4][4] = var('f',{r})
--]]

--[[ tada!
Conn[2][1][1] = -frac(4,3) * I^2 / r^3 - 4 * lambda^2 / r		-- R_tt
Conn[2][1][4] = 4 * I * lambda / r^2							-- R_tz
Conn[2][4][1] = 4 * I * lambda / r^2							-- R_zt
Conn[1][1][1] = Constant(1)										-- R_pp, R_zz
Conn[1][3][3] = -4 * I^2 / r^2 + 4 * lambda^2					-- R_pp
Conn[1][4][4] = 4 * I^2 / r^4 + 4 * lambda^2 / r^2				-- R_zz
Conn[3][2][2] = 4 * phi * (I^2 / r^4 - lambda^2 / r^2)			-- R_rr
--]]

Conn:printElem'\\Gamma'
printbr()

-- R^a_bcd = Conn^a_bd,c - Conn^a_bc,d + Conn^a_ec Conn^e_bd - Conn^a_ed Conn^e_bc - Conn^a_be (Conn^e_dc - Conn^e_cd)
local RiemannExpr = Conn'^a_bd,c' - Conn'^a_bc,d' 
	+ Conn'^a_ec' * Conn'^e_bd' - Conn'^a_ed' * Conn'^e_bc'
	- Conn'^a_be' * (Conn'^e_dc' - Conn'^e_cd')
-- [[
printbr(var'R''^a_bcd':eq(RiemannExpr:replace(Conn, var'\\Gamma')))
printbr(var'R''_ab':eq(RiemannExpr:replace(Conn, var'\\Gamma'):reindex{cacbd='abcde'}))
--]]

local Riemann = Tensor'^a_bcd'
Riemann['^a_bcd'] = RiemannExpr()
--printbr(var'R''^a_bcd':eq(Riemann))

-- R_ab = R^c_acb = Conn^c_ab,c - Conn^c_ac,b + Conn^c_dc Conn^d_ab - Conn^c_db Conn^d_ac - Conn^c_ad (Conn^d_bc - Conn^d_cb)
local Ricci = Riemann'^c_acb'()
print(var'R''_ab':eq(Ricci))

print('vs desired')
printbr(var'R''_ab':eq(Ricci_EM))

print'diff'
printbr((Ricci_EM - Ricci)())

--[[ Bianchi identities
-- This is zero, but it's a bit slow to compute.
-- It's probably zero because I derived the Riemann values from the connections.
-- This will be a 4^5 = 1024, but it only needs to show 20 * 4 = 80, though because it's R^a_bcd, we can't use the R_abcd = R_cdab symmetry, so maybe double that to 160.
-- TODO covariant derivative function?
-- NOTICE this matches em_conn_infwire.lua, so fix both of these
local diffRiemann = (Riemann'^a_bcd,e' + Conn'^a_fe' * Riemann'^f_bcd' - Conn'^f_be' * Riemann'^a_fcd' - Conn'^f_ce' * Riemann'^a_bfd' - Conn'^f_de' * Riemann'^a_bcf')()
local Bianchi = Tensor'^a_bcde'
Bianchi['^a_bcde'] = (diffRiemann + diffRiemann:reindex{abecd='abcde'} +  diffRiemann:reindex{abdec='abcde'})()
print'Bianchi:'
local sep = ''
for index,value in Bianchi:iter() do
	local abcde = table.map(index, function(i) return coords[i].name end)
	local a,b,c,d,e = abcde:unpack()
	local bcde = table{b,c,d,e}
	if value ~= Constant(0) then
		if sep == '' then printbr() end
		print(sep, (
				var('{R^'..a..'}_{'..b..' '..c..' '..d..';'..e..'}')
				+ var('{R^'..a..'}_{'..b..' '..e..' '..c..';'..d..'}')
				+ var('{R^'..a..'}_{'..b..' '..d..' '..e..';'..c..'}')
			):eq(value))
		sep = ';'
	end
end
if sep=='' then print(0) end
printbr()
--]]

--[[ This is zeros also.
-- Since I'm defining the Riemann by the connections explicitly,
-- and the Ricci from the Riemann,
-- the torsion-free Ricci's symmetry is dependent on symmetry of C^c_ac,b = C^c_bc,a
-- since C^c_ac = (1/2 ln|g|),a, so C^c_ac,b = (1/2 ln|g|),ab = (1/2 ln|g|),ba = C^c_bc,a
local dCab = Conn'^c_ac,b'()
printbr(var'\\Gamma''^c_ac,b':eq(dCab))
--]]

for _,l in ipairs(([[
Ok, this gives me the connections that give rise to the curvature.
But the connections themselves come from the coordinate systems
and who is to say the coordinate systems do correctly align with cylindrical Minkowski?
Though their deviation from Minkowski should only be infintesimal, according to $I$ and $\lambda$
which I need to calculate in natural units and specify here ...
]]):split'\n') do printbr(l) end

-- -4/3 I^2 / r^3 - 4 lambda^2 / r

local constants = require 'grem.constants'
local wire_radius = .5 * constants.wire_diameters.electrical_range	-- m
printbr('wire_radius',wire_radius)
local wire_cross_section_area = math.pi * wire_radius^2	-- m^2
printbr('wire_cross_section_area',wire_cross_section_area)  
local wire_length = 12 * constants.in_in_m	-- m
printbr('wire_length',wire_length)  
local wire_resistivity = constants.wire_resistivities.gold
printbr('wire_resistivity',wire_resistivity)  
local wire_resistance = wire_resistivity * wire_length / wire_cross_section_area	-- m^0
printbr('wire_resistance',wire_resistance)  
--local battery_voltage_in_V = 1.5
local battery_voltage_in_V = 1e+5
local battery_voltage_in_m = battery_voltage_in_V * constants.V_in_m	-- m^0
printbr('battery_voltage_in_m',battery_voltage_in_m)  
local wire_current = battery_voltage_in_m / wire_resistance	-- amps = C / s = m / m = m^0, likewise volts = m^0, ohms = m^0, so amps = volts / ohms = m^0
printbr([[wire_current in $m^0$]],wire_current)
printbr([[wire current in $\frac{m}{s}$:]], wire_current / constants.c)

--local current_velocity = 1	-- doesn't matter if lambda = 0.  units of m/s = m^0
-- so ... inside the wire we know q=0 by Kirchoff's law
-- what about J = sigma E? doesn't that mean E = J rho, for rho = resistivity?
local wire_charge_density = 0	-- C / m^3 = m^-2
printbr('wire_charge_density',wire_charge_density)  
local wire_charge_density_per_length = wire_charge_density * wire_cross_section_area	-- m^-2 * m^2 = m^0
printbr('wire_charge_density_per_length',wire_charge_density_per_length)  

-- J is current density, in units of amperes per square meter ...
-- I current = J current density * A area, is in amperes ...
-- Ohm's law: I current = V voltage / R resistance
-- J = sigma E, E = rho J, sigma = 1/rho

--[[
drift speed: I = n A v Q
v = I / (n A Q) = 
example given https://en.wikiversity.org/wiki/Physics_equations/Current_and_current_density#Drift_speed
I = electric current = V / R = 5 Amps
n = number of charged particles per unit volume = charge carrier density = ?
A = cross-section area = .5 mm^2 = .5 (1e-3 m)^2 = 5e-7 m^2
Q = charge on each particle.  k_e = # electrons in 1 Coulomb, so 1/k_e = 1.6e-19 Coulombs = charge of an electron
v = drift velocity ~ 1e-3 m/s

5 Amps = n * 5e-7 m^2 * 1e-3 m/s * 1.6e-19 Coulombs
n = 5 Amps / (5e-7 m^2 * 1e-3 m/s * 1.6e-19 Coulombs)
n = 5 Amps / (8e-29 Coulombs m^3 / s) ... Amps = Coulombs / second ...
n = 6.25e+28 m^-3 for copper wire
n = 1.070e+28 m^-3 for silver wire ... https://en.wikipedia.org/wiki/Charge_carrier_density
--]]
