#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, simplifyConstantPowers=true, MathJax={title='spacetime embedding radius'}}

local units = require 'symmath.physics.units'()
local m = units.m
local kg = units.kg
local H = require 'symmath.Heaviside'


--for radial distance r, radius R, Schwarzschild radius Rs
--inside the planet  (r <= R): z(r) = R sqrt(R/Rs) (1 - sqrt(1 - Rs/R (r/R)^2 ))
--outside the planet (r >= R): z(r) = R sqrt(R/Rs) (1 - sqrt(1 - Rs/R)) + sqrt(4Rs(r - Rs)) - sqrt(4Rs(R - Rs))
local zvar = var'z'
local rvar = var'r'
local Rvar = var'R'
local Rsvar = var'rs'
local epsilonvar = var'\\epsilon'
local z_int_def = zvar:eq(sqrt(Rvar^3/Rsvar) * (1 - sqrt(1 - Rsvar * rvar^2 / Rvar^3)))
local z_ext_def = zvar:eq(sqrt(Rvar^3/Rsvar) * (1 - sqrt(1 - Rsvar/Rvar)) + sqrt(4 * Rsvar * (rvar - Rsvar)) - sqrt(4 * Rsvar * (Rvar - Rsvar)))
local z_def = zvar:eq(H(Rvar - rvar) * z_int_def:rhs() + H(rvar - Rvar - epsilonvar) * z_ext_def:rhs())
printbr('embedding function of spacetime inside a planet of radius', R, 'with Schwarzschild mass', Rs, ':')
printbr(z_int_def)
printbr('embedding function of spacetime outside the planet:')
printbr(z_ext_def)
printbr('combined:')
printbr(z_def)
printbr()


function process(args)
	local name = args.name
	local info = args.body
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
	local z = function(r, rmax)
		return z_def:rhs()
			:replace(Rvar, (info.radius / m)())
			:replace(Rsvar, (info.schwarzschildRadius / m)())
			:replace(rvar, r)
			:replace(epsilonvar, rmax * 1e-9)
	end
	
	local x = var'x'
	local rmax = (3 * info.radius / m)().value
	GnuPlot:plot{
		xlabel = 'distance from center',
		ylabel = 'embedding',
		xrange = {0, rmax},
		--yrange = {0, z(x):replace(x, 3*info.radius/m)().value},
		title = name..' embedding radius',
		-- TODO ... I need to embed the image into the html ...
		-- or determine in advance the destination of the output ...
		{
			z(x, rmax),
			title='z(r)',
		},
--		{
--			sqrt((info.radius / m)()^2 - x^2),
--			title = 'radius',
--		}
	}
end

local au = 149597870700 * m
local pc = 3.1e+16 * m	-- = pc
local nanoarcsec = 1e-9 * pc	-- = mu as ... why do I not think this is related directly to parsec without factoring in distance?

local earthradius = 6.371e+6 * m
local earth = {radius = earthradius, mass = 5.972e+24 * kg}
process{name='earth', body=earth}

local msun = 1.989e+30 * kg
local sun = {radius = 6.955e+8 * m, mass = msun}
process{name='sun', body=sun}

local psr_J1614_2230 = {radius = 1.8729e-5 * sun.radius, mass = 1.97 * sun.mass}
process{name='psr_J1614_2230', body=psr_J1614_2230}

local electronradius = 1.3807e-36 * m
local electron = {radius = electronradius, mass = 9.109e-31 * kg}
process{name='electron', body=electron}

local sgtastar = {radius = 52 * nanoarcsec, mass = 4e+4 * msun}
process{name='sgtastar', body=sgtastar}

process{
	name = 'human',
	body = {
		radius = .86 * m,
		mass = 80 * kg,
	},
}
