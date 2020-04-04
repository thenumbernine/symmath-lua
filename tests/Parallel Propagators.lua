#!/usr/bin/env luajit
require 'ext'
require 'symmath'{MathJax={title='Parallel Propagtors'}}

-- TODO incorporate this with the metric catalog?


local t = var't'
local r = var'r'
local z = var'z'
local phi = var'\\phi'
local theta = var'\\theta'

for _,info in ipairs{
	{
		name = 'cylindrical, coordinate',
		coords = {r, phi, z},
		getConn = function()
			local conn = Tensor'^a_bc'
			conn[2][1][2] = 1/r
			conn[1][2][2] = -r
			conn[2][2][1] = 1/r
			return conn
		end,
	},
	{
		name = 'cylindrical, orthonormal',
		coords = {r, phi, z},
		getConn = function()
			local conn = Tensor'^I_JK'
			conn[1][2][2] = -1/r
			conn[2][2][1] = 1/r
			return conn
		end,
		-- e_a = e_a^I e_I for orthonormal basis e_I and coord derivative e_a
		-- s.t. g_ab = e_a^I e_b^J eta_IJ
		getLinCoeff = function()
			return Tensor('_a^I',
				{1, 0, 0},
				{0, r, 0},
				{0, 0, 1}
			)
		end,
	},
	{
		name = 'spherical, coordinate',
		coords = {r, theta, phi},
		getConn = function()
			local conn = Tensor'^a_bc'
			conn[2][1][2] = 1/r
			conn[3][1][3] = 1/r
			conn[1][2][2] = -r
			conn[2][2][1] = 1/r
			conn[3][2][3] = cos(theta) / sin(theta)
			conn[1][3][3] = -r*sin(theta)^2
			conn[2][3][3] = -sin(theta)*cos(theta)
			conn[3][3][1] = 1/r
			conn[3][3][2] = cos(theta)/sin(theta)
			return conn
		end,
	},
	{
		name = 'spherical, orthonormal',
		coords = {r, theta, phi},
		getConn = function()
			local conn = Tensor'^a_bc'
			conn[1][2][2] = -1/r
			conn[2][2][1] = 1/r
			conn[1][3][3] = -1/r
			conn[2][3][3] = -cos(theta)/(r*sin(theta))
			conn[3][3][1] = 1/r
			conn[3][3][2] = cos(theta)/(r*sin(theta))
			return conn
		end,
		getLinCoeff = function()
			return Tensor('_a^I',
				{1, 0, 0},
				{0, r, 0},
				{0, 0, r*sin(theta)}
			)
		end,
	},
} do

	printbr('<h3>'..info.name..':</h3>')

	local coords = info.coords
	Tensor.coords{
		{variables=coords},
	}

	printbr('coordinates:'..table.mapi(coords, tostring):concat', ')
	printbr()

	local connT = info.getConn()
	local n = #coords
	assert(n == #connT)

	print('connection:')
	connT:printElem'\\Gamma'
	printbr()

	-- connection: Gamma^I_JK, except rescale the lower term to a coordinate basis:
	-- Gamma^I_aK = Gamma^I_JK * e_a^J
	local connCoord = connT
	if info.getLinCoeff then
		local e = info.getLinCoeff() 
		connCoord = (connT'^I_JK' * e'_a^J')():permute'^I_aK'
		
		print('connection with 2nd term transformed to a coordinate basis:')
		connCoord:printElem'\\bar{\\Gamma}'
		printbr()
	end

	printbr'parallel propagators:'
	printbr()

	local propFwd = table()
	local propInv = table()
	
	local P = var'P'

	for i, coord in ipairs(coords) do
		local conn = Matrix:lambda({n,n}, function(a,b)
			return connCoord[a][i][b]
		end)
		--local conn = conns[i]
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
	printbr()
end
