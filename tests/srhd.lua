#! /usr/bin/env luajit
require 'ext'
local symmath = require 'symmath'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
print(MathJax.header)

local function printbr(...)
	print(...)
	print('<br>')
end

local var = symmath.var
local vars = symmath.vars
local Matrix = symmath.Matrix
local sqrt = symmath.sqrt

local gamma = var'\\gamma'
printbr(gamma..' = heat capacity ratio')

local rho, vx, eInt = vars('\\rho', 'v^x', 'e_{int}')
printbr(rho..' = rest-mass density')
printbr(vx..' = 3-velocity')
printbr(eInt..' = rest-mass internal specific energy')
local prims = table{rho, vx, eInt}
local w = Matrix(prims):transpose()
printbr'primitives:'
printbr(var'w''^i':eq(w))

local D, Sx, tau = vars('D', 'S^x', '\\tau')
printbr(D..' = density')
printbr(Sx..' = momentum')
printbr(tau..' = total energy density')
local cons = table{D, Sx, tau}
local U_for_cons = Matrix(cons):transpose()
for i=1,#U_for_cons do U_for_cons[i][1]:depends(prims:unpack()) end
printbr'conservatives:'
printbr(var'U''^i':eq(U_for_cons))

-- TODO an expression function for extracting all variables, then just W = var('W', WDefLhs:vars())
local W = var('W', {vx})
local WDef = W:eq(1/sqrt(1-vx^2))
printbr(WDef..' = Lorentz factor')
local vxSq_for_W = (vx^2):eq(1-1/W^2)
printbr(vxSq_for_W..' = velocity in terms of Lorentz factor')

local P = var('P', {gamma, rho, eInt})	
printbr(P..' = pressure')

local PDef = P:eq((gamma - 1) * rho * eInt)
printbr(PDef..' = pressure for an ideal gas')

local h = var('h', {eInt, P, rho})
local hDef = h:eq(1 + eInt + P/rho)
printbr(h:eq(hDef)..' = internal specific enthalpy')
--[[
local hDefIdealGas = h:eq(hDef:subst(PDef))()
printbr(hDefIdealGas..' = internal specific enthalpy for an ideal gas')
-- TODO fix the :solve function
--local eInt_for_h = hDefIdealGas:solve(eInt)
local eInt_for_h_gamma = ((hDefIdealGas-1)/gamma)():switch()
printbr(eInt_for_h_gamma..' = internal specific energy in terms of enthalpy')
--]]

local UDef = Matrix{
	rho*W,
	rho*h*W^2*vx,
	rho*h*W^2-P-rho*W
}:transpose()

printbr'conservative definitions:'
printbr(var'U''^i':eq(UDef))

printbr'...in terms of primitives:'
UDef = UDef:subst(hDef)
--UDef = UDef:subst(PDef)	-- for a particular equation of state
UDef = UDef:subst(WDef)
printbr(var'U''^i':eq(UDef))

local dU_dw = var'U^i':diff(var'w^j')
local dU_dw_def = Matrix(range(3):map(function(i)
	return range(3):map(function(j)
		return UDef[i][1]:diff(prims[j])
	end)
end):unpack())
printbr'change in conservative vars wrt change in primitives:'
printbr(dU_dw:eq(dU_dw_def))
printbr'...simplified:'
dU_dw_def = dU_dw_def:simplify()
	:subst(vxSq_for_W)()
	:replace(sqrt(1/W^2),1/W)()	-- really?  can't simplify this?
	:replace((1/W^2)^symmath.divOp(3,2),1/W^3)()
--	:subst(eInt_for_h_gamma)()
	:replace(vx^2,1-1/W^2)()
printbr(dU_dw:eq(dU_dw_def))

print(MathJax.footer)
