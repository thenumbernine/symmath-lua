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

local es = {
	-- text
	export.LaTeX,
	export.MathJax,
	export.SingleLine,
	export.MultiLine,
	export.Verbose,

	-- code 
	export.C,
	export.JavaScript,
	export.Lua,
	
	-- code
	export.GnuPlot,
	export.Mathematica,
	export.SymMath,
}



local x = var'x'
local y = var'y'

local exprs = {
	i,
	e,
	pi,
	inf,
	x,
	y,
	x + y,
	x - y,
	x * y,
	x / y,
	x % y,
	x ^ y,
	-x,
	x/2,
	frac(1,2)*x,
	2*x,
	2*(x+1),
	x^2,
	(1+x)^2,
	(1+x)^(1+y),
	2^(1+y),
	e^(1+y),
	
	abs(x),
	
	sqrt(x),
	cbrt(x),
	
	exp(x),
	log(x),
	
	Heaviside(x),
	
	sin(x),
	cos(x),
	tan(x),
	
	asin(x),
	acos(x),
	atan(x),
	atan2(x),
	
	sinh(x),
	cosh(x),
	tanh(x),
	
	asinh(x),
	acosh(x),
	atanh(x),
	
	x:eq(y),	
	x:ne(y),
	x:lt(y),
	x:le(y),
	x:gt(y),
	x:ge(y),
	x:approx(y),
	y:diff(x),
	y:pdiff(x),
	x:integrate(y),
	x:integrate(y, 0, 1),
	Array(x,y),
	Matrix({x}, {y}),
	Matrix{x, y},
	x'_a',
	x'^a',
	x' _\\mu',
	x' ^\\mu',
	x'_ab',
	x'^ab',
	x' _\\mu _\\nu',
	x' ^\\mu ^\\nu',
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
		print'<td><pre>'
		local s
		xpcall(function()
			s = e(expr)
		end, function(err)
			s = 'error'
			--s = err .. '\n' .. debug.traceback()
		end)
		print(s)
		print'</pre></td>'
	end
	print'</tr>'
end
print'</table>'
