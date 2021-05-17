#!/usr/bin/env luajit
-- not in the same vein as the other tests, just going to plot out a temp figure
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='tests/unit/nameForExporter'
	--, pathToTryToFindMathJax='..'
}}

printbr('generated with '..(jit and jit.version or _VERSION))
printbr()

local x = var'x'

local exprs = {
	i,
	e,
	pi,
	inf,
	x,
	x^2,
	exp(x),
	sin(x),
	cos(x),
	x/2,
	frac(1,2)*x,
}

local es = {
	-- code 
	export.C,
	export.JavaScript,
	export.Lua,
	-- code
	export.GnuPlot,
	export.Mathematica,
	export.SymMath,
	-- text
	export.LaTeX,
	export.MathJax,
	export.SingleLine,
	export.MultiLine,
	export.Verbose,
}

print'<table border="1" style="border-collapse:collapse">'
print'<tr>'
print'<th>.name</th>'
for _,e in ipairs(es) do
	print'<th>'
	print(e.name)
	print'</th>'
end
print'</tr>'
for _,expr in ipairs(exprs) do
	print'<tr>'
	print('<td><pre>'..expr.name..'</pre></td>')
	for _,e in ipairs(es) do
		print('<td><pre>'..e(expr)..'</pre></td>')
	end
	print'</tr>'
end
print'</table>'
