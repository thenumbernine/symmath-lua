#! /usr/bin/env luajit
require 'ext'
local _ENV = _ENV or getfenv()
require 'symmath'.setup{env=_ENV}
require 'symmath.tostring.MathJax'.setup{usePartialLHSForDerivative=true, env=_ENV}

local t,r,phi,z = vars('t', 'r', '\\phi', 'z')
local pi = var'\\pi'

--[[
local epsilon_0 = var'\\epsilon_0'
local mu_0 = var'\\mu_0'
--]]
-- [[
local mu_0 = 4 * pi
local epsilon_0 = 1 / mu_0
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
local E_r, E_phi, E_z = table.unpack(E)

local B = Tensor('_i', function(i) return var('B_'..spatialCoords[i].name, coords) end)
local B_r, B_phi, B_z = table.unpack(B)

local S = (LeviCivita3'_i^jk' * E'_j' * B'_k')()

--printbr(var'E''_i':eq(E))
--printbr(var'B''_i':eq(B))
--printbr(var'S''_i':eq(S))

local ESq_plus_BSq = (E'_i' * E'_j' * gammaU'^ij' + B'_i' * B'_j' * gammaU'^ij')()

-- taken from my electrovacuum.lua script
local RicciEM = Tensor'_ab'
RicciEM['_tt'] = Tensor('_tt', {ESq_plus_BSq})
RicciEM['_ti'] = Tensor('_ti', (-2 * S'_i')())
RicciEM['_it'] = Tensor('_ti', (-2 * S'_i')())
RicciEM['_ij'] = (-2 * E'_i' * E'_j' - 2 * B'_i' * B'_j' + ESq_plus_BSq * gamma'_ij')()

local lambda = var'\\lambda'
local I = var'I'
printbr'for a uniformly charged wire...'
-- TODO http://www.physicspages.com/2013/11/18/electric-field-outside-an-infinite-wire/
RicciEM = RicciEM
	-- http://farside.ph.utexas.edu/teaching/302l/lectures/node26.html
	:replace(E_r, lambda / (2 * pi * epsilon_0 * r))
	:replace(E_phi, 0)
	:replace(E_z, 0)
	-- http://hyperphysics.phy-astr.gsu.edu/hbase/magnetic/magcur.html
	:replace(B_r, 0)
	:replace(B_phi, mu_0 * I / (2 * pi))	-- this is B_phiHat = mu_0 I / (2 pi r) ... but B_phiHat = 1/r B_phi ... so B_phi = I mu_0 / (2 pi)
	:replace(B_z, 0)
	:simplify()
--printbr(var'R''_ab':eq(RicciEM'_ab'()))

-- clear the metric
do
	local basis = Tensor.metric() basis.metric = nil basis.metricInverse = nil
	local basis = Tensor.metric(nil, nil, 'i') basis.metric = nil basis.metricInverse = nil
end

local Conn = Tensor'^a_bc'

--[[ 
Conn[2][1][1] = var('a',{r})
Conn[1][2][1] = var('d',{r}) * I / r^2
Conn[1][1][2] = var('g',{r})

Conn[2][1][4] = var('b',{r})
Conn[2][4][1] = var('c',{r})
Conn[2][2][2] = lambda -- var('h',{r})

Conn[2][3][3] = var('e',{r})
Conn[2][4][4] = var('f',{r})
--]]

-- [[ tada!
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
Ricci:print'R'
print(var'R''_ab':eq(Ricci))

print('vs Ricci of EM stress-energy tensor')
RicciEM:print'R'
printbr()

printbr"EM with no current -- in frame of wire carrier drift velocity, right?  How do you apply Lorentz boost to create this setup?"
RicciEM:replace(I, 0)():print'R'
printbr()

printbr'EM with no charge -- in rest frame -- purely magnetic field'
local RicciEMNoCharge = RicciEM:replace(lambda, 0)()
RicciEMNoCharge:print'R'
printbr()

local beta = var'\\beta'
local gamma = var'\\gamma'
local LorentzBoost = Tensor('^a_b', 
	{gamma, 0, 0, -beta * gamma},
	{0, 1, 0, 0},
	{0, 0, 1, 0},
	{-beta * gamma, 0, 0, gamma})

printbr[[
If the wire has either no current or no charge then $R_{tz}$ will be zero.
If $R_{tz}$ is zero then there is no way to apply a Lorentz transformation to create this term (right?).
There would also be no way to transform a EM stress-energy of purely current (observer frame) into one of purely current (frame of charge carriers).
]]

printbr'Lorentz boost'
LorentzBoost:print'\\Lambda'
printbr()

local RicciEMBoosted = (RicciEM'_cd' * LorentzBoost'^c_a' * LorentzBoost'^d_b')()
printbr'EM boosted:'
RicciEMBoosted:print'R' 
printbr()

local RicciEMNoChargeBoosted = (RicciEMNoCharge'_cd' * LorentzBoost'^c_a' * LorentzBoost'^d_b')
	:simplify()
	:replace(gamma^2, 1/(1 - beta^2))
	:simplify()
printbr'EM, no charge, boosted:'
RicciEMNoChargeBoosted:print'R'
printbr()

local J = Tensor('_a', 0, 0, 0, I)
printbr'four-current in rest frame. no charge, only current:'
J:print'J'
printbr()

JBoosted = (J'_b' * LorentzBoost'^b_a')()
printbr'four-current boosted'
JBoosted:print'J'
printbr()

--[[
... but how do we boost to get the new frame's current equal to zero?
for that we solve 0 = -8 I^2 beta / (r^4 (1 - beta^2))
and that means beta = 0 ...
unless all I terms have to be replaced with something ...
	I^2 -> (I^2 - lambda^2 r^2)
... in order to represent the current in the new field
... why is that?
Lorentz transform on 4-current:
J_a = [0, 0, 0, I]
J_a' = [-beta gamma I, 0, 0, gamma I]
so there's your new lambda: equal to beta gamma I
...and your new I is gamma I 
--]]
printbr'EM, no charge, boosted, with four-current exchanged as well'
local tmp = RicciEMBoosted	-- start with the with-charge boosted Ricci, so we can replace the lambda with the boosted J_t'
	:replace(lambda, JBoosted[1])
	:replace(I, JBoosted[4])
	:simplify()
	:replace(gamma^4, 1/(1-beta^2)^2)
	:simplify()
tmp:print'R'
printbr()

--[[
I = rest-frame current.  no charge
I', lambda' = new current, charge
-8 I' lambda' / r^3 = -8 I^2 beta / (r^4 (1 - beta^2))
solve for beta
-8 I' lambda' r^4 (1 - beta^2) = -8 I^2 r^3 beta
(I' / I^2)  lambda' r (beta^2 - 1) + beta = 0 
beta = (-1 +- sqrt( 1 - 4 ((I' / I^2)  lambda' r)^2 ) ) / (2 (I' / I^2)  lambda' r)
beta = (-1 +- sqrt( 1 - 4 lambda'^2 r^2 I'^2 / I^4 ) ) / (2 lambda' r I' / I^2)
beta = (-1 +- (I' / I^2) sqrt( I^4 / I'^2 - 4 lambda'^2 r^2 ) ) / (2 lambda' r I' / I^2)
beta = (-(I' / I^2) / (I' / I^2) +- (I' / I^2) sqrt( I^4 / I'^2 - 4 lambda'^2 r^2 ) ) / (2 lambda' r I' / I^2)
beta = (-I^2 / I' +- sqrt( I^4 / I'^2 - 4 lambda'^2 r^2 ) ) / (2 lambda' r)
--]]

RicciBoostedToCreateB = RicciEMNoChargeBoosted
	:replace(beta, (-I + sqrt(I^2 - 4 * lambda^2 * r^2)) / (2 * lambda * r))
	:simplify()
printbr'Ricci without charge, then boosted to recreate B'
RicciBoostedToCreateB:print'R'
printbr()

--[[
to eliminate B, solve for beta 0 = (lambda I r) beta^2 + (I^2 + lambda^2 r^2) beta + lambda I r
beta = ( -(I^2 + lambda^2 r^2) +- sqrt( (I^2 + lambda^2 r^2)^2 - 4 (lambda I r) lambda I r ) ) / (2 lambda I r)
beta = ( -I^2 - lambda^2 r^2 +- sqrt( I^4 + 2 I^2 lambda^2 r^2 + lambda^4 r^4 - 4 lambda^2 I^2 r^2 ) ) / (2 lambda I r)
beta = ( -I^2 - lambda^2 r^2 +- sqrt( I^4 - 2 I^2 lambda^2 r^2 + lambda^4 r^4 ) ) / (2 lambda I r)
beta = ( -I^2 - lambda^2 r^2 +- sqrt( (I^2 - lambda^2 r^2)^2 ) )  / (2 lambda I r)
beta = ( -I^2 - lambda^2 r^2 +- I^2 -+ lambda^2 r^2) / (2 lambda I r)

beta = ( -I^2 - lambda^2 r^2 + I^2 - lambda^2 r^2) / (2 lambda I r)
beta = ( - 2 lambda^2 r^2 ) / (2 lambda I r)
beta = -lambda r / I

beta = ( -I^2 - lambda^2 r^2 - I^2 + lambda^2 r^2) / (2 lambda I r)
beta = ( -2 I^2) / (2 lambda I r)
beta = -I / (lambda r)

oh yeah, lambda is zero for the rest frame ...
--]]

os.exit()


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

-- grem.constants doesn't work with implicitVars
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
