#!/usr/bin/env luajit
require 'ext'
require 'symmath'{MathJax={title='Parallel Propagtors'}}

-- TODO incorporate this with the metric catalog?


local r = var'r'
local phi = var'\\phi'
local theta = var'\\theta'

for _,info in ipairs{
	{
		name = 'polar, coordinate',
		coords = {r, phi},
		conns = {
			Matrix.diagonal(0, 1/r),
			Matrix({0, -r}, {1/r, 0}),
		},
	},
	{
		name = 'polar, orthonormal',
		coords = {r, phi},
		conns = {
			Matrix.diagonal(0, 0),			-- Gamma_rHat
			--Matrix({0, -1/r}, {1/r, 0})	-- Gamma_phiHat
			Matrix({0, -1}, {1, 0}),		-- Gamma_phi = e_phi^phiHat Gamma_phiHat = r Gamma_phiHat
		},
	},
	{
		name = 'spherical, coordinate:',
		coords = {r, theta, phi},
		conns = {
			Matrix.diagonal(0, 1/r, 1/r),
			Matrix(
				{0, -r, 0}, 
				{1/r, 0, 0}, 
				{0, 0, cos(theta)/sin(theta)}
			),
			Matrix(
				{0, 0, -r*sin(theta)^2}, 
				{0, 0, -sin(theta)*cos(theta)}, 
				{1/r, cos(theta)/sin(theta), 0}
			),
		},
	},
	{
		name = 'spherical, orthonormal:',
		coords = {r, theta, phi},
		conns = {
			-- Gamma_rHat
			Matrix.diagonal(0, 0, 0),
			--[[ Gamma_thetaHat:
			Matrix(
				{0, -1/r, 0},
				{1/r, 0, 0},
				{0, 0, 0}
			)
			--]]
			-- [[ Gamma_theta = e_theta^thetaHat Gamma_thetaHat = r Gamma_thetaHat 
			Matrix(
				{0, -1, 0},
				{1, 0, 0}, 
				{0, 0, 0}
			),
			--]]
			--[[ Gamma_phiHat
			Matrix(
				{0, 0, -1/r}, 
				{0, 0, -cos(theta)/(r*sin(theta))}, 
				{1/r, cos(theta)/(r*sin(theta)), 0}
			),
			--]]
			-- [[ Gamma_phi = e_phi^phiHat Gamma_phiHat = r sin(theta) Gamma_phiHat
			Matrix(
				{0, 0, -sin(theta)}, 
				{0, 0, -cos(theta)}, 
				{sin(theta), cos(theta), 0}
			),
			--]]
		},
	},

} do

	printbr('<h3>'..info.name..':</h3>')
	printbr()

	local coords = info.coords
	local conns = info.conns
	local n = #coords
	assert(n == #conns)

	printbr'parallel propagators:'
	printbr()

	local propFwd = table()
	local propInv = table()
	
	local P = var'P'

	for i, coord in ipairs(coords) do
		local conn = conns[i]
		local name = coords[i].name	
		
		printbr(var('[\\Gamma_'..name..']'):eq(conn))
		printbr()

		local origIntConn = Integral(conn, coord, coord'_L', coord'_R')
		print(origIntConn)
		local intConn = origIntConn()

-- TODO add in the 'assume(r > 0)' stuff
intConn = intConn:replace(abs(r'_L'), r'_L')
intConn = intConn:replace(abs(r'_R'), r'_R')
intConn = intConn:replace(abs(r), r)
		
		printbr('=', intConn)
		printbr()

		print(P(' _'..name), '=', exp(-origIntConn))
		local negIntConn = (-intConn)()
		--[[ you could exp, and that will eigen-decompose ...
		local expNegIntExpr = negIntConn:exp()
		local expIntExpr = expNegIntExpr:inverse()
		--]]
		-- [[ but eigen will let inverting be easy
		local ev = negIntConn:eigen()
		local R, L, allLambdas = ev.R, ev.L, ev.allLambdas
		local expLambda = Matrix.diagonal( allLambdas:mapi(function(lambda) 
			return exp(lambda) 
		end):unpack() )
		local expNegIntExpr = (R * expLambda * L)()
		local invExpLambda = Matrix.diagonal( allLambdas:mapi(function(lambda) 
			return exp(-lambda) 
		end):unpack() )
		local expIntExpr = (R * invExpLambda * L)()
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
		local Piname = P(' _'..coords[i].name)
		
		local PiL = Pi:clone()
		for k=1,n do
			if k ~= i then
				PiL = PiL:replace(coords[k], coords[k]'_L')
			end
		end	
		
		for j=i+1,n do
			local Pj = propFwd[j]
			local Pjname = P(' _'..coords[j].name)

			local PjL = Pj:clone()
			for k=1,n do
				if k ~= j then
					PjL = PjL:replace(coords[k], coords[k]'_L')
				end
			end
		
			local PiR = PiL:replace(coords[j]'_L', coords[j]'_R')
			local PjR = PjL:replace(coords[i]'_L', coords[i]'_R')
	
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
end
