#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup{MathJax={title='partial replace', pathToTryToFindMathJax='..'}}

local x,y,z = vars('x', 'y', 'z')
local xs = table{x,y,z}

Tensor.coords{{variables={x,y,z}}}

local gammaUVars = Tensor('^ij', function(i,j) 
	if i > j then i,j = j,i end 
	return var('\\gamma^{'..xs[i].name..xs[j].name..'}', depvars)
end)

local gammaLVars = Tensor('_ij', function(i,j) 
	if i > j then i,j = j,i end 
	return var('\\gamma_{'..xs[i].name..xs[j].name..'}', depvars)
end)


Tensor.metric(gammaLVars, gammaUVars)



local gammaLU = (gammaLVars'_ik' * gammaUVars'^kj')()
local gammaLL = (gammaLVars'_ik' * gammaLU'_j^k')()
local gammaUU = (gammaUVars'^ik' * gammaLU'_k^j')()


--[[
local expr = (-gammaLL[1][1]:clone())()
printbr'we have this'
printbr(expr)
printbr'we want to replace with this rule'
printbr((gammaLL[1][1]):eq(gammaLVars[1][1]))
printbr"here's how well it works"
local result = expr:replace(gammaLL[1][1], gammaLVars[1][1])
printbr(result)
printbr("did this substitute correctly?")
printbr(result == -gammaLVars[1][1])
--]]

-- don't forget to simplify!
local expr = (gammaLVars[1][1] * gammaUVars[1][1] + gammaLVars[1][2] * gammaUVars[1][2] + gammaLVars[1][3] * gammaUVars[1][3])()
printbr(expr)
printbr(gammaLU[1][1])
printbr(expr:replace(gammaLU[1][1](), 1))
--printbr(gammaLVars[1][2] == gammaLVars[2][1])	-- equality is by variable name
