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

printbr'<h3>Central Difference, 1st deriv, 2nd order</h3>'
--[[
a_{-1} f(x - h) + a_0 f(x) + a_1 f(h) ~ f'(x)
a_{-1} f'(x - h) + a_0 f'(x) + a_1 f'(h) ~ f''(x)
--]]

local x = var'x'
local xBar = var'\\bar{x}'
local h = var'h'

local fvars = Matrix{var'f_1', var'f_2', var'f_3'}:T()

symmath.op.pow:pushRule'Expand/integerPower'	-- don't expand integer powers of expression
local Aval = Matrix:lambda({3,3}, function(i,j)
	return ((xBar + (i-2) * h)^(3-j))()
end)
symmath.op.pow:popRule'Expand/integerPower'
printbr(var'A':eq(Aval))
printbr()

printbr(var'f_i':eq(var'A_{ij}' * var'p_j'))
printbr()
printbr(fvars:eq(Aval * Matrix{var'p_1', var'p_2', var'p_3'}:T()))
printbr()

local detA = Aval:det()
printbr(var'det(A)':eq(detA))
printbr()

local invA = Aval:inv()
printbr((var'A'^-1):eq(invA))
printbr()

local invA_fval = invA * fvars
printbr((var'A'^-1 * var'f_i'):eq(invA_fval))
printbr()
invA_fval = invA_fval()
printbr((var'A'^-1 * var'f_i'):eq(invA_fval))
printbr()

local xval = Matrix{x^2, x, 1}
local x_invA_fval = xval * invA * fvars
printbr((var'x^j' * var'A'^-1 * var'f_i'):eq(x_invA_fval))
printbr()
x_invA_fval = x_invA_fval()[1][1]
printbr((var'x^j' * var'A'^-1 * var'f_i'):eq(x_invA_fval))
printbr()

local d_x_A_f = x_invA_fval:diff(x)() 
printbr((var'x^j' * var'A'^-1 * var'f_i'):diff(x):eq(d_x_A_f))
printbr()

local let = xBar:eq(x)
printbr('let', let)
d_x_A_f = d_x_A_f:subst(let)()
printbr((var'x^j' * var'A'^-1 * var'f_i'):diff(x):eq(d_x_A_f))
printbr()


print(MathJax.footer)
