#!/usr/bin/env luajit
--[[
here's my thought:
test differerent simplified discrete spacetimes
1) solve the simplified spacetime constraint:
1.a) solve alpha_i = alpha(r_i) to minimize phi_i = ||G_ab(alpha_i) - 8 pi T_ab(alpha_i)|| 
--]]
require 'ext'
require 'symmath'.setup()
require 'symmath.tostring.MathJax'.setup{
	title='Discrete EFE funtion of alpha',
}

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
local n = 100
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
		{['8 pi T_x_x'] = _8piT(qs)[2]},
		{['G_t_t'] = G(qs)[1]},
		{['G_x_x'] = G(qs)[2]},
		{['G_t_t - 8 pi T_t_t'] = EFE(qs)[1]},
		{['G_x_x - 8 pi T_x_x'] = EFE(qs)[2]},
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

local Gl = Matrix(EinsteinLL[1][1], EinsteinLL[2][2])
printbr(Gl)
local x = Matrix{A:diff(r,r), B:diff(r,r)}:transpose()
local A, b = factorLinearSystem(Gl, x:transpose()[1])
printbr(A, x, '=', b)
printbr"so there are two solutions to B''"
printbr"if their difference equals zero then we still have a solution..."
printbr((b[1][1] / A[1][2] - b[2][1] / A[2][2])():eq(0))
printbr'...and this is where the constraint that $A \\cdot B = c$ comes from.'
os.exit()

-- TODO PREM data
local StressEnergyCompileArgs = {
	r, A, B,
	{[rho]='earthDensity'}, 
	{[P]='earthPressure'}, 
	{[pi]='pi'},
}
local _8piTtt_func = (8 * pi * StressEnergy[1][1]):compile(StressEnergyCompileArgs)
local _8piTrr_func = (8 * pi * StressEnergy[2][2]):compile(StressEnergyCompileArgs)

local Gtt_func = EinsteinLL[1][1]
	:replace(A:diff(r), var'dA')
	:replace(B:diff(r), var'dB')
	:replace(A:diff(r,r), var'd2A')
	:replace(B:diff(r,r), var'd2B')
	:compile{r, A, B, var'dA', var'dB', var'd2A', var'd2B'}

local solveWithForwardEuler = true 
if solveWithForwardEuler then
	local r = rmax
	local A, B = 1, 1
	local dA, dB = 0, 0
	local d2A, d2B = 0, 0
	for i=1,n do
		local dr = -dr
	end
end
