#!/usr/bin/env lua
require 'ext'
require 'symmath'()

-- [[ trying out compiling of multiple functions in multiple languages
local x = var'x'

local expr1 = (exp(x) - 1/exp(x)) / 2
print'expr1'
print(expr1)

local expr2 = (exp(x) + 1/exp(x)) / 2
print'expr2'
print(expr2)

for _,lang in ipairs{
	'C',
	'JavaScript',
	'Lua',
	'Mathematica',
	'GnuPlot',
} do
	print()
	print('==== lang: '..lang..' ====')
	print()

	print'x'
	print()
	print'code:'
	print(symmath.export[lang]:toCode{output={x}})
	print()
	print'func code:'
	print(symmath.export[lang]:toFuncCode{output={x}})
	print()


	print'expr1'
	print()
	print'code:'
	print(symmath.export[lang]:toCode{output={expr1}, input={x}})
	print()
	print'func code:'
	print(symmath.export[lang]:toFuncCode{output={expr1}, input={x}})
	print()

	print'expr2'
	print()
	print'code:'
	print(symmath.export[lang]:toCode{output={expr2}, input={x}})
	print()
	print'func code:'
	print(symmath.export[lang]:toFuncCode{output={expr2}, input={x}})
	print()

	print'expr1 & expr2'
	print()
	print'code:'
	print(symmath.export[lang]:toCode{output={expr1, expr2}, input={x}})
	print()
	print'func code:'
	print(symmath.export[lang]:toFuncCode{output={expr1, expr2}, input={x}})
	print()
end
--]]

-- [[ trying out something more complex, like radial-remapped spherical coordinates
local A = var'A'
local w = var'w'
	
local rho, theta, phi = vars('ρ', 'θ', 'φ')
	
local r = A * sinh(rho / sinh(w)) / sinh(frac(1, sinh(w)))
local x = r * sin(theta) * cos(phi)
local y = r * sin(theta) * sin(phi)
local z = r * cos(theta)

print(symmath.export.C:toCode{
	-- should we do this, or just let the caller replace() them manually?
	-- "input =" does the same atm
	--rename = {{rho=rho}, {theta=theta}, {phi=phi}},
	
	input = {{rho=rho}, {theta=theta}, {phi=phi}},
	--output = {x, y, z},
	output = {{x=x}, {y=y}, {z=z}},
})
--]]
