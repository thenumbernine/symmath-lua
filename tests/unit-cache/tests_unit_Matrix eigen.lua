{
	{
		code="local A = Matrix({-6, 3}, {4, 5})\nlocal ch = A:charpoly(lambda)\nprintbr(ch)\nlocal solns = table{ch:solve(lambda)}\nprintbr(solns:mapi(tostring):concat',')\nsimplifyAssertEq(ch, (lambda^2 + lambda - 42):eq(0))\nlocal eig = A:eigen()\n\n\nif Constant.isValue(eig.Lambda[1][1], 6) then local P = Matrix({0,1},{1,0}) eig.R = (eig.R * P)() eig.Lambda = (P * eig.Lambda * P)() eig.L = (P * eig.L)() end\n\n\nsimplifyAssertEq(eig.L, Matrix({-frac(4,13), frac(1,13)}, {frac(4, 13), frac(12,13)}))\nsimplifyAssertEq(eig.R, Matrix({-3, frac(1,4)}, {1, 1}))\nsimplifyAssertEq(eig.Lambda, Matrix.diagonal(-7, 6))",
		comment="printbr(A:eq(eig.R * eig.Lambda * eig.L))\nprintbr('permuting to', A:eq(eig.R * eig.Lambda * eig.L))",
		duration=0.141119,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="local A = Matrix({2, 0, 0}, {0, 4, 5}, {0, 4, 3})\nlocal ch = A:charpoly(lambda)\nprintbr(ch)\nlocal solns = table{ch:solve(lambda)}\nprintbr(solns:mapi(tostring):concat',')\nlocal eig = A:eigen()\nprintbr(A:eq(eig.R * eig.Lambda * eig.L))\nif Constant.isValue(eig.Lambda[1][1], 6) then local P = Matrix({0,1},{1,0}) eig.R = (eig.R * P)() eig.Lambda = (P * eig.Lambda * P)() eig.L = (P * eig.L)() printbr('permuting to', A:eq(eig.R * eig.Lambda * eig.L)) end\n\n\nsimplifyAssertEq(eig.R, Matrix({1, 0, 0}, {0, -1, 1}, {0, frac(5,4), 1}):T())\nsimplifyAssertEq(eig.L, Matrix({1, 0, 0}, {0, -frac(4,9), frac(4,9)}, {0, frac(5,9), frac(4,9)}):T())\nsimplifyAssertEq(eig.Lambda, Matrix.diagonal(2, -1, 8))",
		comment="printbr('permuting to', A:eq(eig.R * eig.Lambda * eig.L))",
		duration=0.124957,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="local A = Matrix({1, 1}, {0, 1})\nprintbr'<b>without generalization:</b>'\nlocal eig = A:eigen()\nfor k,v in pairs(eig) do\n\9printbr(k, '=', v)\nend\nassert(eig.defective)\nassertEq(eig.R, Matrix{1, 0}:T())\nsimplifyAssertAllEq(eig.allLambdas, {1})\n\n\n\nprintbr'<b>with generalization:</b>'\neig = A:eigen{generalize=true, verbose=true}\nfor k,v in pairs(eig) do\n\9printbr(k, '=', v)\nend\nprintbr('#allLambdas', #eig.allLambdas)\nprintbr('#lambdas', #eig.lambdas)\nprintbr('lambdas', eig.lambdas:mapi(function(l) return '{mult='..l.mult..', expr='..l.expr..'}' end):concat',')\nsimplifyAssertEq(eig.L, Matrix.identity(2))\nsimplifyAssertEq(eig.R, Matrix.identity(2))",
		comment="printbr(A:eq(eig.R * eig.Lambda * eig.L))\n OK HERE ... what about lambda, and their associations with R and L in the generalized system?",
		duration=0.030738,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}