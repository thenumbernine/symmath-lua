#! /usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
require 'ext.env'(env)
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env}
local MathJax = symmath.export.MathJax
symmath.tostring = MathJax 
local printbr = MathJax.print
MathJax.header.title = 'Finite Difference Coefficients'
print(MathJax.header)


--[[
a_{-1} f(x - h) + a_0 f(x) + a_1 f(h) ~ f'(x)
a_{-1} f'(x - h) + a_0 f'(x) + a_1 f'(h) ~ f''(x)
--]]

local x = var'x'
local xBar = var'\\bar{x}'
local h = var'h'

local yvecvar = var'\\vec{y}'

printbr[[$f(x) = $ the function we are approximating the derivative of.]]
printbr[[$\bar{x} =$ the point at which we are approximating the derivative.]]
printbr[[h = the step size of our finite difference grid.]]
printbr[[$y_k = f(\bar{x}_0 + k h) =$ the function, evaluated along our evenly spaced samples.]]
printbr[[$p(x) = c_i x^i =$ the polynomial approximation of the derivative.]]
printbr()

local Amatvar = var'\\mathbf{A}'
printbr[[$A_{ij} = [ (\bar{x}_0 + i \cdot h)^{j-1} ]$]]

local cvecvar = var'\\vec{c}'

printbr(yvecvar:eq(Amatvar * cvecvar))
printbr()
printbr(cvecvar:eq(Amatvar^-1 * yvecvar))
printbr()

printbr()
printbr'<h3>Central Difference, 1st deriv</h3>'

-- https://en.wikipedia.org/wiki/Finite_difference_coefficient
-- ... they only go up to order 8
for _,order in ipairs{2,4} do
	printbr('<h3>...'..order..' order</h3>')
	local n = order + 1

	symmath.op.pow:pushRule'Expand/integerPower'	-- don't expand integer powers of expression
	local Aval = Matrix:lambda({n, n}, function(i,j)
		return ((xBar + (i - 1 - order/2) * h)^(j-1))()
	end)
	symmath.op.pow:popRule'Expand/integerPower'
	--[[
	printbr(Amatvar:eq(Aval))
	printbr()
	--]]

	local yvars = range(n):mapi(function(i) return var('y_{'..i..'}') end)
	local yvecval = Matrix(yvars):T()

	local cvars = range(n):mapi(function(i) return var('c_{'..i..'}') end)
	local cvecval = Matrix(cvars):T()
	--[[
	printbr(yvecval:eq(Aval * cvecval))
	printbr()
	--]]

	--[[
	local detA = Aval:det()
	printbr(var'det(A)':eq(detA))
	printbr()
	--]]

	local invA = Aval:inv()
	--[[
	printbr((Amatvar^-1):eq(invA))
	printbr()
	--]]

	local invA_fval = invA * yvecval
	-- [[
	printbr(cvecvar:eq(Amatvar^-1 * var'y_i'):eq(invA_fval))
	printbr()
	--]]
	invA_fval = invA_fval()
	--[[
	printbr((Amatvar^-1 * var'y_i'):eq(invA_fval))
	printbr()
	--]]

	local pfunc = var'p(x)'
	local xval = Matrix:lambda({1,n}, function(i,j) return x^(j-1) end)()
	local x_invA_fval = xval * invA * yvecval
	printbr(pfunc:eq(var'x^j' * Amatvar^-1 * var'y_i'):eq(x_invA_fval))
	printbr()
	x_invA_fval = x_invA_fval()[1][1]
	--[[
	printbr(pfunc:eq(x_invA_fval))
	printbr()
	--]]

	local d_x_A_f_h = (x_invA_fval:diff(x) * h)() 
	--[[
	printbr(pfunc:diff(x):eq(frac(1,h) * d_x_A_f_h))
	printbr()
	--]]

	local let = xBar:eq(x)
	printbr('let', let)
	d_x_A_f_h = d_x_A_f_h:subst(let)()
	printbr(pfunc:diff(x):approx(frac(1,h) * d_x_A_f_h))
	printbr()

	local A, b = factorLinearSystem({d_x_A_f_h}, yvars)
	if not Constant.isValue(b[1][1], 0) then
		printbr'!!! DANGER DANGER !!! something went wrong'
		printbr(pfunc:diff(x):approx(frac(1,h) * A * yvecval + b[1][1]))
	else
		printbr(pfunc:diff(x):approx(frac(1,h) * A * yvecval)) 
	end
end

printbr'<h3>Numericaly:</h3>'
local matrix = require 'matrix'
local big = require 'bignumber'
local math = require 'ext.math'
for _,n in ipairs{2, 4, 6} do	-- order of accuracy
	printbr('<h3>...'..n..' order</h3>')
	local m = 1	-- m'th derivative
	local p = math.floor((m + 1) / 2) - 1 + n / 2
	local A = matrix{n+1,n+1}:lambda(function(i,j)
		return big(-p+i-1)^(j-1)
	end)
	local detA = A:det()
	-- [[
	printbr(var'A':eq(Matrix:lambda({n+1,n+1}, function(i,j)
		return var(tostring(A[i][j]))
	end)))
	--]]
	local AInv = A:inv()
	local AInv_detA = AInv * detA
	-- [[
	printbr((var'A'^-1):eq(frac(1, detA) * Matrix:lambda({n+1,n+1}, function(i,j)
		return var(tostring(AInv_detA[i][j]))
	end)))
	--]]
	--[[
	printbr((var'A'^-1 * var'x'):eq(Matrix:lambda({1,n+1}, function(i,j)
		-- TODO why is only half rationalizing and the other half turning into decimals?
		return frac(
			Constant(AInv_detA[m+1][j])(),
			Constant(detA * math.factorial(m))()
		)
	end)))
	--]]
	--[[
	local AInv_x = AInv * matrix{n+1}:lambda(function(i)
		return i == m+1 and math.factorial(m) or 0
	end)
	--]]
end
print(MathJax.footer)
