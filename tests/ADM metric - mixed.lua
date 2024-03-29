#!/usr/bin/env luajit

-- unload API into env without polluting symmath's _G
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, implicitVars=true, MathJax={title='ADM metric - mixed', usePartialLHSForDerivative=true}}

local t,x,y,z = vars('t','x','y','z')
local ijk = var'ijk'	-- not sure about this ...
local spatialCoords = {x,y,z}
local coords = {t,x,y,z}

local C = Tensor.Chart{coords=coords}
local CS = Tensor.Chart{coords=spatialCoords, symbols='ijklmn'}
local CGS = Tensor.Chart{coords={ijk}, symbols='IJKLMN'}
local CG = Tensor.Chart{coords={t,ijk}, symbols='UVW'}	-- maybe 'group' to specify that a split will happen?  but that restricts to a certain form

local alpha = var'\\alpha'
local beta = var'\\beta'
local gamma = var'\\gamma'
local g = var'g'

printbr(alpha)
printbr(beta'^i')
printbr(gamma'_ij')
printbr(gamma'^ij')

-- metric
--[[
how to handle subtensors ... 
how to we declare the indexes of a tensor to use subindexes?
if we say Tensor'_uv' for defaults uv on coords t,x,y,z then the ctor will span 4 variables ...
if we create a new set of indexes for groups of indexes ... we'd have to specify the layout beforehand (to be compatible with the current system)
if we use matrices ...
... then how will we access them in the future?
--]]
local gLLDef = g'_uv':eq(Tensor('_UV', 
	{
		-alpha^2 + beta'^k' * beta'_k',
		beta'_j',
	}, {
		beta'_i',
		gamma'_ij',
	}
))
printbr(gLLDef)

local gUUDef = g'^uv':eq(Tensor('^UV',
	{
		-1/alpha^2,
		beta'^j'/alpha^2,
	}, {
		beta'^i'/alpha^2,
		gamma'^ij' - beta'^i' * beta'^j' / alpha^2,
	}
))
printbr(gUUDef)

--[[
now if 'group' was used in the index definitions ...
I wouldn't need 'group' if I just had separate index information for grouped and non-grouped tensors
... so gamma and beta would be defined on indexes where ijk span xyz
... but g would be defined on indexes where ijk reprsent a single coordinate (which can be later expanded)

... then we could do something like this:
g = Tensor('_UV', {alpha, beta'_i'}, {beta'_j', gamma'_ij'}) 
... and then ...
printbr(g'_ij'()) to show gamma_ij
--]]
--printbr(gLLDef:rhs()'_IJ')	-- this would work if the code were in place for the notion of g'_tt' to return a scalar ... same principle

local Gamma = var'\\Gamma'
printbr(Gamma'_abc':eq((g'_ab,c' + g'_ac,b' - g'_bc,a') / 2))

os.exit()
printbr(var'\\Gamma''_abc':eq(Gamma'_abc'()))
Gamma = Gamma'^a_bc'()
printbr(var'\\Gamma''^a_bc':eq(Gamma'^a_bc'()))

local Riemann = Tensor'^a_bcd'
Riemann['^a_bcd'] = (Gamma'^a_bd,c' - Gamma'^a_bc,d' + Gamma'^a_ec' * Gamma'^e_bd' - Gamma'^a_ed' * Gamma'^e_bc')()
printbr('${R^a}_{bcd} = $'..Riemann'^a_bcd')

print_(MathJax.footer)
