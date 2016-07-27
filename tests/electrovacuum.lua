#! /usr/bin/env luajit
require 'ext'
local symmath = require 'symmath'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
MathJax.usePartialLHSForDerivative = true
print(MathJax.header)
do
	local print = MathJax.print 
	local Tensor = symmath.Tensor
	local var = symmath.var
	local vars = symmath.vars

	local t,x,y,z = vars('t', 'x', 'y', 'z')
	local q,m = vars('q', 'm')
	local coords = {t,x,y,z}
	local spatialCoords = {x,y,z}

	Tensor.coords{
		{variables=coords},
		{symbols='ijklmn', variables=spatialCoords},
	}

	--[[
	wiki https://en.wikipedia.org/wiki/Electromagnetic_four-potential
	says that the 4-potential units of A^i are V s / m
	... and the timelike A^t = phi/\tilde{c} V s / m,
	and natural units say c = 1 = \tilde{c} m/s <=> 1 s = \tilde{c} m
	so A^t = phi / (s / m) V s / m is in V, which fits what everyone else says
	
	if we were to convert these to meters, what would the magnitude be? 

	A^t = V
	A^i = V s/m = \tilde{c} V
	--]]
	local A = Tensor('_u', function(u) return var('A_'..coords[u].name, coords) end)
	local g = Tensor('_uv', function(u,v)
		if u == 1 and v == 1 then
			return -1 + 2 * A[1] * q / m
		elseif u == 1 then
			return A[v] * q / m
		elseif v == 1 then
			return A[u] * q / m
		elseif u == v then
			return 1
		else
			return 0
		end
	end)
	print(var'g''_uv':eq(g))

	local gU = Tensor('^uv', function(u,v)
		-- variable
		--return var('g^{'..coords[u].name..coords[v].name..'}', coords)
		-- eta (near-flat approximation)
		return u == v and (u == 1 and -1 or 1) or 0
		--[[ actual inverse.  explicitly specified since my inverse algorithm can't handle it.
		local denom = -1 + 2 * A[1] - A[2]^2 - A[3]^2 - A[4]^2
		if u == 1 then
			if v == 1 then
				return 1 / denom
			else
				return -A[v] * q/m / denom
			end
		else
			if v == 1 then
				return -A[u] * q/m / denom
			else
				local result = A[u] * A[v] * q^2/m^2 / denom
				if u == v then result = result - 1 end
				return result
			end
		end
		--]]
	end)
	print(var'g''^uv':eq(gU))

	print((var'g''_ac' * var'g''^cb'):eq( (g'_ac' * gU'^cb')() ))

	local basis = Tensor.metric(g, gU)
-- [[
local gU = basis.metricInverse
print(gU)
--]]
	local GammaL = Tensor'_abc'
	GammaL['_abc'] = ((g'_ab,c' + g'_ac,b' - g'_bc,a') / 2)()
	print(var'\\Gamma''_abc':eq(GammaL'_abc'()))

	local E = Tensor('_i', function(i) return var('E_'..spatialCoords[i].name, coords) end)
	print(var'E''_i':eq(E'_i'()))
	
	local B = Tensor('_i', function(i) return var('B_'..spatialCoords[i].name, coords) end)
	print(var'B''_i':eq(B'_i'()))
	
	-- E_i = A_t,i - A_i,t
	-- B_i = epsilon_ijk A_k,j
	-- A_i,t = A_t,i - E_i
	GammaL = GammaL
		:replace(A[2]:diff(t), A[1]:diff(x) - E[1])
		:replace(A[3]:diff(t), A[1]:diff(y) - E[2])
		:replace(A[4]:diff(t), A[1]:diff(z) - E[3])
		:replace(A[4]:diff(y), A[3]:diff(z) + B[1])
		:replace(A[2]:diff(z), A[4]:diff(x) + B[2])
		:replace(A[3]:diff(x), A[2]:diff(y) + B[3])
	print(var'\\Gamma''_abc':eq(GammaL'_abc'()))

--[[
	local Gamma = GammaL'^a_bc'()
	print(var'\\Gamma''^a_bc':eq(Gamma'^a_bc'()))
--]]

	local u = Tensor('^u', function(u)
		-- t approaches 1
		--return u == 1 and 1 or var('u^'..coords[u].name, coords)
		return var('u^'..coords[u].name, coords)
	end)

	local accel = -GammaL'_abc' * u'^b' * u'^c'
	print(var'\\ddot{u}''_a':eq( accel ):eq( accel() ))

-- [[
	local props = require 'symmath.diffgeom'(g)
	for k,eqn in ipairs(props.eqns) do
		for i,x in ipairs(spatialCoords) do
			props[k] = props[k]
				:replace(A[2]:diff(t), A[1]:diff(x) - E[1])
				:replace(A[3]:diff(t), A[1]:diff(y) - E[2])
				:replace(A[4]:diff(t), A[1]:diff(z) - E[3])
				:replace(A[4]:diff(y), A[3]:diff(z) + B[1])
				:replace(A[2]:diff(z), A[4]:diff(x) + B[2])
				:replace(A[3]:diff(x), A[2]:diff(y) + B[3])
		end
	end
	props:calcEqns()

	props:print(print)
--]]
end
print(MathJax.footer)
