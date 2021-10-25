#! /usr/bin/env lua
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='black hole brain'}}
print = printbr

symmath.simplifyConstantPowers = true

local var = symmath.var

local m = var'm'
local s = var's'
local kg = var'kg'

local c = var'c'
local cdef = c:eq(299792458 * (m / s))
print('speed of light: '..cdef)

local G = var'G'
local Gdef = G:eq(6.67408e-11 * (m^3/(kg * s^2)))
print('Gravitational constant: '..Gdef)

local hbar = var'ℏ'
local hbardef = hbar:eq(1.054571817e-34 * ((kg * m^2) / s)) -- = J s
print('reduced Planck constant: '..hbardef)

-- V = 4/3 pi r^3
-- A = 4 pi r^2
local r = var'r'
local A = var'A'
local sphereAreaForRadius = A:eq(4 * symmath.pi * r^2)
print("sphere area for radius: "..sphereAreaForRadius)
sphereAreaForRadius = sphereAreaForRadius:replace(symmath.pi, math.pi)()
print("sphere area for radius: "..sphereAreaForRadius)

local radiusForSphereArea = sphereAreaForRadius:solve(r)
print("sphere radius for area: "..radiusForSphereArea)

-- (m/s)^3 * m^2 / (m^3/(kg s^2) * kg m^2 / s)
local S = var'S'
local entropyBHForSurfaceArea = S:eq(c^3 * A / (4 * G * hbar))
print("Bekenstein-Hawking entropy for surface area: "..entropyBHForSurfaceArea)
entropyBHForSurfaceArea = entropyBHForSurfaceArea:subst(cdef, Gdef, hbardef)()
print("Bekenstein-Hawking entropy for surface area: "..entropyBHForSurfaceArea)
local entropyBHForSphereRadius = entropyBHForSurfaceArea:subst(sphereAreaForRadius)()
print("Bekenstein-Hawking entropy for sphere radius: "..entropyBHForSphereRadius)

-- m^5/s^3 / (m^5/s^3) = 1 = unitless
print('entropy of a black hole with surface area of a sphere with radius of 0.7 m: '..entropyBHForSphereRadius:replace(r, 0.7 * m)())
--5.893054975711e+69

local surfaceAreaForEntropyBH = entropyBHForSurfaceArea:solve(A)
print("surface area for Bekenstein-Hawking entropy: "..surfaceAreaForEntropyBH)
-- 9.1185922001615e-36 m sqrt(S)
-- petabyte:
--1000000000000000
--print(math.log(1000000000000000) / math.log(10))
--15.0

local sphereRadiusForEntropyBH = entropyBHForSphereRadius:solve(r)
print("sphere radius for Bekenstein-Hawking entropy: "..sphereRadiusForEntropyBH)

print('surface area of a black hole with an entropy of $10^{15}$: '..surfaceAreaForEntropyBH:replace(S, 1e+15)())
--1.0448776782866e-54

-- r = sqrt(A / pi) / 2
print('the Schwarzschild-radius of a black hole with an entropy of $10^{15}$: '..sphereRadiusForEntropyBH:replace(S, 1e+15)())
--2.8835520406756e-28

local M = var'M'
local schwarzschildRadiusForMass = r:eq((2 * M * G) / c^2)
print("Schwarzschild radius for mass: "..schwarzschildRadiusForMass)
schwarzschildRadiusForMass = schwarzschildRadiusForMass:subst(cdef, Gdef)()
print("Schwarzschild radius for mass: "..schwarzschildRadiusForMass)
local entropyBHForSchwarzschildRadiusForMass = entropyBHForSphereRadius:subst(schwarzschildRadiusForMass)()
print('Bekenstein-Hawking entropy for the Schwarzschild radius of a given mass:', entropyBHForSchwarzschildRadiusForMass)

-- is the radius of a sphere with a petabyte of bits ... just barely bigger than planck length (1e-35 m)
-- how about by mass? R = 2M schwarzschild radius ...
-- brain weights 0.4 kg ...
print('Schwarzschild radius of a black hole formed from 0.4 kg of weight', schwarzschildRadiusForMass:replace(M, 0.4 * kg)())
--2.9703661944425e-28
-- yeah, the schwarzschild radius of a brain based on its weight does have the Berkenstein-Hawking bits of about 1 petabyte, which some argue is how much bits is in a brain

print("Bekenstein-Hawking entropy for sphere with radius the Schwarzschild radius of a black hole formed from 0.4 kg of weight:", entropyBHForSchwarzschildRadiusForMass:replace(M, 0.4 * kg)())

-- But why do people argue this is the information-density of the brain?  The same equations?  No, from a different conclusion:
-- https://www.scientificamerican.com/article/what-is-the-memory-capacity/
-- 2.5 petabytes




-- alright, same trick applied to the universe?

print()
local universeRadiusEqn = r:eq(8.8e+26 * m)
print('estimated radius of the universe:', universeRadiusEqn)
print('Bekenstein-Hawking entropy of a sphere of this radius:', entropyBHForSphereRadius:subst(universeRadiusEqn)())

local universeBaryonicMassEqn = M:eq(1.5e+53 * kg)	-- est 4.9% of the universe
print('estimated mass of "ordinary matter" in the universe:', universeBaryonicMassEqn)
print('Schwarzschild radius of this mass:', schwarzschildRadiusForMass:subst(universeBaryonicMassEqn)())
print('Bekenstein-Hawking entropy of Schwarzschild radius of this mass:', entropyBHForSchwarzschildRadiusForMass:subst(universeBaryonicMassEqn)())

local universeTotalMassEqn = M:eq((1.5e+53 / .049) * kg)
print('estimated total mass of the universe:', universeTotalMassEqn)
print('Schwarzschild radius of this mass:', schwarzschildRadiusForMass:subst(universeTotalMassEqn)())
print('Bekenstein-Hawking entropy of Schwarzschild radius of this mass:', entropyBHForSchwarzschildRadiusForMass:subst(universeTotalMassEqn)())
