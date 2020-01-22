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

printbr[[$dx^0 = c dt, \partial_0 = \frac{1}{c} \partial_t$]]

printbr'using a metric and look at the dual:'
local etaDef = Matrix.diagonal(-1, 1, 1, 1)
printbr(eta'_ab':eq(etaDef))

local x0 = var'0'
local x0to3 = table{x0,x,y,z}
local x0to3t = table(x0to3):append{t}
Tensor.coords{{variables=x0to3, metric=etaDef}}
local lc = require 'symmath.tensor.LeviCivita'()

local nDef = Tensor('_a', -1,0,0,0)
printbr(n'_a':eq(nDef))

printbr'four-potential as a one-form:'
local ADef = Tensor('_a', function(a) 
	if a == 1 then return var('phi', x0to3t) / c end
	return var('A_'..x0to3[a].name, x0to3t)
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


printbr'<hr>'
printbr'redo the whole thing except use variables for $F_{ab}$'
FDef = Tensor('_ab', function(a,b)
	if a==b then return 0 end
	local s = 1
	if a>b then a,b,s = b,a,-1 end
	return (s * var('F_{'..x0to3[a].name..x0to3[b].name..'}', x0to3t))()
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


printbr'<hr>'
printbr'now redo the whole thing except use $E_i$ and $B_i$'

local EDef = Tensor('_a', function(a)
	if a == 1 then return 0 end
	return var('E_'..x0to3[a].name, x0to3t)
end)
printbr(E'_a':eq(EDef))

local BDef = Tensor('_a', function(a)
	if a == 1 then return 0 end
	return var('B_'..x0to3[a].name, x0to3t)
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
printbr[[replace $\partial_0 = \frac{1}{c} \partial_t$]]
starExtFDef = starExtFDef
	:replace(BDef[2]:diff(x0)(), frac(1,c)*BDef[2]:diff(t))
	:replace(BDef[3]:diff(x0)(), frac(1,c)*BDef[3]:diff(t))
	:replace(BDef[4]:diff(x0)(), frac(1,c)*BDef[4]:diff(t))
	()
printbr(var'\\star dF''_a':eq(starExtFDef):eq(Tensor'_a'))

printbr[[collect equations]]
for a=1,#starExtFDef do
	printbr( (starExtFDef[a]:eq(0) * ({-1, -c, -c, -c})[a])() )
end

printbr[[and you have the Gauss law for the magnetic field and the Faraday law]]


printbr'<hr>'

printbr'four-current as a one-form:'
local JDef = Tensor('^a', function(a) 
	if a == 1 then return c * var('rho', x0to3t) end
	return var('J^'..x0to3[a].name, x0to3t)
end)
printbr(J'^a':eq(JDef))

local mu0JDef = (mu'_0' * JDef'_a')()


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
printbr(var'\\star d \\star F''_a':eq(starExtStarFDef):eq(mu0JDef))
printbr[[replace $\partial_0 = \frac{1}{c} \partial_t$]]
starExtStarFDef = starExtStarFDef
	:replace(EDef[2]:diff(x0)(), frac(1,c)*EDef[2]:diff(t))
	:replace(EDef[3]:diff(x0)(), frac(1,c)*EDef[3]:diff(t))
	:replace(EDef[4]:diff(x0)(), frac(1,c)*EDef[4]:diff(t))
	()
printbr(var'\\star d \\star F''_a':eq(starExtStarFDef):eq(mu0JDef))

printbr[[collect equations]]
for a=1,#starExtFDef do
	printbr( (starExtStarFDef[a]:eq(mu0JDef[a]) * ({-c, -1, -1, -1})[a])() )
end

printbr[[and you have the Gauss law for the electic field and the Ampere law]]


printbr'<hr>'
printbr[[side thought: what is $d \star d \star A$?]]

local starADef = (ADef'^d' * lc'_dabc')()
printbr(var'\\star A''_abc':eq(starADef))

local partialStarADef = starADef'_bcd,a'():permute'_abcd'
printbr(var'\\partial \\star A''_bcd,a':eq(partialStarADef))

local extStarADef = (frac(1,3*2) * partialStarADef:antisym())() 
printbr(var'd \\star A''_abcd':eq(extStarADef))

local starExtStarADef = (frac(1,4*3*2) * extStarADef'^abcd' * lc'_abcd')()
printbr(var'\\star d \\star A':eq(starExtStarADef))

printbr'...and this would be set to zero by the Lorentz gauge condition'

local partialStarExtStarADef = Tensor('_a', function(a) return starExtStarADef:diff(x0to3[a])() end)
printbr(var'd \\star d \\star A''_a':eq(partialStarExtStarADef))

printbr[[...and this is equal to ${A^\mu}_{,\mu\alpha}$, which means as long as ${A^\mu}_{,\mu} = const$ then the gradient is zero.]]

printbr[[This means that $\Delta A = (d \delta + \delta d) A = (d \star d \star + \star d \star d) A = \mu_0 J$ is equal to the Gauss-Ampere laws plus the gradient of the divergence of the four-potential]]

printbr[[So the Gauss/Faraday side of Maxwell's laws are summed up in $d^2 A = 0$]]
printbr[[And the Gauss/Ampere side of Maxwell's laws are summed up in $\Delta A = \mu_0 J$]]

printbr()
printbr()
printbr()

