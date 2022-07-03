{
	{
		code="simplifyAssertEq(#{x:eq(0):solve(x)}, 1)",
		comment="",
		duration=0.000558,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(x:eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.001351,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999753e-07},
	{
		code="simplifyAssertEq(#{x:eq(1):solve(x)}, 1)",
		comment="",
		duration=0.0003,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(x:eq(1):solve(x), x:eq(1))",
		comment="",
		duration=0.000368,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999753e-07},
	{
		code="simplifyAssertEq(#{(x+1):eq(0):solve(x)}, 1)",
		comment="",
		duration=0.000415,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x+1):eq(0):solve(x), x:eq(-1))",
		comment="",
		duration=0.000668,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(#{(x^2):eq(1):solve(x)}, 2)",
		comment="",
		duration=0.001869,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x^2):eq(1):solve(x), x:eq(1))",
		comment="",
		duration=0.001498,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x^2):eq(1):solve(x)), x:eq(-1))",
		comment="",
		duration=0.001479,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq(#{(x^2):eq(-1):solve(x)}, 2)",
		comment="",
		duration=0.002162,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x^2):eq(-1):solve(x), x:eq(i))",
		comment="",
		duration=0.00308,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x^2):eq(-1):solve(x)), x:eq(-i))",
		comment="",
		duration=0.001856,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="print((x^2):eq(0):solve(x))",
		comment="",
		duration=0.001179,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "^:Prune:zeroToTheX", "*:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x^2):eq(0):solve(x)}, 2)",
		comment="",
		duration=0.001229,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x^2):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.00116,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x^2):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.001543,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="same with 3 ...", duration=1.000000000001e-06},
	{
		code="print((x^3):eq(0):solve(x))",
		comment="",
		duration=0.025521,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:zeroToTheX", "*:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x^3):eq(0):solve(x)}, 3)",
		comment="",
		duration=0.019364,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x^3):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.015363,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x^3):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.015519,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x^3):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.016376,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="same with 4 ...", duration=1.000000000001e-06},
	{
		code="print((x^4):eq(0):solve(x))",
		comment="",
		duration=0.004935,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "^:Prune:zeroToTheX", "*:Prune:apply", "*:Prune:flatten", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x^4):eq(0):solve(x)}, 4)",
		comment="",
		duration=0.00339,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x^4):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.002642,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x^4):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.003359,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x^4):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.002851,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(4, (x^4):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.002875,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="distinguish between x*(x^2 + 2x + 1) and (x^3 + 2x^2 + x) , because the solver handles one but not the other", duration=1.000000000001e-06},
	{
		code="printbr( (x * (x^2 + 2*x + 1)):eq(0):solve(x)  )",
		comment="",
		duration=0.002417,
		simplifyStack={"Init", "*:Prune:apply", "unm:Prune:doubleNegative", "^:Prune:simplifyConstantPowers", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:zeroToTheX", "sqrt:Prune:apply", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x * (x^2 + 2*x + 1)):eq(0):solve(x)}, 3)",
		comment="",
		duration=0.002583,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x * (x^2 + 2*x + 1)):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.002628,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x * (x^2 + 2*x + 1)):eq(0):solve(x)), x:eq(-1))",
		comment="",
		duration=0.002888,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x * (x^2 + 2*x + 1)):eq(0):solve(x)), x:eq(-1))",
		comment="",
		duration=0.002558,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="printbr( (x^3 + 2*x^2 + x):eq(0):solve(x) )",
		comment="",
		duration=0.003701,
		simplifyStack={"Init", "*:Prune:apply", "unm:Prune:doubleNegative", "^:Prune:simplifyConstantPowers", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:zeroToTheX", "sqrt:Prune:apply", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x^3 + 2*x^2 + x):eq(0):solve(x)}, 3)",
		comment="",
		duration=0.002877,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x * (x^2 + 2*x + 1)):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.002004,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x * (x^2 + 2*x + 1)):eq(0):solve(x)), x:eq(-1))",
		comment="",
		duration=0.002803,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x * (x^2 + 2*x + 1)):eq(0):solve(x)), x:eq(-1))",
		comment="",
		duration=0.004625,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="same with x^3 + x^2 - x", duration=1.000000000001e-06},
	{
		code="printbr( (x * (x^2 + x - 1)):eq(0):solve(x)  )",
		comment="",
		duration=0.006742,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "^:Prune:simplifyConstantPowers", "*:Prune:apply", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x * (x^2 + x - 1)):eq(0):solve(x)}, 3)",
		comment="",
		duration=0.006833,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x * (x^2 + x - 1)):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.007117,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x * (x^2 + x - 1)):eq(0):solve(x)), x:eq( -(1 - sqrt(5))/2 ))",
		comment="",
		duration=0.014686,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:107: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:216: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:215>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:107: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(select(2, (x * (x^2 + x - 1)...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:208: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:207>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:207: in function 'exec'\n\9solve.lua:126: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9solve.lua:6: in main chunk\n\9[C]: at 0x5646470903e0",
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "^:Prune:sqrtFix4", "^:Tidy:apply", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:apply", "*:Prune:flatten", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x * (x^2 + x - 1)):eq(0):solve(x)), x:eq( -(1 + sqrt(5))/2 ))",
		comment="",
		duration=0.012845,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:107: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:216: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:215>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:107: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(select(3, (x * (x^2 + x - 1)...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:208: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:207>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:207: in function 'exec'\n\9solve.lua:126: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9solve.lua:6: in main chunk\n\9[C]: at 0x5646470903e0",
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="printbr( (x^3 + x^2 - x):eq(0):solve(x) )",
		comment="",
		duration=0.007582,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "^:Prune:simplifyConstantPowers", "*:Prune:apply", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x^3 + x^2 - x):eq(0):solve(x)}, 3)",
		comment="",
		duration=0.004505,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x * (x^2 + x - 1)):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.005458,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x * (x^2 + x - 1)):eq(0):solve(x)), x:eq( -(1 - sqrt(5))/2 ))",
		comment="",
		duration=0.010857,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:107: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:216: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:215>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:107: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(select(2, (x * (x^2 + x - 1)...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:208: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:207>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:207: in function 'exec'\n\9solve.lua:126: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9solve.lua:6: in main chunk\n\9[C]: at 0x5646470903e0",
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "^:Prune:sqrtFix4", "^:Tidy:apply", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:apply", "*:Prune:flatten", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x * (x^2 + x - 1)):eq(0):solve(x)), x:eq( -(1 + sqrt(5))/2 ))",
		comment="",
		duration=0.009282,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:107: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:216: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:215>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:107: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(select(3, (x * (x^2 + x - 1)...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:208: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:207>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:207: in function 'exec'\n\9solve.lua:126: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9solve.lua:6: in main chunk\n\9[C]: at 0x5646470903e0",
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	}
}