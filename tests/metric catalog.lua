#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup{implicitVars=true, MathJax={title='Metric Catalog'}}

local t,x,y,z = vars('t','x','y','z')
local r,phi,theta,psi = vars('r','\\phi','\\theta','\\psi')

local rHat = var'\\hat{r}'
rHat = r

local zHat = var'\\hat{z}'
zHat = z

local thetaHat = var'\\hat{\\theta}'
function thetaHat:applyDiff(x) return x:diff(theta) / r end

local phiHat = var'\\hat{\\phi}'
function phiHat:applyDiff(x) return x:diff(phi) / (r * sin(theta)) end

local psiHat = var'\\hat{\\psi}'
function psiHat:applyDiff(x) return x:diff(psi) end


local rPolarConformal = var'\\bar{r}'
function rPolarConformal:applyDiff(x) return x:diff(r) / sqrt(r) end 

local thetaPolarConformal = var'\\bar{\\theta}'
function thetaPolarConformal:applyDiff(x) return x:diff(theta) / sqrt(r) end


local phiCylindricalSurfaceNormalized = var'\\bar{\\phi}'
function phiCylindricalSurfaceNormalized:applyDiff(x) return x:diff(phi) / r end

local zCylindricalSurfaceNormalized = var'\\bar{z}'
function zCylindricalSurfaceNormalized:applyDiff(x) return x:diff(z) / r end


local phiCylindricalSurfaceConformal = var'\\bar{\\phi}'
function phiCylindricalSurfaceConformal:applyDiff(x) return x:diff(phi) / sqrt(r) end

local zCylindricalSurfaceConformal = var'\\bar{z}'
function zCylindricalSurfaceConformal:applyDiff(x) return x:diff(z) / sqrt(r) end


local alpha = var('\\alpha', {r})
local omega = var('\\omega', {t, r})
local q = var('q', {t,x,y,z})

local delta2 = Matrix:lambda({2,2}, function(i,j) return i==j and 1 or 0 end)
local delta3 = Matrix:lambda({3,3}, function(i,j) return i==j and 1 or 0 end)
local eta3 = Matrix:lambda({3,3}, function(i,j) return i==j and (i==1 and -1 or 1) or 0 end)
local eta4 = Matrix:lambda({4,4}, function(i,j) return i==j and (i==1 and -1 or 1) or 0 end)

local spacetimes = {
-- [=[
	{
		title = 'polar',
		coords = {r,phi},
		embedded = {x,y},
		flatMetric = delta2,
		chart = function() 
			return Tensor('^I', r * cos(phi), r * sin(phi))
		end,
	},
	{
		title = 'polar, anholonomic, normalized',
		coords = {rHat,thetaHat},
		baseCoords = {r,theta},
		embedded = {x,y},
		flatMetric = delta2,
		chart = function()
			return Tensor('^I', r * cos(theta), r * sin(theta))
		end,
	},
	{
		title = 'polar, anholonomic, conformal',
		coords = {rPolarConformal,thetaPolarConformal},
		baseCoords = {r,theta},
		embedded = {x,y},
		flatMetric = delta2,
		chart = function()
			return Tensor('^I', r * cos(theta), r * sin(theta))
		end,
	},
	{
		title = 'cylindrical surface',
		coords = {phi,z},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			return Tensor('^I', r * cos(phi), r * sin(phi), z)
		end,
		-- for the time being, all coord charts where #coords < #embedded need to explicitly provide this.
		-- (which, for now, is only this coordinate chart)
		-- it is equal to dx^a/dx^I in terms of x^a
		eU = function()
			return Tensor('^a_I', 
				--{dphi/dx, dphi/dy, dphi/dz}:
				{-sin(phi)/r, cos(phi)/r, 0},
				--{dz/dx, dz/dy, dz/dz}:
				{0, 0, 1})
		end,
	},
	{
		title = 'cylindrical surface, anholonomic, normalized',
		coords = {phiCylindricalSurfaceNormalized,zCylindricalSurfaceNormalized},
		baseCoords = {phi,z},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			return Tensor('^I', r * cos(phi), r * sin(phi), z)
		end,
		eU = function()
			return Tensor('^a_I', 
				{-sin(phi)/r, cos(phi)/r, 0},
				{0, 0, 1})
		end,
	},
	{
		title = 'cylindrical surface, anholonomic, conformal',
		coords = {phiCylindricalSurfaceConformal,zCylindricalSurfaceConformal},
		baseCoords = {phi,z},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			return Tensor('^I', r * cos(phi), r * sin(phi), z)
		end,
		eU = function()
			return Tensor('^a_I', 
				{-sin(phi)/r, cos(phi)/r, 0},
				{0, 0, 1})
		end,
	},
	{
		title = 'cylindrical',
		coords = {r,phi,z},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			return Tensor('^I', r * cos(phi), r * sin(phi), z)
		end,
	},
	{
		title = 'cylindrical, anholonomic, normalized',
		coords = {rHat,thetaHat,zHat},
		baseCoords = {r,theta,z},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			return Tensor('^I', r * cos(theta), r * sin(theta), z)
		end,
	},
	{
		title = 'cylindrical, anholonomic, conformal',
		coords = {
			class(var, {name = '\\bar{r}', applyDiff = function(self,x) return x:diff(r) * r^(-frac(1,3)) end})(),
			class(var, {name = '\\bar{\\theta}', applyDiff = function(self,x) return x:diff(theta) * r^(-frac(1,3)) end})(),
			class(var, {name = '\\bar{z}', applyDiff = function(self,x) return x:diff(z) * r^(-frac(1,3)) end})(),
		},
		baseCoords = {r,theta,z},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			return Tensor('^I', r * cos(theta), r * sin(theta), z)
		end,
	},
	{
		title = 'cylindrical and time',
		coords = {t,r,phi,z},
		embedded = {t,x,y,z},
		flatMetric = eta4,
		chart = function()
			return Tensor('^I', t, r * cos(phi), r * sin(phi), z)
		end,
	},
	{
		title = 'spiral',
		coords = {r,phi},
		embedded = {x,y},
		flatMetric = delta2,
		chart = function()
			return Tensor('^I',
				r * cos(phi + log(r)),
				r * sin(phi + log(r))
			)
		end,
	},
	{
		title = 'polar and time, constant rotation',
		coords = {t,r,phi},
		embedded = {t,x,y},
		flatMetric = eta3,
		chart = function()
			return Tensor('^I', 
				t,
				r * cos(phi + t),
				r * sin(phi + t))
		end,
	},
	{
		title = 'polar and time, lapse varying in radial',
		coords = {t,r,phi},
		embedded = {t,x,y},
		flatMetric = eta3,
		chart = function()
			return Tensor('^I',
				t * alpha,
				r * cos(phi),
				r * sin(phi))
		end,
	},
-- [[
	{
		title = 'polar and time, lapse varying in radial, rotation varying in time and radial',
		coords = {t,r,phi},
		embedded = {t,x,y},
		flatMetric = eta3,
		chart = function()
			return Tensor('^I', 
				t,
				r * cos(phi + omega),
				r * sin(phi + omega)
			)
		end,
	},
--]]
	{
		title = 'sphere surface',
		coords = {theta,phi},
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
		title = 'spherical',
		coords = {r,theta,phi},
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
		title = 'spherical, anholonomic, normalized',
		coords = {rHat,thetaHat,phiHat},
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
		title = 'spherical and time',
		coords = {t,r,theta,phi},
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
		title = 'spherical and time, lapse varying in radial',
		coords = {t,r,theta,phi},
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
	{
		title = 'torus',
		coords = {r,theta,phi},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			return Tensor('^I', 
				(R + r * sin(theta)) * cos(phi),
				(R + r * sin(theta)) * sin(phi),
				r * cos(theta))
		end,
	},
	{
		title = 'torus surface',
		coords = {theta,phi},
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
--]=]
--[[
	{
		title = '1D spacetime',
		coords = {t,x,y,z},
		embedded = {t,x,y,z},
		flatMetric = eta4,
		chart = function()
			return Tensor('^I', t, q, y, z)
		end,
	},
--]]
--[[ this is schwarzschild, for alpha = 1/sqrt(1 - R/r)
	{
		title = 'spherical and time, lapse varying in radial',
		coords = {t,r,theta,phi},
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
}
for _,info in ipairs(spacetimes) do
	printbr('<a href="#'..info.title..'">'..info.title..'</a>')
end
printbr()

for _,info in ipairs(spacetimes) do
	print('<a name="'..info.title..'">')
	print('<h3>'..info.title..'</h3>')

	Tensor.coords{
		{variables=info.coords},
		{variables=info.embedded, symbols='IJKLMN', metric=info.flatMetric}
	}
			
	local baseCoords = info.baseCoords or info.coords

	printbr('coordinates:', table.unpack(info.coords))
	printbr('base coords:', table.unpack(baseCoords))
	printbr('embedding:', table.unpack(info.embedded))

	local eta = Tensor('_IJ', table.unpack(info.flatMetric))
	printbr'flat metric:'
	eta:printElem'\\eta'
	printbr()
	printbr()

-- [[
	local e = Tensor'_u^I'
	if info.chart then
		local u = info.chart()
		printbr'coordinate chart:'
		u:printElem'u'
		printbr()
		printbr()

		--printbr'holonomic embedded:'
		printbr'embedded:'
		e['_u^I'] = u'^I_,u'()	--dx^I/dx^a
		printbr(var'e''_u^I':eq(var'u''^I_,u'))
		e:printElem'e'
		printbr()
	elseif info.basis then
		printbr'basis:'
		e['_u^I'] = info.basis()()
		e:printElem'e'
		printbr()
		printbr()
	end

	-- but what if this matrix isn't square?
	-- for now provide an override and explicitly provide those eU's
	-- that's why for the true eU value I should be solving P^u_,I 
	local eU
	if info.eU then
		eU = info.eU()
	else
		assert(#info.coords == #info.embedded)
		eU = Tensor('^u_I', table.unpack(Matrix(table.unpack(e)):inverse():transpose()))
	end

	--printbr(var'e''^u_I'
	--	:eq(var'e''_u^I'^-1)	LaTeX output chokes here
	--	:eq(eU))
	eU:printElem'e'
	printbr()
	
	printbr((var'e''_u^I' * var'e''^v_I'):eq((e'_u^I' * eU'^v_I')()))
	printbr((var'e''_u^I' * var'e''^u_J'):eq((e'_u^I' * eU'^u_J')()))
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
	local c = Tensor'_ab^c'
	c['_ab^c'] = ((e'_b^I_,a' - e'_a^I_,b') * eU'^c_I')()
	c:printElem'c'
	printbr()

	local g = (e'_u^I' * e'_v^J' * eta'_IJ')()
	printbr(var'g''_uv':eq(var'e''_u^I' * var'e''_v^J' * var'\\eta''_IJ'))
	g:printElem'g'
	printbr()
--]]

	printbr(var'g''_uv':eq(var'e''_u^I' * var'e''_v^J' * var'\\eta''_IJ'))
	printbr(var'\\Gamma''_abc':eq(frac(1,2)*(var'g''_ab,c' + var'g''_ac,b' - var'g''_bc,a' + var'c''_abc' + var'c''_acb' - var'c''_cba')))
	local Props = class(require 'symmath.physics.diffgeom')
	function Props:doPrint(field)
		print(field.title..':')
		local t = self[field.name]
		if Tensor.is(t) then
			t:printElem(field.symbol)
		else
			print(t)
		end
		printbr()
	end
	Props.verbose = true
	local props = Props(g, nil, c)
	local Gamma = props.Gamma

	local dx = Tensor('^u', function(u)
		return var('\\dot{' .. info.coords[u].name .. '}')
	end)
	local d2x = Tensor('^u', function(u)
		return var('\\ddot{' .. info.coords[u].name .. '}')
	end)

	local A = Tensor('^i', function(i) return var('A^{'..info.coords[i].name..'}', baseCoords) end)
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
end
