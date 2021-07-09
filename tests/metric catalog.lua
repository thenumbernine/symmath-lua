#!/usr/bin/env luajit
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{
	env = env,
	implicitVars = true,
	MathJax = {
		title = 'Metric Catalog',
	},
}

-- implicitVars will cover this automatically:
local t,x,y,z = vars('t','x','y','z')
-- fixVariableNames would cover this automatically:

-- r is in reals >= 0
local r = set.nonNegativeReal:var'r'

-- phi doesn't matter because its whole domain is going to get +s and -s from cos(phi) and sin(phi)
local phi = var'\\phi'

-- but theta, in spherical, should be only 0-pi (and for 2D polar, same?)
-- 		TODO hmm now I see a reason to use symbols with domains instead of ieee floats...
local theta = set.RealSubset(0, math.pi, true, false):var'\\theta'

-- unless I set 'fixVariableNames' I will have to explicitly define all the Greek symbols...
-- this is used by sphere-sinh-radial
local rho = set.nonNegativeReal:var'\\rho'

-- used for Schwarzschild radius or for torus radius
local R = set.nonNegativeReal:var'R'

local alpha = var('\\alpha', {r})
local omega = set.nonNegativeReal:var'\\omega'
local q = var('q', {t,x,y,z})


-- background metrics
local delta2 = Matrix:lambda({2,2}, function(i,j) return i==j and 1 or 0 end)
local delta3 = Matrix:lambda({3,3}, function(i,j) return i==j and 1 or 0 end)
local eta3 = Matrix:lambda({3,3}, function(i,j) return i==j and (i==1 and -1 or 1) or 0 end)
local eta4 = Matrix:lambda({4,4}, function(i,j) return i==j and (i==1 and -1 or 1) or 0 end)


local spacetimes = {
	{
		title = 'Cartesian, coordinate',
		baseCoords = {x,y},
		embedded = {x,y},
		flatMetric = delta2,
		chart = function() 
			return Tensor('^I', x, y)
		end,
	},

--[[
-- the latest thing this needs to pass: Integrate(u/(1 + u^2), u)()
-- I need to either fix my polynomial factoring, or implement a matrix inverse based on adjacency matrix / Levi-Civita permutation tensor in order to get these to run automatically
-- ... or (for the time being) just specify the inverse metric manually
	{
		title = 'paraboliod, coordinate',
		baseCoords = {u,v},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			return Tensor('^I', u, v, -frac(1,2) * (u^2 + v^2))
		end,
		-- e_u = [1, 0, -u]
		-- e_v = [0, 1, -v]
		-- g_ab = {{1 + u^2, uv}, {uv, 1 + v^2}}
		-- g^ab = {{1 + v^2, -uv}, {-uv, 1 + u^2}} / (1 + u^2 + v^2)
		-- det(g) = 1 + u^2 + v^2
		-- n^i = eps^ijk e_j e_k ... is eps g-weighted? which g?
		-- for no weight: n^i = [u, v, 1], |n| = sqrt(u^2 + v^2 + 1)
		-- for the time being, all coord charts where #basisOperators < #embedded need to explicitly provide this.
		-- (which, for now, is only this coordinate chart)
		-- it is equal to dx^a/dx^I in terms of x^a
		eU = function()
			return Tensor('^a_I', 
				--{du/dx, du/dy, du/dz}:
				{1, 0, -1/u},
				--{dv/dx, dv/dy, dv/dv}:
				{0, 1, -1/v})
		end,
		-- same as |du^I/dx^a| for coordinate charts
		-- which is equal to sqrt(det|g_ab|) for metrics based on coordinate (derivative) operators
		-- (unless there is extrinsic curvature? as in this case?)
		-- what about equal to the surface differential area? |e_u x e_v| = sqrt(u^2 + v^2 + 1)
		coordVolumeElem = function()
			return sqrt(u^2 + v^2 + 1)
		end,
	},
	{
		title = 'hyperboloid, coordinate',
		baseCoords = {u,v},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			return Tensor('^I', u, v, frac(1,2) * (u^2 - v^2))
		end,
		-- e_u = [1, 0, u]
		-- e_v = [0, 1, -v]
		-- g_ab = {{1 + u^2, -uv}, {-uv, 1 + v^2}}
		-- g^ab = {{1 + v^2, uv}, {uv, 1 + u^2}} / (1 + u^2 + v^2)
		-- det(g) = 1 + u^2 + v^2
		-- n^i = eps^ijk e_j e_k ... is eps g-weighted? which g?
		-- for no weight: n^i = [-u, v, 1], |n| = sqrt(u^2 + v^2 + 1)
		-- for the time being, all coord charts where #basisOperators < #embedded need to explicitly provide this.
		-- (which, for now, is only this coordinate chart)
		-- it is equal to dx^a/dx^I in terms of x^a
		eU = function()
			return Tensor('^a_I', 
				--{du/dx, du/dy, du/dz}:
				{1, 0, 1/u},
				--{dv/dx, dv/dy, dv/dv}:
				{0, 1, -1/v})
		end,
		-- same as |du^I/dx^a| for coordinate charts
		-- which is equal to sqrt(det|g_ab|) for metrics based on coordinate (derivative) operators
		-- (unless there is extrinsic curvature? as in this case?)
		-- what about equal to the surface differential area? |e_u x e_v| = sqrt(u^2 + v^2 + 1)
		coordVolumeElem = function()
			return sqrt(u^2 + v^2 + 1)
		end,
	},
--]]	
	{
		title = 'polar, coordinate',
		baseCoords = {r,phi},
		embedded = {x,y},
		flatMetric = delta2,
		chart = function() 
			return Tensor('^I', r * cos(phi), r * sin(phi))
		end,
	},

	{
		title = 'polar, anholonomic, orthonormal',
		baseCoords = {r,theta},
		embedded = {x,y},
		flatMetric = delta2,
		chart = function()
			return Tensor('^I', r * cos(theta), r * sin(theta))
		end,
		eToEHol = function()
			-- notice neither is a cartesian index,
			-- but the capital denotes the non-coordinate basis
			-- gHol_ab = g_AB e_a^A e_b^B
			-- notice that orthonormal implies g_ab = eta_ab
			return Tensor('_a^A', 
				{1, 0},
				{0, r}
			)
		end,
		coordVolumeElem = function()
			return r
		end,
	},
	{
		title = 'polar, anholonomic, conformal',
		baseCoords = {r,theta},
		embedded = {x,y},
		flatMetric = delta2,
		chart = function()
			return Tensor('^I', r * cos(theta), r * sin(theta))
		end,
		eToEHol = function()
			return Tensor('_a^A', 
				{sqrt(r), 0},
				{0, sqrt(r)}
			)
		end,
		coordVolumeElem = function()
			return r
		end,
	},
--[[	just by introducing omega, this takes too long to finish
	{
		title = 'polar and time, constant rotation, coordinate',
		baseCoords = {t,r,phi},
		embedded = {t,x,y},
		flatMetric = eta3,
		chart = function()
			return Tensor('^I', 
				t,
				r * cos(phi + omega * t),
				r * sin(phi + omega * t))
		end,
	},
--]]
--[[ these needs the FTC to work	... which needs functions / evaluation expressions
	{
		title = 'polar and time, lapse varying in radial, coordinate',
		baseCoords = {t,r,phi},
		embedded = {t,x,y},
		flatMetric = eta3,
		chart = function()
			return Tensor('^I',
				t * alpha,
				r * cos(phi),
				r * sin(phi))
		end,
	},
	{
		title = 'polar and time, lapse varying in radial, rotation varying in time and radial, coordinate',
		baseCoords = {t,r,phi},
		embedded = {t,x,y},
		flatMetric = eta3,
		chart = function()
			omega = var('\\omega', {t, r})
			return Tensor('^I', 
				t,
				r * cos(phi + omega),
				r * sin(phi + omega)
			)
		end,
	},
--]]
	{
		title = 'cylindrical surface, coordinate',
		baseCoords = {phi,z},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			return Tensor('^I', r * cos(phi), r * sin(phi), z)
		end,
		-- for the time being, all coord charts where #basisOperators < #embedded need to explicitly provide this.
		-- (which, for now, is only this coordinate chart)
		-- it is equal to dx^a/dx^I in terms of x^a
		eU = function()
			return Tensor('^a_I', 
				--{dphi/dx, dphi/dy, dphi/dz}:
				{-sin(phi)/r, cos(phi)/r, 0},
				--{dz/dx, dz/dy, dz/dz}:
				{0, 0, 1})
		end,
		eToEHol = function()
			return Tensor('_a^A', 
				{1, 0},
				{0, 1}
			)
		end,
	},
	{
		title = 'cylindrical surface, anholonomic, orthonormal',
		baseCoords = {phi,z},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			return Tensor('^I', r * cos(phi), r * sin(phi), z)
		end,
		eU = function()
			return Tensor('^a_I', 
				{-sin(phi), cos(phi), 0},
				{0, 0, 1})
		end,
		eToEHol = function()
			return Tensor('_a^A', 
				{1, 0},
				{0, r}
			)
		end,
		coordVolumeElem = function()
			return r
		end,
	},
	{
		title = 'cylindrical surface, anholonomic, conformal',
		baseCoords = {phi,z},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			return Tensor('^I', r * cos(phi), r * sin(phi), z)
		end,
		eU = function()
			return Tensor('^a_I', 
				{-sin(phi) / sqrt(r), cos(phi) / sqrt(r), 0},
				{0, 0, sqrt(r)})
		end,
		eToEHol = function()
			return Tensor('_a^A', 
				{sqrt(r), 0},
				{0, sqrt(r)}
			)
		end,
		coordVolumeElem = function()
			return r
		end,
	},
	{
		title = 'cylindrical, coordinate',
		baseCoords = {r,phi,z},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			return Tensor('^I', r * cos(phi), r * sin(phi), z)
		end,
	},
	{
		title = 'cylindrical, anholonomic, orthonormal',
		baseCoords = {r,theta,z},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			return Tensor('^I', r * cos(theta), r * sin(theta), z)
		end,
		eToEHol = function()
			return Tensor('_a^A', 
				{1, 0, 0},
				{0, r, 0},
				{0, 0, 1}
			)
		end,
		coordVolumeElem = function()
			return r
		end,
	},
	{
		title = 'cylindrical, anholonomic, conformal',
		baseCoords = {r,theta,z},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			return Tensor('^I', r * cos(theta), r * sin(theta), z)
		end,
		eToEHol = function()
			return Tensor('_a^A', 
				{r^frac(1,3), 0, 0},
				{0, r^frac(1,3), 0},
				{0, 0, r^frac(1,3)}
			)
		end,
		coordVolumeElem = function()
			return r
		end,
	},
	{
		title = 'cylindrical and time, coordinate',
		baseCoords = {t,r,phi,z},
		embedded = {t,x,y,z},
		flatMetric = eta4,
		chart = function()
			return Tensor('^I', t, r * cos(phi), r * sin(phi), z)
		end,
	},
	{
		title = 'sphere surface, coordinate',
		baseCoords = {theta,phi},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			return Tensor('^I',
				r * sin(theta) * cos(phi),
				r * sin(theta) * sin(phi),
				r * cos(theta))
		end,
		eU = function()
			-- theta = acos(z/r)
			-- phi = atan(y/x)
			return Tensor('^a_I',
				--{dtheta/dx, dtheta/dy, dtheta/dz}:
				{cos(theta) * cos(phi) / r, cos(theta) * sin(phi) / r, -sin(theta) / r},
				--{dphi/dx, dphi/dy, dphi/dz}:
				{-sin(phi)/(r*sin(theta)),cos(phi)/(r*sin(theta)),0})
		end,
	},
	{
		title = 'sphere surface, anholonomic, orthonormal',
		baseCoords = {theta,phi},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			return Tensor('^I',
				r * sin(theta) * cos(phi),
				r * sin(theta) * sin(phi),
				r * cos(theta))
		end,
		eU = function()
			-- theta = acos(z/r)
			-- phi = atan(y/x)
			return Tensor('^a_I',
				--{dtheta/dx, dtheta/dy, dtheta/dz}:
				{cos(theta) * cos(phi), cos(theta) * sin(phi), -sin(theta)},
				--{dphi/dx, dphi/dy, dphi/dz}:
				{-sin(phi),cos(phi),0})
		end,
		eToEHol = function()
			return Tensor('_a^A', 
				{r, 0},
				{0, r*sin(theta)}
			)
		end,
		coordVolumeElem = function()
			return r^2 * sin(theta)
		end,
	},
	{
		title = 'spherical, coordinate',
		baseCoords = {r,theta,phi},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			return Tensor('^I', 
				r * sin(theta) * cos(phi),
				r * sin(theta) * sin(phi),
				r * cos(theta))
		end,
	},
	{
		title = 'spherical, anholonomic, orthonormal',
		baseCoords = {r,theta,phi},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			return Tensor('^I', 
				r * sin(theta) * cos(phi),
				r * sin(theta) * sin(phi),
				r * cos(theta))
		end,
		eToEHol = function()
			return Tensor('_a^A', 
				{1, 0, 0},
				{0, r, 0},
				{0, 0, r*sin(theta)}
			)
		end,
		coordVolumeElem = function()
			return r^2 * sin(theta)
		end,
	},
--[[ also not doing so well, kinda slow	
	{
		title = 'spherical, anholonomic, conformal',
		baseCoords = {r,theta,phi},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			return Tensor('^I', 
				r * sin(theta) * cos(phi),
				r * sin(theta) * sin(phi),
				r * cos(theta))
		end,
		eToEHol = function()
			local cf = r * sqrt(abs(sin(theta)))
			return Tensor('_a^A', 
				{cf, 0, 0},
				{0, cf, 0},
				{0, 0, cf}
			)
		end,
		coordVolumeElem = function()
			return r^2 * sin(theta)
		end,
	},
--]]
--[[ not doing so well, with some abs derivatives
	{
		title = 'sphere surface, anholonomic, conformal',
		baseCoords = {theta, phi},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			return Tensor('^I',
				r * sin(theta) * cos(phi),
				r * sin(theta) * sin(phi),
				r * cos(theta))
		end,
		eU = function()
			-- theta = acos(z/r)
			-- phi = atan(y/x)
			return Tensor('^a_I',
				--{dtheta/dx, dtheta/dy, dtheta/dz}:
				{cos(theta) * cos(phi), cos(theta) * sin(phi), -sin(theta)},
				--{dphi/dx, dphi/dy, dphi/dz}:
				{-sin(phi),cos(phi),0})
		end,
		eToEHol = function()
			local cf = r * sqrt(abs(sin(theta)))
			return Tensor('_a^A', 
				{cf, 0},
				{0, cf}
			)
		end,
		coordVolumeElem = function()
			return r^2 * sin(theta)
		end,
	},
--]]
	{
		title = 'spherical, sinh-radial, coordinate',
		baseCoords = {rho,theta,phi},	-- reminder, the connectins wrt r,theta,phi are the same as spherical above
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			local rDef = A * sinh(rho / w) / sinh(1 / w)
			return Tensor('^I',
				rDef * sin(theta) * cos(phi),
				rDef * sin(theta) * sin(phi),
				rDef * cos(theta))
		end,
		coordVolumeElem = function()
			local rDef = A * sinh(rho / w) / sinh(1 / w)
			return rDef^2 * sin(theta)
		end,
	},
	{
		title = 'spherical, sinh-radial, anholonomic, orthonormal',
		baseCoords = {rho,theta,phi},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			local rDef = A * sinh(rho / w) / sinh(1 / w)
			return Tensor('^I',
				rDef * sin(theta) * cos(phi),
				rDef * sin(theta) * sin(phi),
				rDef * cos(theta))
		end,
		eToEHol = function()
			return Tensor('_a^A',
				{(A*cosh(rho/w)) / (w * sinh(1/w)), 0, 0},
				{0, (A*sinh(rho/w)) / sinh(1/w), 0},
				{0, 0, (A*sinh(rho/w) * sin(theta)) / sinh(1/w)}
			)
		end,
		coordVolumeElem = function()
			local rDef = A * sinh(rho / w) / sinh(1 / w)
			return rDef^2 * sin(theta)
		end,
	},
	{
		title = 'spherical and time, coordinate',
		baseCoords = {t,r,theta,phi},
		embedded = {t,x,y,z},
		flatMetric = eta4,
		chart = function()
			return Tensor('^I', 
				t,
				r * sin(theta) * cos(phi),
				r * sin(theta) * sin(phi),
				r * cos(theta))
		end,
	},
	{
		title = 'Schwarzschild',
		baseCoords = {t,r,theta,phi},
		embedded = {t,x,y,z},
		flatMetric = eta4,
		basis = function()
			return Tensor('_u^I',
				{sqrt(1 - R/r), 0, 0, 0},
				{0, 1/sqrt(1 - R/r), 0, 0},
				{0, 0, r, 0},
				{0, 0, 0, r * sin(theta)}
			)
		end,
	},
--[[ this is having problems integrating alpha_,r
-- TODO to implement FTC I need to have a function expression, or an evaluate-at expression (same idea)	
	{
		title = 'spherical and time, lapse varying in radial',
		baseCoords = {t,r,theta,phi},
		embedded = {t,x,y,z},
		flatMetric = eta4,
		chart = function()
			return Tensor('^I', 
				t * alpha,
				r * sin(theta) * cos(phi),
				r * sin(theta) * sin(phi),
				r * cos(theta))
		end,
	},
--]]
--[[ hmm, those r's, too much memory used
	{
		title = 'Schwarzschild, pseudo-Cartesian',
		baseCoords = {t,x,y,z},
		embedded = {t,x,y,z},
		flatMetric = eta4,
		metric = function()
			-- where r = sqrt(x^2 + y^2 + z^2)
			return Tensor('_uv',
				{-(1 - R/r), 0, 0, 0},
				{0, (x^2 / ((r - R)/r) + y^2 + z^2)/r^2, x * y * R / (r^2 * (r - R)), x * z * R / (r^2 * (r - R))},
				{0, y * x * R / (r^2 * (r - R)), (x^2 + y^2 * ((r - R)/r) + z^2)/r^2, y * z * R / (r^2 * (r - R))},
				{0, z * x * R / (r^2 * (r - R)), z * y * R / (r^2 * (r - R)), (x^2 + y^2 + z^2 * ((r - R)/r))/r^2}
			)
		end,
	},
--]]
--[[
	{
		title = '1D spacetime',
		baseCoords = {t,x,y,z},
		embedded = {t,x,y,z},
		flatMetric = eta4,
		chart = function()
			return Tensor('^I', t, q, y, z)
		end,
	},
--]]
--[[ this is schwarzschild, for alpha = 1/sqrt(1 - R/r)
	{
		title = 'spherical and time, lapse varying in radial, Schwarzschild form',
		baseCoords = {t,r,theta,phi},
		embedded = {t,x,y,z},
		flatMetric = eta4,
		chart = function()
			return Tensor('^I', 
				t * alpha,
				r/alpha * sin(theta) * cos(phi),
				r/alpha * sin(theta) * sin(phi),
				r/alpha * cos(theta))
		end,
	},
--]]
--[[ this is struggling with the new trig simplification
	{
		title = 'torus',
		baseCoords = {r,theta,phi},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			return Tensor('^I', 
				(R + r * sin(theta)) * cos(phi),
				(R + r * sin(theta)) * sin(phi),
				r * cos(theta))
		end,
	},
--]]
--[[ needs integral evaluation
	{
		title = 'torus surface, coordinate',
		baseCoords = {theta,phi},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			return Tensor('^I', 
				(R + r * sin(theta)) * cos(phi),
				(R + r * sin(theta)) * sin(phi),
				r * cos(theta))
		end,
		eU = function()
			return Tensor('^a_I',
				-- dtheta/dx, dtheta/dy dtheta/dz
				{cos(theta) * cos(phi) / r, cos(theta) * sin(phi) / r, -sin(theta) / r},
				-- dphi/dx, dphi/dy dphi/dz
				{-sin(phi) / (R + r * sin(theta)), cos(phi) / (R + r * sin(theta)), 0})
		end,
	},
--]]	
	{
		title = 'spiral, coordinate',
		baseCoords = {r,phi},
		embedded = {x,y},
		flatMetric = delta2,
		chart = function()
			return Tensor('^I',
				r * cos(phi + log(r)),
				r * sin(phi + log(r))
			)
		end,
	},
}


local MathJax = symmath.export.MathJax
MathJax.header.pathToTryToFindMathJax = '..'
symmath.tostring = MathJax

os.mkdir'output/metric catalog'
-- [[
for _,info in ipairs(spacetimes) do
	printbr('<a href="metric catalog/'..info.title..'.html">'..info.title..'</a>')
end
printbr()
--]]
for _,info in ipairs(spacetimes) do

	io.stderr:write(info.title,'\n')
	io.stderr:flush()

	MathJax.header.title = info.title

	local f = assert(io.open('output/metric catalog/'..info.title..'.html', 'w'))
	local function write(...)
		return f:write(...)
	end
	local function print(...)
		write(table{...}:mapi(tostring):concat'\t'..'\n')
	end
	local function printbr(...)
		print(...)
		print'<br>'
	end
	
	print(MathJax.header)

--print('<a name="'..info.title..'">')
	print('<h3>'..info.title..'</h3>')


	-- technically this is the variable whose derivative operator produces the basis, 
	-- and this is the associated coordinates
	local baseCoords = info.baseCoords
	local embedded = info.embedded
	
	printbr([[chart coordinates: $x^\tilde{\mu} = \{]]..table.mapi(baseCoords, function(x) return x.name end):concat', '..[[\}$]])
	printbr([[chart coordinate basis: $e_\tilde{\mu} = \{]]..table.mapi(baseCoords, function(x) return 'e_{\\tilde{'..x.name..'}}' end):concat', '..[[\}$]])
	printbr([[embedding coordinates: $u^I = \{]]..table.mapi(embedded, function(x) return x.name end):concat', '..[[\}$]])
	printbr([[embedding basis $e_I = \{]]..table.mapi(embedded, function(x) return 'e_{'..x.name..'}' end):concat', '..[[\}$]])


	-- dimension of manifold
	local n = #baseCoords



	-- TODO rename 'Tensor.coords' to 'Tensor.indexes' ?   Since they are possibly a non-coordinate basis.  Rename 'variables=' to 'operators='?  Maybe?  Maybe 'basisOperators='?
	Tensor.coords{
		{variables=baseCoords},
		{variables=embedded, symbols='IJKLMN', metric=info.flatMetric}
	}

	-- assert these are original coordinates + derivatives
	for _,coord in ipairs(baseCoords) do
		assert(getmetatable(coord) == Variable)
		assert(coord.applyDiff == Variable.applyDiff)
	end


	-- transform from Cartesian basis to chart basis 
	-- e_I = Cartesian basis
	-- e_u = chart basis
	-- e_u = e_u^I e_I
	-- e_I = e^u_I e_u
	local e
	-- transform from chart basis to Cartesian basis
	local eU
	-- transform from chart basis to coordinate basis
	-- e_A = chart basis
	-- e_a = coordinate basis
	-- e_a = e_a^A e_A
	-- e_A = e^a_A e_a
	local eToEHol = info.eToEHol and info.eToEHol() or Tensor('_A^a', function(A, a) 
		return A == a and 1 or 0
	end)
	printbr'transform from basis to coordinate:'
	eToEHol:printElem('\\tilde{e}', write)
	printbr()
	printbr()
	-- transform from coordinate basis to chart basis
	local eHolToE = Tensor('^a_A', table.unpack((Matrix.inverse(eToEHol))))
	printbr'transform from coorinate to basis:'
	eHolToE:printElem('\\tilde{e}', write)
	printbr()
	printbr()


	-- create basis operators - as non-coordinate linear combinations of coordinates when available 
	local basisOperators = table()
	for i=1,n do
		local onesi = Matrix:lambda({1,n}, function(_,j) return j==i and 1 or 0 end)
		if eHolToE[i] == onesi[1] then
			basisOperators[i] = baseCoords[i]
		else
			local ci = baseCoords[i].set:var('\\hat{'..baseCoords[i].name..'}')
			function ci:applyDiff(x)
				local sum = 0
				for j=1,n do
					sum = sum + eHolToE[i][j] * x:diff(baseCoords[j])
				end
				return sum()
			end
			basisOperators[i] = ci
		end
		local zeta = var('\\zeta', baseCoords)
		printbr('tensor index associated with coordinate '..baseCoords[i]
			..' is index '..basisOperators[i]
			..' with operator $e_{'..basisOperators[i].name..'}(\\zeta) = $'..basisOperators[i]:applyDiff(zeta))
	end
	printbr()


	-- TODO a set of indexes for the base coordinates?
	Tensor.coords{
		{variables=basisOperators},
		{variables=embedded, symbols='IJKLMN', metric=info.flatMetric},
-- TODO:
--		{variables=baseCoords, symbols='ABCDEF'},
	}


	local eta = Tensor('_IJ', table.unpack(info.flatMetric))
	print'flat metric:'
	eta:printElem('\\eta', write)
	printbr()
	printbr()


	-- metric
	local g
	-- commutation
	local c
	if info.chart or info.basis then
-- [[
		e = Tensor'_u^I'
		
		-- calc basis by applying operators to chart
		if info.chart then
			local u = info.chart()
			printbr'chart in embedded coordinates:'
			u:printElem('u', write)
			printbr()
			printbr()

			printbr'basis operators applied to chart:'
			e['_u^I'] = u'^I_,u'()	--dx^I/dx^a
			printbr(var'e''_u^I':eq(var'u''^I_,u'))
			e:printElem('e', write)
			printbr()
		-- simply use basis provided
		elseif info.basis then
			printbr'basis in embedded coordinates:'
			e['_u^I'] = info.basis()()
			e:printElem('e', write)
			printbr()
			printbr()
		end

		-- but what if this matrix isn't square?
		-- for now provide an override and explicitly provide those eU's
		-- that's why for the true eU value I should be solving P^u_,I 
		if info.eU then
			eU = info.eU()
		else
			assert(#basisOperators == #embedded)
			eU = Tensor('^u_I', table.unpack(Matrix(table.unpack(e)):inverse():transpose()))
		end

		--printbr(var'e''^u_I'
		--	:eq(var'e''_u^I'^-1)	LaTeX output chokes here
		--	:eq(eU))
		eU:printElem('e', write)
		printbr()
	
		-- show orthogonality of basis and its inverse
		printbr((var'e''_u^I' * var'e''^v_I'):eq((e'_u^I' * eU'^v_I')()))
		printbr((var'e''_u^I' * var'e''^u_J'):eq((e'_u^I' * eU'^u_J')()))

		-- NOTICE, this is only the volume element if our basis is a coordinate basis.
		if #e == #e[1] then
			printbr('basis determinant:', var'det(e)':eq(Matrix.det(e)))
		end

		--[[
		e_u = e_u^I d/dx^I
		and e^v_J is the inverse of e_u^I 
		such that e_u^I e^v_I = delta_u^v and e_u^I e^u_J = delta^I_J
		
		[e_u, e_v] = e_u e_v - e_v e_u
			= e_u^I d/dx^I (e_v^J d/dx^J) - e_v^I d/dx^I (e_u^J d/dx^J)
			= e_u^I ( (d/dx^I e_v^J) d/dx^J + e_v^J d/dx^I d/dx^J) - e_v^I ((d/dx^I e_u^J) d/dx^J + e_u^J d/dx^I d/dx^J)
			= e_u^I (d/dx^I e_v^J) d/dx^J - e_v^I (d/dx^I e_u^J) d/dx^J
			= (e_u^I e_v^J_,I - e_v^I e_u^J_,I) d/dx^J 
			= (e_u^I (dx^a/dx^I d/dx^a e_v^J) - e_v^I (dx^a/dx^I d/dx^a e_u^J)) d/dx^J
			= (e_u^I e_v^J_,a - e_v^I e_u^J_,a) e^a_I d/dx^J
			= (delta_u^a e_v^J_,a - delta_v^a e_u^J_,a) d/dx^J
			= (e_v^J_,u - e_u^J_,v) d/dx^J
			
		so for [e_u, e_v] = c_uv^w e_w = c_uv^w e_w^J d/dx^J
		we find c_uv^w e_w^I = (e_v^I_,u - e_u^I_,v)
		or c_uv^w = (e_v^I_,u - e_u^I_,v) e^w_I
		is it just me, or does this look strikingly similar to the spin connection?
		--]]
		c = Tensor'_ab^c'
		c['_ab^c'] = ((e'_b^I_,a' - e'_a^I_,b') * eU'^c_I')()
		c:printElem('c', write)
		printbr()

		g = (e'_u^I' * e'_v^J' * eta'_IJ')()
		printbr(var'g''_uv':eq(var'e''_u^I' * var'e''_v^J' * var'\\eta''_IJ'))
		g:printElem('g', write)
		printbr()
	
		printbr(var'g''_uv':eq(var'e''_u^I' * var'e''_v^J' * var'\\eta''_IJ'))
	elseif info.metric then
		g = info.metric()
		g:printElem('g', write)
		printbr()
	else
		error'here'
	end
--]]

	local detg = Matrix.det(g)
	printbr('metric determinant:', var'det(g)':eq(detg))

	-- TODO just put this once in the intro?
	printbr(var'\\Gamma''_abc':eq(frac(1,2)*(var'g''_ab,c' + var'g''_ac,b' - var'g''_bc,a' + var'c''_abc' + var'c''_acb' - var'c''_cba')))
	
	local Props = class(require 'symmath.physics.diffgeom')
	function Props:doPrint(field)
		print(field.title..':')
		local t = self[field.name]
		if Tensor:isa(t) then
			t:printElem(field.symbol, write)
		else
			print(t)
		end
		printbr()
	end
	Props.verbose = true
	local props = Props(g, nil, c)
	local Gamma = props.Gamma

	local dx = Tensor('^u', function(u)
		return var('\\dot{' .. basisOperators[u].name .. '}')
	end)
	local d2x = Tensor('^u', function(u)
		return var('\\ddot{' .. basisOperators[u].name .. '}')
	end)

	local A = Tensor('^i', function(i) return var('A^{'..basisOperators[i].name..'}', baseCoords) end)
	--[[
	TODO can't use comma derivative, gotta override the :applyDiff of the anholonomic basis variables
	 but when doing so, you must make the embedded variables dependent on the ... variables that the anholonomic are spun off of
	 	i.e. if the anholonomic basis is rHat, phiHat, thetaHat, then the A^I variables must be dependent upon r, theta, phi
	--]]
	local divVarExpr = var'A''^i_,i' + var'\\Gamma''^i_ij' * var'A''^j'
	local divExpr = divVarExpr:replace(var'A', A):replace(var'\\Gamma', Gamma)
	-- TODO only simplify TensorRef, so the indexes are fixed
	printbr('divergence:', divVarExpr:eq(divExpr():factorDivision())) 
	
	printbr'geodesic:'
	-- TODO unravel equaliy, or print individual assignments
	printbr((d2x'^a':eq(-Gamma'^a_bc' * dx'^b' * dx'^c'))():factorDivision())
	printbr()


	-- start of the parallel propagator stuff


	-- Gamma has the conn in it
	local conn = Gamma
	local connCoord = (conn'^a_bc' * eToEHol'_B^b')():permute'^a_Bc'
--[[
printbr(conn)
printbr()
printbr(eToEHol)
printbr()
-- when I add baseCoords as tensor indexes, why is this coming out as zeroes?
printbr(conn'^a_bc'())
printbr(connCoord)
connCoord = connCoord:permute'^a_Bc'
printbr(connCoord)
printbr()
--]]

	printbr'parallel propagators:'
	printbr()

	local xLs = range(n):mapi(function(i)
		return baseCoords[i].set:var(baseCoords[i].name..'_L')
	end)
	local xRs = range(n):mapi(function(i)
		return baseCoords[i].set:var(baseCoords[i].name..'_R')
	end)

	local P = var'P'

	local propFwd = table()
	local propInv = table()

	for i, coord in ipairs(baseCoords) do
		-- conn matrix for coord i
		local conn = Matrix:lambda({n,n}, function(a,b)
			return connCoord[a][i][b]
		end)
		
		local name = baseCoords[i].name	
	
		printbr(var('[\\Gamma_'..name..']'):eq(conn))
		printbr()

		local origIntConn = Integral(conn, coord, xLs[i], xRs[i])
		print(origIntConn)
		local intConn = origIntConn()

		printbr('=', intConn)
		printbr()

		print(P(' _'..name), '=', exp(-origIntConn))
		local negIntConn = (-intConn)()
		--[[ you could exp, and that will eigen-decompose ...
		local expNegIntExpr = negIntConn:exp()
		local expIntExpr = expNegIntExpr:inverse()
		--]]
		-- [[ but eigen will let inverting be easy
-- [[ if :eigen() fails, this will show you what was being eigen'd
if not negIntConn.eigen then
printbr()
printbr('negIntConn', negIntConn)
printbr('negIntConn', negIntConn())
end
--]]
		local ev = negIntConn:eigen()
		local R, L, allLambdas = ev.R, ev.L, ev.allLambdas
		local expNegIntExpr, expIntExpr
		if L then
			local expLambda = Matrix.diagonal( allLambdas:mapi(function(lambda) 
				return exp(lambda) 
			end):unpack() )
			expNegIntExpr = (R * expLambda * L)()
			local invExpLambda = Matrix.diagonal( allLambdas:mapi(function(lambda) 
				return exp(-lambda) 
			end):unpack() )
			expIntExpr = (R * invExpLambda * L)()
		else
			--printbr("Tried to eigendecompose "..negIntConn..", couldn't find left eigenvectors.  Is it defective? "..(ev.defective or false))
			for _,A in ipairs{intConn, negIntConn} do
				local powers = table{A}
				local n = #A
				local zero = Matrix:zeros{n,n}
				local foundZeros
				for i=2,n do
					powers[i] = (powers[i-1] * A)()
					if powers[i] == zero then 
						foundZeros = true
						break 
					end
				end
				-- the matrix exp is a finite sum of powers of the matrix ... 
				-- TODO include this branch into the matrix.exp function
				local expA = A
				local div = 1
				for i=2,#powers do
					div = div * i
					expA = (expA + powers[i] / div)()
				end
				if not foundZeros then
					expA = expA + var('\\mathcal{O}(A^'..(n+1)..')')
				end
				if rawequal(A, intConn) then
					expIntExpr = expA
				elseif rawequal(A, negIntConn) then
					expNegIntExpr = expA
				end
			end
		end
		--]]
		printbr('=', expNegIntExpr)
		printbr()
	
		print(P(' _'..name)^-1, '=', exp(origIntConn))
		printbr('=', expIntExpr)
		printbr()
	
		propInv[i] = expIntExpr
		propFwd[i] = expNegIntExpr
	end

	printbr'propagator commutation:'
	printbr()
	
	for i=1,n-1 do
		local Pi = propFwd[i]
		local Piname = P(' _'..baseCoords[i].name)
		
		local PiL = Pi:clone()
		for k=1,n do
			if k ~= i then
				PiL = PiL:replace(baseCoords[k], xLs[k])
			end
		end	
		
		for j=i+1,n do
			local Pj = propFwd[j]
			local Pjname = P(' _'..baseCoords[j].name)

			local PjL = Pj:clone()
			for k=1,n do
				if k ~= j then
					PjL = PjL:replace(baseCoords[k], xLs[k])
				end
			end
		
			local PiR = PiL:replace(xLs[j], xRs[j])
			local PjR = PjL:replace(xLs[i], xRs[i])
	
			-- Pj propagates coord j from L to R
			-- so in Pi replace coord j from arbitrary to jR
			local Pij = PiR * PjL
			
			-- Pi propagates coord i from L to R
			-- so in Pj replace coord i from arbitrary to iR
			local Pji = PjR * PiL
			
			local Pcij = (Pij - Pji)()
			
			printbr('[', Piname, ',', Pjname, '] =', Pij - Pji, '=', Pcij)
		end
	end
	printbr()

	printbr'propagator partials'
	for i=1,n do
		local Pi = propFwd[i]
		for j=1,n do
			printbr(Pi:diff(baseCoords[j]):eq(
				Pi:diff(baseCoords[j])()
			))
		end
	end


	local deltas = range(n):mapi(function(i)
		return var('\\Delta '..baseCoords[i].name)
	end)
	local deltaSqs = range(n):mapi(function(i)
		return var('\\Delta ('..baseCoords[i].name..'^2)')
	end)
	local deltaCubes = range(n):mapi(function(i)
		return var('\\Delta ('..baseCoords[i].name..'^3)')
	end)
	local deltaCoss = range(n):mapi(function(i)
		return var('\\Delta (cos('..baseCoords[i].name..'))')
	end)

	local function replaceDeltas(expr)
		for k=1,n do
			expr = expr
				:replace((xRs[k] - xLs[k])(), deltas[k])
				:replace((xLs[k] - xRs[k])(), -deltas[k])
				
				:replace((xRs[k]^2 - xLs[k]^2)(), deltaSqs[k])
				:replace((xLs[k]^2 - xRs[k]^2)(), -deltaSqs[k])
				
				:replace((xRs[k]^3 - xLs[k]^3)(), deltaCubes[k])
				:replace((xLs[k]^3 - xRs[k]^3)(), -deltaCubes[k])
				
				:replace((cos(xRs[k]) - cos(xLs[k]))(), deltaCoss[k])
				:replace((cos(xLs[k]) - cos(xRs[k]))(), -deltaCoss[k])
		
				-- hmm
				:replace((xRs[k]^2)(), xLs[k]^2 + deltaSqs[k])()
				:replace((xRs[k]^3)(), xLs[k]^3 + deltaCubes[k])()
		end
		return expr
	end

	-- [[
	--coordVolumeElem should be the determinant of the chart from cartesian to the manifold
	--... or equal to the sqrt of the determinant of the coordinte-based metric tensor
	local coordVolumeElem
	if info.coordVolumeElem then
		coordVolumeElem = info.coordVolumeElem()
	else
		-- determinant of matrix with column vectors equal to the chart coordinate basis vectors (in embedded coordinates)
		-- TODO this needs to be sqrt(det(g-based-on-coordinates))
		-- until then I need to explicitly state coordVolumeElem for all non-coordinate charts
		coordVolumeElem = sqrt(detg)()
	end
	printbr('volume element: ', coordVolumeElem)
	
	local cellVolume = coordVolumeElem
	for k=1,n do
		if not cellVolume:findChild(baseCoords[k]) then
			cellVolume = cellVolume * deltas[k] 
		else
			cellVolume = cellVolume:integrate(baseCoords[k], xLs[k], xRs[k])()
			cellVolume = replaceDeltas(cellVolume):simplify()
		end
	end
	printbr('volume integral: ', cellVolume)

	local FLs = range(n):mapi(function(i)
		return var('F^{'..baseCoords[i].name..'}('..xLs[i].name..')')
	end)
	local FRs = range(n):mapi(function(i)
		return var('F^{'..baseCoords[i].name..'}('..xRs[i].name..')')
	end)
	--]]

	printbr'finite volume (0,0)-form:'

	local sum = 0
	for k,coordk in ipairs(basisOperators) do
		local kLname = xLs[k].name
		local kRname = xRs[k].name
		local term = 
			var('J('..kRname..')') 
			* var('{e_{'..coordk.name..'}}^{\\bar{'..coordk.name..'}}('..kRname..')')
			* FRs[k]
			-
			var('J('..kLname..')') 
			* var('{e_{'..coordk.name..'}}^{\\bar{'..coordk.name..'}}('..kLname..')')
			* FLs[k]
		for j,coordj in ipairs(basisOperators) do
			if j ~= k then
				term = term:integrate(coordj, xLs[j], xRs[j])
			end
		end
		sum = sum - term
	end
	printbr(
		var'u(x_C, t_R)':eq(
			var'u(x_C, t_L)'
			+ var'\\Delta t' * (
				frac(1, var'\\mathcal{V}(x_C)') * sum
				+ var'S(x_C)'
			)
		)
	)
	printbr()

	-- TODO move to Matrix?
	local function isDiagonal(m)
		for i=1,#m do
			for j=1,#m[1] do
				if i ~= j then
					if m[i][j] ~= Constant(0) then return false end
				end
			end
		end
		return true
	end
	if eToEHol then
		if not isDiagonal(eToEHol) then
			error('\n'..symmath.export.MultiLine(eToEHol)..'\n'
				.."TODO add support for linear combinations of fluxes at cell surfaces for anholonomic coordinates"
			)
		end
	end

	local sum = 0
	for k,coordk in ipairs(basisOperators) do
		local kLname = xLs[k].name
		local kRname = xRs[k].name
		local term = 
			coordVolumeElem:replace(basisOperators[k], xRs[k])
			* (eToEHol and eToEHol[k][k] or Constant(1)):replace(basisOperators[k], xRs[k])	-- diagonal {e_a}^I(x_R) quick fix
			* FRs[k]
			-
			coordVolumeElem:replace(basisOperators[k], xLs[k])
			* (eToEHol and eToEHol[k][k] or Constant(1)):replace(basisOperators[k], xLs[k])	-- diagonal {e_a}^I(x_L) quick fix
			* FLs[k]
		for j,coordj in ipairs(basisOperators) do
			if j ~= k then
				term = term:integrate(coordj, xLs[j], xRs[j])
			end
		end
		sum = sum - term
	end
	printbr(
		var'u(x_C, t_R)':eq(
			var'u(x_C, t_L)'
			+ var'\\Delta t' * (
				frac(1, cellVolume) * sum
				+ var'S(x_C)'
			)
		)
	)
	printbr()

	-- now repeat, except as you eval, substitute for the deltas
	
	local sum = 0
	for k,coordk in ipairs(basisOperators) do
		local kLname = xLs[k].name
		local kRname = xRs[k].name
		local term = 
			coordVolumeElem:replace(basisOperators[k], xRs[k])
			* (eToEHol and eToEHol[k][k] or Constant(1)):replace(basisOperators[k], xRs[k])	-- diagonal {e_a}^I(x_R) quick fix
			* FRs[k]
			-
			coordVolumeElem:replace(basisOperators[k], xLs[k])
			* (eToEHol and eToEHol[k][k] or Constant(1)):replace(basisOperators[k], xLs[k])	-- diagonal {e_a}^I(x_L) quick fix
			* FLs[k]
		for j,coordj in ipairs(basisOperators) do
			if j ~= k then
				if not term:findChild(coordj) then
					term = term * deltas[j]
				else
					term = term:integrate(coordj, xLs[j], xRs[j])()
					term = replaceDeltas(term):simplify()
				end
			end
		end
		sum = sum - term
	end
	local expr = var'u(x_C, t_R)':eq(
		var'u(x_C, t_L)'
		+ var'\\Delta t' * (
			frac(1, cellVolume) * sum
			+ var'S(x_C)'
		)
	)
	printbr(expr)
	printbr()

	expr = expr():factorDivision()
	printbr(expr)
	printbr()


	print(MathJax.footer)
	f:close()
end

-- [=[
printbr[[
<br>
Using 2010 Muller, Grave "Catalogue of Spacetimes" for a reference on the spacetime metrics.<br>
<br>
]]
--]=]
