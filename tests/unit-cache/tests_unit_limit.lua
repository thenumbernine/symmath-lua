{
	{
		code="simplifyAssertEq(lim(x, x, a), a)",
		comment="",
		duration=0.000373,
		simplifyStack={"Init", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x, x, a, '+'), a)",
		comment="",
		duration=0.000347,
		simplifyStack={"Init", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x, x, a, '-'), a)",
		comment="",
		duration=9.5000000000001e-05,
		simplifyStack={"Init", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.9999999999985e-06},
	{code="", comment="constants", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(0, x, a), 0)",
		comment="",
		duration=0.000315,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1, x, a), 1)",
		comment="",
		duration=0.000334,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="ops", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(x + 2, x, a), a + 2)",
		comment="",
		duration=0.003474,
		simplifyStack={"Init", "+:Prune:combineConstants", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x + x, x, a), 2 * a)",
		comment="",
		duration=0.001886,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x + a, x, a), 2 * a)",
		comment="",
		duration=0.002141,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(a + a, x, a), 2 * a)",
		comment="",
		duration=0.001817,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x * 2, x, a), 2 * a)",
		comment="",
		duration=0.000968,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x / 2, x, a), a / 2)",
		comment="",
		duration=0.003382,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{code="", comment="involving infinity", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(x, x, inf), inf)",
		comment="",
		duration=0.000528,
		simplifyStack={"Init", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x, x, -inf), -inf)",
		comment="",
		duration=0.001928,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x, x, inf), inf)",
		comment="",
		duration=9.1000000000001e-05,
		simplifyStack={"Init", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1/x, x, inf), 0)",
		comment="",
		duration=0.000377,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1/x, x, -inf), 0)",
		comment="",
		duration=0.00081000000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1/x, x, 0), invalid)",
		comment="",
		duration=0.001368,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(1/x, x, 0), invalid)\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(1/x, x, 0, '+'), inf)",
		comment="",
		duration=0.003024,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(1/x, x, 0, '+'), inf)\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:handleInfAndNan", "Limit:Prune:apply", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1/x, x, 0, '-'), -inf)",
		comment="",
		duration=0.00085200000000001,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(1/x^2, x, 0, '+'), inf)",
		comment="",
		duration=0.00039699999999999,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1/x^2, x, 0, '-'), inf)",
		comment="",
		duration=0.000319,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="sqrts", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(sqrt(x), x, 0), invalid)",
		comment="",
		duration=0.000614,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sqrt(x), x, 0, '-'), invalid)",
		comment="",
		duration=0.000543,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sqrt(x), x, 0, '+'), 0)",
		comment="",
		duration=0.001097,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(sqrt(x), x, 0, '+'), 0)\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="in each form ...", duration=9.9999999999406e-07},
	{
		code="simplifyAssertEq(lim(x^frac(1,2), x, 0), invalid)",
		comment="",
		duration=0.000879,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x^frac(1,2), x, 0, '-'), invalid)",
		comment="",
		duration=0.000507,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x^frac(1,2), x, 0, '+'), 0)",
		comment="",
		duration=0.001189,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(x^frac(1,2), x, 0, '+'), 0)\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="and one more power up ...", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(x^frac(1,4), x, 0), invalid)",
		comment="",
		duration=0.000432,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x^frac(1,4), x, 0, '-'), invalid)",
		comment="",
		duration=0.00024200000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x^frac(1,4), x, 0, '+'), 0)",
		comment="",
		duration=0.000474,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(x^frac(1,4), x, 0, '+'), 0)\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=9.9999999999406e-07},
	{code="", comment="functions", duration=0},
	{code="", comment="", duration=9.9999999999406e-07},
	{code="", comment="TODO all of these are only good for 'a' in Real, not necessarily extended-Real, because I don't distinguish them", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="another thing to consider ... most these are set up so that the limit is the same as the evaluation without a limit", duration=1.000000000001e-06},
	{code="", comment="technically this is not true.  technically atan(inf) is not pi/2 but is instead undefined outside of the limit.", duration=1.000000000001e-06},
	{code="", comment="should I enforce this?", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(sin(x), x, a), sin(a))",
		comment="",
		duration=0.000398,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sin(x), x, inf), invalid)",
		comment="",
		duration=0.000216,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sin(x), x, -inf), invalid)",
		comment="",
		duration=0.00076,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(cos(x), x, a), cos(a))",
		comment="",
		duration=0.000631,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cos(x), x, inf), invalid)",
		comment="",
		duration=0.000222,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cos(x), x, -inf), invalid)",
		comment="",
		duration=0.00042399999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq(lim(abs(x), x, a), abs(a))",
		comment="",
		duration=0.00031100000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(abs(x), x, -inf), inf)",
		comment="",
		duration=0.00035299999999999,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Limit:Prune:apply", "*:Prune:handleInfAndNan", "abs:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(abs(x), x, inf), inf)",
		comment="",
		duration=0.0001,
		simplifyStack={"Init", "Limit:Prune:apply", "abs:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(exp(x), x, a), exp(a))",
		comment="",
		duration=0.000346,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(exp(x), x, -inf), 0)",
		comment="",
		duration=0.000265,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(exp(x), x, inf), inf)",
		comment="",
		duration=0.00022799999999999,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "^:Prune:handleInfAndNan", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(atan(x), x, a), atan(a))",
		comment="",
		duration=0.00052099999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atan(x), x, -inf), -pi/2)",
		comment="",
		duration=0.003149,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "*:Prune:flatten", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "/:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atan(x), x, inf), pi/2)",
		comment="",
		duration=0.002074,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(tanh(x), x, a), tanh(a))",
		comment="",
		duration=0.000134,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tanh(x), x, -inf), -1)",
		comment="",
		duration=0.00062200000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tanh(x), x, inf), 1)",
		comment="",
		duration=0.00015599999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq(lim(asinh(x), x, a), asinh(a))",
		comment="",
		duration=0.00028,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asinh(x), x, -inf), -inf)",
		comment="",
		duration=0.00066100000000001,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asinh(x), x, inf), inf)",
		comment="",
		duration=6.7000000000011e-05,
		simplifyStack={"Init", "Limit:Prune:apply", "asinh:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq(lim(cosh(x), x, a), cosh(a))",
		comment="",
		duration=0.000193,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cosh(x), x, -inf), inf)",
		comment="",
		duration=0.00045200000000001,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Limit:Prune:apply", "cosh:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cosh(x), x, inf), inf)",
		comment="",
		duration=9.7e-05,
		simplifyStack={"Init", "Limit:Prune:apply", "cosh:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(sinh(x), x, a), sinh(a))",
		comment="",
		duration=0.000125,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sinh(x), x, -inf), -inf)",
		comment="",
		duration=0.00045500000000001,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sinh(x), x, inf), inf)",
		comment="",
		duration=5.0999999999995e-05,
		simplifyStack={"Init", "Limit:Prune:apply", "sinh:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(sin(x), x, a), sin(a))",
		comment="",
		duration=0.00022899999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sin(x), x, -inf), invalid)",
		comment="",
		duration=0.00020099999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sin(x), x, inf), invalid)",
		comment="",
		duration=0.000307,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(cos(x), x, a), cos(a))",
		comment="",
		duration=0.00058,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cos(x), x, -inf), invalid)",
		comment="",
		duration=0.000484,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cos(x), x, inf), invalid)",
		comment="",
		duration=0.000102,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq(lim(tan(x), x, a), tan(a))",
		comment="",
		duration=0.003592,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(tan(x), x, a), tan(a))\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "tan:Prune:apply", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, -inf), invalid)",
		comment="",
		duration=0.000488,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, -3*pi/2), invalid)",
		comment="",
		duration=0.001104,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, -pi), tan(-pi))",
		comment="",
		duration=0.001758,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "sin:Prune:apply", "cos:Prune:apply", "*:Prune:apply", "/:Prune:xOverMinusOne", "tan:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, -pi/2), invalid)",
		comment="",
		duration=0.001356,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, 0), tan(0))",
		comment="",
		duration=0.00067399999999999,
		simplifyStack={"Init", "sin:Prune:apply", "cos:Prune:apply", "/:Prune:xOverOne", "tan:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, pi/2), invalid)",
		comment="",
		duration=0.000899,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, pi/2, '+'), -inf)",
		comment="",
		duration=0.002153,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(tan(x), x, pi/2, '+'), -...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, pi/2, '-'), inf)",
		comment="",
		duration=0.00198,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(tan(x), x, pi/2, '-'), inf)\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "tan:Prune:apply", "Limit:Prune:apply", "sin:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "cos:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "sin:Prune:apply", "cos:Prune:apply", "/:Prune:handleInfAndNan", "tan:Prune:apply", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, pi), tan(pi))",
		comment="",
		duration=0.001571,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(tan(x), x, pi), tan(pi))\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "sin:Prune:apply", "cos:Prune:apply", "*:Prune:apply", "/:Prune:xOverMinusOne", "tan:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, 3*pi/2), invalid)",
		comment="",
		duration=0.00067400000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, inf), invalid)",
		comment="",
		duration=0.00078199999999999,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(tan(x), x, inf), invalid)\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="do local a = set.positiveReal:var'a' simplifyAssertEq(lim(log(x), x, a), log(a)) end",
		comment="if the input is within the domain of the function then we can evaluate it for certain",
		duration=0.000301,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.negativeReal:var'a' simplifyAssertEq(lim(log(x), x, a), invalid) end",
		comment="if the input is outside the domain of the function then we know the result is invalid. TODO is this the same as indeterminate?  Or should I introduce a new singleton?",
		duration=0.00014500000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.real:var'a' print(lim(log(x), x, a):prune()) assert(lim(log(x), x, a):prune() == lim(log(x), x, a)) end",
		comment="if the input covers both the domain and its complement, and we can't determine the limit evaluation, then don't touch the expression",
		duration=0.000359,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:83: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:83: in function 'assert'\n\9[string \"do local a = set.real:var'a' print(lim(log(x)...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(log(x), x, -inf), invalid)",
		comment="",
		duration=0.00021900000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(log(x), x, 0), invalid)",
		comment="",
		duration=9.8000000000001e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(log(x), x, 0, '+'), -inf)",
		comment="",
		duration=0.000652,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(log(x), x, 0, '+'), -inf)\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(log(x), x, inf), inf)",
		comment="",
		duration=0.000386,
		simplifyStack={"Init", "Limit:Prune:apply", "log:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local a = set.RealSubset(-1, 1, false, false):var'a' simplifyAssertEq(lim(acosh(x), x, a), acosh(a)) end",
		comment="",
		duration=0.000557,
		simplifyStack={"Init", "acosh:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.RealSubset(-math.huge, -1, false, false):var'a' simplifyAssertEq(lim(acosh(x), x, a), invalid) end",
		comment="",
		duration=0.00016099999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.real:var'a' print(lim(acosh(x), x, a):prune()) assert(lim(acosh(x), x, a):prune() == lim(acosh(x), x, a)) end",
		comment="",
		duration=0.000495,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:83: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:83: in function 'assert'\n\9[string \"do local a = set.real:var'a' print(lim(acosh(...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(acosh(x), x, -inf), invalid)",
		comment="",
		duration=0.000323,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acosh(x), x, 1), invalid)",
		comment="",
		duration=0.000126,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acosh(x), x, 1, '+'), 0)",
		comment="",
		duration=0.000482,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(acosh(x), x, 1, '+'), 0)\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acosh(x), x, inf), inf)",
		comment="",
		duration=0.00019999999999999,
		simplifyStack={"Init", "Limit:Prune:apply", "acosh:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local a = set.RealSubset(-1, 1, false, false):var'a' simplifyAssertEq(lim(atanh(x), x, a), atanh(a)) end",
		comment="",
		duration=0.00060700000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.RealSubset(-math.huge, -1, false, false):var'a' simplifyAssertEq(lim(atanh(x), x, a), invalid) end",
		comment="",
		duration=0.00015900000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.real:var'a' print(lim(atanh(x), x, a):prune()) assert(lim(atanh(x), x, a):prune() == lim(atanh(x), x, a)) end",
		comment="",
		duration=0.00049200000000001,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:83: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:83: in function 'assert'\n\9[string \"do local a = set.real:var'a' print(lim(atanh(...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, -inf), invalid)",
		comment="",
		duration=0.000195,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, -1), invalid)",
		comment="",
		duration=0.001296,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(atanh(x), x, -1), invalid)\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, -1, '+'), -inf)",
		comment="",
		duration=0.001841,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(atanh(x), x, -1, '+'), -...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, 0), 0)",
		comment="",
		duration=0.00035499999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, 1), invalid)",
		comment="",
		duration=0.001474,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(atanh(x), x, 1), invalid)\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, 1, '-'), inf)",
		comment="",
		duration=0.003578,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(atanh(x), x, 1, '-'), inf)\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "Limit:Prune:apply", "Prune", "Expand", "Limit:Prune:apply", "Prune", "Factor", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, inf), invalid)",
		comment="",
		duration=0.00074300000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local a = set.RealSubset(-1, 1, false, false):var'a' simplifyAssertEq(lim(asin(x), x, a), asin(a)) end",
		comment="",
		duration=0.00052500000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.RealSubset(-math.huge, -1, false, false):var'a' simplifyAssertEq(lim(asin(x), x, a), invalid) end",
		comment="",
		duration=0.000538,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.real:var'a' print(lim(asin(x), x, a):prune()) assert(lim(asin(x), x, a):prune() == lim(asin(x), x, a)) end",
		comment="",
		duration=0.001084,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:83: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:83: in function 'assert'\n\9[string \"do local a = set.real:var'a' print(lim(asin(x...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, -inf), invalid)",
		comment="",
		duration=0.00042,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, -1), invalid)",
		comment="",
		duration=0.00062999999999999,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(asin(x), x, -1), invalid)\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, -1, '+'), -inf)",
		comment="",
		duration=0.00075599999999999,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(asin(x), x, -1, '+'), -inf)\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, 0), 0)",
		comment="",
		duration=0.00015800000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, 1), invalid)",
		comment="",
		duration=0.000652,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(asin(x), x, 1), invalid)\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, 1, '-'), inf)",
		comment="",
		duration=0.000863,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(asin(x), x, 1, '-'), inf)\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, inf), invalid)",
		comment="",
		duration=0.00019,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local a = set.RealSubset(-1, 1, false, false):var'a' simplifyAssertEq(lim(acos(x), x, a), acos(a)) end",
		comment="",
		duration=0.000497,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.RealSubset(-math.huge, -1, false, false):var'a' simplifyAssertEq(lim(acos(x), x, a), invalid) end",
		comment="",
		duration=0.00033000000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.real:var'a' print(lim(acos(x), x, a):prune()) assert(lim(acos(x), x, a):prune() == lim(acos(x), x, a)) end",
		comment="",
		duration=0.000392,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:83: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:83: in function 'assert'\n\9[string \"do local a = set.real:var'a' print(lim(acos(x...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, -inf), invalid)",
		comment="",
		duration=0.000233,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, -1), invalid)",
		comment="",
		duration=0.000122,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, -1, '+'), inf)",
		comment="",
		duration=0.00035,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(acos(x), x, -1, '+'), inf)\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "Limit:Prune:apply", "acos:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, 0), pi/2)",
		comment="",
		duration=0.001794,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, 1), invalid)",
		comment="",
		duration=0.00062999999999999,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(acos(x), x, 1), invalid)\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, 1, '-'), -inf)",
		comment="",
		duration=0.001148,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(acos(x), x, 1, '-'), -inf)\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, inf), invalid)",
		comment="",
		duration=0.00043899999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, a), Heaviside(a))",
		comment="",
		duration=0.000116,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, -inf), 0)",
		comment="",
		duration=0.00028599999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, -1), 0)",
		comment="",
		duration=0.00013300000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, 0), invalid)",
		comment="",
		duration=7.3000000000004e-05,
		error="/home/chris/Projects/lua/symmath/Heaviside.lua:54: got a bad limit side\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/Heaviside.lua:54: in function 'func'\n\9/home/chris/Projects/lua/symmath/visitor/Visitor.lua:213: in function 'prune'\n\9/home/chris/Projects/lua/symmath/simplify.lua:176: in function 'simplify'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:90: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(Heaviside(x), x, 0), inv...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, 0, '-'), 0)",
		comment="",
		duration=6.0999999999992e-05,
		error="/home/chris/Projects/lua/symmath/Heaviside.lua:54: got a bad limit side\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/Heaviside.lua:54: in function 'func'\n\9/home/chris/Projects/lua/symmath/visitor/Visitor.lua:213: in function 'prune'\n\9/home/chris/Projects/lua/symmath/simplify.lua:176: in function 'simplify'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:90: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(Heaviside(x), x, 0, '-')...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, 0, '+'), 1)",
		comment="",
		duration=8.5000000000002e-05,
		error="/home/chris/Projects/lua/symmath/Heaviside.lua:54: got a bad limit side\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/Heaviside.lua:54: in function 'func'\n\9/home/chris/Projects/lua/symmath/visitor/Visitor.lua:213: in function 'prune'\n\9/home/chris/Projects/lua/symmath/simplify.lua:176: in function 'simplify'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:90: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(Heaviside(x), x, 0, '+')...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, 1), 1)",
		comment="",
		duration=0.000305,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, inf), 1)",
		comment="",
		duration=0.00015,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="products of functions", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(x * sin(x), x, a), a * sin(a))",
		comment="",
		duration=0.00087699999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="TODO polynomial roots", duration=0},
	{
		code="simplifyAssertEq(lim(1 / (x - 1), x, 1), invalid)",
		comment="",
		duration=0.003643,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(1 / (x - 1), x, 1), inva...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1 / (x - 1), x, 1, '+'), inf)",
		comment="",
		duration=0.003502,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(1 / (x - 1), x, 1, '+'),...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "+:Prune:combineConstants", "Limit:Prune:apply", "Prune", "Expand", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "+:Prune:combineConstants", "Limit:Prune:apply", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "+:Prune:combineConstants", "Limit:Prune:apply", "Prune", "Expand", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "+:Prune:combineConstants", "Limit:Prune:apply", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "+:Prune:combineConstants", "Limit:Prune:apply", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1 / (x - 1), x, 1, '-'), -inf)",
		comment="",
		duration=0.003329,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(1 / (x - 1), x, 1, '-'),...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim((x + 1) / (x^2 - 1), x, 1), invalid)",
		comment="",
		duration=0.010305,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim((x + 1) / (x^2 - 1), x, ...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim((x + 1) / (x^2 - 1), x, 1, '+'), inf)",
		comment="",
		duration=0.010493,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim((x + 1) / (x^2 - 1), x, ...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "Limit:Prune:apply", "Limit:Prune:apply", "+:Prune:combineConstants", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "^:Prune:simplifyConstantPowers", "Limit:Prune:apply", "+:Prune:combineConstants", "Limit:Prune:apply", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "+:Prune:combineConstants", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "^:Prune:simplifyConstantPowers", "Limit:Prune:apply", "+:Prune:combineConstants", "Limit:Prune:apply", "Prune", "+:Factor:apply", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim((x + 1) / (x^2 - 1), x, 1, '-'), -inf)",
		comment="",
		duration=0.01025,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim((x + 1) / (x^2 - 1), x, ...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="can we evaluate derivatives as limits?  yes.", duration=1.000000000001e-06},
	{
		code="difftest(x)",
		comment="",
		duration=0.001683,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="difftest(c * x)",
		comment="",
		duration=0.003661,
		simplifyStack={"Init", "Derivative:Prune:self", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy", "Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="difftest(x^2)",
		comment="",
		duration=0.003601,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="difftest(x^3)",
		comment="",
		duration=0.009522,
		simplifyStack={"Init", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="difftest(1/x)",
		comment="",
		duration=0.006843,
		simplifyStack={"Init", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "^:ExpandPolynomial:apply", "+:Prune:combineConstants", "*:Prune:apply", "/:Factor:polydiv", "Factor", "/:Prune:xOverMinusOne", "*:Prune:apply", "*:Prune:flatten", "Prune", "Constant:Tidy:apply", "/:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="can't handle these yet.", duration=0},
	{code="", comment="TODO give unit tests a 'reach' section?", duration=1.000000000001e-06},
	{code="", comment="so console can show that these tests aren't 100% certified.", duration=1.000000000001e-06},
	{code="", comment="use infinite taylor expansion?", duration=1.000000000001e-06},
	{code="", comment="or just use L'Hospital's rule -- that solves these too, because, basically, that replaces the limit with the derivative, so it will always be equal.", duration=0},
	{
		code="difftest(sqrt(x))",
		comment="",
		duration=0.11842,
		simplifyStack={"Init", "Prune", "Expand", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "/:Prune:xOverX", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "^:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="difftest(sin(x))",
		comment="",
		duration=0.001513,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="difftest(cos(x))",
		comment="",
		duration=0.002865,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="difftest(exp(x))",
		comment="",
		duration=0.002273,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999997324e-07},
	{code="", comment="some other L'Hospital rule problems:", duration=9.9999999997324e-07},
	{
		code="simplifyAssertEq(lim(sin(x) / x, x, 0), 1)",
		comment="",
		duration=0.00049700000000003,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(exp(x) / x^2, x, inf), inf)",
		comment="",
		duration=0.001792,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "^:Prune:handleInfAndNan", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "^:Prune:handleInfAndNan", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim((e^x - 1) / (x^2 + x), x, 0), 1)",
		comment="",
		duration=0.001722,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim((2*sin(x) - sin(2*x)) / (x - sin(x)), x, 0), 6)",
		comment="",
		duration=0.010677,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999997324e-07},
	{code="", comment="TODO this one, repeatedly apply L'Hospital until the power of x on top is <= 0", duration=1.0000000000288e-06},
	{code="", comment="but this seems like it would need a special case of evaluating into a factorial", duration=9.9999999997324e-07},
	{
		code="simplifyAssertEq(lim(x^n * e^x, x, 0), 0)",
		comment="",
		duration=0.00098999999999999,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(x^n * e^x, x, 0), 0)\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.0000000000288e-06},
	{code="", comment="TODO this requires representing x ln x as (ln x) / (1/x) before applying L'Hospital", duration=0},
	{
		code="simplifyAssertEq(lim(x * log(x), x, 0, '+'), 0)",
		comment="",
		duration=0.002614,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:211: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:210>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:102: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(x * log(x), x, 0, '+'), 0)\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:203: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:202>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:202: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x559a7eae13e0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999997324e-07},
	{code="", comment="mortgage repayment formula -- works", duration=1.0000000000288e-06},
	{
		code="simplifyAssertEq(lim( (a * x * (1 + x)^n) / ((1 + x)^n - 1), x, 0 ), a / n)",
		comment="",
		duration=0.010944,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.0000000000288e-06},
	{code="", comment="the infamous tanh(x) ... works?  hmm ... this is infamous for taking an infinite number of L'Hospital applications.  Why is it working?", duration=0},
	{
		code="print( ((e^x + e^-x) / (e^x - e^-x)):lim(x, inf):prune() )",
		comment="",
		duration=0.010774,
		simplifyStack={"Init", "Derivative:Prune:constants", "Derivative:Prune:constants", "*:Prune:apply", "Derivative:Prune:self", "*:Prune:apply", "+:Prune:combineConstants", "Derivative:Prune:eval", "log:Prune:apply", "*:Prune:apply", "Derivative:Prune:other", "*:Prune:apply", "/:Prune:zeroOverX", "+:Prune:combineConstants", "Derivative:Prune:eval", "+:Prune:combineConstants", "Derivative:Prune:eval", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "*:Tidy:apply", "Tidy", "/:Prune:xOverX", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply"}
	}
}