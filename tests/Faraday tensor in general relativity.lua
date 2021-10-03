#!/usr/bin/env luajit
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{
	env=env,
	implicitVars=true,
	fixVariableNames=true,
	MathJax={
		title='Faraday tensor',
		useCommaDerivative=true,			-- this had latex errors when I was using a TensorRef'd variable as my tensor elements
		--usePartialLHSForDerivative=true,
	},
}

printbr[[$dx^0 = c dt, \partial_0 = \frac{1}{c} \partial_t$]]

local x0 = var'0'
local x0to3 = table{x0,x,y,z}
local x0to3t = table(x0to3):append{t}
local x1to3 = table{x,y,z}

local chart = Tensor.Chart{coords=x0to3, metric=function() return Matrix.diagonal(-1, 1, 1, 1) end}	-- preliminary matrix
local spatialChart = Tensor.Chart{coords=x1to3, symbols='ijklmn'}

printbr'using ADM metric:'

local betaUDef = Tensor('^i', function(i) return beta('^'..x1to3[i].name) end)
printbr(beta'^i':eq(betaUDef))

local betaLDef = Tensor('_i', function(i) return beta('_'..x1to3[i].name) end)
printbr(beta'_i':eq(betaLDef))

local betaSqDef = betaUDef[1]*betaLDef[1] + betaUDef[2]*betaLDef[2] + betaUDef[3]*betaLDef[3]
printbr((beta^2):eq(betaSqDef))

local gammaDef = Tensor('_ij', function(i,j)
	if i > j then i,j = j,i end
	return gamma('_'..x1to3[i].name..x1to3[j].name)
end)
printbr(gamma'_ij':eq(gammaDef))

local gammaUDef = Tensor('^ij', function(i,j)
	if i > j then i,j = j,i end
	return gamma('^'..x1to3[i].name..x1to3[j].name)
end)
printbr(gamma'_ij':eq(gammaDef))
printbr(gamma'^ij':eq(gammaUDef))


-- TODO this is from ADM Levi-Civita as well.  maybe put it in a common place?
local gDef = Tensor('_ab', function(a,b)
	if a==1 and b==1 then
		return -alpha^2 + beta^2
	elseif a==1 then
		return betaLDef[b-1]
	elseif b==1 then
		return betaLDef[a-1]
	else
		return gammaDef[a-1][b-1]
	end
end)
printbr(g'_ab':eq(gDef))

local gUDef = Tensor('^ab', function(a,b)
	if a==1 and b==1 then
		return -alpha^-2
	elseif a==1 then
		return alpha^-2*betaUDef[b-1]
	elseif b==1 then
		return alpha^-2*betaUDef[a-1]
	else
		return gammaUDef[a-1][b-1] - alpha^-2*betaUDef[a-1]*betaUDef[b-1]
	end
end)

printbr(var'g''^ab':eq(gU))
local sqrtdetg = alpha * sqrt(gamma)

-- calculate this before we set the metric, since we already know the detemrinant
-- or I could call it after and just override the determinant
local lcL = require 'symmath.tensor.LeviCivita'()
local lcU = lcL'^abcd'()	-- raise/lower using eta, before setting the ADM metric
local glcL = (lcL * sqrtdetg)()
local glcU = (lcU / sqrtdetg)()

chart:setMetric(gDef, gUDef)
spatialChart:setMetric(gammaDef, gammaUDef)

local nDef = Tensor('_a', -alpha,0,0,0)
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
local starExtFDef = (frac(1,6) * extFDef'^bcd' * glcL'_bcda')()
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

local extFDef = partialFDef:antisym()
printbr'$d^2 A = 0$ in terms of $F_{ab}$'
printbr(var'dF''_abc':eq(extFDef))

printbr[[$\star d^2 A = \star d F$]]
local starExtFDef = (frac(1,6) * extFDef'_bcd' * glcU'^bcda')()
printbr(var'\\star dF''^a':eq(starExtFDef):eq(Tensor'^a'))


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
--local FDefLL = ((frac(1,c) * nDef'_a' * EDef'_b')():antisym() + nDef'^c' * BDef'^d' * glcL'_cdab')():permute'_ab'
local FDefLL = FExpr:rhs():replace(E, EDef):replace(B, BDef):replace(n, nDef):replace(epsilon, glcL)():permute'_ab'
printbr(F'_ab':eq(FDefLL))

local FDefLU = FDefLL'_a^b'()
printbr(F'_a^b':eq(FDefLU))

local FDefUL = FDefLL'^a_b'()
printbr(F'^a_b':eq(FDefUL))

local FDefUU = FDefLU'^ab'()
printbr(F'^ab':eq(FDefUU))

local partialFDef = FDefLL'_bc,a'():permute'_abc'
printbr(F'_bc,a':eq(partialFDef))

local extFDef = partialFDef:antisym()
printbr'$d^2 A = 0$ in terms of $F_{ab}$'
printbr(var'dF''_abc':eq(extFDef))

printbr[[$\star d^2 A = \star d F$]]
local starExtFDef = (frac(1,6) * extFDef'_bcd' * glcU'^bcda')()
printbr(var'\\star dF''^a':eq(starExtFDef):eq(Tensor'^a'))
printbr[[replace $\partial_0 = \frac{1}{c} \partial_t$]]
starExtFDef = starExtFDef
	:replace(BDef[2]:diff(x0)(), frac(1,c)*BDef[2]:diff(t))
	:replace(BDef[3]:diff(x0)(), frac(1,c)*BDef[3]:diff(t))
	:replace(BDef[4]:diff(x0)(), frac(1,c)*BDef[4]:diff(t))
	()
printbr(var'\\star dF''_a':eq(starExtFDef):eq(Tensor'_a'))

printbr[[collect equations]]
for a=1,#starExtFDef do
	printbr( (starExtFDef[a]:eq(0) * ({-frac(1,2), -frac(1,2) * c, -frac(1,2) * c, -frac(1,2) * c})[a])() )
end

printbr[[and you have the Gauss law for the magnetic field and the Faraday law]]


printbr'<hr>'

printbr'four-current as a one-form:'
local JDef = Tensor('^a', function(a) 
	if a == 1 then return c * var('rho', x0to3t) end
	return var('J^'..x0to3[a].name, x0to3t)
end)
printbr(J'^a':eq(JDef))

local _2mu0JDef = (2 * mu'_0' * JDef'_a')()


printbr'now look at the co-differential'

printbr[[$(\star F)_{ab} = (\star dA)_{ab} = \frac{1}{2} \epsilon_{abcd} F^{cd}$]]
local starFDef = (frac(1,2) * FDefUU'^cd' * glcL'_cdab')()
local starF = var'\\star F'
printbr(starF'_ab':eq(starFDef))

printbr[[$(\partial_a \star dA)_{bc}$]]
local partialStarFDef = starFDef'_bc,a'():permute'_abc'
printbr(starF'_bc,a':eq(partialStarFDef))

printbr[[$d \star dA = d \star F = -2 \star \mu_0 J$]]
local extStarFDef = partialStarFDef:antisym()
printbr(var'd \\star F''_abc':eq(extStarFDef))

printbr[[$\star d \star d A = \star d \star F = 2 \mu_0 J$]]
local starExtStarFDef = (frac(1,3*2) * extStarFDef'^bcd' * glcL'_bcda')()
printbr(var'\\star d \\star F''_a':eq(starExtStarFDef):eq(_2mu0JDef))
printbr[[replace $\partial_0 = \frac{1}{c} \partial_t$]]
starExtStarFDef = starExtStarFDef
	:replace(EDef[2]:diff(x0)(), frac(1,c)*EDef[2]:diff(t))
	:replace(EDef[3]:diff(x0)(), frac(1,c)*EDef[3]:diff(t))
	:replace(EDef[4]:diff(x0)(), frac(1,c)*EDef[4]:diff(t))
	()
printbr(var'\\star d \\star F''_a':eq(starExtStarFDef):eq(_2mu0JDef))

printbr[[collect equations]]
for a=1,#starExtStarFDef do
	printbr( (starExtStarFDef[a]:eq(_2mu0JDef[a]) * ({-frac(1,2) * c, -frac(1,2), -frac(1,2), -frac(1,2)})[a])() )
end

printbr[[and you have the Gauss law for the electic field and the Ampere law]]


printbr'<hr>'
printbr[[side thought: what is $d \star d \star A$?]]

local starADef = (ADef'^d' * glcL'_dabc')()
printbr(var'\\star A''_abc':eq(starADef))

local partialStarADef = starADef'_bcd,a'():permute'_abcd'
printbr(var'\\partial \\star A''_bcd,a':eq(partialStarADef))

local extStarADef = partialStarADef:antisym()
printbr(var'd \\star A''_abcd':eq(extStarADef))

local starExtStarADef = (frac(1,4*3*2) * extStarADef'^abcd' * glcL'_abcd')()
printbr(var'\\star d \\star A':eq(starExtStarADef))

printbr'...and this would be set to zero by the Lorentz gauge condition'

local partialStarExtStarADef = Tensor('_a', function(a) return starExtStarADef:diff(x0to3[a])() end)
printbr(var'd \\star d \\star A''_a':eq(partialStarExtStarADef))

printbr[[...and this is equal to ${A^\mu}_{,\mu\alpha}$, which means as long as ${A^\mu}_{,\mu} = const$ then the gradient is zero.]]

printbr[[This means that $\frac{1}{2} \Delta A = \frac{1}{2} (d \delta + \delta d) A = \frac{1}{2} (d \star d \star + \star d \star d) A = \mu_0 J$ is equal to the Gauss-Ampere laws plus the gradient of the divergence of the four-potential]]

printbr[[So the Gauss/Faraday side of Maxwell's laws are summed up in $d^2 A = 0$]]
printbr[[And the Gauss/Ampere side of Maxwell's laws are summed up in $\frac{1}{2} \Delta A = \mu_0 J$]]

printbr()
printbr()
printbr()

