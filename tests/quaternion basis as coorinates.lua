#!/usr/bin/env luajit
--[[
TODO
FINISHME
I thought I'd follow the "rotation group" worksheet but for 4D instead of 3D 
--]]
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, implicitVars=true, MathJax={title='quaternion basis as coordinates'}}

-- TODO make print print brs by default
local print = printbr

local t,x,y,z = vars('t','x','y','z')
local gamma = var'\\gamma'
local theta = var'\\theta'
local phi = var'\\phi'
local psi = var'\\psi'

local Kt = Matrix(
	{0,1,0,0},
	{1,0,0,0},
	{0,0,0,0},
	{0,0,0,0})
local Kx = Matrix(
	{0,0,0,0},
	{0,0,0,0},
	{0,0,0,-1},
	{0,0,1,0})
local Ky = Matrix(
	{0,0,0,0},
	{0,0,0,1},
	{0,0,0,0},
	{0,-1,0,0})
local Kz = Matrix(
	{0,0,0,0},
	{0,0,-1,0},
	{0,1,0,0},
	{0,0,0,0})
local Ks = table{Kt, Kx, Ky, Kz}

print(K'_t':eq(Kt))
print(K'_x':eq(Kx))
print(K'_y':eq(Ky))
print(K'_z':eq(Kz))

local RtM = (Kt * gamma)():exp()
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

local RxM = (Kx * theta)():exp()
local RyM = (Ky * psi)():exp()
local RzM = (Kz * phi)():exp()
local function Rt(v) return RtM:replace(gamma, v) end
local function Rx(v) return RxM:replace(theta, v) end
local function Ry(v) return RyM:replace(psi, v) end
local function Rz(v) return RzM:replace(phi, v) end

print(R'_t':eq(Rt(gamma)))
print(R'_x':eq(Rx(theta)))
print(R'_y':eq(Ry(psi)))
print(R'_z':eq(Rz(phi)))

print[[$P = Rt(\gamma) R_z(\psi) R_x(\theta) R_z(\phi) = $]]
P = (Rt(gamma) * Rz(psi) * Rx(theta) * Rz(phi))()
print(var'P':eq(P))

local embedded = {t,x,y,z}
local baseCoords = table{gamma, psi, theta, phi}
local dP = baseCoords:map(function(theta_i,i)
	return (P:diff(theta_i)())
end)
for i,theta_i in ipairs(baseCoords) do 
	printbr(var'P':diff(theta_i):eq(dP[i]))
end

-- next step is to determine the linear combination of derivatives of P wrt its 4 parameters that are required to make up each generator left-times P

-- e_a P = e_a^I d/dtheta^I P = K_I * P
local eP = Ks:map(function(Ki,i) 
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
local dPm = Matrix(range(4*4):map(function(ij)
	local i, j = math.floor((ij-1)/4)+1, (ij-1)%4+1 return range(4):map(function(k)
		return dP[k][i][j]
	end)
end):unpack())

-- e_a^I coefficients of e_a, as a matrix
-- here's the variables
local emv = Matrix(range(4):map(function(i)
	return range(4):map(function(j)
		return var('{e_'..embedded[j].name..'}^{'..baseCoords[i].name..'}')
	end)
end):unpack())

-- unraveled e_a(P) matrices
local ePm = Matrix(range(4*4):map(function(ij)
	local i, j = math.floor((ij-1)/4)+1, (ij-1)%4+1
	return range(4):map(function(k)
		return eP[k][i][j]
	end)
end):unpack())

-- matrix representation of (d/dtheta^I P)_ij e_b^I = e_a(P)_ij
printbr((dPm * emv):eq(ePm))

--[[ using a pseudoinverse
--- TODO this is too slow
local emvsoln
do
	local A = dPm
	local b = ePm
	local APlus, determinable = A:pseudoInverse()
	if not determinable then
		printbr"the pseudoinverse was not determinable"
	end
	emvsoln = (APlus * b)()
	printbr(emv:eq(APlus * b))
	printbr(emv:eq(emvsoln))
end
--]]
-- [[ attempting a rectangular linear solver ...
local results = table.pack(dPm:inverse(ePm, nil, true))
for i=1,results.n do
	printbr(i,results[i])
end
local emvsoln = results[1]
printbr(emv:eq(emvsoln))
--]]
