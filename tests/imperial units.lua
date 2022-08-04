#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'ext.env'(env)
require 'symmath'.setup{env=env, MathJax={title='imperial units'}}

print[[
<style>
table {
	border : 1px solid black;
	border-collapse : collapse;
}
table td {
	border : 1px solid black;
}
</style>
]]

local function printTable(t)
	print'<table border=1 borderspacing=0>'
	print'<tr>'
	print'<td></td>'
	for j,vj in ipairs(t) do
		print('<td>', vj.name, '</td>')
	end
	print'</tr>'
	for i,vi in ipairs(t) do
		print'<tr>'
		print('<td>', vi.name, '</td>')
		for j,vj in ipairs(t) do
			print('<td>', (vj.expr / vi.expr)(), '</td>')
		end
		print'</tr>'
	end
	print'</table>'
end

local bases = {2, 3, 4, 5, 6, 10, 12}

local function printTableInBases(title)
	return function(t)
		t = table(t):map(function(v,k,t)
			v = clone(v)()
			return {name=k, expr=v, value=v:eval()}, #t+1
		end):sort(function(a,b)
			return a.value < b.value
		end)

		print('<h3>', title, '</h3>')

		for _,base in ipairs(bases) do
			printbr()
			printbr('in base '..base)

			-- [[ changing the base of the numbers
			require 'symmath.export.LaTeX'.lookupTable[Constant] = function(self, expr)
				local s = tostring(
					require 'bignumber'(expr.value):toBase(base)
				)
				if base ~= 10 then
					s = s:match('^(.*)_'..base..'$')
					--s = s ..'_{'..base..'}'
				end
				return s
			end
			--]]

			printTable(t)

			printbr()
		end
		print'<hr>'
	end
end


printTableInBases'distance units' {
	-- in feet
	twip = frac(1, 17280),
	thou = frac(1, 12000),
	barleycorn = frac(1, 36),
	inch = frac(1, 12),
	hand = frac(1, 3),
	foot = 1,
	yard = 3,
	chain = 66,
	furlong = 660,
	mile = 5280,
	league = 15840,
}

printTableInBases'area units' {
	-- in sq. ft.
	perch = 272*frac(1,4),
	rood = 10890,
	acre = 43560,
	['square mile'] = 27878400,
}

printTableInBases'volume units' {
	-- in ounces
	['fluid ounce'] = 1,
	gil = 5,
	pint = 20,
	quart = 40,
	gallon = 160,
}

printTableInBases'weight' {
	-- in pounds
	grain = frac(1,7000),
	drachm = frac(1,256),
	ounce = frac(1,16),
	pound = 1,
	stone = 14,
	quarter = 28,
	hundredweight = 112,
	ton = 2240,
	--slug = 32.17404856,
}
