#!/usr/bin/env luajit
-- TOV spherical metric
require 'ext'
require 'symmath'.setup{
	MathJax={title='TOV metric', useCommaDerivative=true}
}

-- coordinates
local t,r,theta,phi = vars('t','r','\\theta','\\phi')

local Phi = var('\\Phi', {r})
local Lambda = var('\\Lambda', {r})

local coords = {t,r,theta,phi}
Tensor.coords{{variables = coords}}

-- schwarzschild metric in cartesian coordinates
local g = Tensor('_uv', function(u,v) 
	return u ~= v and 0
		or ({
			-e^(-2*Phi),
			e^(2*Lambda), 
			r^2, 
			r^2 * sin(theta)^2,
		})[u] 
end) 

local Props = class(require 'symmath.physics.diffgeom')
Props.verbose = true
Props.fields = table(Props.fields)
Props.fields:append{
	{
		name = 'EinsteinLL',
		symbol = 'G',
		title = 'Einstein, $\\flat\\flat$',
		calc = function(self) return self.Einstein'_ab'() end,
		display = function(self) return var'G''_ab':eq(self.EinsteinLL'_ab'()) end,
	},
	{
		name = 'RicciLL',
		symbol = 'R',
		title = 'Ricci, $\\flat\\flat$',
		calc = function(self) return self.Ricci'_ab'() end,
		display = function(self) return var'R''_ab':eq(self.RicciLL'_ab'()) end,
	},
}
local props = Props(g)

local dx = Tensor('^u', function(u)
	return var('\\dot{' .. coords[u].name .. '}')
end)
local d2x = Tensor('^u', function(u)
	return var('\\ddot{' .. coords[u].name .. '}')
end)

local A = Tensor('^i', function(i) return var('A^{'..coords[i].name..'}', coords) end)
local divVarExpr = var'A''^i_,i' + var'\\Gamma''^i_ji' * var'A''^j'
local divExpr = divVarExpr:replace(var'A', A):replace(var'\\Gamma', props.Gamma)
printbr('divergence:', divVarExpr:eq(divExpr():factorDivision())) 

printbr'geodesic:'
printbr(((d2x'^a' + props.Gamma'^a_bc' * dx'^b' * dx'^c'):eq(Tensor'^u'))())
printbr()

print(require 'symmath.tostring.MathJax'.footer)
