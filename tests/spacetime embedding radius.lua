#!/usr/bin/env luajit
require 'symmath'.setup{simplifyConstantPowers=true, MathJax={title='spacetime embedding radius'}}

local units = require 'symmath.physics.units'()
local m = units.m
local kg = units.kg

function process(...)
	for _,body in ipairs{...} do
		local name, info = next(body)
		info.radius = info.radius
		info.mass = info.mass:subst(units.kg_in_m)()
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
	
		--embedding diagram formulas
		local z = function(r)
			--for radial distance r, radius R, Schwarzschild radius Rs
			--inside the planet  (r <= R): z(r) = R sqrt(R/Rs) (1 - sqrt(1 - Rs/R (r/R)^2 ))
			--outside the planet (r >= R): z(r) = R sqrt(R/Rs) (1 - sqrt(1 - Rs/R)) + sqrt(4Rs(r - Rs)) - sqrt(4Rs(R - Rs))
			local R = (info.radius / m)()
			local Rs = (info.schwarzschildRadius / m)()
			local z_int = sqrt(R^3/Rs) * (1 - sqrt(1 - Rs * r^2 / R^3))
			z_int = z_int()
			local z_ext = (sqrt(R^3/Rs) * (1 - sqrt(1 - Rs/R)) + sqrt(4 * Rs * (r - Rs)) - sqrt(4 * Rs * (R - Rs)))
			-- I think simplify() is moving out a -1 from the subtractions, then sqrt()'ing it into an 'i' ... oops
			--z_ext = z_ext()
			local H = require 'symmath.Heaviside'
			local epsilon = 1e-9
			return H(R - r) * z_int + H(r - R - epsilon) * z_ext
		end

		local x = var'x'
		GnuPlot:plot{
			xlabel = 'distance from center',
			ylabel = 'embedding',
			xrange = {0, (3 * info.radius / m)().value},
			title = name..' embedding radius',
			-- TODO ... I need to embed the image into the html ...
			-- or determine in advance the destination of the output ...
			{z(x), title='z(r)'}
		}
	end
end

local au = 149597870700 * m
local pc = 3.1e+16 * m	-- = pc
local nanoarcsec = 1e-9 * pc	-- = mu as ... why do I not think this is related directly to parsec without factoring in distance?

local earthradius = 6.371e+6 * m
local earth = {radius = earthradius, mass = 5.972e+24 * kg, distance = earthradius}
process{earth=earth}

local msun = 1.989e+30 * kg
local sun = {radius = 6.955e+8 * m, mass = msun, distance = 1 * au}
process{sun=sun}

local psr_J1614_2230 = {radius = 1.8729e-5 * sun.radius, mass = 1.97 * sun.mass, distance = 1200 * pc}
process{psr_J1614_2230 = psr_J1614_2230}

local electronradius = 1.3807e-36 * m
local electron = {radius = electronradius, mass = 9.109e-31 * kg, distance = electronradius}
process{electron=electron}

local sgtastar = {radius = 52 * nanoarcsec, mass = 4e+4 * msun, distance = 8000 * pc}
process{sgtastar = sgtastar}
