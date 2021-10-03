#!/usr/bin/env lua
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, implicitVars=true, fixVariableNames=true, MathJax={title='spinors'}}

local i = var'i'	-- looks better than 0+1i

local tz = var'tz'
local xy = var'xy'
local xyz = table{x,y,z}
local chart_tx_yz = Tensor.Chart{coords={tz, xy}, symbols='ABCDEFGHIJKLMNOPQRSTUVWXYZ'}
local chart_xyz = Tensor.Chart{coords=xyz, symbols='abcdefghijklmnopqrstuvw'}
local chart_x = Tensor.Chart{coords={x}, symbols='x'}
local chart_y = Tensor.Chart{coords={y}, symbols='y'}
local chart_z = Tensor.Chart{coords={z}, symbols='z'}

local eps = Tensor('_AB', {0, 1}, {-1, 0})
local epsU = Tensor('^AB', table.unpack(eps))

chart_tx_yz:setMetric(eps, epsU)

local pauli = Tensor('_i^A_B',
	Tensor('^A_B', {0, 1}, {1, 0}),
	Tensor('^A_B', {0, -i}, {i, 0}),
	Tensor('^A_B', {1, 0}, {0, -1}))

-- kind of a messy way to pick out an individual pauli matrix
printbr(sigma'_x^A_B':eq(pauli'_x^A_B'()[1]))
-- this is the alternative, however you have to explicitly construct sub-tensors as Tensor objects
--  maybe I should do that automatically ...
for i,xi in ipairs(xyz) do
	printbr()
	printbr()
	printbr(sigma('_'..xi.name..'^A_B'):eq(pauli[i]))

	-- how about raising?
	printbr(sigma('_'..xi.name..'^AB'):eq(pauli[i]'^A_C'() * eps'^CB'() ):eq( (pauli[i]'^A_C' * eps'^CB')() ))
	printbr(sigma('_'..xi.name..'_AB'):eq(eps'_AC'() * pauli[i]'^C_B'() ):eq( (eps'_AC' * pauli[i]'^C_B')() ))
end
