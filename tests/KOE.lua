#!/usr/bin/env luajit
-- 1998 Vinti, Der, Bonavito. "Orbital and Celestial Mechanics"
-- https://en.wikipedia.org/wiki/Orbital_elements
-- https://en.wikipedia.org/wiki/Eccentric_anomaly
-- https://en.wikipedia.org/wiki/Mean_anomaly
-- https://en.wikipedia.org/wiki/Standard_gravitational_parameter
-- https://en.wikipedia.org/wiki/Longitude_of_the_periapsis
-- https://en.wikipedia.org/wiki/Semi-major_and_semi-minor_axes
-- https://en.wikipedia.org/wiki/Conic_section#Conic_parameters

local env = setmetatable({}, {__index=_G})
require 'ext.env'(env)
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env}
local MathJax = symmath.export.MathJax
symmath.tostring = MathJax
local printbr = MathJax.print
MathJax.header.title = 'Keplerian Orbital Elements'
print(MathJax.header)

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

local mu = var'\\mu'
printbr(mu, '= gravitational parameter')
local mudef = mu:eq(G * (mass + massParent))
printbr(mudef)

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

local P = var'P'
printbr(P, '= orbital period')
local pdef = P:eq(2 * pi * sqrt(a^3 / mu))
printbr(pdef)

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
local meanMotionDef = meanMotion:eq(2 * pi / P)
printbr(meanMotionDef)

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
