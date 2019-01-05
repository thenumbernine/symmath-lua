#! /usr/bin/env luajit
require 'ext'
require 'symmath'.setup()
require 'symmath.tostring.MathJax'.setup()

local x,y,z = vars('x', 'y', 'z')
local xs = table{x,y,z}

-- primitives:

local rho = var'\\rho'

local vs = xs:map(function(x) return var('v_'..x.name) end)
local v_x, v_y, v_z = vs:unpack()

local eInt = var'e_{int}'

local prims = table{rho, v_x, v_y, v_z, eInt}

local vSq = var('v^2', vs)
local vSq_from_v = vSq:eq(v_x^2 + v_y^2 + v_z^2)

local dvSq_dv_defs = vs:map(function(v) return vSq_from_v:diff(v)() end)
for _,eq in ipairs(dvSq_dv_defs) do printbr(eq) end

local W = var('W', vs)
local W_from_v = W:eq( 1 / sqrt(1 - v_x^2 - v_y^2 - v_z^2) )
local W_from_v = W:eq( 1 / sqrt(1 - vSq) )
printbr(W_from_v)

local invLorentzSq_from_W = ((1 / W_from_v)^2)():switch()
printbr(invLorentzSq_from_W)

local dW_dv_defs = vs:map(function(v) 
	return W_from_v:diff(v)():subst(invLorentzSq_from_W, dvSq_dv_defs:unpack())()
end)
for _,eq in ipairs(dW_dv_defs) do printbr(eq) end

--printbr(W_from_v:diff(v_x)())

local P = var('P', {rho, eInt})

local gamma = var'\\gamma'
local P_def = P:eq((gamma - 1) * rho * eInt)
printbr(P_def)

local dP_drho_def = P_def:diff(rho)()
printbr(dP_drho_def)

local dP_deInt_def = P_def:diff(eInt)()
printbr(dP_deInt_def)
printbr()

local h = var('h', {eInt})
local h_def = h:eq(1 + eInt + P / rho)
printbr(h_def)

local h_from_prim = h_def:subst(P_def)()
printbr(h_from_prim)

local dh_deInt_def = h_from_prim:diff(eInt)()
printbr(dh_deInt_def)

local D = var('D', prims)
local D_from_rho_W = D:eq(rho * W)
printbr(D_from_rho_W) 

local D_from_rho_v = D_from_rho_W:subst(W_from_v)
printbr(D_from_rho_v) 

local Ss = xs:map(function(x) return var('S_'..x.name, prims) end)
local S_x, S_y, S_z = Ss:unpack()

local S_def = Matrix(Ss):T():eq(rho * h * W^2 * Matrix(vs):T())()
printbr(S_def)

--S_def = S_def:subst(h_from_prim)()
--printbr(S_def)

local tau = var('\\tau', prims)
local E = var'E'
local tau_from_E_D = tau:eq(E - D)
printbr(tau_from_E_D)

local tau_def = tau:eq(rho * h * W^2 - P - D)
printbr(tau_def)

local U = var'U'
local cons_def = U:eq(Matrix{D, S_x, S_y, S_z, tau}:T())
printbr(cons_def)

local F_x = var'F_x'
local F_x_def = F_x:eq(Matrix{D * v_x, S_x * v_x - P, S_y * v_x, S_z * v_x, S_x - D * v_x}:T())
printbr(F_x_def)

--	dD/drho

local dD_drho_def = D_from_rho_W:diff(rho)()
printbr(dD_drho_def)

--	dD/dv

local dD_dv_def = Matrix:lambda({3,1}, function(i)
	return D:diff(vs[i])
end):eq(Matrix:lambda({3,1}, function(j)
	return D_from_rho_W[2]:diff(vs[j])():subst(dW_dv_defs:unpack())
end))
printbr(dD_dv_def)

--	dD/deInt

local dD_deInt_def = D_from_rho_v:diff(eInt)()
printbr(dD_deInt_def)

--	dS/drho

local dS_drho_def = S_def:diff(rho)()
printbr(dS_drho_def)

local dS_dv_def = Matrix:lambda({3,3}, function(i,j)
	return Ss[i]:diff(vs[j])
end):eq(Matrix:lambda({3,3}, function(i,j)
	return S_def[2][i][1]:diff(vs[j])():subst(dW_dv_defs:unpack())()
end))
printbr(dS_dv_def)

local dS_deInt_def = S_def:diff(eInt)():subst(dh_deInt_def)
printbr(dS_deInt_def)

--	dtau/drho

local dtau_drho_def = tau_def:diff(rho)()
printbr(dtau_drho_def)

dtau_drho_def = dtau_drho_def:subst(dD_drho_def, dP_drho_def)()
printbr(dtau_drho_def)

--	dtau/dv

local dtau_dv_def = Matrix:lambda({3,1}, function(i)
	return tau:diff(vs[i])
end):eq(Matrix:lambda({3,1}, function(j)
	return tau_def[2]:diff(vs[j])()
		:subst(dW_dv_defs:unpack())
		:subst(dD_dv_def:unravel():unpack())()
end))
printbr(dtau_dv_def)

--	dtau/deInt

local dtau_deInt_def = tau_def:diff(eInt)()
printbr(dtau_deInt_def)

dtau_deInt_def = dtau_deInt_def:subst(dD_deInt_def, dh_deInt_def, dP_deInt_def)()
printbr(dtau_deInt_def)

local dcons_dprim = U:diff(W):eq(Matrix(
	{dD_drho_def[2], dD_dv_def[2][1][1], dD_dv_def[2][2][1], dD_dv_def[2][3][1], dD_deInt_def[2]},
	{dS_drho_def[2][1][1], dS_dv_def[2][1][1], dS_dv_def[2][1][2], dS_dv_def[2][1][3], dS_deInt_def[2][1][1]},
	{dS_drho_def[2][2][1], dS_dv_def[2][2][1], dS_dv_def[2][2][2], dS_dv_def[2][2][3], dS_deInt_def[2][2][1]},
	{dS_drho_def[2][3][1], dS_dv_def[2][3][1], dS_dv_def[2][3][2], dS_dv_def[2][3][3], dS_deInt_def[2][3][1]},
	{dtau_drho_def[2], dtau_dv_def[2][1][1], dtau_dv_def[2][2][1], dtau_dv_def[2][3][1], dtau_deInt_def[2]}
))
printbr(dcons_dprim)

local dFx_dprim = F_x:diff(W):eq(Matrix:lambda({5,5}, function(i,j)
	return F_x_def[2][i][1]:diff(prims[j])()
		:subst(
			table{
				dP_drho_def, dP_deInt_def,
				dD_drho_def, dD_deInt_def,
			}:append(
				dD_dv_def:unravel(),
				dS_drho_def:unravel(),
				dS_dv_def:unravel(),
				dS_deInt_def:unravel()
			):unpack()
		)()
end))
printbr(dFx_dprim)



--[[
printbr"proof of orthogonality of A:"
printbr((A_def[2] * AInv_def[2]):subst(vSq_from_v)())
--]]

-- derived by hand, since the automatic inverse() function on both this and maxima are crashing

--[[
do
	local a = var'a'
	local c = var'c'
	
	local A = Matrix:lambda({3,3}, function(i,j)
		return (i==j and c or 0) + a * vs[i] * vs[j]
	end)()
	printbr(var'A':eq(A))

	local AInv = Matrix:lambda({3,3}, function(i,j)
		return 1/c * ( (i==j and 1 or 0) - vs[i] * vs[j] / (vSq + c / a))
	end)
	printbr((var'A'^-1):eq(A:inverse()))
	
	printbr((var'A' * var'A'^-1):eq( (A * AInv)():subst(vSq_from_v)() ))
end
--]]

local Phi = var'\\Phi'
local Phi_def = Phi:eq(rho * (W^2 * gamma - (gamma - 1)))
printbr(Phi_def)

--[[
local A_def = var'A':eq(Matrix:lambda({3,3}, function(i,j)
	return ((i==j and (h * Phi / rho) or 0) - (gamma + h) * (gamma - 1) * vs[i] * vs[j]) * rho^2 * W^4
end)())
printbr(A_def)
--]]

local AInv_def = (var'A'^-1):eq(Matrix:lambda({3,3}, function(i,j)
	return (
		(i == j and 1 or 0) 
		- vs[i] * vs[j] / (
			vSq 
			+ (h * Phi / rho) / ((gamma + h) * (gamma - 1))
		)
	) / (rho * W^4 * h * Phi)
end)())
printbr(AInv_def)

local AInv_v = (AInv_def[2] * Matrix(vs):T())()
printbr((var'A'^-1 * var'v'):eq(AInv_v)) 

local v_AInv_v = (Matrix(vs) * AInv_v)()[1][1]
printbr((var'v' * var'A'^-1 * var'v'):eq(v_AInv_v)) 

local dprim_dcons = W:diff(U):eq(Matrix(
	{
		1/W - v_AInv_v * rho^2 * rho^2 * W^3 * (W * gamma - (gamma - 1)),
		-rho^2 * W^2 * Phi * AInv_v[1][1],
		-rho^2 * W^2 * Phi * AInv_v[2][1],
		-rho^2 * W^2 * Phi * AInv_v[3][1],
		v_AInv_v,
	},
	{
		-AInv_v[1][1] * rho * W * (W * gamma - (gamma - 1)),
		Phi * AInv_def[2][1][1],
		Phi * AInv_def[2][1][2],
		Phi * AInv_def[2][1][3],
		-rho * gamma * W^2 * AInv_v[1][1],
	},
	{
		-AInv_v[2][1] * rho * W * (W * gamma - (gamma - 1)),
		Phi * AInv_def[2][2][1],
		Phi * AInv_def[2][2][2],
		Phi * AInv_def[2][2][3],
		-rho * gamma * W^2 * AInv_v[2][1],
	},
	{
		-AInv_v[3][1] * rho * W * (W * gamma - (gamma - 1)),
		Phi * AInv_def[2][3][1],
		Phi * AInv_def[2][3][2],
		Phi * AInv_def[2][3][3],
		-rho * gamma * W^2 * AInv_v[3][1],
	},
	{
		( 
			-(h * W^2 - W - (gamma-1) * eInt) + v_AInv_v * rho^2 * W^4 * (W * gamma - (gamma - 1)) * (h * W^2 + (gamma-1)*eInt)
		) / (
			W * Phi
		),
		-AInv_v[1][1] * rho * W^2 * (h * W^2 + (gamma-1) * eInt),
		-AInv_v[2][1] * rho * W^2 * (h * W^2 + (gamma-1) * eInt),
		-AInv_v[3][1] * rho * W^2 * (h * W^2 + (gamma-1) * eInt),
		1/Phi + 1/Phi * (gamma * rho * W^2 * v_AInv_v * rho * W^2 * (h * W^2 + (gamma-1) * eInt)),
	}
))
printbr(dprim_dcons)

printbr'verify orthogonality:'
printbr((dcons_dprim[2] * dprim_dcons[2])())
printbr((dprim_dcons[2] * dcons_dprim[2])())

--[[ too much for it
local dprim_dcons = W:diff(U):eq( dcons_dprim[2]:inverse() )
printbr(dprim_dcons)
--]]
