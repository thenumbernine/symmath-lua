#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup{
	implicitVars=true,
	fixVariableNames=true,
	MathJax={
		title='Faraday tensor',
		useCommaDerivative=true,			-- this had latex errors when I was using a TensorRef'd variable as my tensor elements
		--usePartialLHSForDerivative=true,
	},
}

printbr'using a metric and look at the dual:'
local etaDef = Matrix.diagonal(-1, 1, 1, 1)
printbr(eta'_ab':eq(etaDef))

local txs = table{t,x,y,z}
Tensor.coords{{variables=txs, metric=etaDef}}
local lc = require 'symmath.tensor.LeviCivita'()

local nDef = Tensor('_a', -1,0,0,0)
printbr(n'_a':eq(nDef))

printbr'four-potential as a one-form:'
local ADef = Tensor('_a', function(a) 
	return var('A_'..txs[a].name, txs)
end)
printbr(A'_a':eq(ADef))

printbr'$F = dA$'
local FDef = ADef'_d,c'():antisym()
printbr(F'_ab':eq(FDef))

printbr'$\\partial_a F_{bc}$:'
local partialFDef = FDef'_bc,a'():permute'_abc'
printbr(F'_bc,a':eq(partialFDef))

printbr'$dF = d^2 A$'
local extFDef = partialFDef:antisym()
printbr(var'dF''_abc':eq(extFDef))

printbr[[$\star d^2 A = \star d F$]]
local starExtFDef = (frac(1,6) * extFDef'^bcd' * lc'_bcda')()
printbr(var'\\star dF''_a':eq(starExtFDef))


printbr'redo the whole thing except use variables for $F_{ab}$'
FDef = Tensor('_ab', function(a,b)
	if a==b then return 0 end
	local s = 1
	if a>b then a,b,s = b,a,-1 end
	return (s * var('F_{'..txs[a].name..txs[b].name..'}', txs))()
end)
printbr(F'_ab':eq(FDef))

local partialFDef = FDef'_bc,a'():permute'_abc'
printbr(F'_bc,a':eq(partialFDef))

local extFDef = (frac(1,2) * partialFDef:antisym())()
printbr'$d^2 A = 0$ in terms of $F_{ab}$'
printbr(var'dF''_abc':eq(extFDef))

printbr[[$\star d^2 A = \star d F$]]
local starExtFDef = (frac(1,6) * extFDef'^bcd' * lc'_bcda')()
printbr(var'\\star dF''_a':eq(starExtFDef):eq(Tensor'_a'))


printbr'now redo the whole thing except use $E_i$ and $B_i$'

local EDef = Tensor('_a', function(a)
	if a == 1 then return 0 end
	return var('E_'..txs[a].name, txs)
end)
printbr(E'_a':eq(EDef))

local BDef = Tensor('_a', function(a)
	if a == 1 then return 0 end
	return var('B_'..txs[a].name, txs)
end)
printbr(B'_a':eq(BDef))

local FExpr = F'_ab':eq(frac(1,c) * n'_a' * E'_b' - frac(1,c) * E'_a' * n'_b' + n'^c' * B'^d' * epsilon'_cdab')
printbr(FExpr)
--FDef = ((frac(1,c) * nDef'_a' * EDef'_b')():antisym() + nDef'^c' * BDef'^d' * lc'_cdab')():permute'_ab'
FDef = FExpr:rhs():replace(E, EDef):replace(B, BDef):replace(n, nDef):replace(epsilon, lc)():permute'_ab'
printbr(F'_ab':eq(FDef))

local partialFDef = FDef'_bc,a'():permute'_abc'
printbr(F'_bc,a':eq(partialFDef))

local extFDef = (frac(1,2) * partialFDef:antisym())()
printbr'$d^2 A = 0$ in terms of $F_{ab}$'
printbr(var'dF''_abc':eq(extFDef))

printbr[[$\star d^2 A = \star d F$]]
local starExtFDef = (frac(1,6) * extFDef'^bcd' * lc'_bcda')()
printbr(var'\\star dF''_a':eq(starExtFDef):eq(Tensor'_a'))


printbr'four-current as a one-form:'
local JDef = Tensor('^a', function(a) 
	return var('J^'..txs[a].name, txs)
end)
printbr(J'^a':eq(JDef))


printbr'now look at the co-differential'

printbr[[$(\star F)_{ab} = (\star dA)_{ab} = \frac{1}{2} \epsilon_{abcd} F^{cd}$]]
local starFDef = (frac(1,2) * FDef'^cd' * lc'_cdab')()
local starF = var'\\star F'
printbr(starF'_ab':eq(starFDef))

printbr[[$(\partial_a \star dA)_{bc}$]]
local partialStarFDef = starFDef'_bc,a'():permute'_abc'
printbr(starF'_bc,a':eq(partialStarFDef))

printbr[[$d \star dA = d \star F = -\star \mu_0 J$]]
local extStarFDef = (frac(1,2) * partialStarFDef:antisym())()
printbr(var'd \\star F''_abc':eq(extStarFDef))

printbr[[$\star d \star d A = \star d \star F = \mu_0 J$]]
local starExtStarFDef = (frac(1,6) * extStarFDef'^bcd' * lc'_bcda')()
printbr(var'\\star d \\star F''_a':eq(starExtStarFDef):eq((mu'_0' * JDef'_a')()))
