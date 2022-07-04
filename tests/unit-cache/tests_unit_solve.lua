{
	{
		code="simplifyAssertEq(#{x:eq(0):solve(x)}, 1)",
		comment="",
		duration=0.000872,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(x:eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.00121,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(#{x:eq(1):solve(x)}, 1)",
		comment="",
		duration=0.000405,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(x:eq(1):solve(x), x:eq(1))",
		comment="",
		duration=0.000675,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(#{(x+1):eq(0):solve(x)}, 1)",
		comment="",
		duration=0.00043,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x+1):eq(0):solve(x), x:eq(-1))",
		comment="",
		duration=0.000609,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(#{(x^2):eq(1):solve(x)}, 2)",
		comment="",
		duration=0.001984,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x^2):eq(1):solve(x), x:eq(1))",
		comment="",
		duration=0.001881,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x^2):eq(1):solve(x)), x:eq(-1))",
		comment="",
		duration=0.001823,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(#{(x^2):eq(-1):solve(x)}, 2)",
		comment="",
		duration=0.002298,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x^2):eq(-1):solve(x), x:eq(i))",
		comment="",
		duration=0.002143,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x^2):eq(-1):solve(x)), x:eq(-i))",
		comment="",
		duration=0.002485,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="print((x^2):eq(0):solve(x))",
		comment="",
		duration=0.001866,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "^:Prune:zeroToTheX", "*:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x^2):eq(0):solve(x)}, 2)",
		comment="",
		duration=0.001543,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x^2):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.001003,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x^2):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.001302,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="same with 3 ...", duration=1.000000000001e-06},
	{
		code="print((x^3):eq(0):solve(x))",
		comment="",
		duration=0.030788,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:zeroToTheX", "*:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x^3):eq(0):solve(x)}, 3)",
		comment="",
		duration=0.019948,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x^3):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.018197,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x^3):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.01804,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x^3):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.018134,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="same with 4 ...", duration=0},
	{
		code="print((x^4):eq(0):solve(x))",
		comment="",
		duration=0.003388,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "^:Prune:zeroToTheX", "*:Prune:apply", "*:Prune:flatten", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x^4):eq(0):solve(x)}, 4)",
		comment="",
		duration=0.004569,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x^4):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.003222,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x^4):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.002516,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x^4):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.002534,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(4, (x^4):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.002645,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="distinguish between x*(x^2 + 2x + 1) and (x^3 + 2x^2 + x) , because the solver handles one but not the other", duration=1.000000000001e-06},
	{
		code="printbr( (x * (x^2 + 2*x + 1)):eq(0):solve(x)  )",
		comment="",
		duration=0.00266,
		simplifyStack={"Init", "*:Prune:apply", "unm:Prune:doubleNegative", "^:Prune:simplifyConstantPowers", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:zeroToTheX", "sqrt:Prune:apply", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x * (x^2 + 2*x + 1)):eq(0):solve(x)}, 3)",
		comment="",
		duration=0.003364,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x * (x^2 + 2*x + 1)):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.007183,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x * (x^2 + 2*x + 1)):eq(0):solve(x)), x:eq(-1))",
		comment="",
		duration=0.004131,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x * (x^2 + 2*x + 1)):eq(0):solve(x)), x:eq(-1))",
		comment="",
		duration=0.00366,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="printbr( (x^3 + 2*x^2 + x):eq(0):solve(x) )",
		comment="",
		duration=0.002807,
		simplifyStack={"Init", "*:Prune:apply", "unm:Prune:doubleNegative", "^:Prune:simplifyConstantPowers", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:zeroToTheX", "sqrt:Prune:apply", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x^3 + 2*x^2 + x):eq(0):solve(x)}, 3)",
		comment="",
		duration=0.002554,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x * (x^2 + 2*x + 1)):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.002224,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x * (x^2 + 2*x + 1)):eq(0):solve(x)), x:eq(-1))",
		comment="",
		duration=0.002342,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x * (x^2 + 2*x + 1)):eq(0):solve(x)), x:eq(-1))",
		comment="",
		duration=0.002847,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="same with x^3 + x^2 - x", duration=1.000000000001e-06},
	{
		code="printbr( (x * (x^2 + x - 1)):eq(0):solve(x)  )",
		comment="",
		duration=0.007316,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "^:Prune:simplifyConstantPowers", "*:Prune:apply", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x * (x^2 + x - 1)):eq(0):solve(x)}, 3)",
		comment="",
		duration=0.007217,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x * (x^2 + x - 1)):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.006578,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x * (x^2 + x - 1)):eq(0):solve(x)), x:eq( -(1 - sqrt(5))/2 ))",
		comment="",
		duration=0.023709,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:107: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:216: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:215>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:107: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(select(2, (x * (x^2 + x - 1)...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:208: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:207>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:207: in function 'exec'\n\9solve.lua:126: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9solve.lua:6: in main chunk\n\9[C]: at 0x55c681e8c3e0",
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "^:Prune:sqrtFix4", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "^:Tidy:apply", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:apply", "*:Prune:flatten", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x * (x^2 + x - 1)):eq(0):solve(x)), x:eq( -(1 + sqrt(5))/2 ))",
		comment="",
		duration=0.011061,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:107: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:216: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:215>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:107: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(select(3, (x * (x^2 + x - 1)...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:208: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:207>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:207: in function 'exec'\n\9solve.lua:126: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9solve.lua:6: in main chunk\n\9[C]: at 0x55c681e8c3e0",
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "^:Prune:sqrtFix4", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=3.3000000000005e-05},
	{
		code="printbr( (x^3 + x^2 - x):eq(0):solve(x) )",
		comment="",
		duration=0.005697,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "^:Prune:simplifyConstantPowers", "*:Prune:apply", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x^3 + x^2 - x):eq(0):solve(x)}, 3)",
		comment="",
		duration=0.006982,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x * (x^2 + x - 1)):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.009365,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x * (x^2 + x - 1)):eq(0):solve(x)), x:eq( -(1 - sqrt(5))/2 ))",
		comment="",
		duration=0.012283,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:107: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:216: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:215>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:107: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(select(2, (x * (x^2 + x - 1)...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:208: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:207>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:207: in function 'exec'\n\9solve.lua:126: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9solve.lua:6: in main chunk\n\9[C]: at 0x55c681e8c3e0",
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "^:Prune:sqrtFix4", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "^:Tidy:apply", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:apply", "*:Prune:flatten", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x * (x^2 + x - 1)):eq(0):solve(x)), x:eq( -(1 + sqrt(5))/2 ))",
		comment="",
		duration=0.012161,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:107: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:216: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:215>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:107: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(select(3, (x * (x^2 + x - 1)...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:208: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:207>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:207: in function 'exec'\n\9solve.lua:126: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9solve.lua:6: in main chunk\n\9[C]: at 0x55c681e8c3e0",
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "^:Prune:sqrtFix4", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	}
}