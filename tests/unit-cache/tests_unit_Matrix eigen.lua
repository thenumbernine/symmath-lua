{
	{
		code="local A = Matrix({-6, 3}, {4, 5})\nlocal ch = A:charpoly(lambda)\nprintbr(ch)\nlocal solns = table{ch:solve(lambda)}\nprintbr(solns:mapi(tostring):concat',')\nsimplifyAssertEq(ch, (lambda^2 + lambda - 42):eq(0))\nlocal eig = A:eigen()\nprintbr(A:eq(eig.R * eig.Lambda * eig.L))\nsimplifyAssertEq(eig.L, Matrix({-frac(4,13), frac(1,13)}, {frac(4, 13), frac(12,13)}))\nsimplifyAssertEq(eig.R, Matrix({-3, frac(1,4)}, {1, 1}))\nsimplifyAssertEq(eig.Lambda, Matrix.diagonal(-7, 6))",
		comment="",
		duration=0.083161,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:107: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:216: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:215>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:107: in function 'simplifyAssertEq'\n\9[string \"local A = Matrix({-6, 3}, {4, 5})...\"]:9: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:208: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:207>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:207: in function 'exec'\n\9./Matrix eigen.lua:67: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9./Matrix eigen.lua:6: in main chunk\n\9[C]: at 0x55764bfcc3e0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="local A = Matrix({2, 0, 0}, {0, 4, 5}, {0, 4, 3})\nlocal ch = A:charpoly(lambda)\nprintbr(ch)\nlocal solns = table{ch:solve(lambda)}\nprintbr(solns:mapi(tostring):concat',')\nlocal eig = A:eigen()\n\n\nsimplifyAssertEq(eig.R, Matrix({0, 1, 0}, {5, 0, -1}, {4, 0, 1}))\nsimplifyAssertEq(eig.L, Matrix({-frac(4,13), frac(1,13)}, {frac(4, 13), frac(12,13)}))\nsimplifyAssertEq(eig.Lambda, Matrix.diagonal(-7, 6))",
		comment="printbr(A:eq(eig.R * eig.Lambda * eig.L))",
		duration=0.063622,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:107: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:216: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:215>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:107: in function 'simplifyAssertEq'\n\9[string \"local A = Matrix({2, 0, 0}, {0, 4, 5}, {0, 4,...\"]:9: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:208: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:207>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:207: in function 'exec'\n\9./Matrix eigen.lua:67: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9./Matrix eigen.lua:6: in main chunk\n\9[C]: at 0x55764bfcc3e0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="local A = Matrix({1, 1}, {0, 1})\nprintbr'<b>without generalization:</b>'\nlocal eig = A:eigen()\nfor k,v in pairs(eig) do\n\9printbr(k, '=', v)\nend\nassert(eig.defective)\nassertEq(eig.R, Matrix{1, 0}:T())\nsimplifyAssertAllEq(eig.allLambdas, {1})\n\n\n\nprintbr'<b>with generalization:</b>'\neig = A:eigen{generalize=true, verbose=true}\nfor k,v in pairs(eig) do\n\9printbr(k, '=', v)\nend\nprintbr('#allLambdas', #eig.allLambdas)\nprintbr('#lambdas', #eig.lambdas)\nprintbr('lambdas', eig.lambdas:mapi(function(l) return '{mult='..l.mult..', expr='..l.expr..'}' end):concat',')\nsimplifyAssertEq(eig.L, Matrix.identity(2))\nsimplifyAssertEq(eig.R, Matrix.identity(2))",
		comment="printbr(A:eq(eig.R * eig.Lambda * eig.L))\n OK HERE ... what about lambda, and their associations with R and L in the generalized system?",
		duration=0.017524,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}