#!/usr/bin/env luajit
local table = require 'ext.table'
local range = require 'ext.range'
local class = require 'ext.class'
local symmath = require 'symmath'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
print(MathJax.header)
local printbr = MathJax.print

local frac = symmath.divOp
local Tensor = symmath.Tensor
local var = symmath.var
local vars = symmath.vars

local t,x,y,z = vars('t','x','y','z')
local r,phi,theta,psi = vars('r','\\phi','\\theta','\\psi')

local baseCoords = table{psi,theta,phi}

local delta3 = symmath.Matrix:lambda({3,3}, function(i,j) return i==j and 1 or 0 end)

local cos = symmath.cos
local sin = symmath.sin
local tan = symmath.tan
local function cot(...) return cos(...) / sin(...) end

-- notice MTW uses negative rotations, then concludes with c_ab^c = -epsilon_abc 
-- turning these from negative to positive rotations results in c_ab^c = epsilon_abc 
local function Rx(theta)
	return symmath.Matrix(
		{1, 0, 0},
		{0, cos(theta), -sin(theta)},
		{0, sin(theta), cos(theta)})
end
local function Ry(theta)
	return symmath.Matrix(
		{cos(theta), 0, sin(theta)},
		{0, 1, 0},
		{-sin(theta), 0, cos(theta)})
end
local function Rz(theta)
	return symmath.Matrix(
		{cos(theta), -sin(theta), 0},
		{sin(theta), cos(theta), 0},
		{0, 0, 1})
end
local Rs = table{Rx, Ry, Rz}

--[=[ mtw's:
-- u spans rows, I spans cols
local em = { 
	{-sin(psi) * cot(theta), cos(psi), sin(psi) / sin(theta)},
	{cos(psi) * cot(theta), sin(psi), -cos(psi) / sin(theta)},
	{1, 0, 0},
}
--]=]
--[=[ mtw's, with rows rescaled to remove sin(theta) in denominator.  doesn't produce the same commutations	
local em = { 
	{-sin(psi) * cos(theta), cos(psi) * sin(theta), sin(psi)},
	{cos(psi) * cos(theta), sin(psi) * sin(theta), -cos(psi)},
	{1, 0, 0},
}
--]=]	
--[=[ mtw picked apart
local invem = symmath.Matrix(
	{0, 0, 1},
	{cos(psi), sin(psi), 0},
	{sin(theta) * sin(psi), -sin(theta) * cos(psi), cos(theta)}
)
local em = symmath.Matrix(table.unpack(invem)):inverse())
--]=]
-- [=[ mtw by construction

-- [=[ MTW uses ZXZ negative Euler angles
local P = (Rz(-psi) * Rx(-theta) * Rz(-phi))()
printbr([[$P = R_z(-\psi) R_x(-\theta) R_z(-\phi) = $]], P)
--]=]
--[=[ here's me using ZYX angles
local P = (Rz(psi) * Ry(theta) * Rx(phi))()
printbr([[$P = R_z(\psi) R_y(\theta) R_x(\phi) = $]], P)
--]=]
-- and here's me trying to remove one of the rotations
--local P = (Rz(psi) * Ry(theta))()
-- ... sure enough, I need to fix my linear system solver to handle multiple solutions 

local dP = baseCoords:map(function(theta_i,i)
	return (P:diff(theta_i)())
end)
local eP = Rs:map(function(R,i) 
	return ((R(t):diff(t)() * P)():replace(t,0))
end)

local xs = {'x','y','z'}
for i=1,3 do
	printbr([[$e_]]..i..[[(P) = \frac{\partial}{\partial t} R_]]..xs[i]..[[(t) |_{t=0} \cdot P = K_]]..xs[i]..[[ \cdot P = $]], eP[i])
end
for i,theta_i in ipairs(baseCoords) do 
	printbr(var'P':diff(theta_i):eq(dP[i]))
end
printbr(var'P':diff(psi):eq(var'e''_3' * var'P'), '?', P:diff(psi)() == e3P) 	-- e3(P) := d/dpsi P == d/dt Rz(t) * P
for i=1,3 do
	printbr([[$e_{]]..i..[[1} \frac{\partial P}{\partial \psi} + e_{]]..i..[[2} \frac{\partial P}{\partial \theta} + e_{]]..i..[[3} \frac{\partial P}{\partial \psi} = e_]]..i..[[(P) = K_]]..xs[i]..[[ \cdot P$]])
end
--[[
(ei1 d/dpsi + ei2 d/dtheta + ei3 d/dphi) P = Ri(t):diff(t) * P
solve for eij
--]]
printbr[[
$\left[\matrix{
\frac{\partial P}{\partial \psi} |
\frac{\partial P}{\partial \theta} |
\frac{\partial P}{\partial \phi}
}\right] \left[\matrix{
e_1 | e_2 | e_3
}\right] = \left[\matrix{
K_x P | K_y P | K_z P
}\right]$
]]

local dPm = symmath.Matrix(range(9):map(function(ij)
	local i, j = math.floor((ij-1)/3)+1, (ij-1)%3+1
	return range(3):map(function(k)
		return dP[k][i][j]
	end)
end):unpack())

local emv = symmath.Matrix(range(3):map(function(i)
	return range(3):map(function(j)
		return var'e'('_'..j..i)
	end)
end):unpack())

local ePm = symmath.Matrix(range(9):map(function(ij)
	local i, j = math.floor((ij-1)/3)+1, (ij-1)%3+1
	return range(3):map(function(k)
		return eP[k][i][j]
	end)
end):unpack())

printbr((dPm * emv):eq(ePm))

-- [[ using a pseudoinverse
-- A x = b
-- At A x = At b
-- TODO use (rectangular) linear system solver instead
local AtA = (dPm:transpose() * dPm)()
local Atb = (dPm:transpose() * ePm)()
printbr(( AtA * emv ):eq( Atb ))
local APlus = AtA:inverse()
local emvsoln = (APlus * Atb)()
printbr(emv:eq(emvsoln))
--]]
--[[ attempting a rectangular linear solver ...
local results = getn(dPm:inverse(ePm, nil, true))
for i=1,results.n do
	printbr(i,results[i])
end
local emvsoln = results[1]
printbr(emv:eq(emvsoln))
--]]
local em = emvsoln:transpose()

local evs = range(3):map(function(i) 
	local ei = var('e_'..i) 
	function ei:applyDiff(x)
		return range(3):map(function(j) 
			return em[i][j] * x:diff(baseCoords[j])
		end):sum()
	end
	return ei
end)
		
local title = 'rotation group'
local coords = evs
local baseCoords = baseCoords
local embedded = {x,y,z}
local flatMetric = delta3
local basis = function()
	return Tensor('_u^I', table.unpack(em))
end

print('<h3>'..title..'</h3>')

Tensor.coords{
	{variables=coords},
	{variables=embedded, symbols='IJKLMN', metric=flatMetric}
}
		
printbr('coordinates:', table.unpack(coords))
printbr('base coords:', table.unpack(baseCoords))
printbr('embedding:', table.unpack(embedded))

local eta = Tensor('_IJ', table.unpack(flatMetric))
printbr'flat metric:'
printbr(var'\\eta''_IJ':eq(eta'_IJ'()))
printbr()
Tensor.metric(eta, eta, 'I')

local e = Tensor'_u^I'

printbr'basis:'
e['_u^I'] = basis()()
printbr(var'e''_u^I':eq(e'_u^I'()))
printbr()

-- but what if this matrix isn't square?

local eUm = symmath.Matrix(table.unpack(e)):inverse():transpose()
eU = Tensor('^u_I', function(u,I) return eUm[{u,I}] or 0 end)
printbr(var'e''^u_I':eq(eU))
printbr((var'e''_u^I' * var'e''^v_I'):eq((e'_u^I' * eU'^v_I')()))
printbr((var'e''_u^I' * var'e''^u_J'):eq((e'_u^I' * eU'^u_J')()))
--[[
e_u = e_u^I d/dx^I
and e^v_J is the inverse of e_u^I 
such that e_u^I e^v_I = delta_u^v and e_u^I e^u_J = delta^I_J

[e_u, e_v] = e_u e_v - e_v e_u
	= e_u^I d/dx^I (e_v^J d/dx^J) - e_v^I d/dx^I (e_u^J d/dx^J)
	= e_u^I ( (d/dx^I e_v^J) d/dx^J + e_v^J d/dx^I d/dx^J) - e_v^I ((d/dx^I e_u^J) d/dx^J + e_u^J d/dx^I d/dx^J)
	= e_u^I (d/dx^I e_v^J) d/dx^J - e_v^I (d/dx^I e_u^J) d/dx^J
	= (e_u^I e_v^J_,I - e_v^I e_u^J_,I) d/dx^J 
	= (e_u^I (dx^a/dx^I d/dx^a e_v^J) - e_v^I (dx^a/dx^I d/dx^a e_u^J)) d/dx^J
	= (e_u^I e_v^J_,a - e_v^I e_u^J_,a) e^a_I d/dx^J
	= (delta_u^a e_v^J_,a - delta_v^a e_u^J_,a) d/dx^J
	= (e_v^J_,u - e_u^J_,v) d/dx^J
	
so for [e_u, e_v] = c_uv^w e_w = c_uv^w e_w^J d/dx^J
we find c_uv^w e_w^I = (e_v^I_,u - e_u^I_,v)
or c_uv^w = (e_v^I_,u - e_u^I_,v) e^w_I
is it just me, or does this look strikingly similar to the spin connection?
--]]

local g = (e'_u^I' * e'_v^J' * eta'_IJ')()

printbr(var'g''_uv':eq(var'e''_u^I' * var'e''_v^J' * var'\\eta''_IJ'))
printbr(var'g''_uv':eq(g'_uv'()))

local gU = Tensor'^uv'
gU['^uv'] = (eU'^u_I' * eU'^v_J' * eta'^IJ')()
printbr(var'g''^uv':eq(var'e''^u_I' * var'e''^v_J' * var'\\eta''^IJ'))
printbr(var'g''^uv':eq(gU'^uv'()))

Tensor.metric(g, gU)

local c = Tensor'_ab^c'
c['_ab^c'] = ((e'_b^I_,a' - e'_a^I_,b') * eU'^c_I')()
printbr(var'c''_ab^c':eq(c'_ab^c'()))

local cL = Tensor'_abc'
cL['_abc'] = c'_abc'()
printbr(var'c''_abc':eq(cL'_abc'()))

local dg = Tensor'_abc'
dg['_abc'] = g'_ab,c'()
printbr(var'g''_ab,c':eq(dg'_abc'()))

local GammaL = Tensor'_abc'
GammaL['_abc'] = (frac(1,2) * (dg'_abc' + dg'_acb' - dg'_bca' + cL'_abc' + cL'_acb' - cL'_bca'))()
printbr(var'\\Gamma''_abc':eq(frac(1,2)*(var'g''_ab,c' + var'g''_ac,b' - var'g''_bc,a' + var'c''_abc' + var'c''_acb' - var'c''_bca')))
printbr(var'\\Gamma''_abc':eq(GammaL'_abc'()))

local Gamma = Tensor'^a_bc'
Gamma['^a_bc'] = GammaL'^a_bc'()
printbr(var'\\Gamma''^a_bc':eq(var'g''^ad' * var'\\Gamma''_dbc'))
printbr(var'\\Gamma''^a_bc':eq(Gamma'^a_bc'()))
os.exit()

local Props = class(require 'symmath.diffgeom')
Props.print = printbr
Props.verbose = true
local props = Props(g, nil, c)
local Gamma = props.Gamma

local dx = Tensor('^u', function(u)
	return var('\\dot{' .. coords[u].name .. '}')
end)
local d2x = Tensor('^u', function(u)
	return var('\\ddot{' .. coords[u].name .. '}')
end)

local A = Tensor('^i', function(i) return var('A^{'..coords[i].name..'}', baseCoords) end)
--[[
TODO can't use comma derivative, gotta override the :applyDiff of the anholonomic basis variables
 but when doing so, you must make the embedded variables dependent on the ... variables that the anholonomic are spun off of
	i.e. if the anholonomic basis is rHat, phiHat, thetaHat, then the A^I variables must be dependent upon r, theta, phi
--]]
local divVarExpr = var'A''^i_,i' + var'\\Gamma''^i_ji' * var'A''^j'
local divExpr = divVarExpr:replace(var'A', A):replace(var'\\Gamma', Gamma)
-- TODO only simplify TensorRef, so the indexes are fixed
printbr('divergence:', divVarExpr:eq(divExpr):eq(divExpr():factorDivision())) 

printbr'geodesic:'
-- TODO unravel equaliy, or print individual assignments
printbr(((d2x'^a' + Gamma'^a_bc' * dx'^b' * dx'^c'):eq(Tensor'^u'))())
printbr()

