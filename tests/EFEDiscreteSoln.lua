#!/usr/bin/env luajit
--[[
here's my thought:
test differerent simplified discrete spacetimes
1) solve the simplified spacetime constraint:
1.a) solve alpha_i = alpha(r_i) to minimize phi_i = ||G_ab(alpha_i) - 8 pi T_ab(alpha_i)|| 
--]]
require 'ext'
require 'symmath'.setup{implicitVars=true}
require 'symmath.tostring.MathJax'.setup{
	title='Discrete EFE funtion of alpha',
}

local t,r,theta,phi = vars('t','r','\\theta','\\phi')
local coords = {t,r,theta,phi}
Tensor.coords{
	{variables=coords},
}

local alpha = var('\\alpha', {r})
local g = Tensor('_ab', table.unpack(Matrix.diagonal(-alpha^2, 1,r^2,(r*sin(theta))^2)))
local gU = Tensor('^ab', table.unpack(Matrix.diagonal(-1/alpha^2, 1,r^-2,(r*sin(theta))^-2)))
g:print'g'
gU:print'g'

local props = class(
	require 'symmath.physics.diffgeom'
	--{print=printbr}
)(g, gU)
--props:print()
local EinsteinLL = props.Einstein'_ab'()
printbr(EinsteinLL:print'G')

-- ok now we have alpha, we have G_ab as a function of alpha ...
local Phi = 
	Integral(
		Integral(
			Integral(
				Sum(Sum(G'_ab' - 8 * pi * T'_ab',a,1,4),b,1,4),
			r, 0, R),
		phi, 0, pi),
	theta, 0, 2 * pi)
printbr(var'\\Phi':eq(Phi))
-- assume T_ab is only a function of r ...
-- and is diagonal ...
local StressEnergy = Tensor('_ab', table.unpack(Matrix.diagonal(
	var('T_{tt}',{r}),
	var('T_{rr}',{r}),
	var('T_{\\theta\\theta}',{r}),
	var('T_{\\phi\\phi}',{r}))))
StressEnergy:print'T'
-- I would replace this, but let's just redefine it
Phi = nil
for a=1,4 do
	for b = 1,4 do
		if EinsteinLL[a][b] ~= Constant(0)
		or StressEnergy[a][b] ~= Constant(0)
		then
			local diffSq = (EinsteinLL[a][b] - StressEnergy[a][b])^2
			Phi = Phi and (Phi + diffSq) or diffSq
		end
	end
end
-- fixme
Phi = 4 * pi * Integral(Phi * r, r, 0, R)
printbr(var'\\Phi':eq(Phi))
