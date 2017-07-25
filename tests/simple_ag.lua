#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup{implicitVars=true, MathJax=true}
Tensor.coords{{variables={t,x,y,z}}, {variables={T,X,Y,Z}, symbols='ABCDEFGHIJKLMNOPQRSTUVWXYZ'}}
local eta = Tensor('_IJ', table.unpack(Matrix.diagonal(-1,1,1,1)))
Tensor.metric(eta, eta, 'I')
eta:printElem'\\eta' printbr()

local units = require 'symmath.physics.units'()
local b_def = b:eq(9.8 * units.m / units.s^2)
printbr(b_def)
symmath.simplifyConstantPowers = true
b_def = b_def:subst(units.s_in_m)()
printbr(b_def)

-- [[
local e = Tensor('_u^I',
	{sqrt(1 - 2*b*z), 0, 0, 0},
	{0, 1, 0, 0},
	{0, 0, 1, 0},
	{0, 0, 0, 1})
e:print'e' printbr()
local g = (e'_u^I' * e'_vI')()
--]]
--[[
local g = Tensor('_ab', table.unpack(Matrix.diagonal(-1 - 2 * b * z, 1, 1, 1)))
--]]
local dg = require 'symmath.physics.diffgeom'(g)
--[[
dg.g:print'g' printbr()
dg.gU:printElem'g' printbr()
dg.GammaL:printElem'\\Gamma' printbr()
dg.Gamma:printElem'\\Gamma' printbr()
--]]
dg:print()
