#!/usr/bin/env luajit
require 'ext'
require 'symmath'{MathJax={title='Parallel Propagtors'}}

-- TODO incorporate this with the metric catalog?


local t = var't'
local x = var'x'
local y = var'y'
local z = var'z'
local phi = var'\\phi'
local theta = var'\\theta'

-- radial variables
local r = set.nonNegativeReal:var'r'
local rho = set.nonNegativeReal:var'\\rho'

-- sphere-log-radial parameters:
local A = set.nonNegativeReal:var'A'
local w = set.nonNegativeReal:var'w'

for _,info in ipairs{
	{
		name = 'Cartesian',
		coordVolumeElem = Constant(1),
		coords = {x,y,z},
		getConn = function()
			return Tensor'^a_bc'
		end,
	},
	{
		name = 'cylindrical, coordinate',
		coordVolumeElem = r,
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
		coordVolumeElem = r,
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
		coordVolumeElem = r^2 * sin(theta),
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
		coordVolumeElem = r^2 * sin(theta),
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
	{
		name = 'spherical log-radial',
		coordVolumeElem = A^3 * sinh(rho / w)^2 * sin(theta) * cosh(rho / w) / (w * sinh(1/w)^3),
		coords = {rho, theta, phi},
		getConn = function()
			local conn = Tensor'^a_bc'
			conn[1][1][1] = sinh(rho/w) / (w * cosh(rho/w))
			conn[1][2][2] = -w * sinh(rho/w) / cosh(rho/w)
			conn[1][3][3] = -w * sinh(rho/w) / cosh(rho/w) * sin(theta)^2
			conn[2][3][3] = -sin(theta) * cos(theta)
			
			conn[2][1][2] = cosh(rho/w) / (w * sinh(rho/w))
			conn[3][1][3] = cosh(rho/w) / (w * sinh(rho/w))
			conn[3][2][3] = cos(theta) / sin(theta)
			conn[2][2][1] = conn[2][1][2]
			conn[3][3][1] = conn[3][1][3]
			conn[3][3][2] = conn[3][2][3]
			return conn
		end,
	}
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
	local e
	if info.getLinCoeff then
		e = info.getLinCoeff() 
		connCoord = (connT'^I_JK' * e'_a^J')():permute'^I_aK'
		
		print('connection with 2nd term transformed to a coordinate basis:')
		connCoord:printElem'\\bar{\\Gamma}'
		printbr()
	end

	printbr'parallel propagators:'
	printbr()

	local xLs = range(n):mapi(function(i)
		return coords[i].set:var(coords[i].name..'_L')
	end)
	local xRs = range(n):mapi(function(i)
		return coords[i].set:var(coords[i].name..'_R')
	end)

	local P = var'P'

	local propFwd = table()
	local propInv = table()

	for i, coord in ipairs(coords) do
		local conn = Matrix:lambda({n,n}, function(a,b)
			return connCoord[a][i][b]
		end)
		--local conn = conns[i]
		local name = coords[i].name	
		
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
				PiL = PiL:replace(coords[k], xLs[k])
			end
		end	
		
		for j=i+1,n do
			local Pj = propFwd[j]
			local Pjname = P(' _'..coords[j].name)

			local PjL = Pj:clone()
			for k=1,n do
				if k ~= j then
					PjL = PjL:replace(coords[k], xLs[k])
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
			printbr(Pi:diff(coords[j]):eq(
				Pi:diff(coords[j])()
			))
		end
	end

	local deltas = range(n):mapi(function(i)
		return var('\\Delta '..coords[i].name)
	end)
	local deltaSqs = range(n):mapi(function(i)
		return var('\\Delta ('..coords[i].name..'^2)')
	end)
	local deltaCubes = range(n):mapi(function(i)
		return var('\\Delta ('..coords[i].name..'^3)')
	end)
	local deltaCoss = range(n):mapi(function(i)
		return var('\\Delta (cos('..coords[i].name..'))')
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

	local coordVolumeElem = info.coordVolumeElem
	printbr('volume element: ', coordVolumeElem)
	
	local cellVolume = coordVolumeElem
	for k=1,n do
		if not cellVolume:findChild(coords[k]) then
			cellVolume = cellVolume * deltas[k] 
		else
			cellVolume = cellVolume:integrate(coords[k], xLs[k], xRs[k])()
			cellVolume = replaceDeltas(cellVolume):simplify()
		end
	end
	printbr('volume integral: ', cellVolume)

	local FLs = range(n):mapi(function(i)
		return var('F^{'..coords[i].name..'}('..xLs[i].name..')')
	end)
	local FRs = range(n):mapi(function(i)
		return var('F^{'..coords[i].name..'}('..xRs[i].name..')')
	end)

	printbr'finite volume (0,0)-form:'

	local sum = 0
	for k,coordk in ipairs(coords) do
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
		for j,coordj in ipairs(coords) do
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
	if e then
		assert(isDiagonal(e), "TODO add support for linear combinations of fluxes at cell surfaces for anholonomic coordinates")
	end

	local sum = 0
	for k,coordk in ipairs(coords) do
		local kLname = xLs[k].name
		local kRname = xRs[k].name
		local term = 
			coordVolumeElem:replace(coords[k], xRs[k])
			* (e and e[k][k] or Constant(1)):replace(coords[k], xRs[k])	-- diagonal {e_a}^I(x_R) quick fix
			* FRs[k]
			-
			coordVolumeElem:replace(coords[k], xLs[k])
			* (e and e[k][k] or Constant(1)):replace(coords[k], xLs[k])	-- diagonal {e_a}^I(x_L) quick fix
			* FLs[k]
		for j,coordj in ipairs(coords) do
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
	for k,coordk in ipairs(coords) do
		local kLname = xLs[k].name
		local kRname = xRs[k].name
		local term = 
			coordVolumeElem:replace(coords[k], xRs[k])
			* (e and e[k][k] or Constant(1)):replace(coords[k], xRs[k])	-- diagonal {e_a}^I(x_R) quick fix
			* FRs[k]
			-
			coordVolumeElem:replace(coords[k], xLs[k])
			* (e and e[k][k] or Constant(1)):replace(coords[k], xLs[k])	-- diagonal {e_a}^I(x_L) quick fix
			* FLs[k]
		for j,coordj in ipairs(coords) do
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


end
