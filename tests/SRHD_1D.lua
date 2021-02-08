#! /usr/bin/env luajit
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='SRHD 1D'}}

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

-- TODO an expression function for extracting all variables, then just W = var('W', WDefLhs:vars())
local W = var('W', {vx})
local WDef = W:eq(1/sqrt(1-vx^2))
printbr(WDef..' = Lorentz factor')
local vxSq_for_W = (vx^2):eq(1-1/W^2)
printbr(vxSq_for_W..' = velocity in terms of Lorentz factor')

local P = var('P', {gamma, rho, eInt})	
printbr(P..' = pressure')

local PDef_idealGas = P:eq((gamma - 1) * rho * eInt)
printbr(PDef_idealGas..' = pressure for an ideal gas')

local h = var('h', {eInt, P, rho})
local hDef = h:eq(1 + eInt + P/rho)
printbr(hDef..' = internal specific enthalpy')
-- [[
local hDefIdealGas = hDef:subst(PDef_idealGas)()
printbr(hDefIdealGas..' = internal specific enthalpy for an ideal gas')
-- TODO fix the :solve function
--local eInt_for_h_idealGas = hDefIdealGas:solve(eInt)
local eInt_for_h_idealGas = ((hDefIdealGas-1)/gamma)():switch()
printbr(eInt_for_h_idealGas..' = internal specific energy in terms of enthalpy')
--]]
local eInt_for_h = (hDef-1-P/rho)():switch()
printbr(eInt_for_h)

local D = var'D'
local DDef = D:eq(rho*W)
printbr(DDef..' = density')

local Sx = var'S^x'
local SxDef = Sx:eq(rho*h*W^2*vx)
printbr(Sx..' = momentum')

local tau = var'\\tau'
local tauDef = tau:eq(rho*h*W^2-P-rho*W)
printbr(tau..' = total energy density')

local cons = table{D, Sx, tau}
for i=1,#cons do cons[i]:setDependentVars(prims:unpack()) end

local U_for_cons = Matrix(cons):transpose()
printbr'conservatives:'
printbr(var'U''^i':eq(U_for_cons))

local UDef = U_for_cons:subst(DDef, SxDef, tauDef)
printbr'conservative definitions:'
printbr(var'U''^i':eq(UDef))

printbr'...in terms of primitives:'
UDef = UDef:subst(hDef)
UDef = UDef:subst(PDef_idealGas)	-- for a particular equation of state
UDef = UDef:subst(WDef)
printbr(var'U''^i':eq(UDef))

local dU_dw = var'U^i':diff(var'w^j')
local dU_dw_def = Matrix(range(3):map(function(i)
	return range(3):map(function(j)
		return UDef[i][1]:diff(prims[j])
	end)
end):unpack())
	:simplify()
	:subst(vxSq_for_W)()
	:replace(sqrt(1/W^2),1/W)()	-- really?  can't simplify this?
	:replace((1/W^2)^frac(3,2),1/W^3)()
	:replace(vx^2,1-1/W^2)()
	--[[ useful when not computing the ideal gas pressure
	:replace(eInt, eInt_for_h:rhs(), function(expr)
		return Derivative:isa(expr)
	end)()
	--]]
	:subst(eInt_for_h_idealGas)()
printbr'change in conservative vars wrt primitives:'
printbr(dU_dw:eq(dU_dw_def))

local F_for_cons = Matrix{D*vx, Sx*vx - P, Sx-D*vx}:transpose()
printbr'flux in terms of conservative variables:'
printbr(var'F''^i':eq(F_for_cons))
printbr'flux in terms of primitive variables:'
F_for_prim = F_for_cons:subst(tauDef, SxDef, DDef, hDef)
F_for_prim = F_for_prim:subst(PDef_idealGas)
F_for_prim = F_for_prim:subst(WDef)()
printbr(var'F''^i':eq(F_for_prim))
local dF_dw = Matrix(range(3):map(function(i)
	return range(3):map(function(j)
		return F_for_prim[i][1]:diff(prims[j])
	end)
end):unpack())()
	:subst(vxSq_for_W)()
	:replace(sqrt(1/W^2),1/W)()	-- really?  can't simplify this?
	:replace((1/W^2)^frac(3,2),1/W^3)()
	:replace((1/W^2)^2,1/W^4)()
	--[[ general
	:replace(eInt, eInt_for_h:rhs(), function(expr)
		return Derivative:isa(expr)
	end)()
	--]]
	:subst(eInt_for_h_idealGas)()
printbr'change in flux wrt primitives:'
printbr(var'F^i':diff(var'w^j'):eq(dF_dw))

--[[ dying
local dF_dU = (dF_dw * dU_dw_def:inverse())()
printbr'change in flux wrt conservatives:'
printbr(var'F^i':diff(var'w^j'):eq(dF_dU))
--]]
