{
	{
		code=[[
local A = Matrix({-6, 3}, {4, 5})
local ch = A:charpoly(lambda)
printbr(ch)
local solns = table{ch:solve(lambda)}
printbr(solns:mapi(tostring):concat',')
simplifyAssertEq(ch, (lambda^2 + lambda - 42):eq(0))
local eig = A:eigen()


if Constant.isValue(eig.Lambda[1][1], 6) then local P = Matrix({0,1},{1,0}) eig.R = (eig.R * P)() eig.Lambda = (P * eig.Lambda * P)() eig.L = (P * eig.L)() end


simplifyAssertEq(eig.L, Matrix({-frac(4,13), frac(1,13)}, {frac(4, 13), frac(12,13)}))
simplifyAssertEq(eig.R, Matrix({-3, frac(1,4)}, {1, 1}))
simplifyAssertEq(eig.Lambda, Matrix.diagonal(-7, 6))]],
		comment=[[
printbr(A:eq(eig.R * eig.Lambda * eig.L))
printbr('permuting to', A:eq(eig.R * eig.Lambda * eig.L))]],
		duration=0.061081,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code=[[
local A = Matrix({2, 0, 0}, {0, 4, 5}, {0, 4, 3})
local ch = A:charpoly(lambda)
printbr(ch)
local solns = table{ch:solve(lambda)}
printbr(solns:mapi(tostring):concat',')
local eig = A:eigen()
printbr(A:eq(eig.R * eig.Lambda * eig.L))
if Constant.isValue(eig.Lambda[1][1], 6) then local P = Matrix({0,1},{1,0}) eig.R = (eig.R * P)() eig.Lambda = (P * eig.Lambda * P)() eig.L = (P * eig.L)() printbr('permuting to', A:eq(eig.R * eig.Lambda * eig.L)) end


simplifyAssertEq(eig.R, Matrix({1, 0, 0}, {0, -1, 1}, {0, frac(5,4), 1}):T())
simplifyAssertEq(eig.L, Matrix({1, 0, 0}, {0, -frac(4,9), frac(4,9)}, {0, frac(5,9), frac(4,9)}):T())
simplifyAssertEq(eig.Lambda, Matrix.diagonal(2, -1, 8))]],
		comment="printbr('permuting to', A:eq(eig.R * eig.Lambda * eig.L))",
		duration=0.052471,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="local A = Matrix({1, 1}, {0, 1})\nprintbr'<b>without generalization:</b>'\nlocal eig = A:eigen()\nfor k,v in pairs(eig) do\n\9printbr(k, '=', v)\nend\nassert(eig.defective)\nassertEq(eig.R, Matrix{1, 0}:T())\nsimplifyAssertAllEq(eig.allLambdas, {1})\n\n\n\nprintbr'<b>with generalization:</b>'\neig = A:eigen{generalize=true, verbose=true}\nfor k,v in pairs(eig) do\n\9printbr(k, '=', v)\nend\nprintbr('#allLambdas', #eig.allLambdas)\nprintbr('#lambdas', #eig.lambdas)\nprintbr('lambdas', eig.lambdas:mapi(function(l) return '{mult='..l.mult..', expr='..l.expr..'}' end):concat',')\nsimplifyAssertEq(eig.L, Matrix.identity(2))\nsimplifyAssertEq(eig.R, Matrix.identity(2))",
		comment=[[
printbr(A:eq(eig.R * eig.Lambda * eig.L))
 OK HERE ... what about lambda, and their associations with R and L in the generalized system?]],
		duration=0.012695,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}