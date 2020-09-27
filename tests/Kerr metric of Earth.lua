#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='Kerr metric of Earth'}}

local units = require 'symmath.physics.units'()

local m = units.m
local s = units.s
local kg = units.kg

local c = units.c
local G = units.G
local REarth = var'r_🜨'
local MEarth = var'm_🜨'

local RSch = var'r_s'
local RSchDef = RSch:eq(2 * G * MEarth / c^2)
printbr(RSchDef)

local IEarth = var'I_🜨'
local IEarthDef = IEarth:eq(frac(2,5) * MEarth * REarth^2)
printbr(IEarthDef)

local omegaEarth = var'\\omega_🜨'

local JEarth = var'J_🜨'
local JEarthDef = JEarth:eq(IEarth * omegaEarth)
printbr(JEarthDef)

JEarthDef = JEarthDef:subst(IEarthDef)():factorDivision()
printbr(JEarthDef)

local a = var'a'
local aDef = a:eq(JEarth / (MEarth * c))
printbr(aDef)

aDef = aDef:subst(JEarthDef)()
printbr(aDef)

printbr'with numerical values:'

symmath.simplifyConstantPowers = true

printbr(units.c_in_m_s)
printbr(units.G_in_SI)

local REarthNumDef = REarth:eq(6371e+3 * m)
printbr(REarthNumDef)

local MEarthNumDef = MEarth:eq(5.792e+24 * kg)
printbr(MEarthNumDef)

local RSchNumDef = RSchDef:subst(units.G_in_SI, MEarthNumDef, units.c_in_m_s)()
printbr(RSchNumDef)

local omegaEarthNumDef = omegaEarth:eq(2 * pi/((4 + 60*(56 + 60*23))*s))
printbr(omegaEarthNumDef, [[= sidereal rotation of Earth]])

omegaEarthNumDef = omegaEarthNumDef:subst(units.s_in_m)():factorDivision()
printbr(omegaEarthNumDef)

local IEarthNumDef = IEarthDef:subst(MEarthNumDef, REarthNumDef)()
printbr(IEarthNumDef)

local JEarthNumDef = JEarthDef:subst(omegaEarthNumDef, MEarthNumDef, REarthNumDef, pi:eq(math.pi))():factorDivision()
printbr(JEarthNumDef)

local aNumDef = aDef:subst(omegaEarthNumDef, MEarthNumDef, REarthNumDef, units.c_eq_1, pi:eq(math.pi))()
printbr(aNumDef)


local t = var't'
local r = var'r'
local theta = var'\\theta'
local phi = var'\\phi'

local Sigma = var'\\Sigma'
local SigmaDef = Sigma:eq(r^2 + a^2 * cos(theta)^2)
printbr(SigmaDef)

local Delta = var'\\Delta'
local DeltaDef = Delta:eq(r^2 - RSch * r + a^2)
printbr(DeltaDef)

local A = var'A'
local ADef = A:eq((r^2 + a^2)^2 - a^2 * Delta * sin(theta)^2)
printbr(ADef)

Tensor.coords{{variables={t,r,theta,phi}}}

-- from Kerr Metric Wikipedia / 2010 Muller, Grave "Catalog of Spacetimes" / 1972 Bardeen, Press, Teukolsky "Rotating Black Holes..."
local rs_r_a_sin_theta_sq_over_sigma = (RSch*r*a*sin(theta)^2)/Sigma
local g_tt = -(1 - RSch*r/Sigma)
local g_t_phi = -rs_r_a_sin_theta_sq_over_sigma 

--[[
Wiki and Bardeen says (r^2 + a^2 + (RSch * r * a^2 * sin(theta)^2)/Sigma) * sin(theta)^2
Rezzolla says A/Sigma^2
do they match:
A/Sigma^2
= ( (r^2 + a^2)^2 - a^2 * Delta * sin(theta)^2 ) / Sigma^2
= ( r^4 + 2 r^2 a^2 + a^4 - a^2 * (r^2 - rs r + a^2) * sin(theta)^2 ) / (r^2 + a^2 cos(theta)^2)^2
= ( r^4 + 2 r^2 a^2 + a^4 - a^2 r^2 sin(theta)^2 + a^2 rs r sin(theta)^2 - a^4 sin(theta)^2 ) / (r^2 + a^2 cos(theta)^2)^2
= ( r^4 + r^2 a^2 + r^2 a^2 cos(theta)^2 + a^2 rs r - a^2 rs r cos(theta)^2 + a^4 cos(theta)^2 ) / (r^2 + a^2 cos(theta)^2)^2
...
--]]
local g_phi_phi = (r^2 + a^2 + (RSch * r * a^2 * sin(theta)^2)/Sigma) * sin(theta)^2

local g = var'g'
printbr(g' _\\phi _\\phi':eq(g_phi_phi))
printbr((A / Sigma^2):eq(
	(ADef[2] / SigmaDef[2]^2)()
))

local gDef = g'_ab':eq(Tensor('_ab',
	{g_tt, 0, 0, g_t_phi},
	{0, Sigma / Delta, 0, 0},
	{0, 0, Sigma, 0},
	{g_t_phi, 0, 0, g_phi_phi}
))
printbr(gDef)

--[[ see if my inverse() can handle it
local gDetDef = g:eq(Matrix.determinant(gDef[2]))
printbr(gDetDef)

local guDef = g'^ab':eq(Tensor('^ab', table.unpack((Matrix.inverse(gDef[2], nil, nil, nil, g))) ))
--]]
-- [[ taken from 1972 Bardeen, Press, Teukolsky "Rotating Black Holes..."
local guDef = g'^ab':eq(Tensor('^ab',
	{-A / (Sigma * Delta), 0, 0, -(RSch * a * r) / (Sigma * Delta)},
	{0,	Delta / Sigma, 0, 0},
	{0, 0, 1 / Sigma, 0},
	{-(RSch * a * r) / (Sigma * Delta), 0, 0, (Delta - a^2 * sin(theta)^2) / (Sigma * Delta * sin(theta)^2)}
))
--]]
printbr(guDef)

local gEarthDef = gDef:subst(
	SigmaDef,
	DeltaDef,
	aNumDef,
	RSchNumDef
)()
printbr(gEarthDef)

printbr'at earth surface:'
gEarthDef = gEarthDef:replace(theta, pi/2):replace(r, REarthNumDef[2])()
printbr(gEarthDef)
