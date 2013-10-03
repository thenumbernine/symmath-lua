local run = ... or 'separate'

require 'symmath'

symmath.toStringMethod = 'singleLine'
symmath.simplifyConstantPowers  = true

_ = symmath.simplify

local speedOfLightInMPerS = 299792458
local gravitationalConstantInM3PerKgS2 = 6.67384e-11
local cmInM = .01
local kmInM = 1000
local lightYearInM = 9.4605284e+15
local megaParsecInM = 3.08567758e+22

m = symmath.variable('m', nil, true)

if run == 'unified' then -- unified units
	s = speedOfLightInMPerS * m	-- 1 = c m/s <=> s = c m
	kg = _(gravitationalConstantInM3PerKgS2 * m^3/s^2)  -- 1 = G m^3/(kg s^2) <=> kg = G m^3/s^2
	lyr = lightYearInM * m
	mpc = megaParsecInM * m
	function show(x) return x end
else	--default: if run == 'separate' then -- separate units
	cm = symmath.variable('cm', nil, true)
	km = symmath.variable('km', nil, true)
	s = symmath.variable('s', nil, true)
	kg = symmath.variable('kg', nil, true)
	lyr = symmath.variable('lyr', nil, true)

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
		return tostring(_(unify(x)))
		--]]
		--[[ for showing conversions
		x = _(x)
		local sx = tostring(x)
		local ux = tostring(unify(x))
		if sx == ux then return sx end
		return sx .. ' = ' .. ux
		--]]
		-- [[ convert to the most appropriate units
		x = _(unify(x))
		local amount 
		amount = x.value
		if amount then return tostring(amount) end
		amount = _(unify(x/m)).value		-- keep it in meters
		if amount > .5 * lightYearInM then
			return tostring(_(amount/lightYearInM))..' lyr'
		elseif amount > .5 * kmInM then
			return tostring(_(amount/kmInM))..' km'
		elseif amount < 10*cmInM then
			return tostring(_(amount/cmInM))..' cm'
		else
			return tostring(_(amount))..' m'
		end
		--]]
	end
end


print('1 m = 1 m')
print('1 s = '..unify(s/m).value..' m')
print('1 m = '..unify(m/kg).value..' kg')
print()

function process(bodies)
	for name, info in pairs(bodies) do
		info.radius = _(info.radius)
		info.mass = _(info.mass)
		info.embeddingRadius = _((info.radius^3 / (2 * info.mass))^.5)
		info.photonOuterOrbit = _(info.radius^2 / info.mass)
		info.schwarzschildRadius = _(info.mass * 2)
		info.photonSphereRadius = _(info.mass * 3)

		print(name..' radius = '..show(info.radius))
		print(name..' mass = '..show(info.mass))
		print(name..' embedding radius = '..show(info.embeddingRadius))
		print(name..' embedding radius to physical radius ratio = '..show(info.embeddingRadius / info.radius))
		--print(name..' photon outer orbit = '..show(info.photonOuterOrbit / lyr)..' lyr') -- not sure about this one ...
		print(name..' schwarzschild radius = '..show(info.schwarzschildRadius))
		print(name..' photon sphere radius = '..show(info.photonSphereRadius))
		print()
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
	print('z('..r..') = '..unify(z))
end

print('earth embedding at different radii...')
z(0)
z(.25 * earth.radius)
z(.5 * earth.radius)
z(earth.radius)
z(2 * earth.radius)
z(10 * earth.radius)
z(100 * earth.radius)
