#!/usr/bin/env luajit
local symmath = require 'symmath'
local x = symmath.var'x'
local c = 2
local f = x^2-c
local df_dx = f:diff(x):simplify()
local xn = c
for i=1,5 do
	xn = xn - f:eval{x=xn} / df_dx:eval{x=xn}
	print(xn,math.sqrt(c))
end
