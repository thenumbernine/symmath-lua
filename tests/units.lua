#!/usr/bin/env luajit
local run = ... or 'separate'

local symmath = require 'symmath'

local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
symmath.simplifyConstantPowers  = true

local function printbr(...)
	print(...)
	print('<br>')
end

print(MathJax.header)

local speedOfLightInMPerS = 299792458
local gravitationalConstantInM3PerKgS2 = 6.67384e-11
local cmInM = .01
local kmInM = 1000
local lightYearInM = 9.4605284e+15
local megaParsecInM = 3.08567758e+22

m = symmath.Variable('m')

if run == 'unified' then -- unified units
	s = speedOfLightInMPerS * m	-- 1 = c m/s <=> s = c m
	kg = symmath.simplify(gravitationalConstantInM3PerKgS2 * m^3/s^2)  -- 1 = G m^3/(kg s^2) <=> kg = G m^3/s^2
	lyr = lightYearInM * m
	mpc = megaParsecInM * m
	function show(x) return x end
else	--default: if run == 'separate' then -- separate units
	cm = symmath.Variable('cm')
	km = symmath.Variable('km')
	s = symmath.Variable('s')
	kg = symmath.Variable('kg')
	lyr = symmath.Variable('lyr')

	function unify(x)
		if type(x) == 'number' then return x end
		x = symmath.simplify(symmath.replace(x, kg, gravitationalConstantInM3PerKgS2 * m^3 / s^2)) 
		x = symmath.simplify(symmath.replace(x, s, speedOfLightInMPerS * m))
		x = symmath.simplify(symmath.replace(x, mpc, megaParsecInM * m))
		x = symmath.simplify(symmath.replace(x, lyr, lightYearInM * m))
		x = symmath.simplify(symmath.replace(x, cm, cmInM * m))
		return x
	end
	function show(x)
		--[[ convert to meters
		return tostring(symmath.simplify(unify(x)))
		--]]
		--[[ for showing conversions
		x = symmath.simplify(x)
		local sx = tostring(x)
		local ux = tostring(unify(x))
		if sx == ux then return sx end
		return sx .. ' = ' .. ux
		--]]
		-- [[ convert to the most appropriate units
		x = symmath.simplify(unify(x))
		local amount 
		amount = x.value
		if amount then return tostring(amount) end
		amount = symmath.simplify(unify(x/m)) 		-- keep it in meters
		amount = amount.value
		if amount > .5 * lightYearInM then
			return tostring(symmath.simplify(amount/lightYearInM))..' lyr'
		elseif amount > .5 * kmInM then
			return tostring(symmath.simplify(amount/kmInM))..' km'
		elseif amount < 10*cmInM then
			return tostring(symmath.simplify(amount/cmInM))..' cm'
		else
			return tostring(symmath.simplify(amount))..' m'
		end
		--]]
	end
end


printbr('1 m = 1 m')
printbr('1 s = '..unify(s/m)..' m')
printbr('1 m = '..unify(m/kg)..' kg')
printbr()

function process(bodies)
	for name, info in pairs(bodies) do
		info.radius = symmath.simplify(info.radius)
		info.mass = symmath.simplify(info.mass)
		info.embeddingRadius = symmath.simplify((info.radius^3 / (2 * info.mass))^.5)
		info.photonOuterOrbit = symmath.simplify(info.radius^2 / info.mass)
		info.schwarzschildRadius = symmath.simplify(info.mass * 2)
		info.photonSphereRadius = symmath.simplify(info.mass * 3)

		printbr(name..' radius = '..show(info.radius))
		printbr(name..' mass = '..show(info.mass))
		printbr(name..' embedding radius = '..show(info.embeddingRadius))
		printbr(name..' embedding radius to physical radius ratio = '..show(info.embeddingRadius / info.radius))
		--printbr(name..' photon outer orbit = '..show(info.photonOuterOrbit / lyr)..' lyr') -- not sure about this one ...
		printbr(name..' schwarzschild radius = '..show(info.schwarzschildRadius))
		printbr(name..' photon sphere radius = '..show(info.photonSphereRadius))
		printbr()
	end
end

earth = {radius = 6.371e+6 * m, mass = 5.972e+24 * kg}
sun = {radius = 6.955e+8 * m, mass = 1.989e+30 * kg}
psr = {radius = 1.8729e-5 * sun.radius, mass = 1.97 * sun.mass}
process{earth=earth, sun=sun, psr=psr}

--earth embedding diagram formulas
function z(r)
	--for radial distance r, radius R, Schwarzschild radius Rs
	--inside the planet  (r <= R): z(r) = R sqrt(R/Rs) (1 - sqrt(1 - Rs/R (r/R)^2 ))
	--outside the planet (r >= R): z(r) = R sqrt(R/Rs) (1 - sqrt(1 - Rs/R)) + sqrt(4Rs(r - Rs)) - sqrt(4Rs(R - Rs))
	local R = earth.radius
	local Rs = earth.schwarzschildRadius
	local z
	if unify(r/m).value < unify(R/m).value then
		z = (R^3/Rs)^.5 * (1 - (1 - Rs * r^2 / R^3)^.5)
	else
		z = (R^3/Rs)^.5 * (1 - (1 - Rs/R)^.5) + (4 * Rs * (r - Rs))^.5 - (4 * Rs * (R - Rs))^.5
	end
	printbr('z('..r..') = '..unify(z))
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
