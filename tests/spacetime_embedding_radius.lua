#!/usr/bin/env luajit
require 'symmath'.setup{simplifyConstantPowers=true}
require 'symmath.tostring.MathJax'.setup{title='Spacetime Embedding Function'}

local const_c = 299792458
local const_G = 6.67384e-11

local m = var'm'
local cm = var'cm'
local km = var'km'
local s = var's'
local kg = var'kg'
local lyr = var'lyr'

local c = var'c'
local c_from_m_s = c:eq(const_c * (m / s))
printbr(c_from_m_s)
local s_from_m = c_from_m_s:subst(c:eq(1)):solve(s)
printbr(s_from_m)

local G = G or var'G'
local G_from_kg_m_s = G:eq(const_G * (m^3 / (kg * s^2)))
printbr(G_from_kg_m_s)
local kg_from_m = G_from_kg_m_s:subst(G:eq(1)):subst(s_from_m):solve(kg) 
printbr(kg_from_m)

function process(bodies)
	for name, info in pairs(bodies) do
		info.radius = info.radius
		info.mass = info.mass:subst(kg_from_m)
		info.embeddingRadius = sqrt(info.radius^3 / (2 * info.mass))()
		info.photonOuterOrbit = (info.radius^2 / info.mass)()
		info.schwarzschildRadius = (info.mass * 2)()
		info.photonSphereRadius = (info.mass * 3)()

		printbr(name..' radius = '..info.radius)
		printbr(name..' mass = '..info.mass)
		printbr(name..' embedding radius = '..info.embeddingRadius)
		printbr(name..' embedding radius to physical radius ratio = '..(info.embeddingRadius / info.radius)())
		--printbr(name..' photon outer orbit = '..(info.photonOuterOrbit / lyr)..' lyr') -- not sure about this one ...
		printbr(name..' schwarzschild radius = '..info.schwarzschildRadius)
		printbr(name..' photon sphere radius = '..info.photonSphereRadius)
		printbr()
	end
end

earth = {radius = 6.371e+6 * m, mass = 5.972e+24 * kg}
sun = {radius = 6.955e+8 * m, mass = 1.989e+30 * kg}
psr = {radius = 1.8729e-5 * sun.radius, mass = 1.97 * sun.mass}
process{earth=earth, sun=sun, psr=psr}
do return end

--earth embedding diagram formulas
function z(r)
	--for radial distance r, radius R, Schwarzschild radius Rs
	--inside the planet  (r <= R): z(r) = R sqrt(R/Rs) (1 - sqrt(1 - Rs/R (r/R)^2 ))
	--outside the planet (r >= R): z(r) = R sqrt(R/Rs) (1 - sqrt(1 - Rs/R)) + sqrt(4Rs(r - Rs)) - sqrt(4Rs(R - Rs))
	local R = earth.radius
	local Rs = earth.schwarzschildRadius
	local z
	if (r/m)().value < (R/m)().value then
		z = (R^3/Rs)^.5 * (1 - (1 - Rs * r^2 / R^3)^.5)
	else
		z = (R^3/Rs)^.5 * (1 - (1 - Rs/R)^.5) + (4 * Rs * (r - Rs))^.5 - (4 * Rs * (R - Rs))^.5
	end
	printbr('z('..r..') = '..z)
end

printbr('earth embedding at different radii...')
z(0)
z(.25 * earth.radius)
z(.5 * earth.radius)
z(earth.radius)
z(2 * earth.radius)
z(10 * earth.radius)
z(100 * earth.radius)

print(MathJax.footer)
