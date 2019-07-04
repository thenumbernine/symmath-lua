#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup()

local output = 'html'
--local output = 'tex'

output = ... or output

local header = [[
translation of BSSN_RHS.nb from Zach Etienne's SENR project, from Mathematica into Lua symmath
found at <a href='https://math.wvu.edu/~zetienne/SENR/'>https://math.wvu.edu/~zetienne/SENR/</a>
]]

if output == 'html' then
	symmath.tostring = require 'symmath.tostring.MathJax'
	symmath.tostring.setup{title='BSSN'}
	print((header:gsub('\n', '<br>\n')))
elseif output == 'tex' then
	symmath.tostring = require 'symmath.tostring.LaTeX'
	printbr = print 
	--symmath.tostring.title = 'BSSN'	-- I don't have this yet?
	print(symmath.tostring.header)
	header = header:gsub('_', '\\_') .. [[
\DeclareMathSymbol{\beth}{\mathord}{hebrewletters}{98}\let\bet\beth
\DeclareMathSymbol{\vet}{\mathord}{hebrewletters}{99}
]]
	print(header)
end

symmath.tostring.useCommaDerivative = true

local function printAndWarn(str)
	printbr(str)
	io.stderr:write(str,'\n')
end


-- TODO redo this whole thing, don't use any dense tensors, just index notation expression
-- and only last substitute in actual dense tensor values for specific coordinate systems
-- but only do this once I have transcribed and understand the whole notebook file

local SHIFTADVECT = true
printbr('SHIFTADVECT =',SHIFTADVECT)

local BIADVECT = true
printbr('BIADVECT =',BIADVECT)

--local CFEvolution = 'EvolvePhi'
--local CFEvolution = 'EvolveChi'
local CFEvolution = 'EvolveW'
printbr('CFEvolution =',CFEvolution)

--local CoordSystem = 'Cartesian'
--local CoordSystem = 'Cylindrical'
--local CoordSystem = 'LogRadialSphericalPolar'
local CoordSystem = 'SphericalPolar'
--local CoordSystem = 'SymTP'
printbr('CoordSystem =',CoordSystem)

local InitialDataType = 'Minkowski'
--local InitialDataType = 'BrillLindquist'
--local InitialDataType = 'StaticTrumpet'
--local InitialDataType = 'UIUC'
printbr('InitialDataType =',InitialDataType)

local InitialLapseType = 'PunctureR2'
printbr('InitialLapseType =',InitialLapseType)

local InitialShiftType = 'Zero'
printbr('InitialShiftType =',InitialShiftType)

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
printbr(var'r_{coord}':eq(r))
printbr(var'\\theta_{coord}':eq(th))
printbr(var'\\phi_{coord}':eq(ph))
printbr('$y^i = \\{$', y1, y2, y3, '$\\}$')
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

printbr('coordinate basis $x^i = \\{$', xs:map(tostring):concat', ', '$\\}$')
printbr('non-coordinate basis $x^I = \\{$', xns:map(tostring):concat', ', '$\\}$')

local eLens
if CoordSystem == 'Cartesian' then
	eLens = Array(1, 1, 1)
elseif CoordSystem == 'Cylindrical' or CoordSystem == 'SymTP' then
	eLens = Array(1, y1, 1)
elseif CoordSystem == 'SphericalPolar' or CoordSystem == 'LogRadialSphericalPolar' then
	eLens = Array(y1:diff(x1)(), y1, y1 * sin(y2))
end

printbr"Using capital letters to denote sums over non-coordinate basis."
printbr"Using hats to denote individual non-coordinate basis terms."
printbr"Rescaling transform to non-coordinate basis:"
local evar = var'e'
local e = Tensor('^I_i', function(i,j)
	return (i==j and eLens[i] or 0)
end)
--e:printElem'e' printbr()
printbr(evar'^I_i':eq(e))

local eu = Tensor('_I^i', function(i,j)
	return i==j and (1/eLens[i])() or 0
end)
printbr(evar'_I^i':eq(eu))
--eu:printElem'e' printbr()

-- Initialize ghat_ij to zero
-- Set nonzero ghat_ij components

printbr"grid metric:"

local ghatvar = var'\\hat{\\gamma}'
local ghatDD = Tensor('_ij', function(i,j)
	return i==j and (eLens[i]^2)() or 0
end)
printbr(ghatvar'_ij':eq(ghatDD))

-- Set upper-triangular of rescaling matrix for metric & extrinsic curvature tensors
-- Set rescaling vector for lambda^i, beta^i, and B^i

-- End of inputs.  Next compute all needed hatted quantities for BSSN
-- First focus on hatted quantities related to rank-2 tensors

local ghatUU = Tensor('^ij', table.unpack((symmath.Matrix.inverse(ghatDD))))
printbr(ghatvar'^ij':eq(ghatUU))

printbr()
local Gammahatvar = var'\\hat{\\Gamma}'
local GammahatUDDexpr = Gammahatvar'^i_jk':eq(frac(1,2) * ghatvar'^im' * (ghatvar'_mj,k' + ghatvar'_mk,j' - ghatvar'_jk,m'))
printbr(GammahatUDDexpr) 
-- TODO hmm, you have to replaceIndex() the dense TensorRefs with comma derivatives.
-- if you splitOffDerivIndexes() before replaceIndex()'ing the dense tensors then you cannot evaluate them without (once again) providing all indexes to the TensorRef (including comma dervative)
local GammahatUDD = GammahatUDDexpr:rhs():replaceIndex(ghatvar'^ij', ghatUU'^ij'):replaceIndex(ghatvar'_ij,k', ghatDD'_ij,k')()
printbr(Gammahatvar'^i_jk':eq(GammahatUDD))

local GammahatUDDdD = GammahatUDD'^i_jk,l'()
printbr(Gammahatvar'^i_jk,l':eq(GammahatUDDdD))

-- state variables
printAndWarn'state variables:'

--[[
What is "dup" vs "d"? Aha, upwind-sampled vs centered-sampled derivatives.
TODO take notice of this.
TODO only do index notation equations for the first half of this worksheet,
and only later substitute in dense tensors.
That way if deriving the dense ones runs too slow (as it tends to), at least you have the index notion expressions.
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
local hvar = var'h'
printbr(hvar'_IJ':eq(hDD))
	
local hDDdD = hDD'_IJ,k'()
printbr(hvar'_IJ,k':eq(hDDdD))

local aDD = Tensor('_IJ', function(i,j)
	if i > j then i,j = j,i end
	return var('a_{'..xns[i].name..' '..xns[j].name..'}', xs)
end)
local avar = var'a'
printbr(avar'_IJ':eq(aDD))

-- this was hDD * ReDD
printbr()
local epsvar = var'\\epsilon'
local epsDDexpr = epsvar'_ij':eq(hvar'_IJ' * evar'^I_i' * evar'^J_j')
printbr(epsDDexpr)
local epsDD = epsDDexpr:rhs():replaceIndex(hvar'_IJ', hDD'_IJ'):replaceIndex(evar'^I_i', e'^I_i')()
printbr(epsvar'_ij':eq(epsDD))

printbr()
local gbarvar = var'\\bar{\\gamma}'
local gammabarDDexpr = gbarvar'_ij':eq(ghatvar'_ij' + epsvar'_ij')
printbr(gammabarDDexpr)
local gammabarDD = gammabarDDexpr:rhs():replaceIndex(ghatvar'_ij', ghatDD'_ij'):replaceIndex(epsvar'_ij', epsDD'_ij')()
printbr(gbarvar'_ij':eq(gammabarDD))

printbr()
local Abarvar = var'\\bar{A}'
local AbarDDexpr = Abarvar'_ij':eq(avar'_IJ' * evar'^I_i' * evar'^J_j')
printbr(AbarDDexpr)
local AbarDD = AbarDDexpr:rhs():replaceIndex(avar'_IJ', aDD'_IJ'):replaceIndex(evar'^I_i', e'^I_i')()
printbr(Abarvar'_ij':eq(AbarDD))

-- the nb worksheet has epsDDdD[jki] = hDD[jk] * ReDDdD[jki] + ReDD[jk]*hDDdD[jki]
-- but we can just automatically differentiate it ...
local epsDDdD = epsDD'_ij,k'()
printbr(epsvar'_ij,k':eq(epsDDdD))

-- DHat_i gammaBar_jk = DHat_i (gammaHat_jk + epsilon_jk) = DHat_i epsilon_jk
local function Dhat(suffix) 
	return makefunc('\\hat{D}'..suffix)	-- TODO better formatting
end
local Dhatgammabarexpr = Dhat'_i'(epsvar'_jk'):eq(
	epsvar'_jk,i'
	- epsvar'_jd' * Gammahatvar'^d_ik'
	- epsvar'_dk' * Gammahatvar'^d_ij')
printbr(Dhatgammabarexpr)
local DhatgammabarDDdD = Dhatgammabarexpr:rhs():replace(epsvar, epsDD):replace(Gammahatvar, GammahatUDD)()
printbr(Dhat'_i'(gbarvar'_jk'):eq(DhatgammabarDDdD))

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

local epsDDdDD = epsDD'_ij,kl'()
printbr(epsvar'_ij,kl':eq(epsDDdDD))

-- Why "DDdDdD" and why not "DDdDD"?
local Dhat2gammabarDDdDD = Tensor'_jkil'
Dhat2gammabarDDdDD['_ijkl'] = (DhatgammabarDDdD'_ijk,l' + 
	- DhatgammabarDDdD'_mjl' * GammahatUDD'^m_ki'
	- DhatgammabarDDdD'_iml' * GammahatUDD'^m_kj'
	- DhatgammabarDDdD'_ijm' * GammahatUDD'^m_kl')()
printbr(Dhat'_k'(Dhat'_l'(gbarvar'_ij')):eq(Dhat2gammabarDDdDD))

-- Then focus on hatted quantities related to vectors
printAndWarn'hatted quantities related to vectors'

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

local vetvar = var(output == 'tex' and '\\vet' or 'ב')
local vetU = Tensor('^I', function(i)
	return var(vetvar.name..'^'..xns[i].name, xs)
end)

local betavar = var'\\beta'
local betaU = (vetU'^I' * eu'_I^i')()
printbr(betavar'^i'
	:eq(vetvar'^I' * evar'_I^i')
	:eq(betaU))

local betvar = var(output == 'tex' and '\\bet' or 'בּ')
local betU = Tensor('^I', function(i)
	return var(betvar.name..'^'..xns[i].name, xs)
end)

local Bvar = var'B'
local BU = (betU'^I' * eu'_I^i')()
printbr(Bvar'^i'
	:eq(betvar'^I' * evar'_I^i')
	:eq(BU))

local lambdavar = var'\\lambda'
local lambdaU = Tensor('^I', function(i)
	return var('\\lambda^'..xns[i].name, xs)
end)

local Lambdavar = var'\\Lambda'
local LambdaU = (lambdaU'^I' * eu'_I^i')()
printbr(Lambdavar'^i'
	:eq(lambdavar'^I' * evar'_I^i')
	:eq(LambdaU))

local LambdaUdD = Tensor'^i_j'
LambdaUdD['^i_j'] = LambdaU'^i_,j'()
printbr(Lambdavar'^i_,j':eq(LambdaUdD))

local betaUdD = Tensor'^i_j'
betaUdD['^i_j'] = betaU'^i_,j'()
printbr(betavar'^i_,j':eq(betaUdD))

local BUdupD = Tensor'^i_j'
BUdupD['^i_j'] = BU'^i_,j'()
printbr(Bvar'^i_,j':eq(BUdupD))

local betaUdupD = Tensor'^i_j'
betaUdupD['^i_j'] = betaU'^i_,j'()
printbr(betavar'^i_,j':eq(betaUdupD))

local LambdaUdupD = Tensor'^i_j'
LambdaUdupD['^i_j'] = LambdaU'^i_,j'()
printbr(Lambdavar'^i_,j':eq(LambdaUdupD))

local betaUdDD = Tensor'^i_jk'
betaUdDD['^i_jk'] = betaU'^i_,jk'()
printbr(betavar'^i_,jk':eq(betaUdDD))

local DhatLambdaUdD = Tensor'^i_j'
DhatLambdaUdD['^i_j'] = (LambdaUdD'^i_j' + GammahatUDD'^i_jk' * LambdaU'^k')()
printbr(Dhat'_j'(Lambdavar'^i'):eq(DhatLambdaUdD))

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
printbr(Dhat'_j'(betavar'^i'):eq(DhatbetaUdD))

local Dhat2betaUdDD = Tensor'^j_ik'
Dhat2betaUdDD['^j_ik'] = (DhatbetaUdD'^j_i,k'
	+ GammahatUDD'^j_kd' * DhatbetaUdD'^d_i'
	- GammahatUDD'^d_ki' * DhatbetaUdD'^j_d')()
printbr(Dhat'_k'(Dhat'_i'(betavar'^j')):eq(Dhat2betaUdDD))

-- Next define BSSN quantities
printAndWarn'BSSN quantities'

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
printbr(Abarvar'_ij,k':eq(AbarDDdupD))

local gammabarDDdD = Tensor'_ijk'
gammabarDDdD['_ijk'] = gammabarDD'_ij,k'()
printbr(gbarvar'_ij,k':eq(gammabarDDdD))

local gammabarDDdupD = gammabarDDdD

local gammabarDDdDD = Tensor'_ijkl'
gammabarDDdDD['_ijkl'] = gammabarDDdD'_ijk,l'()
printbr(gbarvar'_ij,kl':eq(gammabarDDdDD))

--[[ evaluating the inverse symbolically:
local detgammabarDD = Matrix.determinant(gammabarDD)
printbr('det(', gbarvar'_ij', ') =', detgammabarDD)
local detgammabarDDvar = var('\\bar{\\gamma}', xs)
local gammabarUU = Tensor('^ij', table.unpack((symmath.Matrix.inverse(gammabarDD, nil, nil, nil, detgammabarDDvar))))
--]]
-- [[ store them for later
local gammabarUU = Tensor('^ij', function(i,j)
	if i > j then i,j = j,i end
	return var('\\bar{\\gamma}^{'..xs[i].name..' '..xs[j].name..'}', xs)
end)
--]]
--[[ halfway: separate the determinant
printbr()
local detgammabar = Matrix.determinant(gammabarDD)
printbr()
printbr(gbarvar:eq(detgammabar))
local gammabarUU = Tensor('^ij', table.unpack((Matrix.inverse(gammabarDD, nil, nil, nil, gbarvar))))
--]]
printbr(gbarvar'^ij':eq(gammabarUU))

local Gammabarvar = var'\\bar{\\Gamma}'
local GammabarDDD = Tensor'_ijk'
GammabarDDD['_ijk'] = (frac(1,2) * (gammabarDDdD'_ijk' + gammabarDDdD'_ikj' - gammabarDDdD'_jki'))()
printbr(Gammabarvar'_ijk':eq(GammabarDDD))

local GammabarUDD = Tensor'^i_jk'
GammabarUDD['^i_jk'] = (gammabarUU'^il' * GammabarDDD'_ljk')()
printbr(Gammabarvar'^i_jk':eq(GammabarUDD))

local Deltavar = var'\\Delta'
local DGammaUDD = (GammabarUDD'^i_jk' - GammahatUDD'^i_jk')()
printbr(Deltavar'^i_jk':eq(DGammaUDD))

local DGammaDDD = (gammabarDD'_im' * DGammaUDD'^m_jk')()
printbr(Deltavar'_ijk':eq(DGammaDDD))

local DGammaU = (DGammaUDD'^i_jk' * gammabarUU'^jk')()
printbr(Deltavar'^i':eq(DGammaU))

local AbarUD = (gammabarUU'^ik' * AbarDD'_kj')()
printbr(Abarvar'^i_j':eq(AbarUD)) 

local AbarUU = (AbarUD'^i_k' * gammabarUU'^kj')()
printbr(Abarvar'^ij':eq(AbarUU))

-- Here I interject the initial data stuff ... for Minkowski ...
-- because, when doing the derivative stuff, my computer stalls at the RBarDD calculations
printAndWarn'Initial Data'

local K = var('K', xs)
if InitialDataType == 'Minkowski' then
	local r0 = x1 -- or should it be 'r' ?
	local theta = x2
	
	-- TODO different metrics for different coordinate systems
	assert(CoordSystem == 'SphericalPolar')
	local gPhys0DD = Tensor('_ij', {1,0,0}, {0, r0^2, 0}, {0, 0, r0^2 * sin(theta)^2})
	printbr(var'\\gamma''_ij':eq(gPhys0DD))
	printbr(ghatvar'_ij':eq(gPhys0DD))

	local APhys0DD = Tensor'_ij'
	printbr(Abarvar'_ij':eq(APhys0DD))

	local trK = 0
	printbr(K:eq(trK))
else
	error'not yet supported'
end

-- Lie derivatives
printAndWarn'Lie derivatives'

local Lbeta = makefunc'\\mathcal{L}_\\beta'
local LbetagammabarDD = Tensor'_ij'
LbetagammabarDD['_ij'] = (betaU'^k' * gammabarDDdupD'_ijk'
	+ gammabarDD'_ki' * betaUdD'^k_j' + gammabarDD'_kj' * betaUdD'^k_i')()
printbr(Lbeta(gbarvar'_ij'):eq(LbetagammabarDD))

local LbetaAbarDD = Tensor'_ij'
LbetaAbarDD['_ij'] = (betaU'^k' * AbarDDdupD'_ijk'
	+ AbarDD'_ki' * betaUdD'^k_j' + AbarDD'_kj' * betaUdD'^k_i')()
printbr(Lbeta(Abarvar'_ij'):eq(LbetaAbarDD))

-- TODO trKdupD = K'_,i':makeDense() or Tensor('_i', K'_,i') or something
-- this is the clash between applying indexes to variables without and with and dense Tensor data objects
local trKdupD = Tensor('_i', function(i)
	return K:diff(xs[i])()
end)
printbr(K'_,i':eq(trKdupD))

local LbetatrK = (betaU'^l' * trKdupD'_l')()
printbr(Lbeta(K):eq(LbetatrK))

local cf = var('W', xs)
local cfdD = Tensor('_i', function(i)
	return cf:diff(xs[i])()
end)
local cfdDD = cfdD'_i,j'()

local phivar = var'\\phi'
local psim4, phidD, phidupD, phidDD
if CFEvolution ~= 'EvolveW' then	-- W = exp(-2 phi)
	error("not yet implemented")
else
	psim4 = cf^2
	phidD = (-1/(2*cf) * cfdD'_i')()
	printbr(phivar'_,i'
		:eq(-1/(2*cf) * cf'_,i')
		:eq(phidD))
	phidupD = phidD
	phidDD = (1/(2*cf)*( 1/cf * cfdD'_i' * cfdD'_j' - cfdDD'_ij'))()
	printbr(phivar'_,ij'
		:eq(1/(2*cf)*( 1/cf * cf'_,i' * cf'_,j' - cf'_,ij'))
		:eq(phidDD))
end

local Lbetaphi = (betaU'^l' * phidupD'_l')()
printbr(Lbeta(phivar):eq(Lbetaphi))

local alpha = var('\\alpha', xs)
local alphadD = Tensor('_i', function(i)
	return alpha:diff(xs[i])()
end)
local alphadupdD = alphadD

local alphadDD = alphadD'_i,j'()

local Lbetaalpha = (betaU'^l' * alphadupdD'_l')()
printbr(Lbeta(alpha):eq(Lbetaalpha))

local LbetaLambdaU = (betaU'^j' * LambdaUdupD'^i_j' - betaUdD'^i_j' * LambdaU'^j')()
printbr(Lbeta(Lambdavar)'^i':eq(LbetaLambdaU)) 

-- Covariant derivatives of phi and alpha
printAndWarn'Covariant derivatives of phi and alpha'

local function Dbar(suffix)
	return makefunc('\\bar{D}'..suffix)
end

local DbaralphaD = alphadD'_i'
printbr(Dbar'_i'(alpha):eq(DbaralphaD))

local DbaralphaU = (gammabarUU'^ij' * alphadD'_j')()
printbr(Dbar'_i'(alpha):eq(DbaralphaU))

local DbarphiD = phidD'_i'
printbr(Dbar'_i'(phivar):eq(DbarphiD))

local DbarphiU = (gammabarUU'^ij' * phidD'_j')()
printbr(Dbar'_i'(phivar):eq(DbarphiU))

local Dbar2phiDD = (phidDD'_ij' - GammabarUDD'^l_ij' * phidD'_l')()
printbr(Dbar'_i'(Dbar'_j'(phivar)):eq(Dbar2phiDD))

local Dbarphi2 = (DbarphiD'_i' * DbarphiU'^i')()
printbr((gbarvar'^ij' * Dbar'_i'(phivar) * Dbar'_j'(phivar)):eq(Dbarphi2))

local Dbar2alphaDD = (alphadDD'_ij' - GammabarUDD'^l_ij' * alphadD'_l')()
printbr(Dbar'_i'(Dbar'_j'(alpha)):eq(Dbar2alphaDD))

local Dbar2alpha = (gammabarUU'^ij' * Dbar2alphaDD'_ij')()
printbr((gbarvar'^ij' * Dbar'_i'(Dbar'_j'(alpha))):eq(Dbar2alpha))

local phitermsDD = (-2 * alpha * Dbar2phiDD'_ij'
	+ 4 * alpha * DbarphiD'_i' * DbarphiD'_j'
	+ 2 * (DbaralphaD'_i' * DbarphiD'_j' + DbaralphaD'_j' * DbaralphaD'_i'))()
printbr('$(\\phi$ extra terms$)_{ij} =$', phitermsDD)

-- TODO instead defer evaluation of Matrix.determinant?
-- or maybe have a 'defer(Matrix.determinant, ghatDD)' command?
-- but then again, the defer command is associated with a function, a function doesn't have a name,
-- so how would the defer'd function be displayed?
-- why not just use a class?
-- and then, why not just always defer until simplification?
local det = makefunc'det'

local detgammahat = Matrix.determinant(ghatDD)
printbr(det(ghatvar'_mn'):eq(detgammahat))

local gammavar = var'\\gamma'
local detg = var('\\gamma', xs)
printbr(det(gammavar'_mn'):eq(detg))

local detgdD = Tensor('_i', function(i)
	return detg:diff(xs[i])()
end)

local detgammabar = detgammahat * detg
printbr(det(gbarvar'_mn'):eq(detgammabar))

local detgammabardD = Tensor('_i', function(i)
	return (detgammahat * detg):diff(xs[i])()
end)
printbr(det(gbarvar'_mn')'_,i':eq(detgammabardD))

local detgammabardDD = detgammabardD'_i,j'()
printbr(det(gbarvar'_mn')'_,ij':eq(detgammabardDD))

local DbarbetaUD = (betaUdD'^i_j' 
	+ GammabarUDD'^j_il' * betaU'^l')()
printbr(Dbar'_j'(betavar'^i'):eq(DbarbetaUD))

--local Dbarbetacontraction = DbarbetaUD'^i_i'() 
local Dbarbetacontraction = (betaUdD'^i_i' + betaU'^i' * detgammabardD'_i' / (2*detgammabar))()
printbr(Dbar'_k'(betavar'^k'):eq(Dbarbetacontraction))

local Dbar2betacontractionD = (betaUdDD'^j_jk'
	+ frac(1,2) * (
		detgammabardDD'_jk' * betaU'^j'
		- detgammabardD'_j' * detgammabardD'_k' * betaU'^j' / detgammabar
		+ detgammabardD'_j' * betaUdD'^j_k'
	) / detgammabar)()
printbr(Dbar'_k'(Dbar'_j'(betavar'^j')):eq(Dbar2betacontractionD))

local Dbar2betacontractionU = (gammabarUU'^ij' * Dbar2betacontractionD'_j')()
printbr(Dbar'^k'(Dbar'_j'(betavar'^j')):eq(Dbar2betacontractionU))

-- Ricci tensor, wrt barred metric ... goes too slow.

-- temp cache to save on computation time
io.stderr:write'trDHat2gammabarDDdDD...\n'
local trDHat2gammabarDDdDD = (gammabarUU'^kl' * Dhat2gammabarDDdDD'_ijkl')()
io.stderr:write'DhatLambdaUdD_DD...\n'
local DhatLambdaUdD_DD = (gammabarDD'_ki' * DhatLambdaUdD'^k_j')()
io.stderr:write'DGammaU_dot3_DGammaDDD...\n'
local DGammaU_dot3_DGammaDDD = (DGammaU'^k' * DGammaDDD'_ijk')()
io.stderr:write'DGammaUDD_dot12_DGammaDDD...\n'
local DGammaUDD_dot12_DGammaDDD = (DGammaUDD'^m_ij' * DGammaDDD'_kml')()
io.stderr:write'tr14_DGammaUDD_dot12_DGammaDDD...\n'
local tr14_DGammaUDD_dot12_DGammaDDD = (gammabarUU'^kl' * DGammaUDD_dot12_DGammaDDD'_kijl')()
io.stderr:write'DGammaUDD_dot11_DGammaDDD...\n'
local DGammaUDD_dot11_DGammaDDD = (DGammaUDD'^m_ik' * DGammaDDD'_mjl')()
io.stderr:write'tr24_DGammaUDD_dot11_DGammaDDD...\n'
local tr24_DGammaUDD_dot11_DGammaDDD = (gammabarUU'^kl' * DGammaUDD_dot11_DGammaDDD'_ikjl')()
io.stderr:write'RbarDD...\n'

local Rbarvar = var'\\bar{R}'
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
printbr(Rbarvar'_ij':eq(RbarDD))

local deltavar = var'\\delta'
local deltaUD = Tensor('^i_j', function(i,j) return i==j and 1 or 0 end)
printbr(deltavar'^i_j':eq(deltaUD))

-- Trace-free parts of RBarDD, phitermsDD, and DBar2_alphaDD

local function tracefree(x)
	local tr = (gammabarUU'^kl' * x'_kl')()
	return (x'_ij' - gammabarDD'_ij' * tr / 3)()
end

local RbarTFDD = tracefree(RbarDD)
local phitermsTFDD = tracefree(phitermsDD)
local Dbar2alphaTFDD = tracefree(Dbar2alphaDD)

-- BSSN RHS
printAndWarn'BSSN RHS'

local gammabarrhsDD = (LbetagammabarDD'_ij'
	- frac(2,3) * gammabarDD'_ij' * Dbarbetacontraction
	- 2 * alpha * AbarDD'_ij')()
printbr(gbarvar'_ij,t':eq(gammabarrhsDD))

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
printbr(Abarvar'_ij,t')
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
printbr(cf'_,t':eq(cfrhs))

local trAbar = (gammabarUU'^ij' * AbarDD'_ij')()
printbr(Abarvar'^k_k':eq(trAbar))

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
printbr(Lambdavar'^i_,t')
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
printbr(alpha'_,t':eq(alpharhs))

local betarhsU = BU'^i'()
if SHIFTADVECT then
	betarhsU = (betarhsU'^i' + betaU'^j' * betaUdupD'^i_j')()
end
printbr(betavar'^i_,t':eq(betarhsU))

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
printbr(Bvar'^i_,t')
printbr('L1', BrhsU)
printbr('L2', L2BrhsU)
printbr('L3', L3BrhsU)

-- Kronecher delta

local deltaDD = Tensor('_IJ', function(i,j) return i==j and 1 or 0 end)
printbr(deltavar'_IJ':eq(deltaDD))

local vetrhsU = (betarhsU'^i' * e'^I_i')()
printbr(vetvar'^I_,t'
	:eq(betavar'^i' * evar'^I_i')
	:eq(vetrhsU)) 

local hrhsDD = (gammabarrhsDD'_ij' * eu'_I^i' * eu'_J^j'
	+ frac(2,3) * alpha * (
		deltaDD'_IJ' + hDD'_IJ'
	) * trAbar)()
printbr(hvar'_IJ,t':eq(hrhsDD))

local L2betrhsU = (L2BrhsU'^i' * e'^I_i')()
local L3betrhsU = (L3BrhsU'^i' * e'^I_i')()
printbr(betvar'^I_,t')
printbr('L2', L2betrhsU)
printbr('L3', L3betrhsU)

local L2lambdarhsU = (L2LambdarhsU'^i' * e'^I_i')()
local L3lambdarhsU = (L3LambdarhsU'^i' * e'^I_i')()
printbr(lambdavar'^I_,t')
printbr('L2', L2lambdarhsU)
printbr('L3', L3lambdarhsU) 

local L2arhsDD = (L2ABarrhsDD'_ij' * eu'_I^i' * eu'_J^j')()
local L3arhsDD = (L3AbarrhsDD'_ij' * eu'_I^i' * eu'_J^j')()
printbr(avar'_IJ,t')
printbr('L2', L2arhsDD)
printbr('L3', L3arhsDD)

printbr(require 'symmath.tostring.MathJax'.footer)
