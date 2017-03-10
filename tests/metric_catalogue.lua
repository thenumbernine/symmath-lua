#!/usr/bin/env luajit
--[[

    File: polar_geodesic.lua 

    Copyright (C) 2000-2014 Christopher Moore (christopher.e.moore@gmail.com)
	  
    This software is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
  
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
  
    You should have received a copy of the GNU General Public License along
    with this program; if not, write the Free Software Foundation, Inc., 51
    Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

--]]
local table = require 'ext.table'
local range = require 'ext.range'
local symmath = require 'symmath'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
print(MathJax.header)

local function printbr(...)
	MathJax.print(...)
	io.flush()
end

-- [=[ keeping my rules simple
local function simplifyTrig(x)
	local sin = symmath.sin
	local cos = symmath.cos
	-- [[ tan => sin / cos
	x = x:map(function(expr)
		if symmath.tan.is(expr) then
			local th = expr[1]
			return symmath.sin(th:clone()) / symmath.cos(th:clone())
		end
	end)()
	--]]
	-- [[
	x = x:replace(cos(0), 1)
	x = x:replace(sin(0), 0)
	x = x()
	--]]
	-- [[ cos^n => cos^(n-2) * (1 - sin^2) 
	local found
	repeat
		found = false
		x = x:map(function(expr)
			if symmath.powOp.is(expr)
			and cos.is(expr[1])
			and symmath.Constant.is(expr[2])
			and expr[2].value > 1
			and expr[2].value == math.floor(expr[2].value)
			then
				local n = expr[2].value
				local th = expr[1][1]
				found = true
				local res = 1 - sin(th:clone())^2
				if n > 2 then res = cos(th:clone())^(n-2) * res end
				return res
			end
		end)()
	until not found
	return x
	--]]
end
--]=]
--[=[ trying to not rely on the other simplification operations for help: 

-- remove one element from x. if only one is left then return that element, otherwise returns the modified x.
local function removeFromBinOp(x,i)
	x = x:clone()
	table.remove(x,i)
	if #x == 1 then return x[1] end
	return x
end

-- for x_1 * ... * x_n, returns the first x_i such that f(x_i) is true, then the rest of the elements as a product
local function getCoeffsOf(x, f)
	if not symmath.mulOp.is(x) then
		if f(x) then return x, symmath.Constant(1) end
	end
	for i=1,#x do
		local xi = x[i]
		if f(xi) then
			return xi, removeFromBinOp(x,i)
		end
	end
end


local function simplifyTrig(x)
	local sin = symmath.sin
	local cos = symmath.cos
	-- cos^2 + sin^2 => 1
	x = x:map(function(expr)
		expr = expr:prune()
		if symmath.addOp.is(expr) then
			-- test used by ei and ej for getCoeffsOf
			-- TODO multiple bases, then expand powers, then collect cos^3 => cos cos, cos and cos sin^2 => sin sin, cos, but to do that you'd have to test all permutations ... or just factor first
			local function coeffTest(x)
				return symmath.powOp.is(x)
					and x[2] == symmath.Constant(2)
					and (symmath.sin.is(x[1]) or symmath.cos.is(x[1]))
			end
			
			for i=1,#expr-1 do
				local ei, ci = getCoeffsOf(expr[i], coeffTest)
				if ei then
					for j=i+1,#expr do
						local ej, cj = getCoeffsOf(expr[j], coeffTest)
						if ej 
						and ci == cj
						and ((symmath.sin.is(ei[1]) and symmath.cos.is(ej[1]))
							or (symmath.cos.is(ei[1]) and symmath.sin.is(ej[1])))
						and ei[1][1] == ej[1][1]
						then
							if #expr == 2 then return ci:clone() end	-- this can't happen with subOp because it starts at 2
							local newexpr = expr:clone()
							table.remove(newexpr, j)
							table.remove(newexpr, i)
							table.insert(newexpr, i, ci:clone())
							return newexpr
						end
					end
				end
			end
		end
		--]]

		--[[ replace 1 - sin^2 => cos^2 and 1 - cos^2 => sin^2
		expr = expr:prune()
		if symmath.addOp.is(expr) then
		end
	end)()
	return x
end
--]=]

local function simplifyPowers(x)
	return x:map(function(expr) 
		if symmath.powOp.is(expr) then 
			if symmath.divOp.is(expr[1]) then
				return expr[1][1]:clone()^expr[2]:clone()
					/ expr[1][2]:clone()^expr[2]:clone()
			end
			return expr:expand() 
		end 
	end)()
end




local Tensor = symmath.Tensor
local var = symmath.var
local vars = symmath.vars

local t,x,y,z = vars('t','x','y','z')
local r,phi,theta,psi = vars('r','\\phi','\\theta','\\psi')

local rHat = var'\\hat{r}'
rHat = r

local zHat = var'\\hat{z}'
zHat = z

local thetaHat = var'\\hat{\\theta}'
function thetaHat:applyDiff(x) return x:diff(theta) / r end

local phiHat = var'\\hat{\\phi}'
function phiHat:applyDiff(x) return x:diff(phi) / (r * symmath.sin(theta)) end

local psiHat = var'\\hat{\\psi}'
function psiHat:applyDiff(x) return x:diff(psi) end

local alpha = var('\\alpha', {r})
local omega = var('\\omega', {t, r})
local q = var('q', {t,x,y,z})

-- I need a better way of (1) defining functions, and (2) keeping track of their derivatives
local class = require 'ext.class'

local delta2 = symmath.Matrix:lambda({2,2}, function(i,j) return i==j and 1 or 0 end)
local delta3 = symmath.Matrix:lambda({3,3}, function(i,j) return i==j and 1 or 0 end)
local eta3 = symmath.Matrix:lambda({3,3}, function(i,j) return i==j and (i==1 and -1 or 1) or 0 end)
local eta4 = symmath.Matrix:lambda({4,4}, function(i,j) return i==j and (i==1 and -1 or 1) or 0 end)

for _,info in ipairs{
--[=[
	{
		title = 'polar',
		coords = {r,phi},
		embedded = {x,y},
		flatMetric = delta2,
		chart = function() 
			return Tensor('^I', r * symmath.cos(phi), r * symmath.sin(phi))
		end,
	},
	{
		title = 'polar, anholonomic, normalized',
		coords = {rHat,thetaHat},
		baseCoords = {r,theta},
		embedded = {x,y},
		flatMetric = delta2,
		chart = function()
			return Tensor('^I', r * symmath.cos(theta), r * symmath.sin(theta))
		end,
	},
	{
		title = 'cylindrical surface',
		coords = {phi,z},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			return Tensor('^I', r * symmath.cos(phi), r * symmath.sin(phi), z)
		end,
	},
	{
		title = 'cylindrical',
		coords = {r,phi,z},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			return Tensor('^I', r * symmath.cos(phi), r * symmath.sin(phi), z)
		end,
	},
	{
		title = 'cylindrical, anholonomic, normalized',
		coords = {rHat,thetaHat,zHat},
		baseCoords = {r,theta,z},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			return Tensor('^I', r * symmath.cos(theta), r * symmath.sin(theta), z)
		end,
	},
	{
		title = 'spiral',
		coords = {r,phi},
		embedded = {x,y},
		flatMetric = delta2,
		chart = function()
			return Tensor('^I',
				r * symmath.cos(phi + symmath.log(r)),
				r * symmath.sin(phi + symmath.log(r))
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
				r * symmath.cos(phi + t),
				r * symmath.sin(phi + t))
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
				r * symmath.cos(phi),
				r * symmath.sin(phi))
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
				r * symmath.cos(phi + omega),
				r * symmath.sin(phi + omega)
			)
		end,
	},
--]]
	{
		title = 'spherical',
		coords = {r,theta,phi},
		embedded = {x,y,z},
		flatMetric = delta3,
		chart = function()
			return Tensor('^I', 
				r * symmath.sin(theta) * symmath.cos(phi),
				r * symmath.sin(theta) * symmath.sin(phi),
				r * symmath.cos(theta))
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
				r * symmath.sin(theta) * symmath.cos(phi),
				r * symmath.sin(theta) * symmath.sin(phi),
				r * symmath.cos(theta))
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
				r * symmath.sin(theta) * symmath.cos(phi),
				r * symmath.sin(theta) * symmath.sin(phi),
				r * symmath.cos(theta))
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
				r * symmath.sin(theta) * symmath.cos(phi),
				r * symmath.sin(theta) * symmath.sin(phi),
				r * symmath.cos(theta))
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
				r/alpha * symmath.sin(theta) * symmath.cos(phi),
				r/alpha * symmath.sin(theta) * symmath.sin(phi),
				r/alpha * symmath.cos(theta))
		end,
	},
--]]
-- [[
	(function()
		local baseCoords = table{psi,theta,phi}
		
		local cos = symmath.cos
		local sin = symmath.sin
		local tan = symmath.tan
		local function cot(...) return cos(...) / sin(...) end

		-- notice these are negative the Rodrigues rotation formula / typical Euler angles
		-- but they are this way to match MTW while I pick the question apart
		local function Rx(theta)
			return symmath.Matrix(
				{1, 0, 0},
				{0, cos(theta), -sin(theta)},
				{0, sin(theta), cos(theta)})
		end
		local function Ry(theta)
			return symmath.Matrix(
				{cos(theta), 0, sin(theta)},
				{0, 1, 0},
				{-sin(theta), 0, cos(theta)})
		end
		local function Rz(theta)
			return symmath.Matrix(
				{cos(theta), -sin(theta), 0},
				{sin(theta), cos(theta), 0},
				{0, 0, 1})
		end
		local Rs = table{Rx, Ry, Rz}

		--[=[ mtw's:
		-- u spans rows, I spans cols
		local em = { 
			{-sin(psi) * cot(theta), cos(psi), sin(psi) / sin(theta)},
			{cos(psi) * cot(theta), sin(psi), -cos(psi) / sin(theta)},
			{1, 0, 0},
		}
		--]=]
		--[=[ mtw's, with rows rescaled to remove sin(theta) in denominator.  doesn't produce the same commutations	
		local em = { 
			{-sin(psi) * cos(theta), cos(psi) * sin(theta), sin(psi)},
			{cos(psi) * cos(theta), sin(psi) * sin(theta), -cos(psi)},
			{1, 0, 0},
		}
		--]=]	
		--[=[ mtw picked apart
		local invem = symmath.Matrix(
			{0, 0, 1},
			{cos(psi), sin(psi), 0},
			{sin(theta) * sin(psi), -sin(theta) * cos(psi), cos(theta)}
		)
		local em = simplifyTrig(symmath.Matrix(table.unpack(invem)):inverse())()
		--]=]
		-- [=[ mtw by construction
		local P = (Rz(psi) * Rx(theta) * Rz(phi))()
		local dP = baseCoords:map(function(theta_i,i)
			return (P:diff(theta_i)())
		end)
		local eP = Rs:map(function(R,i) 
			return (simplifyTrig((R(t):diff(t)() * P)():replace(t,0)))
		end)

		local xs = {'x','y','z'}
		printbr([[$P = R_z(\psi) R_x(\theta) R_z(\phi) = $]],P)
		for i=1,3 do
			printbr([[$e_]]..i..[[(P) = \frac{\partial}{\partial t} R_]]..xs[i]..[[(t) |_{t=0} \cdot P = K_]]..xs[i]..[[ \cdot P = $]], eP[i])
		end
		for i,theta_i in ipairs(baseCoords) do 
			printbr(var'P':diff(theta_i):eq(dP[i]))
		end
		printbr(var'P':diff(psi):eq(var'e''_3' * var'P'), '?', P:diff(psi)() == e3P) 	-- e3(P) := d/dpsi P == d/dt Rz(t) * P
		for i=1,3 do
			printbr([[$e_{]]..i..[[1} \frac{\partial P}{\partial \psi} + e_{]]..i..[[2} \frac{\partial P}{\partial \theta} + e_{]]..i..[[3} \frac{\partial P}{\partial \psi} = e_]]..i..[[(P) = K_]]..xs[i]..[[ \cdot P$]])
		end
		--[[
		(ei1 d/dpsi + ei2 d/dtheta + ei3 d/dphi) P = Ri(t):diff(t) * P
		solve for eij
		--]]
		printbr[[
$\left[\matrix{
	\frac{\partial P}{\partial \psi} |
		\frac{\partial P}{\partial \theta} |
		\frac{\partial P}{\partial \phi}
}\right] \left[\matrix{
	e_1 | e_2 | e_3
}\right] = \left[\matrix{
	K_x P | K_y P | K_z P
}\right]$
]]

		local dPm = symmath.Matrix(range(9):map(function(ij)
			local i, j = math.floor((ij-1)/3)+1, (ij-1)%3+1
			return range(3):map(function(k)
				return dP[k][i][j]
			end)
		end):unpack())

		local emv = symmath.Matrix(range(3):map(function(i)
			return range(3):map(function(j)
				return var'e'('_'..i..j)
			end)
		end):unpack())

		local ePm = symmath.Matrix(range(9):map(function(ij)
			local i, j = math.floor((ij-1)/3)+1, (ij-1)%3+1
			return range(3):map(function(k)
				return eP[k][i][j]
			end)
		end):unpack())


		printbr((dPm * emv):eq(ePm))

		--[[
		A x = b
		pseudoinverse
		At A x = At b
		--]]
		local AtA = simplifyTrig(simplifyPowers((dPm:transpose() * dPm)()))
		local Atb = simplifyTrig(simplifyPowers((dPm:transpose() * ePm)()))
		printbr(( AtA * emv ):eq( Atb ))
		local emvsoln = simplifyTrig((AtA:inverse() * Atb)())
		printbr(emv:eq(emvsoln))

		local em = emvsoln:transpose()
		--]=]

		local evs = range(3):map(function(i) 
			local ei = var('e_'..i) 
			function ei:applyDiff(x)
				return range(3):map(function(j) 
					return em[i][j] * x:diff(baseCoords[j])
				end):sum()
			end
			return ei
		end)
		
		return {
			title = 'rotation group',
			coords = evs,
			baseCoords = baseCoords,
			embedded = {x,y,z},
			flatMetric = delta3,
			basis = function()
				return Tensor('_u^I', table.unpack(em))
			end,
		}
	end)(),
--]]
} do
	print('<h3>'..info.title..'</h3>')

	Tensor.coords{
		{variables=info.coords},
		{variables=info.embedded, symbols='IJKLMN', metric=info.flatMetric}
	}
			
	local baseCoords = info.baseCoords or info.coords

	printbr('coordinates:', table.unpack(info.coords))
	printbr('base coords:', table.unpack(baseCoords))
	printbr('embedding:', table.unpack(info.embedded))

	local eta = Tensor('_IJ', unpack(info.flatMetric))
	printbr'flat metric:'
	printbr(var'\\eta''_IJ':eq(eta'_IJ'()))
	printbr()

-- [[
	local e = Tensor'_u^I'
	if info.chart then
		local u = info.chart()
		printbr'coordinate chart:'
		printbr(var'u''^I':eq(u'^I'()))
		printbr()

		--printbr'holonomic embedded:'
		printbr'embedded:'
		e['_u^I'] = u'^I_,u'()
		printbr(var'e''_u^I':eq(var'u''^I_,u'):eq(u'^I_,u'()):eq(e'_u^I'()))
		printbr()
	elseif info.basis then
		printbr'basis:'
		e['_u^I'] = info.basis()()
		printbr(var'e''_u^I':eq(e'_u^I'()))
		printbr()
	end

	eU = Tensor('^u_I', table.unpack(simplifyTrig(symmath.Matrix(table.unpack(e)):inverse():transpose())))
	printbr(var'e''^u_I':eq(eU))
	printbr((var'e''_u^I' * var'e''^v_I'):eq(simplifyTrig((e'_u^I' * eU'^v_I')())))
	printbr((var'e''_u^I' * var'e''^u_J'):eq(simplifyTrig((e'_u^I' * eU'^u_J')())))
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
	c['_ab^c'] = simplifyTrig(((e'_b^I_,a' - e'_a^I_,b') * eU'^c_I')())
	printbr(var'c''_ab^c':eq(c'_ab^c'()))

	local g = (e'_u^I' * e'_v^J' * eta'_IJ')()
	-- TODO automatically do this ...
	g = simplifyTrig(simplifyPowers(g))
printbr(var'g''_uv':eq(var'e''_u^I' * var'e''_v^J' * var'\\eta''_IJ'):eq(g'_uv'()))
--]]

--[[  I don't remember what this was about ...
local g = Tensor('_ab', function(a,b) 
	if a~=b then return 0 end
	if a == 1 then return -1 end
	if a == 2 then return q end
	return 1
end)
--]]

--[[ using diffgeom
verbose = true
	local props = require 'symmath.diffgeom'(g, nil, c)
	printbr(var'g''_uv':eq(var'e''_u^I' * var'e''_v^J' * var'\\eta''_IJ'))
	printbr(var'\\Gamma''_abc':eq(symmath.divOp(1,2)*(var'g''_ab,c' + var'g''_ac,b' - var'g''_bc,a' + var'c''_abc' + var'c''_acb' - var'c''_bca')))
	props:print(printbr)
	local Gamma = props.Gamma
--]]
-- [[ inline
	local basis = Tensor.metric(g, nil)
	g = basis.metric
	local gU = basis.metricInverse

	printbr(var'g''^uv':eq(gU'^uv'()))

	local dg = Tensor'_abc'
	dg['_abc'] = g'_ab,c'()
	printbr(var'g''_ab,c':eq(dg'_abc'()))
	
	local expr = ((dg'_abc' + dg'_acb' - dg'_bca') / 2)
	if c then expr = expr + (c'_abc' + c'_acb' - c'_bca')/2 end
	local GammaL = Tensor'_abc'
	printbr(var'\\Gamma''_abc':eq(expr))
	GammaL['_abc'] = expr()
	printbr(var'\\Gamma''_abc':eq(GammaL'_abc'()))
	
	local Gamma = GammaL'^a_bc'()
	printbr(var'\\Gamma''^a_bc':eq(Gamma'^a_bc'()))
	
	local dGamma = Tensor'^a_bcd'
	dGamma['^a_bcd'] = Gamma'^a_bc,d'()
	printbr(var'\\Gamma''^a_bc,d':eq(dGamma'^a_bcd'()))

	local expr = Gamma'^a_ec' * Gamma'^e_bd'
	local GammaSq = Tensor'^a_bcd'
	GammaSq['^a_bcd'] = expr()
	printbr(expr:eq(GammaSq))
--]]

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
	local divVarExpr = var'A''^i_,i' + var'\\Gamma''^i_ji' * var'A''^j'
	local divExpr = divVarExpr:replace(var'A', A):replace(var'\\Gamma', Gamma)
	-- TODO only simplify TensorRef, so the indexes are fixed
	printbr('divergence:', divVarExpr:eq(divExpr):eq(divExpr():factorDivision())) 
	
	printbr'geodesic:'
	-- TODO unravel equaliy, or print individual assignments
	printbr(((d2x'^a' + Gamma'^a_bc' * dx'^b' * dx'^c'):eq(Tensor'^u'))())
	printbr()
end

print(MathJax.footer)
