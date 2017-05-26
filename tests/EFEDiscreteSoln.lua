#!/usr/bin/env luajit
--[[
here's my thought:
test differerent simplified discrete spacetimes
1) solve the simplified spacetime constraint:
1.a) solve alpha_i = alpha(r_i) to minimize phi_i = ||G_ab(alpha_i) - 8 pi T_ab(alpha_i)|| 
--]]
require 'ext'
require 'symmath'.setup()
require 'symmath.tostring.MathJax'.setup{
	title='Discrete EFE funtion of alpha',
}

local t,r,theta,phi = vars('t','r','\\theta','\\phi')

Tensor.coords{
	{variables={t,r,theta,phi}},
}

local alpha = var('\\alpha', {r})
local g = Tensor('_ab', table.unpack(Matrix.diagonal(-alpha^2, 1,r^2,(r*sin(theta))^2)))
local gU = Tensor('^ab', table.unpack(Matrix.diagonal(-1/alpha^2, 1,r^-2,(r*sin(theta))^-2)))
local props = require 'symmath.physics.diffgeom'(g, gU)
props:print()
