#!/usr/bin/env luajit
--[[
here's my thought:
test differerent simplified discrete spacetimes
1) solve the simplified spacetime constraint:
1.a) solve alpha_i = alpha(r_i) to minimize phi_i = ||G_ab(alpha_i) - 8 pi T_ab(alpha_i)|| 
--]]
require 'ext'
require 'symmath'.setup() --{implicitVars=true}
require 'symmath.tostring.MathJax'.setup()

local solveWithGMRES = false
local solveWithLU = false
local solveWithInitValue = true

local GnuPlot = require 'symmath.tostring.GnuPlot'
local function plot(x, y, title)
	args = {
		data = {x, y},
		style = 'data lines',
	}
	args[1] = {using='1:2', title=title}
	return GnuPlot:plot(args)
end

local t,r,theta,phi = vars('t','r','\\theta','\\phi')
local coords = {t,r,theta,phi}
Tensor.coords{
	{variables=coords},
	{symbols='t', variables={t}},
}

local alpha = var('\\alpha', {r})
--[[ alpha of ADM in spherical, constant spatial
local g = Tensor('_ab', table.unpack(Matrix.diagonal(-alpha^2, 1,r^2,(r*sin(theta))^2)))
local gU = Tensor('^ab', table.unpack(Matrix.diagonal(-1/alpha^2, 1,r^-2,(r*sin(theta))^-2)))
--]]
--[[ alpha of ADM in cartesian, constant spatial
local g = Tensor('_ab', table.unpack(Matrix.diagonal(-alpha^2, 1,1,1)))
local gU = Tensor('^ab', table.unpack(Matrix.diagonal(-1/alpha^2, 1,1,1)))
--]]
-- [[ alpha in ADM in spherical, spatial is inverse temporal
local g = Tensor('_ab', table.unpack(Matrix.diagonal(-alpha^2, 1/alpha^2, r^2, (r*sin(theta))^2)))
local gU = Tensor('^ab', table.unpack(Matrix.diagonal(-1/alpha^2, alpha^2, r^-2, (r*sin(theta))^-2)))
--]]
g:print'g'
gU:print'g'

local props = class(
	require 'symmath.physics.diffgeom'
	--{print=printbr}
)(g, gU)
--props:print()

printbr()
printbr'resting gravity:'
printbr(var'\\Gamma''^u_tt':eq((props.Gamma'^u_tt')()))

local EinsteinLL = props.Einstein'_ab'()
EinsteinLL:print'G'

-- ok now we have alpha, we have G_ab as a function of alpha ...

-- assume T_ab is only a function of r ...
-- and is diagonal ...
-- MTW 22.16d, for u_a = n_a = t_,a: T_ab = (rho + P) n_a n_b + P g_ab
-- for g_ab = diag(-1, 1, r^2, r^2 sin(theta)^2) and n_a = (1, 0, 0, 0)
-- we get T_ab = diag(rho, P, P r^2, P r^2 sin(theta)^2)
local n = Tensor('_a', 1, 0, 0, 0)
local P = 0
local rho = var'\\rho'
--local StressEnergy = Tensor('_ab', table.unpack(Matrix.diagonal(rho, P, P * r^2, P * (r * sin(theta))^2)))
local StressEnergy = ((rho + P) * n'_a' * n'_b' + P * g'_ab')()
StressEnergy:print'T'
printbr()

for a=1,4 do
	for b=1,4 do
		if EinsteinLL[a][b] ~= Constant(0) or StressEnergy[a][b] ~= Constant(0) then
			printbr(EinsteinLL[a][b]:eq((8 * pi * StressEnergy[a][b])()))
		end
	end
end

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

local function Dlhs(y) return y[1] end
local function Drhs(y) return 1 end

local function D(y) 
	return matrix{n}:lambda(function(i)
		local yR = i == n and Drhs(y) or y[i+1]
		local yL = i == 1 and Dlhs(y) or y[i-1]
		return (yR - yL) / (2 * dr)
	end)
end
local function D2(y)
	return matrix{n}:lambda(function(i)
		local yi =  y[i]
		local yR = i == n and Drhs(y) or y[i+1]
		local yL = i == 1 and Dlhs(y) or y[i-1]
		return (yR - 2 * yi + yL) / (dr * dr)
	end)
end

local _8piTtt_func = (8 * pi * StressEnergy[1][1]):compile{
	{[rho]='earthDensity'}, {[pi]='pi'},
}

local Gtt_func = EinsteinLL[1][1]
	:replace(alpha:diff(r), var'dr_alpha')
	:replace(alpha:diff(r,r), var'd2r_alpha')
	:compile{r, {[alpha]='alpha'}, var'dr_alpha', var'd2r_alpha'}

local function _8piTtt(r)
	return r < earthRadius 
		and _8piTtt_func(earthDensity, math.pi)
		or 0 
end
local _8piTtts = matrix{n}:lambda(function(i) return _8piTtt(rs[i]) end)	-- TODO PREM data
local scaleByR = false
if scaleByR then
	_8piTtts = _8piTtts:emul(rs)
end
plot(rs, _8piTtts, '8 pi T_t_t')

if solveWithGMRES then
	printbr'<h2>solutions using gmres</h2>'
	
	-- finite difference of G_tt
	local function Gtt(alphas)
		-- spherical coordinates: -a (a'' r + 2 a') = 8 pi T_tt r
		--local Gtts = -alphas:emul(D2(alphas) + 2 * D(alphas):ediv(rs))
		-- cartesian coordinates:
		--local Gtts = -alphas:emul(D2(alphas))
		-- poisson
		--local Gtts = -D2(alphas)
		
		-- compiled expr:
		local dr_alphas = D(alphas)
		local d2r_alphas = D2(alphas)
		local Gtts = matrix{n}:lambda(function(i)
			return Gtt_func(rs[i], alphas[i], dalphas[i], d2alphas[i])
		end)
		
		if scaleByR then
			Gtts = Gtts:emul(rs)
		end
		return Gtts
	end

	local alphas = matrix{n}:ones()
	alphas = require 'solver.gmres'{
		x = alphas,
		b = _8piTtts,
		A = Gtt,
		clone = matrix,
		dot = matrix.dot,
		maxiter = 10 * n,
		restart = n,
		epsilon = 1e-20,
		errorCallback = function(err, iter)
			io.stderr:write('gmres iter ',iter,' err ',err,'\n')
			io.stderr:flush()
		end,
	}
	plot(rs, alphas, 'alpha')
	plot(rs, Gtt(alphas), 'G_t_t')
	plot(rs, Gtt(alphas) - _8piTtts, 'G_t_t - 8 pi T_t_t')
end

if solveWithLU then
	printbr'<h2>solving iteratively using a dense LU inverse</h2>'
	Dlhs = function(y) return y[1] end
	Drhs = function(y) return 1 end
	local alphaIters = matrix()
	local Gtt_mat
	local alphas = matrix{n}:ones()
	table.insert(alphaIters, alphas)
	for iter=1,10 do
		Gtt_mat = matrix{n,n}:lambda(function(i,j)
			local alpha = alphas[i]
			local alphaR = i == n and Drhs(alphas) or alphas[i+1]
			local alphaL = i == 1 and Dlhs(alphas) or alphas[i-1]
			-- cartesian coordinates:
			if i == j then -- diagonal
				return 2 * alpha^2 / dr^2
			elseif i+1 == j then	-- right
				return -alpha * alphaR / dr^2
			elseif i-1 == j then	-- left
				return -alpha * alphaL / dr^2
			end
			return 0
		end)
		alphas = matrix(require 'solver.solve_qr'(Gtt_mat, _8piTtts))
		table.insert(alphaIters, alphas)
	end
	
	--plot(rs, alphas, 'alpha')
	GnuPlot:plot{
		style = 'data lines',
		log = 'y',
		griddata = {x=range(#alphaIters), y=rs, alphaIters},
		xlabel = 'r',
		ylabel = 'alpha',
		cblabel = 'iteration',
		{using='2:3:1', title='alpha', palette=true},
	}
--[[ annnd if the alphas are diverging then the rest of the calculations are moot
	plot(rs, Gtt_mat * alphas, 'G_t_t')
	plot(rs, Gtt_mat * alphas - _8piTtts, 'G_t_t - 8 pi T_t_t')
	local gravity = -alphas:emul(D(alphas)) * c * c * c
	gravity[1] = gravity[2]
	gravity[n] = gravity[n-1]
	plot(rs, gravity, 'gravity')
--]]
end

if solveWithInitValue then
	printbr'<h2>solutions using explicit integration backwards</h2>'
	local alphas = table()
	local dr_alphas = table()
	local d2r_alphas = table()
	local alpha = 1
	local dr_alpha = 0
	local r = rs[n]
	-- -a a'' = 8 pi rho => a'' = -8 pi rho / a
	for i=1,n do
		local d2r_alpha = -_8piTtt(r) / alpha
		alpha = alpha - dr * dr_alpha
		dr_alpha = dr_alpha - dr * d2r_alpha
		r = r - dr
		alphas:insert(1, alpha)
		dr_alphas:insert(1, dr_alpha)
		d2r_alphas:insert(1, d2r_alpha)
	end
	plot(rs, alphas, 'alpha')
	plot(rs, dr_alphas, 'd/dr alpha')
	plot(rs, d2r_alphas, 'd^2/dr^2 alpha')
	--plot(rs, A * alphas, 'G_t_t')
	--plot(rs, A * alphas - _8piTtts, 'G_t_t - 8 pi T_t_t')
	local gravity = -matrix(alphas):emul(matrix(dr_alphas)) * c * c * c
	gravity[1] = gravity[2]
	gravity[n] = gravity[n-1]
	plot(rs, gravity, 'gravity')

	printbr'solutions using explicit integration forwards'
	local alphas = table()
	local dr_alphas = table()
	local d2r_alphas = table()
	local alpha = .1
	local dr_alpha = 0
	local r = rs[1]
	-- -a a'' = 8 pi rho => a'' = -8 pi rho / a
	for i=1,n do
		local d2r_alpha = -_8piTtt(r) / alpha
		alpha = alpha + dr * dr_alpha
		dr_alpha = dr_alpha + dr * d2r_alpha
		r = r + dr
		alphas:insert(alpha)
		dr_alphas:insert(dr_alpha)
		d2r_alphas:insert(d2r_alpha)
	end
	plot(rs, alphas, 'alpha')
	plot(rs, dr_alphas, 'd/dr alpha')
	plot(rs, d2r_alphas, 'd^2/dr^2 alpha')
	--plot(rs, A * alphas, 'G_t_t')
	--plot(rs, A * alphas - _8piTtts, 'G_t_t - 8 pi T_t_t')
	local gravity = -matrix(alphas):emul(matrix(dr_alphas)) * c * c * c
	gravity[1] = gravity[2]
	gravity[n] = gravity[n-1]
	plot(rs, gravity, 'gravity')


end
