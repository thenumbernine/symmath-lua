#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup{MathJax={title='BSSN', useCommaDerivative=true}}

printbr"translation of BSSN_RHS.nb from Zach Etienne's SENR project, from Mathematica into Lua symmath"
printbr"found at <a href='https://math.wvu.edu/~zetienne/SENR/'>https://math.wvu.edu/~zetienne/SENR/</a>"

local SHIFTADVECT = true
local BIADVECT = true

--local CFEvolution = 'EvolvePhi'
--local CFEvolution = 'EvolveChi'
local CFEvolution = 'EvolveW'

--local CoordSystem = 'Cartesian'
--local CoordSystem = 'Cylindrical'
--local CoordSystem = 'LogRadialSphericalPolar'
local CoordSystem = 'SphericalPolar'
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

local eLens
if CoordSystem == 'Cartesian' then
	eLens = table{1, 1, 1}
elseif CoordSystem == 'Cylindrical' or CoordSystem == 'SymTP' then
	eLens = table{1, y1, 1}
elseif CoordSystem == 'SphericalPolar' or CoordSystem == 'LogRadialSphericalPolar' then
	eLens = table{y1:diff(x1)(), y1, y1 * sin(y2)}
end

printbr"Using capital letters to denote non-coordinate basis... which I'm denoting individually with hats."
printbr"Rescaling to non-coordinate basis:"
local e = Tensor('^I_i', function(i,j)
	return (i==j and eLens[i] or 0)
end)
--e:printElem'e' printbr()
printbr(var'e''^I_i':eq(e))

local eu = Tensor('_I^i', function(i,j)
	return (i==j and 1/eLens[i] or 0)
end)
printbr(var'e''_I^i':eq(eu))
--eu:printElem'e' printbr()

-- Initialize ghat_ij to zero
-- Set nonzero ghat_ij components

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

error'here ... is eps in coord or non coord basis?'

local epsDDdDD = Tensor'_jkil'
epsDDdDD['_jkil'] = hDD'_jk,il'()
printbr(var'\\epsilon''_jk,il':eq(epsDDdDD))

-- Why "DDdDdD" and why not "DDdDD"?
local DhatgammabarDDdDdD = Tensor'_jkil'
DhatgammabarDDdDdD['_ijkl'] = (DhatgammabarDDdD'_ijk,l' + 
	- DhatgammabarDDdD'_mjl' * GammahatUDD'^m_ki'
	- DhatgammabarDDdD'_iml' * GammahatUDD'^m_kj'
	- DhatgammabarDDdD'_ijm' * GammahatUDD'^m_kl')()
printbr(var'\\hat{D}_k \\hat{D}_l \\bar{\\gamma}_{ij}':eq(DhatgammabarDDdDdD))

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

local vetU = Tensor('^I', function(i)
	return var('ב^'..xns[i].name, xs)
end)

local betaU = (vetU'^I' * eu'_I^i')()
printbr(var'\\beta''^i'
	:eq(var'ב''^I' * var'e''_I^i')
	:eq(betaU))

local betU = Tensor('^I', function(i)
	return var('בּ^'..xns[i].name, xs)
end)

local BU = (betU'^I' * eu'_I^i')()
printbr(var'B''^i'
	:eq(var'בּ''^I' * var'e''_I^i')
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

-- What is "dup" vs "d"?  Why not just "BUdU"?
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
	local lambdaUdD = lambdaU'^i_,j'()
	verify(DhatLambdaUdD[3][3], (1/(r*sin(th))*(lambdaUdD[3][3] + sin(th)*lambdaU[1] + cos(th)*lambdaU[2]))())
	verify(DhatLambdaUdD[2][3], (1/r*lambdaUdD[2][3] - cos(th) * lambdaU[3])())
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

printbr(require 'symmath.tostring.MathJax'.footer)
