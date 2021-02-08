#! /usr/bin/env luajit
require 'ext'
require 'symmath'.setup{implicitVars=true, MathJax={title='uniform field - spherical', usePartialLHSForDerivative=true, pathToTryToFindMathJax='..'}}

local t, r, theta, phi = vars('t', 'r', '\\theta', '\\phi')
local coords = {t, r, theta, phi}

Tensor.coords{
	{variables=coords},
	{symbols='t', variables={t}},
	{symbols='r', variables={r}},
	--{symbols='theta', variables={theta}},
	{symbols='h', variables={theta}},
	--{symbols='phi', variables={phi}},
	{symbols='p', variables={phi}},
}

--[[
local xa = Tensor('^a', t, r, theta, phi)
xa:print'x'
printbr()

local xI = Tensor('^I', t, x, y, z)
local xIa = Tensor('^I', 
	sqrt(a) * t,
	sqrt(b) * r * cos(phi) * sin(theta),
	sqrt(b) * r * sin(phi) * sin(theta),
	sqrt(b) * r * cos(theta))
printbr(var'x''^I':eq(xI):eq(xIa))

local eta = Tensor('_IJ', table.unpack(Matrix.diagonal(-1, 1, 1, 1)))
eta:print'\\eta'
printbr()

--local eIa = (xIa'^I_,a')()	-- applying _,a is lowering I as well ...
local eIa = Tensor'_a^I'
eIa['_a^I'] = (xIa'^I_,a')()
eIa:print'e'
printbr()

local g = (eIa'_a^I' * eIa'_b^J' * eta'_IJ')()
g:print'g'
printbr()
printbr'...I need to change $x^I$ to get the $b$ off of the $d\\theta^2$ and $d\\phi^2$'
--]]

local g = Tensor'_ab'
-- [[
g['_tt'] = var('a', {r})
g['_rr'] = var('b', {r})
g['_hh'] = r^2 
g['_pp'] = r^2 * sin(theta)^2
--]]
g:print'g'
printbr()

local gU = Tensor('^ab', table.unpack(( Matrix.inverse(g) )))
gU:print'g'
printbr()

local ConnFromMetric = Tensor'_abc'
ConnFromMetric['_abc'] = (frac(1,2) * (g'_ab,c' + g'_ac,b' - g'_bc,a'))()	-- ... plus commutation? in this case I have a symmetric Conn so I don't need comm
ConnFromMetric = (gU'^ad' * ConnFromMetric'_dbc')()
ConnFromMetric:print'\\Gamma'
printbr()

local RiemannExpr = var'\\Gamma''^a_bd,c' - var'\\Gamma''^a_bc,d' 
	+ var'\\Gamma''^a_ec' * var'\\Gamma''^e_bd' - var'\\Gamma''^a_ed' * var'\\Gamma''^e_bc'
	- var'\\Gamma''^a_be' * (var'\\Gamma''^e_dc' - var'\\Gamma''^e_cd')

local RiemannFromManualMetric = Tensor'^a_bcd'
RiemannFromManualMetric['^a_bcd'] = RiemannExpr:replace(var'\\Gamma', ConnFromMetric)()

local RicciFromManualMetric = Tensor'_ab'
RicciFromManualMetric['_ab'] = RiemannFromManualMetric'^c_acb'()
printbr'Ricci from manual metric'
RicciFromManualMetric:print'R'
printbr()

local FaradayFromMetric = require 'symmath.physics.Faraday'{g=g, gU=gU}
	:map(function(expr) if abs:isa(expr) then return expr[1] end end)()
printbr'Faraday in spherical geometry'
FaradayFromMetric:print'F'
printbr()

local StressEnergyFromMetric = require 'symmath.physics.StressEnergy'.EM{F=FaradayFromMetric, g=g, gU=gU}()
printbr'stress-energy in spherical geometry'
printbr(var'T''_ab':eq(StressEnergyFromMetric))

StressEnergyFromMetric = StressEnergyFromMetric
	:replace(var'B_{r}', 0)
	:replace(var'B_{\\theta}', 0)
	:replace(var'B_{\\phi}', 0)
	:simplify()
printbr'...for electric field in x-direction and no magnetic field:'
printbr'TODO convert a constant direction into these new spherical coordinates'
printbr(var'T''_ab':eq(StressEnergyFromMetric))
