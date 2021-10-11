#!/usr/bin/env luajit
-- not in the same vein as the other tests, just going to plot out a temp figure
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='tests/unit/plot'}}

local function header(s)
	print('<h3>'..s..'</h3>')
end

local function printpre(code)
	print'<pre style="background-color:#e0e0e0; padding:15px">'
	print(code:trim())
	print'</pre>'
end

local function run(code)
	assert(load(code, nil, nil, env))()
end

local function printAndRun(code)
	printpre(code)
	run(code)
end

printbr'This only works with MathJax inline SVG and Console output at the moment.'
printbr()

header'using the gnuplot syntax:'
printAndRun[[
local symmath = require 'symmath'
local GnuPlot = symmath.export.GnuPlot
GnuPlot:plot{
	title = 'test plot',
	xrange = {-2,2},
	{'x**2.', title='test plot "x**2."'},
	{'x**3.', title='test plot "x**3."'},
}
]]

header'using symmath expressions:'
printAndRun[[
local symmath = require 'symmath'
local GnuPlot = symmath.export.GnuPlot
local x = symmath.var'x'
GnuPlot:plot{
	title = 'test expression',
	xrange = {-2,2},
	{x^2, title=GnuPlot(x^2)},
	{x^3, title=GnuPlot(x^3)},
}
]]

header'using plot member function:'
printAndRun[[
local symmath = require 'symmath'
local x = symmath.var'x'
-- unless it's assigned to another var, or an argument of a function call, math operators will screw up Lua grammar so a subsequent member call is ignored
-- to get around this I'm wrapping the call in print()
-- but take note: (x^2):plot(...) will cause a Lua error
print((x^2):plot{
	title = 'test expression',
	xrange = {-2,2},
	{title=GnuPlot(x^2)},	-- the first table is assumed to be associated with the calling expression 
})
]]

header'using Lua data for formula:'
printAndRun[[
local symmath = require 'symmath'
local GnuPlot = symmath.export.GnuPlot
local n = 50
local xmin, xmax = -10, 10
local xs, ys = {}, {}
for i=1,n do
	local x = (i-.5)/n * (xmax - xmin) + xmin
	xs[i] = x
	ys[i] = math.sin(x) / x
end
GnuPlot:plot{
	title = 'test data title',
	style = 'data linespoints',
	data = {xs, ys},
	{using = '1:2', title = 'test data sin(x)/x'},
}
]]

header'using symmath expressions, code generation, and Lua data:'
printAndRun[[
local symmath = require 'symmath'
local GnuPlot = symmath.export.GnuPlot

local x = symmath.var'x'
local f = symmath.sin(x) / x
local ff = symmath.export.Lua:toFunc{input={x}, output={f}}
local n = 50
local xmin, xmax = -10, 10
local xs, ys = {}, {}
for i=1,n do
	local x = (i-.5)/n * (xmax - xmin) + xmin
	xs[i] = x
	ys[i] = ff(x)
end
GnuPlot:plot{
	title = 'test data title',
	style = 'data linespoints',
	data = {xs, ys},
	{using = '1:2', title = 'test data '..export.GnuPlot(f)},
}
]]

header'using the gnuplot syntax:'
printAndRun[[
local symmath = require 'symmath'
local GnuPlot = symmath.export.GnuPlot
print'<pre>'
GnuPlot:plot{
	outputType = 'Console',
	title = 'test plot',
	xrange = {-2,2},
	{'x**2.', title='test plot "x**2."'},
	{'x**3.', title='test plot "x**3."'},
}
print'</pre>'
]]
