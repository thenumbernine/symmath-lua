#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup{MathJax={title='BSSN', useCommaDerivative=true}}

printbr"translation of BSSN_RHS.nb from Zach Etienne's SENR project, from Mathematica into Lua symmath"
printbr"found at <a href='https://math.wvu.edu/~zetienne/SENR/'>https://math.wvu.edu/~zetienne/SENR/</a>"

-- TODO redo this whole thing, don't use any dense tensors, just index notation expression
-- and only last substitute in actual dense tensor values for specific coordinate systems
-- but only do this once I have transcribed and understand the whole notebook file

local SHIFTADVECT = true
local BIADVECT = true

--local CFEvolution = 'EvolvePhi'
--local CFEvolution = 'EvolveChi'
local CFEvolution = 'EvolveW'

local CoordSystem = 'Cartesian'
--local CoordSystem = 'Cylindrical'
--local CoordSystem = 'LogRadialSphericalPolar'
--local CoordSystem = 'SphericalPolar'
--local CoordSystem = 'SymTP'

local InitialDataType = 'Minkowski'
--local InitialDataType = 'BrillLindquist'
--local InitialDataType = 'StaticTrumpet'
--local InitialDataType = 'UIUC'

local InitialLapseType = 'PunctureR2'

local InitialShiftType = 'Zero'

-- Choose output coordinates
local x1, x2, x3 
local xx, yy, zz, r, th, ph, y1, y2, y3
if CoordSystem == 'Cartesian' then
	x1, x2, x3 = vars('x', 'y', 'z')
	xx = x1
	yy = x2
	zz = x3
	r = sqrt(xx^2 + yy^2 + zz^2)
	th = acos(zz/r)
	ph = atan2(yy, xx)
	y1 = xx
	y2 = yy
	y3 = zz
elseif CoordSystem == 'Cylindrical' then
	x1, x2, x3 = vars('\\rho', '\\phi', 'z')
	rho = x1
	ph = x2
	zz = x3
	r = sqrt(rho^2 + zz^2)
	th = acos(zz/r)
	y1 = rho
	y2 = ph
	y3 = zz
elseif CoordSystem == 'SphericalPolar' then
	x1, x2, x3 = vars('r', '\\theta', '\\phi')
	r = x1
	th = x2
	ph = x3
	y1 = r
	y2 = th
	y3 = ph
elseif CoordSystem == 'LogRadialSphericalPolar' then
	x1, x2, x3 = vars('\\rho', '\\theta', '\\phi')
	local DRGF = var'DRGF'
	local Nx1 = var'Nx1'
	local DRMIN = var'DRMIN'
	--r = (DRGF^(x1/(RMAX/Nx1)) * (1+DRGF) - 2) / (DRGF^(Nx1-1) * (1+DRGF) - 2) * RMAX
	r = ((DRGF+1)/2 * exp((x1*Nx1 - frac(1,2)) * log(DRGF)) - 1) * frac(DRMIN, DRGF-1)
	th = x2
	ph = x3
	y1 = r
	y2 = th
	y3 = ph
elseif CoordSystem == 'SymTP' then
	x1, x2, x3 = vars('A', 'B', '\\phi')
	local A = x1
	local B = x2
	ph = x3
	rho = bScale * A * cos(pi/2 * B)
	zz = bScale * sqrt(1 + A^2) * sin(pi/2 * B)
	r = sqrt(rho^2 + zz^2)
	th = acos(zz/r)
	y1 = rho
	y2 = ph
	y3 = zz
end
-- hmm, why is xx used distinct, xx,yy,zz, but then later as an array: xx[0],xx[1],xx[2]
--local xx = {x1,x2,x3}
local xs = table{x1,x2,x3}
local xns = xs:map(function(x)
	return var('\\hat{'..x.name..'}')
end)
Tensor.coords{
	{variables=xs},
	{symbols='IJKLMN', variables=xns}
}

printbr('coordinate basis:', xs:map(tostring):concat', ')
printbr('non-coordinate basis:', xns:map(tostring):concat', ')

local eLens
if CoordSystem == 'Cartesian' then
	eLens = Array(1, 1, 1)
elseif CoordSystem == 'Cylindrical' or CoordSystem == 'SymTP' then
	eLens = Array(1, y1, 1)
elseif CoordSystem == 'SphericalPolar' or CoordSystem == 'LogRadialSphericalPolar' then
	eLens = Array(y1:diff(x1)(), y1, y1 * sin(y2))
end

printbr"Using capital letters to denote non-coordinate basis... which I'm denoting individually with hats."
printbr"Rescaling transform to non-coordinate basis:"
local e = Tensor('^I_i', function(i,j)
	return (i==j and eLens[i] or 0)
end)
--e:printElem'e' printbr()
printbr(var'e''^I_i':eq(e))

local eu = Tensor('_I^i', function(i,j)
	return i==j and (1/eLens[i])() or 0
end)
printbr(var'e''_I^i':eq(eu))
--eu:printElem'e' printbr()

-- Initialize ghat_ij to zero
-- Set nonzero ghat_ij components

printbr"grid metric:"

local ghatDD = Tensor('_ij', function(i,j)
	return i==j and (eLens[i]^2)() or 0
end)
printbr(var'\\hat{\\gamma}''_ij':eq(ghatDD))

-- Set upper-triangular of rescaling matrix for metric & extrinsic curvature tensors
-- Set rescaling vector for lambda^i, beta^i, and B^i

-- End of inputs.  Next compute all needed hatted quantities for BSSN
-- First focus on hatted quantities related to rank-2 tensors

local ghatUU = Tensor('^ij', table.unpack((symmath.Matrix.inverse(ghatDD))))
printbr(var'\\hat{\\gamma}''^ij':eq(ghatUU))

local GammahatUDD = Tensor'^i_jk'
GammahatUDD['^i_jk'] = (frac(1,2) * ghatUU'^im' * (ghatDD'_mj,k' + ghatDD'_mk,j' - ghatDD'_jk,m'))()
printbr(var'\\hat{\\Gamma}''^i_jk':eq(GammahatUDD))

local GammahatUDDdD = Tensor'^i_jkl'
GammahatUDDdD['^i_jkl'] = GammahatUDD'^i_jk,l'()
printbr(var'\\hat{\\Gamma}''^i_jk,l':eq(GammahatUDDdD))

printbr'state variables:'

--[[
What is "dup" vs "d"? 
hint in gammabarDDdD vs gammabarDDdupD
which is only different in their use of hDDdD vs hDDdupD
--]]

--[[
next comes vars for:
hDD (sym on 1&2)
hDDdD (sym on 1&2)
hDDdupD (sym on 1&2)
hDDdDD (sym on 1&2 and 3&4)
aDD (sym on 1&2)
aDDdupD (sym on 1&2)
--]]
local hDD = Tensor('_IJ', function(i,j)
	if i > j then i,j = j,i end
	return var('h_{'..xns[i].name..' '..xns[j].name..'}', xs)
end)
printbr(var'h''_IJ':eq(hDD))
	
local hDDdD = hDD'_IJ,k'()
printbr(var'h''_IJ,k':eq(hDDdD))

local aDD = Tensor('_IJ', function(i,j)
	if i > j then i,j = j,i end
	return var('a_{'..xns[i].name..' '..xns[j].name..'}', xs)
end)
printbr(var'a''_IJ':eq(aDD))

-- this was hDD * ReDD
local epsDD = (hDD'_IJ' * e'^I_i' * e'^J_j')()
printbr(var'\\epsilon''_ij'
	:eq(var'h''_IJ' * var'e''^I_i' * var'e''^J_j')
	:eq(epsDD))

local gammabarDD = (ghatDD'_ij' + epsDD'_ij')()
printbr(var'\\bar{\\gamma}''_ij'
	:eq(var'\\hat{\\gamma}''_ij' + var'\\epsilon''_ij')
	:eq(gammabarDD))

local AbarDD = (aDD'_IJ' * e'^I_i' * e'^J_j')()
printbr(var'\\bar{A}''_ij'
	:eq(var'a''_IJ' * var'e''^I_i' * var'e''^J_j')
	:eq(AbarDD))

-- the nb worksheet has epsDDdD[jki] = hDD[jk] * ReDDdD[jki] + ReDD[jk]*hDDdD[jki]
-- but we can just automatically compute it ...
local epsDDdD = Tensor'_jki'
epsDDdD['_jki'] = epsDD'_ij,k'()
printbr(var'\\epsilon''_jk,i':eq(epsDDdD))

-- DHat_i gammaBar_jk = DHat_i (gammaHat_jk + epsilon_jk) = DHat_i epsilon_jk
local DhatgammabarDDdD = Tensor'_jki'
DhatgammabarDDdD['_jki'] = (epsDD'_jk,i'
	- epsDD'_jd' * GammahatUDD'^d_ik'
	- epsDD'_dk' * GammahatUDD'^d_ij')()
printbr(var'\\hat{D}_i \\bar{\\gamma}_{jk}':eq(DhatgammabarDDdD))

local function verify(a,b)
	printbr(a, 'should be', b, '...?', (a() == b()))
end

if CoordSystem == 'SphericalPolar' then
	printbr'begin verification:'
	local hDDdD = hDD'_IJ,k'()
	verify(DhatgammabarDDdD[2][3][1], (r^2 * sin(th) * hDDdD[2][3][1])())
	verify(DhatgammabarDDdD[2][3][2], (r^2 * sin(th) * (hDDdD[2][3][2] + hDD[1][3]))())
	verify(DhatgammabarDDdD[1][2][3], (r*(hDDdD[1][2][3] - cos(th)*hDD[1][3] - sin(th)*hDD[2][3]))())
	verify(DhatgammabarDDdD[2][3][3], (r^2*sin(th)*(hDDdD[2][3][3] + sin(th) * hDD[1][2] + cos(th) * hDD[2][2] - cos(th) * hDD[3][3]))())
	printbr'end verification'
end

local epsDDdDD = Tensor'_jkil'
epsDDdDD['_jkil'] = epsDD'_jk,il'()
printbr(var'\\epsilon''_jk,il':eq(epsDDdDD))

-- Why "DDdDdD" and why not "DDdDD"?
local Dhat2gammabarDDdDD = Tensor'_jkil'
Dhat2gammabarDDdDD['_ijkl'] = (DhatgammabarDDdD'_ijk,l' + 
	- DhatgammabarDDdD'_mjl' * GammahatUDD'^m_ki'
	- DhatgammabarDDdD'_iml' * GammahatUDD'^m_kj'
	- DhatgammabarDDdD'_ijm' * GammahatUDD'^m_kl')()
printbr(var'\\hat{D}_k \\hat{D}_l \\bar{\\gamma}_{ij}':eq(Dhat2gammabarDDdDD))

-- Then focus on hatted quantities related to vectors

--[[
vetU
betU
alphadupD
cfdupD
trKdupD
lambdaU
vetUdD
vetUdupD
betUdupD
vetUdDD
lambdaUdD
lambdaUdupD
--]]

local vetvar = var'ב'
local vetU = Tensor('^I', function(i)
	return var(vetvar.name..'^'..xns[i].name, xs)
end)

local betaU = (vetU'^I' * eu'_I^i')()
printbr(var'\\beta''^i'
	:eq(vetvar'^I' * var'e''_I^i')
	:eq(betaU))

local betvar = var'בּ'
local betU = Tensor('^I', function(i)
	return var(betvar.name..'^'..xns[i].name, xs)
end)

local BU = (betU'^I' * eu'_I^i')()
printbr(var'B''^i'
	:eq(betvar'^I' * var'e''_I^i')
	:eq(BU))

local lambdaU = Tensor('^I', function(i)
	return var('\\lambda^'..xns[i].name, xs)
end)

local LambdaU = (lambdaU'^I' * eu'_I^i')()
printbr(var'\\Lambda''^i'
	:eq(var'\\lambda''^I' * var'e''_I^i')
	:eq(LambdaU))

local LambdaUdD = Tensor'^i_j'
LambdaUdD['^i_j'] = LambdaU'^i_,j'()
printbr(var'\\Lambda''^i_,j':eq(LambdaUdD))

local betaUdD = Tensor'^i_j'
betaUdD['^i_j'] = betaU'^i_,j'()
printbr(var'\\beta''^i_,j':eq(betaUdD))

local BUdupD = Tensor'^i_j'
BUdupD['^i_j'] = BU'^i_,j'()
printbr(var'B''^i_,j':eq(BUdupD))

local betaUdupD = Tensor'^i_j'
betaUdupD['^i_j'] = betaU'^i_,j'()
printbr(var'\\beta''^i_,j':eq(betaUdupD))

local LambdaUdupD = Tensor'^i_j'
LambdaUdupD['^i_j'] = LambdaU'^i_,j'()
printbr(var'\\Lambda''^i_,j':eq(LambdaUdupD))

local betaUdDD = Tensor'^i_jk'
betaUdDD['^i_jk'] = betaU'^i_,jk'()
printbr(var'\\beta''^i_,jk':eq(betaUdDD))

local DhatLambdaUdD = Tensor'^i_j'
DhatLambdaUdD['^i_j'] = (LambdaUdD'^i_j' + GammahatUDD'^i_jk' * LambdaU'^k')()
printbr(var'\\hat{D}_j \\Lambda^i':eq(DhatLambdaUdD))

if CoordSystem == 'SphericalPolar' then
	printbr'begin verification:'
	local lambdaUdD = lambdaU'^I_,j'()
	verify(DhatLambdaUdD[3][3], (1/(r*sin(th))*(lambdaUdD[3][3] + sin(th)*lambdaU[1] + cos(th)*lambdaU[2]))())
	verify(DhatLambdaUdD[2][3], (1/r*(lambdaUdD[2][3] - cos(th) * lambdaU[3]))())
	verify(DhatLambdaUdD[1][2], (lambdaUdD[1][2] - lambdaU[2])())
	printbr'end verification'
end

local DhatbetaUdD = Tensor'^i_j'
DhatbetaUdD['^i_j'] = (betaUdD'^i_j' + GammahatUDD'^i_jk' * betaU'^k')()
printbr(var'\\hat{D}_j \\beta^i':eq(DhatbetaUdD))

local Dhat2betaUdDD = Tensor'^j_ik'
Dhat2betaUdDD['^j_ik'] = (DhatbetaUdD'^j_i,k'
	+ GammahatUDD'^j_kd' * DhatbetaUdD'^d_i'
	- GammahatUDD'^d_ki' * DhatbetaUdD'^j_d')()
printbr(var'\\hat{D}_k \\hat{D}_i \\beta^j':eq(Dhat2betaUdDD))

-- Next define BSSN quantities

--[[
AbarDDdupD
hDDdupD
alphadDD
cfdDD
detgammabardDD
detgDD
--]]

local AbarDDdupD = Tensor'_ijk'
AbarDDdupD['_ijk'] = AbarDD'_ij,k'()
printbr(var'\\bar{A}''_ij,k':eq(AbarDDdupD))

local gammabarDDdD = Tensor'_ijk'
gammabarDDdD['_ijk'] = gammabarDD'_ij,k'()
printbr(var'\\bar{\\gamma}''_ij,k':eq(gammabarDDdD))

-- TODO what's the difference between these two?
local gammabarDDdupD = gammabarDDdD

local gammabarDDdDD = Tensor'_ijkl'
gammabarDDdDD['_ijkl'] = gammabarDDdD'_ijk,l'()
printbr(var'\\bar{\\gamma}''_ij,kl':eq(gammabarDDdDD))

--[[ evaluating the inverse symbolically:
local detgammabarDD = Matrix.determinant(gammabarDD)
printbr('det(', var'\\bar{\\gamma}''_ij', ') =', detgammabarDD)
local detgammabarDDvar = var('\\bar{\\gamma}', xs)
local gammabarUU = Tensor('^ij', table.unpack((symmath.Matrix.inverse(gammabarDD, nil, nil, nil, detgammabarDDvar))))
--]]
-- [[ store them for later
local gammabarUU = Tensor('^ij', function(i,j)
	if i > j then i,j = j,i end
	return var('\\bar{\\gamma}^{'..xs[i].name..' '..xs[j].name..'}', xs)
end)
--]]
printbr(var'\\bar{\\gamma}''^ij':eq(gammabarUU))

local GammabarDDD = Tensor'_ijk'
GammabarDDD['_ijk'] = (frac(1,2) * (gammabarDDdD'_ijk' + gammabarDDdD'_ikj' - gammabarDDdD'_jki'))()
printbr(var'\\bar{\\Gamma}''_ijk':eq(GammabarDDD))

local GammabarUDD = Tensor'^i_jk'
GammabarUDD['^i_jk'] = (gammabarUU'^il' * GammabarDDD'_ljk')()
printbr(var'\\bar{\\Gamma}''^i_jk':eq(GammabarUDD))

local DGammaUDD = (GammabarUDD'^i_jk' - GammahatUDD'^i_jk')()
printbr(var'\\Delta''^i_jk':eq(DGammaUDD))

local DGammaDDD = (gammabarDD'_im' * DGammaUDD'^m_jk')()
printbr(var'\\Delta''_ijk':eq(DGammaDDD))

local DGammaU = (DGammaUDD'^i_jk' * gammabarUU'^jk')()
printbr(var'\\Delta''^i':eq(DGammaU))

local AbarUD = (gammabarUU'^ik' * AbarDD'_kj')()
printbr(var'\\bar{A}''^i_j':eq(AbarUD)) 

local AbarUU = (AbarUD'^i_k' * gammabarUU'^kj')()
printbr(var'\\bar{A}''^ij':eq(AbarUU))

-- Lie derivatives

local LbetagammabarDD = Tensor'_ij'
LbetagammabarDD['_ij'] = (betaU'^k' * gammabarDDdupD'_ijk'
	+ gammabarDD'_ki' * betaUdD'^k_j' + gammabarDD'_kj' * betaUdD'^k_i')()
printbr(var'\\mathcal{L}_\\beta \\bar{\\gamma}''_ij':eq(LbetagammabarDD))

local LbetaAbarDD = Tensor'_ij'
LbetaAbarDD['_ij'] = (betaU'^k' * AbarDDdupD'_ijk'
	+ AbarDD'_ki' * betaUdD'^k_j' + AbarDD'_kj' * betaUdD'^k_i')()
printbr(var'\\mathcal{L}_\\beta \\bar{A}''_ij':eq(LbetaAbarDD))

-- TODO trKdupD = K'_,i':makeDense() or Tensor('_i', K'_,i') or something
-- this is the clash between applying indexes to variables without and with and dense Tensor data objects
local K = var('K', xs)
local trKdupD = Tensor('_i', function(i)
	return K:diff(xs[i])()
end)
printbr(K'_,i':eq(trKdupD))

local LbetatrK = (betaU'^l' * trKdupD'_l')()
print(var'\\mathcal{L}_\\beta K':eq(LbetatrK))

local cf = var('W', xs)
local cfdD = Tensor('_i', function(i)
	return cf:diff(xs[i])()
end)
local cfdDD = cfdD'_i,j'()

local psim4, phidD, phidupD, phidDD
if CFEvolution ~= 'EvolveW' then	-- W = exp(-2 phi)
	error("not yet implemented")
else
	psim4 = cf^2
	phidD = (-1/(2*cf) * cfdD'_i')()
	printbr(var'\\phi''_,i'
		:eq(-1/(2*cf) * cf'_,i')
		:eq(phidD))
	-- TODO phidupD	
	phidupD = phidD
	phidDD = (1/(2*cf)*( 1/cf * cfdD'_i' * cfdD'_j' - cfdDD'_ij'))()
	printbr(var'\\phi''_,ij'
		:eq(1/(2*cf)*( 1/cf * cf'_,i' * cf'_,j' - cf'_,ij'))
		:eq(phidDD))
end

local Lbetaphi = (betaU'^l' * phidupD'_l')()
printbr(var'\\mathcal{L}_\\beta \\phi':eq(Lbetaphi))

local alpha = var('\\alpha', xs)
local alphadD = Tensor('_i', function(i)
	return alpha:diff(xs[i])()
end)
-- TODO
local alphadupdD = alphadD

local alphadDD = alphadD'_i,j'()

local Lbetaalpha = (betaU'^l' * alphadupdD'_l')()
printbr(var'\\mathcal{L}_\\beta \\alpha':eq(Lbetaalpha))

local LbetaLambdaU = (betaU'^j' * LambdaUdupD'^i_j' - betaUdD'^i_j' * LambdaU'^j')()
printbr(var'\\mathcal{L}_\\beta \\Lambda''^i':eq(LbetaLambdaU)) 

-- Covariant derivatives of phi and alpha

local DbaralphaD = alphadD'_i'
printbr(var'\\bar{D}_i \\alpha':eq(DbaralphaD))

local DbaralphaU = (gammabarUU'^ij' * alphadD'_j')()
printbr(var'\\bar{D}^i \\alpha':eq(DbaralphaU))

local DbarphiD = phidD'_i'
printbr(var'\\bar{D}_i \\phi':eq(DbarphiD))

local DbarphiU = (gammabarUU'^ij' * phidD'_j')()
printbr(var'\\bar{D}^i \\phi':eq(DbarphiU))

local Dbar2phiDD = (phidDD'_ij' - GammabarUDD'^l_ij' * phidD'_l')()
printbr(var'\\bar{D}_i \\bar{D}_j \\phi':eq(Dbar2phiDD))

local Dbarphi2 = (DbarphiD'_i' * DbarphiU'^i')()
printbr(var'\\bar{\\gamma}^{ij} \\bar{D}_i \\phi \\bar{D}_j \\phi':eq(Dbarphi2))

local Dbar2alphaDD = (alphadDD'_ij' - GammabarUDD'^l_ij' * alphadD'_l')()
printbr(var'\\bar{D}_i \\bar{D}_j \\alpha':eq(Dbar2alphaDD))

local Dbar2alpha = (gammabarUU'^ij' * Dbar2alphaDD'_ij')()
printbr(var'\\bar{\\gamma}^{ij} \\bar{D}_i \\bar{D}_j \\alpha':eq(Dbar2alpha))

local phitermsDD = (-2 * alpha * Dbar2phiDD'_ij'
	+ 4 * alpha * DbarphiD'_i' * DbarphiD'_j'
	+ 2 * (DbaralphaD'_i' * DbarphiD'_j' + DbaralphaD'_j' * DbaralphaD'_i'))()
printbr('$(\\phi$ extra terms$)_{ij} =$', phitermsDD)

local detgammahat = Matrix.determinant(ghatDD)
printbr(var'det(\\hat{\\gamma}_{mn})':eq(detgammahat))

local detg = var('g', xs)
printbr(var'det(\\gamma_{mn})':eq(detg))

local detgdD = Tensor('_i', function(i)
	return detg:diff(xs[i])()
end)

local detgammabar = detgammahat * detg
printbr(var'det(\\bar{\\gamma}_{mn})':eq(detgammabar))

local detgammabardD = Tensor('_i', function(i)
	return (detgammahat * detg):diff(xs[i])()
end)
printbr(var'det(\\bar{\\gamma}_{mn})_{,i}':eq(detgammabardD))

local detgammabardDD = detgammabardD'_i,j'()
printbr(var'det(\\bar{\\gamma}_{mn})_{,ij}':eq(detgammabardDD))

local DbarbetaUD = (betaUdD'^i_j' 
	+ GammabarUDD'^j_il' * betaU'^l')()
printbr(var'\\bar{D}_j \\beta^i':eq(DbarbetaUD))

--local Dbarbetacontraction = DbarbetaUD'^i_i'() 
local Dbarbetacontraction = (betaUdD'^i_i' + betaU'^i' * detgammabardD'_i' / (2*detgammabar))()
printbr(var'\\bar{D}_k \\beta^k':eq(Dbarbetacontraction))

local Dbar2betacontractionD = (betaUdDD'^j_jk'
	+ frac(1,2) * (
		detgammabardDD'_jk' * betaU'^j'
		- detgammabardD'_j' * detgammabardD'_k' * betaU'^j' / detgammabar
		+ detgammabardD'_j' * betaUdD'^j_k'
	) / detgammabar)()
printbr(var'\\bar{D}_k \\bar{D}_j \\beta^j':eq(Dbar2betacontractionD))

local Dbar2betacontractionU = (gammabarUU'^ij' * Dbar2betacontractionD'_j')()
printbr(var'\\bar{D}^k \\bar{D}_j \\beta^j':eq(Dbar2betacontractionU))

-- Ricci tensor, wrt barred metric

-- temp cache to save on computation time
local trDHat2gammabarDDdDD = (gammabarUU'^kl' * Dhat2gammabarDDdDD'_ijkl')()
local DhatLambdaUdD_DD = (gammabarDD'_ki' * DhatLambdaUdD'^k_j')()
local DGammaU_dot3_DGammaDDD = (DGammaU'^k' * DGammaDDD'_ijk')()
local DGammaUDD_dot12_DGammaDDD = (DGammaUDD'^m_ij' * DGammaDDD'_kml')()
local tr14_DGammaUDD_dot12_DGammaDDD = (gammabarUU'^kl' * DGammaUDD_dot12_DGammaDDD'_kijl')()
local DGammaUDD_dot11_DGammaDDD = (DGammaUDD'^m_ik' * DGammaDDD'_mjl')()
local tr24_DGammaUDD_dot11_DGammaDDD = (gammabarUU'^kl' * DGammaUDD_dot11_DGammaDDD'_ikjl')()

local RbarDD = (
	-- first term
	-frac(1,2) * trDHat2gammabarDDdDD'_ij' -- -frac(1,2) * gammabarUU'^kl' * Dhat2gammabarDDdDD'_ijkl'
	-- second term
	+ frac(1,2) * (DhatLambdaUdD_DD'_ij' + DhatLambdaUdD_DD'_ji')   -- + frac(1,2) * (gammabarDD'_ki' * DhatLambdaUdD'^k_j' + gammabarDD'_kj' * DhatLambdaUdD'^k_i')
	-- third term
	--+ DGammaU'^k' * frac(1,2) * (DGammaDDD'_ijk' + DGammaDDD'_jik')
	+ frac(1,2) * (DGammaU_dot3_DGammaDDD'_ij' + DGammaU_dot3_DGammaDDD'_ji')
	-- fourth term
	+ tr14_DGammaUDD_dot12_DGammaDDD'_ij' + tr14_DGammaUDD_dot12_DGammaDDD'_ji' -- + gammabarUU'^kl' * (DGammaUDD_dot12_DGammaDDD'_kijl' + DGammaUDD_dot12_DGammaDDD'_kjil') --(DGammaUDD'^m_ki' * DGammaDDD'_jml' + DGammaUDD'^m_kj' * DGammaDDD'_iml')
	+ tr24_DGammaUDD_dot11_DGammaDDD'_ij'	-- + gammabarUU'^kl' * DGammaUDD_dot11_DGammaDDD'_ikjl' -- + gammabarUU'^kl' * DGammaUDD'^m_ik' * DGammaDDD'_mjl'
)()
printbr(var'\\bar{R}''_ij':eq(RbarDD))

local deltaUD = Tensor('^i_j', function(i,j) return i==j and 1 or 0 end)
printbr(var'\\delta''^i_j':eq(deltaUD))

-- Trace-free parts of RBarDD, phitermsDD, and DBar2_alphaDD

local function tracefree(x)
	local tr = (gammabarUU'^kl' * x'_kl')()
	return (x'_ij' - gammabarDD'_ij' * tr / 3)()
end

local RbarTFDD = tracefree(RbarDD)
local phitermsTFDD = tracefree(phitermsDD)
local Dbar2alphaTFDD = tracefree(Dbar2alphaDD)

-- BSSN RHSs

local gammabarrhsDD = (LbetagammabarDD'_ij'
	- frac(2,3) * gammabarDD'_ij' * Dbarbetacontraction
	- 2 * alpha * AbarDD'_ij')()
printbr(var'\\bar{\\gamma}''_ij,t':eq(gammabarrhsDD))

local AbarrhsDD = (LbetaAbarDD'_ij'
	- frac(2,3) * AbarDD'_ij' * Dbarbetacontraction
	+ alpha * AbarDD'_ij' * K
	+ psim4 * (
		phitermsTFDD'_ij' 
		- Dbar2alphaTFDD'_ij'
		+ alpha * RbarTFDD'_ij'
	)
	- 2 * alpha * AbarDD'_il' * AbarUD'^l_j')()
local L2AbarrhsDD = (psim4 * (
	phitermsTFDD'_ij' 
	- Dbar2alphaTFDD'_ij'
	+ alpha * RbarTFDD'_ij'))()
local L3AbarrhsDD = (LbetaAbarDD'_ij'
	- frac(2,3) * AbarDD'_ij' * Dbarbetacontraction
	+ alpha * AbarDD'_ij' * K
	- 2 * alpha * AbarDD'_il' * AbarUD'^l_j')()
printbr(var'\\bar{A}''_ij,t')
printbr('L1', AbarrhsDD'_ij')
printbr('L2', L2AbarrhsDD'_ij')
printbr('L3', L3AbarrhsDD'_ij')

local cfrhs = (Lbetaphi + frac(1,6) * (Dbarbetacontraction - alpha * K))()
if CFEvolution == 'EvolvePhi' then
	-- keep it the same
elseif CFEvolution == 'EvolveChi' then
	cfrhs = cfrhs * -4 * cf
elseif CFEvolution == 'EvolveW' then
	cfrhs = cfrhs * -2 * cf
end
printbr(var'cf''_,t':eq(cfrhs))

local trAbar = (gammabarUU'^ij' * AbarDD'_ij')()
printbr(var'tr(\\bar{A})':eq(trAbar))

trKrhs = (LbetatrK
	+ alpha / 3 * K^2
	- psim4 * Dbar2alpha
	+ alpha * (AbarDD'_ij' * AbarUU'^ij')
	- psim4 * 2 * DbaralphaU'^i' * DbarphiD'_i')()
local L2trKrhs = (-psim4 * Dbar2alpha
	- psim4 * 2 * DbaralphaU'^i' * DbarphiD'_i')()
local L3trKrhs = (LbetatrK
	+ alpha / 3 * K^2
	+ alpha * (AbarDD'_ij' * AbarUU'^ij'))()
printbr(K'_,t')
printbr('L1', trKrhs)
printbr('L2', L2trKrhs)
printbr('L3', L3trKrhs)

local LambdarhsU = (LbetaLambdaU'^i'
	+ frac(2,3) * DGammaU'^i' * Dbarbetacontraction
	+ frac(1,3) * Dbar2betacontractionU'^i'
	- frac(4,3) * alpha * gammabarUU'^ij' * trKdD'_j'
	+ gammabarUU'^jk' * Dhat2betaUdDD'^i_jk'
	- 2 * AbarUU'^jk' * (
		deltaUD'^i_j' * alphadD'_k' 
		- 6 * alpha * deltaUD'^i_j' * phidD'_k'
		- alpha * DGammaUDD'^i_jk'
	))()

local L2LambdarhsU = (frac(1,3) * Dbar2betacontractionU'^i'
	- frac(4,3) * alpha * gammabarUU'^ij' * trKdD'_j'
	+ gammabarUU'^jk' * Dhat2betaUdDD'^i_jk'
	- 2 * AbarUU'^jk' * (
		deltaUD'^i_j' * alphadD'_k'
		- 6 * alpha * deltaUD'^i_j' * phidD'_k'
		- alpha * DGammaUDD'^i_jk'
	))()
local L3LambdarhsU = LbetaLambdaU'^i'
	+ frac(2,3) * DGammaU'^i' * Dbarbetacontraction
printbr(var'\\Lambda''^i_,t')
printbr('L1', LambdarhsU)
printbr('L2', L2LambdarhsU)
printbr('L3', L3LambdarhsU)

local alpharhs
if InitialDataType == 'StaticTrumpet' then
	alpharhs = -alpha * (1 - alpha) * trK
else
	alpharhs = -2*alpha*trK
end
alpharhs = (alpharhs + betaU'^i' * alphadupD'_i')()
printbr(var'\\alpha''_,t':eq(alpharhs))

local betarhsU = BU'^i'()
if SHIFTADVECT then
	betarhsU = (betarhsU'^i' + betaU'^j' * betaUdupD'^i_j')()
end
printbr(var'\\beta''^i_,t':eq(betarhsU))

local eta = var'\\eta'
local BrhsU = (frac(3,4) * LambdarhsU'^i' - eta * BU'^i')()
if BIADVECT then
	BrhsU = (BrhsU'^i' + betaU'^j' * BUdupD'^j_i')()
end
local L2BrhsU = (frac(3,4) * (L2LambdarhsU'^i' + L3LambdarhsU'^i'))()
local L3BrhsU = (-eta * BU'^i')()
local betadotBd = (betaU'^j' * BUdupD'^i_j')()
if BIADVECT then
	L3BrhsU = (L3BrhsU'^i' + betaU'^j' * BUdupD'^i_j')()
end
printbr(var'B''^i_,t')
printbr('L1', BrhsU)
printbr('L2', L2BrhsU)
printbr('L3', L3BrhsU)

-- Kronecher delta

local deltaDD = Tensor('_IJ', function(i,j) return i==j and 1 or 0 end)
printbr(var'\\delta''_IJ':eq(deltaDD))

local vetrhsU = (betarhsU'^i' * e'^I_i')()
printbr(vetvar'^I_,t'
	:eq(var'\\beta''^i' * var'e''^I_i')
	:eq(vetrhsU)) 

local hrhsDD = (gammabarrhsDD'_ij' * eu'_I^i' * eu'_J^j'
	+ frac(2,3) * alpha * (
		deltaDD'_IJ' + hDD'_IJ'
	) * trAbar)()
printbr(var'h''_IJ,t':eq(hrhsDD))

local L2betrhsU = (L2BrhsU'^i' * e'^I_i')()
local L3betrhsU = (L3BrhsU'^i' * e'^I_i')()
printbr(betvar'^I_,t')
printbr('L2', L2betrhsU)
printbr('L3', L3betrhsU)

local L2lambdarhsU = (L2LambdarhsU'^i' * e'^I_i')()
local L3lambdarhsU = (L3LambdarhsU'^i' * e'^I_i')()
printbr(var'\\lambda''^I_,t')
printbr('L2', L2lambdarhsU)
printbr('L3', L3lambdarhsU) 

local L2arhsDD = (L2ABarrhsDD'_ij' * eu'_I^i' * eu'_J^j')()
local L3arhsDD = (L3AbarrhsDD'_ij' * eu'_I^i' * eu'_J^j')()
printbr(var'a''_IJ,t')
printbr('L2', L2arhsDD)
printbr('L3', L3arhsDD)

printbr(require 'symmath.tostring.MathJax'.footer)
