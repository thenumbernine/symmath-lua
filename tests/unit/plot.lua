#!/usr/bin/env luajit
-- not in the same vein as the other tests, just going to plot out a temp figure
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='tests/unit/plot'}}

local GnuPlot = symmath.export.GnuPlot

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

printbr'This only works with MathJax output at the moment.'
printbr()

header'using symmath expressions:'
printAndRun[[
local x = var'x'
GnuPlot:plot{
	title = 'test expression',
	xrange = {-2,2},
	{x^2, title=GnuPlot(x^2)},
	{x^3, title=GnuPlot(x^3)},
}
]]

header'using gnuplot strings for formula:'
printAndRun[[
GnuPlot:plot{
	title = 'test plot',
	xrange = {-2,2},
	{'x**2.', title='test plot "x**2."'},
	{'x**3.', title='test plot "x**3."'},
}
]]


header'using Lua data for formula:'
printAndRun[[
local n = 50
local xmin, xmax = -10, 10
local xs = range(n):mapi(function(i) return (i-.5)/n * (xmax - xmin) + xmin end)
GnuPlot:plot{
	title = 'test data title',
	style = 'data linespoints',
	data = {
		xs,
		xs:mapi(function(x) return math.sin(x)/x end),
	},
	{using = '1:2', title = 'test data sin(x)/x'},
}
]]
