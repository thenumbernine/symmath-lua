#!/usr/bin/env luajit
-- not in the same vein as the other tests, just going to plot out a temp figure
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='tests/unit/export', pathToTryToFindMathJax='..'}}

printbr('generated with '..(jit and jit.version or _VERSION))
printbr()

print[[
<style>
/* TODO this breaks multi-line output formatting in the html */
/* and disabling this only for multiline causes text to overflow into the multiline output */
/* quick fix: put MultiLine first */
.pre-not-multiline {
	white-space: pre;		   /* CSS 2.0 */
	white-space: pre-wrap;	  /* CSS 2.1 */
	white-space: pre-line;	  /* CSS 3.0 */
	white-space: -pre-wrap;	 /* Opera 4-6 */
	white-space: -o-pre-wrap;   /* Opera 7 */
	white-space: -moz-pre-wrap; /* Mozilla */
	white-space: -hp-pre-wrap;  /* HP Printers */
	word-wrap: break-word;	  /* IE 5+ */
}
table {
	table-layout: fixed;
	width: 100%;
}
td {
	padding: 5px;
}
</style>
]]

local es = {
	-- text
	export.MultiLine,
	export.SingleLine,
	export.LaTeX,
	--export.MathJax,	-- identical to LaTeX.

	-- code 
	export.C,
	export.JavaScript,
	export.Lua,
	
	-- code
	export.GnuPlot,
	export.Mathematica,
	
	-- support
	export.Verbose,
	export.SymMath,
}



local a,b,c,d = vars('a', 'b', 'c', 'd')
local x,y = vars('x', 'y')

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
	
	y:lim(x, 0),
	y:lim(x, 0, '+'),
	y:lim(x, 0, '-'),
	(1/x):lim(x, 0, '-'),
	(1/x^2):lim(x, 0, '-'),
	exp(-1/x):lim(x, 0, '-'),
	(1+x):lim(x, 0),
	(-x):lim(x, 0),

	y:diff(x),
	y:pdiff(x),
	x:integrate(y),
	x:integrate(y, 0, 1),
	Array(x,y),
	Matrix({x}, {y}),
	Matrix{x, y},
	Matrix{{a, b}, {c,d}},
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
	if e.name == 'LaTeX' then print(' / MathJax') end
	print'</th>'
end
print'</tr>'
for _,expr in ipairs(exprs) do
	print'<tr>'
	print('<td><pre>'..expr.name..'</pre></td>')
	for _,e in ipairs(es) do
		print'<td>'
		local s
		local error
		xpcall(function()
			s = e(expr)
		end, function(errstr)
			error = 'error'
			--error = errstr .. '\n' .. debug.traceback()
		end)
		if error then
			print'<span style="color:red">error</span>'
		else
			if e.name == 'MultiLine' then
				print'<pre>'
			else
				print'<pre class="pre-not-multiline">'
			end
			print(s)
			print'</pre>'
			if e.name == 'LaTeX' then	-- since this is a Mathjax document, why not use it
				print(s)
			end
		end

		print'</td>'
	end
	print'</tr>'
end
print'</table>'
