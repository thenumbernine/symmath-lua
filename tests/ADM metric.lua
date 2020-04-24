#!/usr/bin/env luajit
require 'symmath'.setup{MathJax={title='ADM metric', useCommaDerivative=true}}
require 'ext'

local t,x,y,z = vars('t','x','y','z')
local spatialCoords = {x,y,z}
local coords = {t,x,y,z}
local spacetimeIndexes = {variables=coords}
local spatialIndexes = {symbols='ijklmn', variables=spatialCoords}
Tensor.coords{
	spacetimeIndexes,
	spatialIndexes,
}

-- lapse
local alpha = var('\\alpha', coords)
printbr(alpha)

-- shift
local betaUDense = Tensor('^i', function(i)
	return var('\\beta^'..spatialCoords[i].name, coords)
end)
local beta = var'\\beta'
printbr(beta'^i':eq(betaUDense))

-- spatial metric
local gamma = var'\\gamma'
local gammaLLDense = Tensor('_ij', function(i,j)
	return var('\\gamma_{'..spatialCoords[i].name..spatialCoords[j].name..'}', coords)
end)
printbr(gamma'_ij':eq(gammaLLDense))
local gammaUUDense = Tensor('^ij', function(i,j)
	return var('\\gamma^{'..spatialCoords[i].name..spatialCoords[j].name..'}', coords)
end)
printbr(gamma'^ij':eq(gammaUUDense))

local betaLDense = (betaUDense'^k' * gammaLLDense'_ki')() 

-- metric
local g = var'g'
local gLLDense = Tensor('_uv', function(u,v)
	if u == 1 and v == 1 then
		return -alpha^2 + (betaUDense'^k' * betaUDense'^l' * gammaLLDense'_kl')()
	elseif u == 1 then
		return betaLDense[v-1]
	elseif v == 1 then
		return betaLDense[u-1]
	else
		return gammaLLDense[{u-1,v-1}]
	end
end)
local gLLDef = g'_uv':eq(gLLDense)
printbr(gLLDef)

local gUUDense = Tensor('^uv', function(u,v)
	if u == 1 and v == 1 then
		return -1/alpha^2
	elseif u == 1 then
		return betaUDense[v-1] / alpha
	elseif v == 1 then
		return betaUDense[u-1] / alpha
	else
		return gammaUUDense[{u-1,v-1}] - betaUDense[u-1] * betaUDense[v-1] / alpha^2
	end
end)
local gUUDef = g'^uv':eq(gUUDense)
printbr(gUUDef)

Tensor.metric(gLLDense, gUUDense)

local dgLLLDense = gLLDense'_uv,w'()

local Gamma = var'\\Gamma'
printbr(Gamma'_abc':eq((g'_ab,c' + g'_ac,b' - g'_bc,a') / 2))
local GammaLLLDense = ((dgLLLDense'_abc' + dgLLLDense'_acb' - dgLLLDense'_bca') / 2)()
printbr(Gamma'_abc':eq(GammaLLLDense'_abc'()))

printbr(Gamma'^a_bc':eq(g'^ad' * Gamma'_dbc'))
local GammaULLDense = (gUUDense'^ad' * GammaLLLDense'_dbc')()
printbr(Gamma'^a_bc':eq(GammaULLDense'^a_bc'()))

local Riemann = var'R'
local RiemannDense = Tensor'^a_bcd'
RiemannDense['^a_bcd'] = (GammaULLDense'^a_bd,c' - GammaULLDense'^a_bc,d' + GammaULLDense'^a_ec' * GammaULLDense'^e_bd' - GammaULLDense'^a_ed' * GammaULLDense'^e_bc')()
printbr(R'^a_bcd':eq(RiemannDense'^a_bcd'))
