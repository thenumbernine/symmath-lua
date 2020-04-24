#!/usr/bin/env lua
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, implicitVars=true, fixVariableNames=true, MathJax={title='spinors'}}

local i = var'i'	-- looks better than 0+1i

local xyz = table{x,y,z}
Tensor.coords{
	{
		symbols = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
		variables = {tz, xy},
	},
	{
		symbols = 'abcdefghijklmnopqrstuvw',
		variables = xyz,
	},
	{symbols = 'x', variables = {x}},
	{symbols = 'y', variables = {y}},
	{symbols = 'z', variables = {z}},
}

local eps = Tensor('_AB', {0, 1}, {-1, 0})
local epsU = Tensor('^AB', table.unpack(eps))

Tensor.metric(eps, epsU, 'A')

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
