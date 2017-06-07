#!/usr/bin/env luajit

-- i'm too lazy to fix this, but i've got two loops when i only need one

-- explicit integration:

--[[
f = function
x = dependent variable
x0 = start
x1 = end
n = number of divisions (default 200)
--]]

local methods = {}

methods.euler = function(f, x, x0, x1, n)
	n = n or 200
	local y = f(x0)
	local dx = (x1 - x0) / n
	for i=1,n do
		local xv = i / n * (x1 - x0) + x0
		-- dy/dx = f(x)
		-- (y(x+dx) - y(x))/dx = f(x)
		-- y(x+dx) = y(x) + dx * f(x)
		y = y + dx * f(xv)
	end
	return y
end

methods.midpoint = function(f, x, x0, x1, n)
	n = n or 200
	local y = f(x0)
	local dx = (x1 - x0) / n
	for i=1,n do
		local xv = (i + .5) / n * (x1 - x0) + x0
		y = y + dx * f(xv)
	end
	return y
end

methods.trapezoid = function(f, x, x0, x1, n)
	n = n or 200
	local y = f(x0)
	local dx = (x1 - x0) / n
	for i=1,n do
		local xv = i / n * (x1 - x0) + x0
		local ytilde = y + dx * f(xv)
		y = y + dx/2 * (f(xv) + f(xv + dx))
	end
	return y
end

methods.simpson = function(f, x, x0, x1, n)
	n = math.floor((n or 200) / 2) * 2
	local dx = (x1 - x0) / n
	local y = dx/3 * (f(x0) + 4 * f(x0+dx))
	for i=2,n-1,2 do
		local xv = i/n * (x1 - x0) + x0
		y = y + dx/3 * (2 * f(xv) + 4 * f(xv+dx))
	end
	y = y + dx/3 * f(x1)
	return y
end

local table = require 'ext.table'
local symmath = require 'symmath'
require 'symmath.tostring.MathJax'.setup()
local x = symmath.var'x'		-- x-variable
local f = x^2					-- symbolic function
local df = f:diff(x)()			-- symbolic function derivative
local t0 = 0					-- start time
local t1 = 1					-- end time
local n = 100					-- number of iterations
local norm = math.abs			-- norm

print('solving',var'f':eq(f),'<br>')
local _f = f:compile{x}			-- numeric function

for _,method in ipairs{
	'euler',
	'midpoint',
	'trapezoid',
	'simpson',
} do
	local ts = table()
	local xs = table()
	local correctXs = table()
	local errs = table()

	local dt = (t1 - t0) / n
	local t = t0
	local _x = _f(t)			-- numeric value
	local err = 0
	for i=1,n do
		local correctX = _f(t)
		local diffX = _x - correctX
		local normDiff = norm(diffX)
		err = err + normDiff

		_x = methods[method](_f, _x, _x+dt, n)
		t = t + dt

		ts:insert(t)
		xs:insert(_x)
		correctXs:insert(correctX)
		errs:insert(err)
	end

	print('<h3>', method, '</h3>')

	symmath.GnuPlot:plot{
		style = 'data lines',
		data = {ts, xs, correctXs},
		{using = '1:2', title = 'x'},
		{using = '1:3', title = 'correct x'},
	}

	symmath.GnuPlot:plot{
		style = 'data lines',
		data = {ts, errs},
		log = 'y',
		{using = '1:(abs($2))', title = 'error'},
	}
end
