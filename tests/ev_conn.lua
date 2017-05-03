#! /usr/bin/env luajit
require 'ext'
local symmath = require 'symmath'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
print(MathJax.header)
local printbr = MathJax.print
MathJax.usePartialLHSForDerivative = true

local Tensor = symmath.Tensor
local TensorIndex = require 'symmath.tensor.TensorIndex'
local var = symmath.var
local vars = symmath.vars
local sqrt = symmath.sqrt

local t,x,y,z = vars('t', 'x', 'y', 'z')
local r = var('r', {x,y,z})

local spatialCoords = {x,y,z}
local coords = table{t}:append(spatialCoords)

Tensor.coords{
	{variables=coords},
	{symbols='ijklmn', variables=spatialCoords},
	{symbols='t', variables={t}},
	{symbols='x', variables={x}},
	{symbols='y', variables={y}},
	{symbols='z', variables={z}},
}

local E = var'E'

local Conn = Tensor'^a_bc'

-- [[ this gives rise to the stress-energy tensor for EM with E in the x dir and B = 0
-- to account for other E's and B's, just boost and rotate your coordinate system
-- don't forget, when transforming Conn, to use its magic transformation eqn, since it's not a real tensor
Conn[1][1][1] = sqrt(E)
Conn[2][1][1] = -sqrt(E)
Conn[1][2][1] = sqrt(E)
Conn[1][1][2] = sqrt(E)
Conn[1][3][3] = sqrt(E)
Conn[1][4][4] = sqrt(E)
--]]

--printbr(var'\\Gamma''^a_bc':eq(Conn))
--printbr(var'c''_cb^a':eq(var'\\Gamma''^a_bc' - var'\\Gamma''^a_cb'):eq((Conn'^a_bc' - Conn'^a_cb')()))

local RiemannExpr = Conn'^a_bd,c' - Conn'^a_bc,d' 
	+ Conn'^a_ec' * Conn'^e_bd' - Conn'^a_ed' * Conn'^e_bc'
	- Conn'^a_be' * (Conn'^e_dc' - Conn'^e_cd')
printbr(var'R''^a_bcd':eq(RiemannExpr:replace(Conn, var'\\Gamma')))
printbr(var'R''_ab':eq(RiemannExpr
	:replace(Conn, var'\\Gamma')
	:replace(TensorIndex{lower=false, symbol='a'}, TensorIndex{lower=false, symbol='c'})
	:replace(TensorIndex{lower=true, symbol='b'}, TensorIndex{lower=true, symbol='a'})
	:replace(TensorIndex{lower=true, symbol='d'}, TensorIndex{lower=true, symbol='b'})
	:replace(TensorIndex{lower=true, symbol='d', derivative='partial'}, TensorIndex{lower=true, symbol='b', derivative='partial'})
))

for index,value in Conn:iter() do
	local a,b,c = table.unpack(index)
	if value ~= symmath.Constant(0) then
		print(
			var'\\Gamma'(
				'^'..coords[a].name
				..'_'..coords[b].name
				..coords[c].name
			):eq(value),',') 
	end
end
printbr()

local Riemann = Tensor'^a_bcd'
Riemann['^a_bcd'] = RiemannExpr()
--printbr(var'R''^a_bcd':eq(Riemann))

local Ricci = Riemann'^c_acb'()
print(var'R''_ab':eq(Ricci))

-- 8 pi T_ab = G_ab = R_ab - 1/2 R g_ab
-- and R = 0 for electrovac T_ab
-- so 8 pi T_ab = R_ab
print('vs desired')
local R = Tensor('_ab',
	{E, 0, 0, 0},
	{0, -E, 0, 0},
	{0, 0, E, 0},
	{0, 0, 0, E})
printbr(var'R''_ab':eq(R))
