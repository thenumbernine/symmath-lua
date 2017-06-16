#!/usr/bin/env luajit
--[[
here's my thought:
test differerent simplified discrete spacetimes
1) solve the simplified spacetime constraint:
1.a) solve alpha_i = alpha(r_i) to minimize phi_i = ||G_ab(alpha_i) - 8 pi T_ab(alpha_i)|| 
--]]
require 'ext'
require 'symmath'.setup()
require 'symmath.tostring.MathJax'.setup()

local t,r,theta,phi = vars('t','r','\\theta','\\phi')
local coords = {t,r,theta,phi}
Tensor.coords{
	{variables=coords},
}

local alpha = var('\\alpha', {r})
--[[ alpha of ADM in spherical
local g = Tensor('_ab', table.unpack(Matrix.diagonal(-alpha^2, 1,r^2,(r*sin(theta))^2)))
local gU = Tensor('^ab', table.unpack(Matrix.diagonal(-1/alpha^2, 1,r^-2,(r*sin(theta))^-2)))
--]]
--[[ alpha of ADM in cartesian
local g = Tensor('_ab', table.unpack(Matrix.diagonal(-alpha^2, 1,1,1)))
local gU = Tensor('^ab', table.unpack(Matrix.diagonal(-1/alpha^2, 1,1,1)))
--]]
-- [[ A and B of Schwarzschild in spherical
local A = var('A',{r})
local B = var('B',{r})
local g = Tensor('_ab', table.unpack(Matrix.diagonal(B, A, r^2, (r*sin(theta))^2)))
local gU = Tensor('^ab', table.unpack(Matrix.diagonal(1/B, 1/A, r^-2, (r*sin(theta))^-2)))
--]]
--[[ A and B of Schwarzschild in cartesian 
local A = var('A',{r})
local B = var('B',{r})
local g = Tensor('_ab', table.unpack(Matrix.diagonal(A, B, B, B)))
local gU = Tensor('^ab', table.unpack(Matrix.diagonal(1/A, 1/B, 1/B, 1/B)))
--]]
g:print'g'
gU:print'g'

local props = class(
	require 'symmath.physics.diffgeom'
	--{print=printbr}
)(g, gU)
--props:print()
local EinsteinLL = props.Einstein'_ab'()
printbr(EinsteinLL:print'G')

-- ok now we have alpha, we have G_ab as a function of alpha ...

-- assume T_ab is only a function of r ...
-- and is diagonal ...
-- MTW 22.16d, for u_a = n_a = t_,a: T_ab = (rho + P) n_a n_b + P g_ab
-- for g_ab = diag(-1, 1, r^2, r^2 sin(theta)^2) and n_a = (1, 0, 0, 0)
-- we get T_ab = diag(rho, P, P r^2, P r^2 sin(theta)^2)
local n = Tensor('_a', 1, 0, 0, 0)
--local StressEnergy = Tensor('_ab', table.unpack(Matrix.diagonal(rho, P, P * r^2, P * (r * sin(theta))^2)))
local rho = var'\\rho'
local P = var'P'
local StressEnergy = ((rho + P) * n'_a' * n'_b' + P * g'_ab')()
printbr(StressEnergy:print'T')

local matrix = require 'matrix'
local c = 299792458						--  ... m/s = 1
local G = 6.67384e-11						--  ... m^3 / (kg s^2) = 1
local earthRadius = 6.37101e+6
local earthMass = 5.9736e+24 * G / c / c					--  total mass within radius, in m
local earthDensity = earthMass / (4/3 * math.pi * earthRadius^3)	--  average density, in m^-2
local earthPressure = 0
local n = 1000
local rmax = 2 * earthRadius
local rmin = rmax * .01
local dr = (rmax - rmin) / n
local rs = matrix{n}:lambda(function(i) return rmin + (i-.5) * dr end)

local solveWithGMRES = false 
if solveWithGMRES then
	local function D(y) 
		return matrix{n}:lambda(function(i)
			local yL = i == n and Drhs(y) or y[i+1]
			local yR = i == 1 and Dlhs(y) or y[i-1]
			return (yL - yR) / (2 * dr)
		end)
	end
	local function D2(y)
		return matrix{n}:lambda(function(i)
			local yi =  y[i]
			local yL = i == n and Drhs(y) or y[i+1]
			local yR = i == 1 and Dlhs(y) or y[i-1]
			return (yL - 2 * yi + yR) / (dr * dr)
		end)
	end

	Dlhs = function(qs) return assert(qs[1]) end
	Drhs = function(qs) return 1 end
	local qs = matrix{2,n}:ones()	-- A's and B's
	local function _8piT(qs)
		local As, Bs = table.unpack(qs)
		return matrix{
			matrix{n}:lambda(function(i) return earthPressure * (1 + As[i]) + earthDensity end),
			matrix{n}:lambda(function(i) return earthPressure * Bs[i] end),
		} * 8 * math.pi
	end
	local function G(qs)
		local As, Bs = qs:unpack()
		local DAs = D(As)
		local D2As = D2(As)
		local DBs = D(Bs)
		local D2Bs = D2(Bs)
		local _8piTs = _8piT(qs)
		return matrix{
			matrix{n}:lambda(function(i) 
				local A, B = As[i], Bs[i]
				local DA, DB = DAs[i], DBs[i]
				local D2A, D2B = D2As[i], D2Bs[i]
				return (2 * D2A * A * B^2
					- DA^2 * B^2
					+ 8 * D2B * A^2 * B
					+ DA * DB * A * B
					- 6 * DB^2 * A^2)
						/ 4 * A * B^3
			end),
			matrix{n}:lambda(function(i)
				local A, B = As[i], Bs[i]
				local DA, DB = DAs[i], DBs[i]
				local D2A, D2B = D2As[i], D2Bs[i]
				return (2 * D2A * A * B^2
					+ 3 * DA * DB * A * B
					- DA^2 * B^2
					+ 4 * D2B * A^2 * B
					- 2 * DB^2 * A^2)
						/ 4 * A^2 * B^2
			end),
		}

	end
	local function EFE(qs)
		local As, Bs = qs:unpack()
		assert(As[1])
		local DAs = D(As)
		local D2As = D2(As)
		local DBs = D(Bs)
		local D2Bs = D2(Bs)
		local _8piTs = _8piT(qs)
		return matrix{
			matrix{n}:lambda(function(i) 
				local A, B = As[i], Bs[i]
				local DA, DB = DAs[i], DBs[i]
				local D2A, D2B = D2As[i], D2Bs[i]
				assert(A)
				assert(B)
				assert(DA)
				assert(DB)
				assert(D2A)
				assert(D2B)
				assert(_8piTs[1][i], "failed to find 8piT["..i..']')
				return 2 * D2A * A * B^2
					- DA^2 * B^2
					+ 8 * D2B * A^2 * B
					+ DA * DB * A * B
					- 6 * DB^2 * A^2
					- 4 * A * B^3 * _8piTs[1][i]
			end),
			matrix{n}:lambda(function(i)
				local A, B = As[i], Bs[i]
				local DA, DB = DAs[i], DBs[i]
				local D2A, D2B = D2As[i], D2Bs[i]
				assert(A)
				assert(B)
				assert(DA)
				assert(DB)
				assert(D2A)
				assert(D2B)
				assert(_8piTs[2][i])
				return 2 * D2A * A * B^2
					+ 3 * DA * DB * A * B
					- DA^2 * B^2
					+ 4 * D2B * A^2 * B
					- 2 * DB^2 * A^2
					- 4 * A^2 * B^2 * _8piTs[2][i]
			end),
		}
	end
	qs = require 'solver.jfnk'{
		x = qs,
		f = EFE,
		clone = matrix,
		dot = function(a,b) return a[1]:dot(b[1]) + a[2]:dot(b[2]) end,
		epsilon = 1e-50,
		errorCallback = function(err, iter)
			io.stderr:write('jfnk iter ',iter,' err ',err,'\n')
			io.stderr:flush()
		end,
		gmres = {
			maxiter = n,
			restart = 20,
			epsilon = 1e-20,
			errorCallback = function(err, iter)
				io.stderr:write('gmres iter ',iter,' err ',err,'\n')
				io.stderr:flush()
			end,
		},
	}
	for _,info in ipairs{
		{['A'] = qs[1]},
		{['B'] = qs[2]},
		{['8 pi T_t_t'] = _8piT(qs)[1]},
		{['8 pi T_r_r'] = _8piT(qs)[2]},
		{['G_t_t'] = G(qs)[1]},
		{['G_r_r'] = G(qs)[2]},
		{['G_t_t - 8 pi T_t_t'] = EFE(qs)[1]},
		{['G_r_r - 8 pi T_r_r'] = EFE(qs)[2]},
	} do
		local title, y = next(info)
		require 'symmath.tostring.GnuPlot':plot{
			style = 'data lines',
			--log = 'y',
			data = {rs, y},
			{using='1:(abs($2))', title=title},
		}
	end
end

local eqns = range(4):map(function(i) 
	local eqn = EinsteinLL[i][i]:eq(8 * pi * StressEnergy[i][i])
	printbr(eqn)
	return eqn
end)
printbr'difference between 1st and 2nd...'
printbr(((eqns[1] / B - eqns[2] / A) * -r * A^2 * B)())
printbr((A * B):diff(r):eq(-8 * pi * r * A^2 * (rho + P)))
printbr'difference between 2nd and 3rd...'
printbr(((eqns[2] / A - eqns[3] / r^2) * 4 * A^2 * B^2 * r^2 )())
printbr'differences between 3rd and 4th...'
printbr((eqns[3] - eqns[4] / sin(theta)^2)())	-- match!

--[[
local x = Matrix{A:diff(r,r), B:diff(r,r)}:transpose()
local A, b = factorLinearSystem(Gl, x:transpose()[1])
printbr(A, x, '=', b)
printbr"(note, factoring this is based on assuming $8 \\pi T_{ab} = 0$)"
printbr"so there are two solutions to B''"
printbr"if their difference equals zero then we still have a solution..."
printbr((b[1][1] / A[1][2] - b[2][1] / A[2][2])():eq(0))
printbr'...and this is where the constraint that $A \\cdot B = c$ comes from.'
os.exit()
--]]

-- TODO PREM data
local StressEnergyCompileArgs = {
	r, A, B,
	{earthDensity=rho},
	{earthPressure=P},
	{pi=pi},
}
local _8piTtt_func = (8 * pi * StressEnergy[1][1]):compile(StressEnergyCompileArgs)
local _8piTrr_func = (8 * pi * StressEnergy[2][2]):compile(StressEnergyCompileArgs)

local Gtt_func = EinsteinLL[1][1]
	:replace(A:diff(r), var'dA')
	:replace(B:diff(r), var'dB')
	:replace(B:diff(r,r), var'd2B')
	:compile{r, A, B, var'dA', var'dB', var'd2B'}
local Grr_func = EinsteinLL[2][2]
	:replace(A:diff(r), var'dA')
	:replace(B:diff(r), var'dB')
	:replace(B:diff(r,r), var'd2B')
	:compile{r, A, B, var'dA', var'dB', var'd2B'}

local solveWithForwardEuler = true 
if solveWithForwardEuler then

	function table.reverse(t)
		local r = table()
		for i=#t,1,-1 do
			r:insert(t[i])
		end
		return r
	end

	local function calcDerivVars(r, q)
		local A, B, dB_dr = q:unpack()

		local rhoPlusP = r < earthRadius and (earthPressure + earthDensity) or 0

		-- (G_tt = 8 pi T_tt) / B - (G_rr / 8 pi T_rr) / A gives 
		-- (A B)' = - 8 pi r A^2 (rho + P)
		local dAB_dr = -8 * math.pi * r * A^2 * rhoPlusP 
		local dA_dr = (dAB_dr - dB_dr * A) / B
		-- (G_rr = 8 pi T_rr) / A - (G_theta_theta - 8 pi T_theta_theta) / r^2
		-- 2 A' B^2 r - 2 B'' A B r^2 + A' B' B r^2 + B'^2 A r^2 + 2 B' A B r + 4 A B^2 - 4 A^2 B^2 = 0
		-- 2 B'' A B r^2 = (A' B + B' A) (2 B r + B' r^2) + 4 A B^2 (1 - A)
		-- B'' = ((A' B + B' A) (2 B r + B' r^2) + 4 A B^2 (1 - A)) / (2 A B r^2)
		-- B'' = -4 pi A (rho + P) (2 + B'/B r) + 2 B (1 - A) / r^2
		local d2B_dr2 = -4 * math.pi * A * rhoPlusP * (2 + r * dB_dr / B) + 2 * B * (1 - A) / r^2
		return dA_dr, dB_dr, d2B_dr2
	end

	local function dq_dr(r, q)
		local dA_dr, dB_dr, d2B_dr2 = calcDerivVars(r, q)
		return matrix{dA_dr, dB_dr, d2B_dr2}
	end

	local function int_fe(r, q, dq_dr, dr)
		return r + dr, q + dq_dr(r, q) * dr
	end

	local function int_rk4(r, q, dq_dr, dr)
		local k1 = dq_dr(r, q)
		local k2 = dq_dr(r + .5 * dr, q + .5 * dr * k1)
		local k3 = dq_dr(r + .5 * dr, q + .5 * dr * k2)
		local k4 = dq_dr(r + dr, q + dr * k3)
		return r + dr, q + (k1 + 2 * k2 + 2 * k3 + k4) * dr / 6
	end

	local function definite_integral(r1, r2, q1)
		local r = r1
		local q = q1
		local dr = (r2 - r1) / n
	
		local rs = table()
		local As = table()
		local Bs = table()
		local dA_drs = table()
		local dB_drs = table()
		local d2B_dr2s = table()
		for i=1,n do
			r, q = int_rk4(r, q, dq_dr, dr)
			local A, B, dB_dr = q:unpack()
			local dA_dr, dB_dr, d2B_dr2 = calcDerivVars(r, q)
			rs:insert(r)
			As:insert(A)
			Bs:insert(B)
			dA_drs:insert(dA_dr)
			dB_drs:insert(dB_dr)
			d2B_dr2s:insert(d2B_dr2)
		end
	
		return rs, As, Bs, dA_drs, dB_drs, d2B_dr2s
	end
	
	-- start at rmax and integrate inwards
	local r = rmax
	local q = matrix{1,-1,0}	-- A, B, B'
	local rs, As, Bs, dA_drs, dB_drs, d2B_dr2s = definite_integral(rmax, rmin, q)
	local inward = table{rs=rs, As=As, Bs=Bs, dA_drs=dA_drs, dB_drs=dB_drs, d2B_dr2s=d2B_dr2s}

	-- reverse the inward trace
	for _,k in ipairs(inward:keys()) do
		inward[k] = inward[k]:reverse()
	end

	-- start at rmin (with the last q) and integrate outwards
	local r = rs:last()
	local q = matrix{As:last(), Bs:last(), dB_drs:last()}
	local rs, As, Bs, dA_drs, dB_drs, d2B_dr2s = definite_integral(rmin, rmax, q)
	local outward = table{rs=rs, As=As, Bs=Bs, dA_drs=dA_drs, dB_drs=dB_drs, d2B_dr2s=d2B_dr2s}

	-- looks basically the same
	-- ok
	-- so now that we have (approximations of) functions for B(r) and A(r) where ds^2 = B(r) dt^2 + A(r) dr^2 + r^2 (dtheta^2 + sin(theat)^2 dphi^2)
	-- since dr itself is growing and shrinking
	-- I need to re-plot the graph with respect to a fixed radial ruler ...
	for _,t in ipairs{inward, outward} do
		t.rhos = table()	-- ds^2 = A(r) dr^2 <=> dr = ds/sqrt(A)
		local rho = 0
		for i=1,n do
			rho = rho + dr/math.sqrt(t.As[i])
			t.rhos:insert(rho)
		end
	end

	local _8piTtts = matrix{n}:lambda(function(i) return _8piTtt_func(rs[i], As[i], Bs[i], earthDensity, earthPressure, math.pi) end)
	local _8piTrrs = matrix{n}:lambda(function(i) return _8piTrr_func(rs[i], As[i], Bs[i], earthDensity, earthPressure, math.pi) end)
	local Gtts = matrix{n}:lambda(function(i) return Gtt_func(rs[i], As[i], Bs[i], dA_drs[i], dB_drs[i], d2B_dr2s[i]) end)
	local Grrs = matrix{n}:lambda(function(i) return Grr_func(rs[i], As[i], Bs[i], dA_drs[i], dB_drs[i], d2B_dr2s[i]) end)
	for _,info in ipairs{
		{['A'] = 'As'},
		{['B'] = 'Bs'},
		--[[
		{['8 pi T_t_t'] = _8piTtts},
		{['8 pi T_r_r'] = _8piTrrs},
		{['G_t_t'] = Gtts},
		{['G_r_r'] = Grrs},
		{['G_t_t - 8 pi T_t_t'] = Gtts - _8piTtts},
		{['G_r_r - 8 pi T_r_r'] = Grrs - _8piTrrs},
		--]]
	} do
		local title, ys = next(info)
		require 'symmath.tostring.GnuPlot':plot{
			style = 'data lines',
			data = {inward.rs, inward[ys], outward.rs, outward[ys]},
			{using='1:2', title='inward '..title},
			{using='3:4', title='outward '..title},
		}
		require 'symmath.tostring.GnuPlot':plot{
			style = 'data lines',
			data = {inward.rhos, inward[ys], outward.rhos, outward[ys]},
			{using='1:2', title='inward '..title..' wrt abs coord rho'},
			{using='3:4', title='outward '..title..' wrt abs coord rho'},
		}
	end
end
