#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'tests/unit/Matrix_eigen')

timer(nil, function()

env.lambda = var'\\lambda'

for _,line in ipairs{
-- from https://www.mathsisfun.com/algebra/eigenvalue.html
[[
local A = Matrix({-6, 3}, {4, 5})
local ch = A:charpoly(lambda)
printbr(ch)
local solns = table{ch:solve(lambda)}
printbr(solns:mapi(tostring):concat',')
simplifyAssertEq(ch, (lambda^2 + lambda - 42):eq(0))
local eig = A:eigen()
printbr(A:eq(eig.R * eig.Lambda * eig.L))
simplifyAssertEq(eig.L, Matrix({-frac(4,13), frac(1,13)}, {frac(4, 13), frac(12,13)}))
simplifyAssertEq(eig.R, Matrix({-3, frac(1,4)}, {1, 1}))
simplifyAssertEq(eig.Lambda, Matrix.diagonal(-7, 6))
]],

-- this fails because it requires a cubic polynomial solution
-- my implementation of the cubic solver algorithm is stalling out because my sqrt simplifications are too slow (notice all the pushRules involving sqrts in my tests)
[[
local A = Matrix({2, 0, 0}, {0, 4, 5}, {0, 4, 3})
local ch = A:charpoly(lambda)
printbr(ch)
local solns = table{ch:solve(lambda)}
printbr(solns:mapi(tostring):concat',')
local eig = A:eigen()
--printbr(A:eq(eig.R * eig.Lambda * eig.L))
simplifyAssertEq(eig.R, Matrix({0, 1, 0}, {5, 0, -1}, {4, 0, 1}))
simplifyAssertEq(eig.L, Matrix({-frac(4,13), frac(1,13)}, {frac(4, 13), frac(12,13)}))
simplifyAssertEq(eig.Lambda, Matrix.diagonal(-7, 6))
]],

-- defective matrix
[[
local A = Matrix({1, 1}, {0, 1})
printbr'<b>without generalization:</b>'
local eig = A:eigen()
for k,v in pairs(eig) do
	printbr(k, '=', v)
end
assert(eig.defective)
assertEq(eig.R, Matrix{1, 0}:T())
simplifyAssertAllEq(eig.allLambdas, {1})

--printbr(A:eq(eig.R * eig.Lambda * eig.L))
printbr'<b>with generalization:</b>'
eig = A:eigen{generalize=true, verbose=true}
for k,v in pairs(eig) do
	printbr(k, '=', v)
end
printbr('#allLambdas', #eig.allLambdas)
printbr('#lambdas', #eig.lambdas)
printbr('lambdas', eig.lambdas:mapi(function(l) return '{mult='..l.mult..', expr='..l.expr..'}' end):concat',')
simplifyAssertEq(eig.L, Matrix.identity(2))
simplifyAssertEq(eig.R, Matrix.identity(2))
-- OK HERE ... what about lambda, and their associations with R and L in the generalized system?
]]
} do
	env.exec(line)
end

end)
