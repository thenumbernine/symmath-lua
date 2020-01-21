#!/usr/bin/env lua
require 'ext'
require 'symmath'.setup{implicitVars=true, fixVariableNames=true, MathJax={title='ADM Levi-Civita'}}

local xs = {x,y,z}
local txs = {t,x,y,z}
Tensor.coords{
	{variables={t,x,y,z}},
	{symbols='ijklmn', variables=xs},
}

local betaU = Tensor('^i', function(i) return beta('^'..xs[i].name) end)
printbr(beta'^i':eq(betaU))

local betaL = Tensor('_i', function(i) return beta('_'..xs[i].name) end)
printbr(beta'_i':eq(betaL))

local betaSq = betaU[1]*betaL[1] + betaU[2]*betaL[2] + betaU[3]*betaL[3]
printbr((beta^2):eq(betaSq))

local gammaLL = Tensor('_ij', function(i,j)
	if i > j then i,j = j,i end
	return gamma('_'..xs[i].name..xs[j].name)
end)
printbr(gamma'_ij':eq(gammaLL))

local gammaUU = Tensor('^ij', function(i,j)
	if i > j then i,j = j,i end
	return gamma('^'..xs[i].name..xs[j].name)
end)
printbr(gamma'_ij':eq(gammaLL))
printbr(gamma'^ij':eq(gammaUU))

--[[
local eta = Matrix.diagonal(-1, 1, 1, 1)
local g, gU = eta, eta
local sqrtdetg = eta:determinant()
--]]
-- [[
local g = Tensor('_ab', function(a,b)
	if a==1 and b==1 then
		return -alpha^2 + beta^2
	elseif a==1 then
		return betaL[b-1]
	elseif b==1 then
		return betaL[a-1]
	else
		return gammaLL[a-1][b-1]
	end
end)
printbr(var'g''_ab':eq(g))
--printbr(var'g':eq(export.SingleLine(g:determinant())))
local gU = Tensor('^ab', function(a,b)
	if a==1 and b==1 then
		return -alpha^-2
	elseif a==1 then
		return alpha^-2*betaU[b-1]
	elseif b==1 then
		return alpha^-2*betaU[a-1]
	else
		return gammaUU[a-1][b-1] - alpha^-2*betaU[a-1]*betaU[b-1]
	end
end)

printbr(var'g''^ab':eq(gU))
local sqrtdetg = alpha * sqrt(gamma)
--]]
local lcLLLL = require 'symmath.tensor.LeviCivita'()
Tensor.coords{{variables={t,x,y,z},metric=g,metricInverse=gU}}

local glcLLLL = (lcLLLL * sqrtdetg)()
printbr()
printbr(epsilon'_abcd')
glcLLLL:printElem'epsilon'
printbr()

local glcULLL = glcLLLL'^a_bcd'()
printbr()
printbr(epsilon'^a_bcd')
glcULLL:printElem'epsilon'
printbr()

printbr('ratios', epsilon'^a_bcd' / epsilon'_abcd')
printbr('...shared with ', epsilon'_abcd')
for is,v in glcLLLL:iter() do
	if v ~= Constant(0) then
		printbr(table.mapi(is, function(i) return txs[i].name end):concat(), ':', (glcULLL[is] / v)() )
	end
end
printbr('...unique to', epsilon'^a_bcd')
for is,v in glcULLL:iter() do
	if v ~= Constant(0) and glcLLLL[is] == Constant(0) then
		printbr(table.mapi(is, function(i) return txs[i].name end):concat(), ':', v )
	end
end

local glcUULL = glcULLL'^ab_cd'()
printbr()
printbr(epsilon'^ab_cd')
glcUULL:printElem'epsilon'
printbr()
