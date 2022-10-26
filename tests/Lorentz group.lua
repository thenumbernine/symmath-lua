#!/usr/bin/env luajit
--[[
TODO
FINISHME
I thought I'd follow the "rotation group" worksheet but for 4D instead of 3D 
--]]
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, implicitVars=true, MathJax={title='Lorentz group'}}

-- TODO make print print brs by default
local sameline = print
local print = printbr

local t,x,y,z = vars('t','x','y','z')

local embedded = {t,x,y,z}

local eta = var'\\eta'
local gamma = var'\\gamma'
local theta = var'\\theta'
local phi = var'\\phi'
local psi = var'\\psi'

local baseCoords = table{gamma, psi, theta, phi}

local etaval = Matrix.diagonal(1, -1, -1, -1)
print(eta:eq(etaval))

local Kx = Matrix(
	{0,-1,0,0},
	{1,0,0,0},
	{0,0,0,0},
	{0,0,0,0})
local Ky = Matrix(
	{0,0,-1,0},
	{0,0,0,0},
	{1,0,0,0},
	{0,0,0,0})
local Kz = Matrix(
	{0,0,0,-1},
	{0,0,0,0},
	{0,0,0,0},
	{1,0,0,0})
local Jx = Matrix(
	{0,0,0,0},
	{0,0,0,0},
	{0,0,0,-1},
	{0,0,1,0})
local Jy = Matrix(
	{0,0,0,0},
	{0,0,0,1},
	{0,0,0,0},
	{0,-1,0,0})
local Jz = Matrix(
	{0,0,0,0},
	{0,0,-1,0},
	{0,1,0,0},
	{0,0,0,0})
local generators = table{Kx, Ky, Kz, Jx, Jy, Jz}
local gennames = table{'K_x', 'K_y', 'K_z', 'J_x', 'J_y', 'J_z'}
sameline(K' _x ^\\sharp _\\flat':eq(Kx))
sameline(K' _y ^\\sharp _\\flat':eq(Ky))
print(K' _z ^\\sharp _\\flat':eq(Kz))
sameline(J' _x ^\\sharp _\\flat':eq(Jx))
sameline(J' _y ^\\sharp _\\flat':eq(Jy))
print(J' _z ^\\sharp _\\flat':eq(Jz))

sameline(K' _x ^\\sharp ^\\sharp':eq((Kx * etaval)()))
sameline(K' _y ^\\sharp ^\\sharp':eq((Ky * etaval)()))
print(K' _z ^\\sharp ^\\sharp':eq((Kz * etaval)()))
sameline(J' _x ^\\sharp ^\\sharp':eq((Jx * etaval)()))
sameline(J' _y ^\\sharp ^\\sharp':eq((Jy * etaval)()))
print(J' _z ^\\sharp ^\\sharp':eq((Jz * etaval)()))



local function getname(m)
	if m == Matrix:zeros{4,4} then return 0 end
	for i,g in ipairs(generators) do
		if (m - g)() == Matrix:zeros{4,4} then return var(gennames[i]) end
		if (m + g)() == Matrix:zeros{4,4} then return -var(gennames[i]) end
	end
	return m
end

--[[
print(Matrix:lambda({#generators+1,#generators+1}, function(a,b)
	if a==1 and b==1 then return var'\\cdot' end
	if a==1 then return var(gennames[b-1]) end
	if b==1 then return var(gennames[a-1]) end
	return getname(((generators[a-1] * etaval * generators[b-1])()))
end))
--]]
print(table(Matrix:lambda({#generators+1,#generators+1}, function(a,b)
	if a==1 and b==1 then return var'[\\cdot,\\cdot]' end
	if a==1 then return var(gennames[b-1]) end
	if b==1 then return var(gennames[a-1]) end
	local Ki = generators[a-1]
	local Kj = generators[b-1]
	return getname((Ki * etaval * Kj - Kj * etaval * Ki)())
end), {rowsplits={1}, colsplits={1}}):setmetatable(Matrix))
--[[
print(Matrix:lambda({#generators+1,#generators+1}, function(a,b)
	if a==1 and b==1 then return var'\\{\\cdot,\\cdot\\}' end
	if a==1 then return var(gennames[b-1]) end
	if b==1 then return var(gennames[a-1]) end
	local Ki = generators[a-1]
	local Kj = generators[b-1]
	return getname((Ki * etaval * Kj + Kj * etaval * Ki)())
end))
--]]

-- rotations ...

local RtM = (Kx * gamma)():exp()
-- TODO ... substitute up front, like is already going on in the antisymmetric generators' exps
-- cosh(gamma) = (exp(gamma) + exp(-gamma))/2
local coshdef = cosh(gamma):eq( ((exp(gamma) + exp(-gamma))/2))()
print(coshdef)
print(coshdef:solve(exp(2*gamma)))
RtM[1][1] = RtM[1][1]:subst(  coshdef:solve(exp(2*gamma)) )()
RtM[2][2] = RtM[2][2]:subst(  coshdef:solve(exp(2*gamma)) )()
local sinhdef = sinh(gamma):eq( ((exp(gamma) - exp(-gamma))/2))()
print(sinhdef)
print(sinhdef:solve(exp(-1*gamma)))
print(sinhdef:solve(exp(2*gamma)))
RtM[1][2] = RtM[1][2]:subst( sinhdef:solve(exp(2*gamma)) )()
RtM[2][1] = RtM[2][1]:subst( sinhdef:switch() )()

local RxM = (Jx * theta)():exp()
local RyM = (Jy * psi)():exp()
local RzM = (Jz * phi)():exp()
local function Rt(v) return RtM:replace(gamma, v) end
local function Rx(v) return RxM:replace(theta, v) end
local function Ry(v) return RyM:replace(psi, v) end
local function Rz(v) return RzM:replace(phi, v) end

print(R'_t':eq(Rt(gamma)))
print(R'_x':eq(Rx(theta)))
print(R'_y':eq(Ry(psi)))
print(R'_z':eq(Rz(phi)))

print[[$P =  R_t(\gamma) R_z(\psi) R_x(\theta) R_z(\phi) = $]]
P = (Rt(gamma) * Rz(psi) * Rx(theta) * Rz(phi))()
print(var'P':eq(P))


-- the e stuff is frustrating
do return end



local dP = baseCoords:map(function(theta_i,i)
	return (P:diff(theta_i)())
end)
for i,theta_i in ipairs(baseCoords) do 
	printbr(var'P':diff(theta_i):eq(dP[i]))
end

-- next step is to determine the linear combination of derivatives of P wrt its 4 parameters that are required to make up each generator left-times P

-- e_a P = e_a^I d/dtheta^I P = K_I * P
local eP = generators:map(function(Ki,i) 
	--return ((R(t):diff(t)() * P)():replace(t,0))
	-- meh, this works too, right?
	local ePi = (Ki * P)()
	printbr((K(' _'..embedded[i].name) * var'P'):eq(ePi))
	return ePi 
end)

for i=1,4 do
	print(
		symmath.op.add(
			range(4):mapi(function(j)
				return e(' _'..embedded[i].name..' ^'..baseCoords[j].name) * var'P':diff(baseCoords[j])
			end):unpack()
		):eq((K(' _'..embedded[i].name) * var'P'))
	)
end

-- unraveled d/dtheta^I P matrices
--local dPm = Matrix(range(4*4):map(function(ij)
local dPm = Matrix(range(1,4*4,4+1):map(function(ij)
	local i, j = math.floor((ij-1)/4)+1, (ij-1)%4+1 return range(4):map(function(k)
		return dP[k][i][j]
	end)
end):unpack())

-- e_a^I coefficients of e_a, as a matrix
-- here's the variables
local emv = Matrix:lambda({4,4}, function(i,j)
	return var('{e_'..embedded[j].name..'}^{'..baseCoords[i].name..'}')
end)

-- unraveled e_a(P) matrices
--local ePm = Matrix(range(4*4):map(function(ij)
local ePm = Matrix(range(1,4*4,4+1):map(function(ij)
	local i, j = math.floor((ij-1)/4)+1, (ij-1)%4+1
	return range(4):map(function(k)
		return eP[k][i][j]
	end)
end):unpack())

-- matrix representation of (d/dtheta^I P)_ij e_b^I = e_a(P)_ij
printbr((dPm * emv):eq(ePm))
-- so emv = dPm^-1 * ePm

-- the trig stuff is slowing me down
-- what if i just replace it with vars?
dPm = Matrix:lambda(dPm:dim(), function(i,j)
	return Constant.isValue(dPm[{i,j}], 0) and 0 or var'A'('_'..i..j)
end)
ePm = Matrix:lambda(ePm:dim(), function(i,j)
	return Constant.isValue(ePm[{i,j}], 0) and 0 or var'B'('_'..i..j)
end)
printbr((dPm * emv):eq(ePm))

-- [[ using a pseudoinverse
local emvsoln
do
	--local APlus, determinable = dPm:pseudoInverse()
	local dPmInv, ARemaining, determinable = dPm:inverse()
	if not determinable then
		printbr"the pseudoinverse was not determinable"
	end
	printbr(emv:eq(dPmInv * ePm))
	emvsoln = (dPmInv * ePm)()
	printbr(emv:eq(emvsoln))
end
--]]
--[[ attempting a rectangular linear solver ...
local results = table.pack(dPm:inverse(ePm, nil, true))
for i=1,results.n do
	printbr(i,results[i])
end
local emvsoln = results[1]
printbr(emv:eq(emvsoln))
--]]
