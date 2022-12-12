#!/usr/bin/env luajit
-- 1998 Vinti, Der, Bonavito. "Orbital and Celestial Mechanics"

local env = setmetatable({}, {__index=_G})
require 'ext.env'(env)
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env}
local MathJax = symmath.export.MathJax
symmath.tostring = MathJax
local printbr = MathJax.print
MathJax.header.title = 'Keplerian Orbital Elements'
print(MathJax.header)

local function ahref(x)
	printbr("<a href='"..x.."'>"..x.."</a>")
end

ahref'https://en.wikipedia.org/wiki/Orbital_elements'
ahref'https://en.wikipedia.org/wiki/Eccentric_anomaly'
ahref'https://en.wikipedia.org/wiki/Mean_anomaly'
ahref'https://en.wikipedia.org/wiki/Standard_gravitational_parameter'
ahref'https://en.wikipedia.org/wiki/Longitude_of_the_periapsis'
ahref'https://en.wikipedia.org/wiki/Semi-major_and_semi-minor_axes'
ahref'https://en.wikipedia.org/wiki/Conic_section#Conic_parameters'
ahref'https://astronomy.stackexchange.com/questions/632/determining-effect-of-small-variable-force-on-planetary-perihelion-precession'
ahref'https://en.wikipedia.org/wiki/Two-body_problem_in_general_relativity'
ahref'https://en.wikipedia.org/wiki/Laplace%E2%80%93Runge%E2%80%93Lenz_vector#Evolution_under_perturbed_potentials'

-- units

local units = require 'symmath.physics.units'()
local m = units.m
printbr(m, '= meter')

local kg = units.kg
printbr(kg, '= kilogram')

local s = units.s
printbr(s, '= second')

-- constants

local G = var'G'
printbr(G, '= gravitational constant')
local Gdef = G:eq(6.6738480e-11 * frac(m^3, kg * s^2))
printbr(Gdef)

-- properties

local mass = var'Mass'
printbr(mass, '= mass')

local massParent = var'Mass_{parent}'
printbr(massParent, '= parent mass')

local gravitationalParameter = var'\\mu'
printbr(gravitationalParameter, '= gravitational parameter')
local gravitationalParameterDef = gravitationalParameter:eq(G * (mass + massParent))
printbr(gravitationalParameterDef)

local L = var'L'	-- angular momentum
printbr(L, '= angular momentum')

-- KOE

local eccentricity = var'e'	-- eccentricity
printbr(eccentricity, '= eccentricity')

local l = var'l'	-- semi-latus rectum
printbr(l, '= semi-latus rectum')
local ldef = l:eq(L^2 / G)
printbr(ldef)

local i = var'i'	-- inclination
printbr(i, '= inclination')

local Omega = var'\\Omega'
printbr(Omega, '= longitude of ascending node')

local omega = var'\\omega'
printbr(omega, '= argument of periapsis')

local a = var'a'	-- semi-major axis
printbr(a, '= semi-major axis')

local b = var'b'
printbr(b, '= semi-minor axis')

local bdef1 = b:eq(sqrt(a * l))
printbr(bdef1)

local bdef2 = b:eq(a * sqrt(1 - eccentricity^2))
printbr(bdef2)

local ldef2 = l:eq(a * (1 - eccentricity^2))
printbr(ldef2)

local Avec = var'\\vec{A}'	-- Vinti semi-major axis vector
printbr(Avec, '= semi-major axis vector')
local Avecdef = Avec:eq(Matrix{
    a * (cos(Omega) * cos(omega) - sin(Omega) * sin(omega) * cos(i)),
    a * (sin(Omega) * cos(omega) + cos(Omega) * sin(omega) * cos(i)),
    a *                                         sin(omega) * sin(i)
}:T())
printbr(Avecdef)

local Bvec = var'\\vec{B}'
printbr(Bvec, '= semi-minor axis vector')
local Bvecdef = Bvec:eq(Matrix{
    -b * ( cos(Omega) * sin(omega) + sin(Omega) * cos(omega) * cos(i)),
     b * (-sin(Omega) * sin(omega) + cos(Omega) * cos(omega) * cos(i)),
     b *                                          cos(omega) * sin(i)
}:T())
printbr(Bvecdef)

local orbitalPeriod = var'T'
printbr(orbitalPeriod, '= orbital period')
local orbitalPeriodDef = orbitalPeriod:eq(2 * pi * sqrt(a^3 / gravitationalParameter))
printbr(orbitalPeriodDef, ": Kepler's 3rd law")

-- ugly ... cuz it's not factoring the cube-root ... (TODO?)
--local semiMajorAxisFor3rdLaw = orbitalPeriodDef:solve(a)()
local semiMajorAxisFor3rdLaw = a:eq(cbrt(frac(gravitationalParameter * orbitalPeriod^2, 4 * pi^2)))
printbr(semiMajorAxisFor3rdLaw)

local rvec = var'\\vec{r}'
printbr(rvec, '= position')

local d = var'd'
printbr(d, '= distance to parent')
local ddef = d:eq(abs(rvec))

local eccentricAnomaly = var'E'
printbr(eccentricAnomaly, '= eccentric anomaly')
local Edef = cos(eccentricAnomaly):eq((1 - d / a) / eccentricity)
printbr(Edef)

local meanAnomalyAtEpoch = var'M_0'
printbr(meanAnomalyAtEpoch, '= mean anomaly at epoch')

local t = var't'
printbr(t, '= time')

local t0 = var't_0'
printbr(t0, '= epoch')

local meanMotion = var'n'
printbr(meanMotion, '= mean motion')
local meanMotionDef = meanMotion:eq(2 * pi / orbitalPeriod)
printbr(meanMotionDef)

local angle = var'\\theta'
printbr(angle, '= angle of orbit (better name?)')
local angleDef = angle:eq(meanMotion * (t - t0))
printbr(angleDef)

local meanAnomaly = var'M'
printbr(meanAnomaly, 'mean anomaly')
local meanAnomalyDef1 = meanAnomaly:eq(meanAnomalyAtEpoch + meanMotion * (t - t0))
printbr(meanAnomalyDef1)
local meanAnomalyDef2 = meanAnomaly:eq(eccentricAnomaly - eccentricity * sin(eccentricAnomaly))
printbr(meanAnomalyDef2)
printbr[[
This equation relates E to M, and the previous relates M to t, 
so from these two you can calculate E based on t.
Also notice that all arguments of $\vec{A}$ and $\vec{B}$ are not determined by time.
]]

local rvecdef = rvec:eq(
	(cos(eccentricAnomaly) - eccentricity) * Avec
	+ sin(eccentricAnomaly) * Bvec
)
printbr(rvecdef)

print(MathJax.footer)
