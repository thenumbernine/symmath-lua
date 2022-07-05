{
	{
		code="simplifyAssertEq(lim(x, x, a), a)",
		comment="",
		duration=0.000996,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x, x, a, '+'), a)",
		comment="",
		duration=0.000392,
		simplifyStack={"Init", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x, x, a, '-'), a)",
		comment="",
		duration=0.000478,
		simplifyStack={"Init", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="constants", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(0, x, a), 0)",
		comment="",
		duration=0.00094399999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1, x, a), 1)",
		comment="",
		duration=0.000857,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="ops", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(x + 2, x, a), a + 2)",
		comment="",
		duration=0.004253,
		simplifyStack={"Init", "+:Prune:combineConstants", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x + x, x, a), 2 * a)",
		comment="",
		duration=0.004453,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x + a, x, a), 2 * a)",
		comment="",
		duration=0.003147,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(a + a, x, a), 2 * a)",
		comment="",
		duration=0.003968,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x * 2, x, a), 2 * a)",
		comment="",
		duration=0.004164,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x / 2, x, a), a / 2)",
		comment="",
		duration=0.004605,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="involving infinity", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(x, x, inf), inf)",
		comment="",
		duration=0.000684,
		simplifyStack={"Init", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x, x, -inf), -inf)",
		comment="",
		duration=0.000971,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x, x, inf), inf)",
		comment="",
		duration=0.000348,
		simplifyStack={"Init", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1/x, x, inf), 0)",
		comment="",
		duration=0.001331,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1/x, x, -inf), 0)",
		comment="",
		duration=0.001442,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1/x, x, 0), invalid)",
		comment="",
		duration=0.002073,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq(lim(1/x, x, 0, '+'), inf)",
		comment="",
		duration=0.001132,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1/x, x, 0, '-'), -inf)",
		comment="",
		duration=0.001727,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=9.9999999998712e-07},
	{
		code="simplifyAssertEq(lim(1/x^2, x, 0, '+'), inf)",
		comment="",
		duration=0.005117,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1/x^2, x, 0, '-'), inf)",
		comment="",
		duration=0.003219,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="sqrts", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(sqrt(x), x, 0), invalid)",
		comment="",
		duration=0.000961,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sqrt(x), x, 0, '-'), invalid)",
		comment="",
		duration=0.00067199999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sqrt(x), x, 0, '+'), 0)",
		comment="",
		duration=0.000998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="in each form ...", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(x^frac(1,2), x, 0), invalid)",
		comment="",
		duration=0.00087599999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x^frac(1,2), x, 0, '-'), invalid)",
		comment="",
		duration=0.001137,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x^frac(1,2), x, 0, '+'), 0)",
		comment="",
		duration=0.000725,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="and one more power up ...", duration=0},
	{
		code="simplifyAssertEq(lim(x^frac(1,4), x, 0), invalid)",
		comment="",
		duration=0.001115,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x^frac(1,4), x, 0, '-'), invalid)",
		comment="",
		duration=0.00072899999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x^frac(1,4), x, 0, '+'), 0)",
		comment="",
		duration=0.00079900000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=0},
	{code="", comment="functions", duration=9.9999999998712e-07},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="TODO all of these are only good for 'a' in Real, not necessarily extended-Real, because I don't distinguish them", duration=1.000000000001e-06},
	{code="", comment="", duration=9.9999999998712e-07},
	{code="", comment="another thing to consider ... most these are set up so that the limit is the same as the evaluation without a limit", duration=1.000000000001e-06},
	{code="", comment="technically this is not true.  technically atan(inf) is not pi/2 but is instead undefined outside of the limit.", duration=1.000000000001e-06},
	{code="", comment="should I enforce this?", duration=9.9999999998712e-07},
	{
		code="simplifyAssertEq(lim(sin(x), x, a), sin(a))",
		comment="",
		duration=0.000787,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sin(x), x, inf), invalid)",
		comment="",
		duration=0.00031200000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sin(x), x, -inf), invalid)",
		comment="",
		duration=0.00096400000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(cos(x), x, a), cos(a))",
		comment="",
		duration=0.001086,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cos(x), x, inf), invalid)",
		comment="",
		duration=0.000389,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cos(x), x, -inf), invalid)",
		comment="",
		duration=0.00063600000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(abs(x), x, a), abs(a))",
		comment="",
		duration=0.00038100000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(abs(x), x, -inf), inf)",
		comment="",
		duration=0.00064699999999999,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Limit:Prune:apply", "*:Prune:handleInfAndNan", "abs:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(abs(x), x, inf), inf)",
		comment="",
		duration=0.00030999999999999,
		simplifyStack={"Init", "Limit:Prune:apply", "abs:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq(lim(exp(x), x, a), exp(a))",
		comment="",
		duration=0.00082399999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(exp(x), x, -inf), 0)",
		comment="",
		duration=0.000566,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(exp(x), x, inf), inf)",
		comment="",
		duration=0.00036700000000001,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "^:Prune:handleInfAndNan", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(atan(x), x, a), atan(a))",
		comment="",
		duration=0.000888,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atan(x), x, -inf), -pi/2)",
		comment="",
		duration=0.004579,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "*:Prune:flatten", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "/:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atan(x), x, inf), pi/2)",
		comment="",
		duration=0.003455,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{code="", comment="", duration=2.9000000000001e-05},
	{
		code="simplifyAssertEq(lim(tanh(x), x, a), tanh(a))",
		comment="",
		duration=0.00071499999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tanh(x), x, -inf), -1)",
		comment="",
		duration=0.001407,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tanh(x), x, inf), 1)",
		comment="",
		duration=0.000598,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(asinh(x), x, a), asinh(a))",
		comment="",
		duration=0.00085500000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asinh(x), x, -inf), -inf)",
		comment="",
		duration=0.001189,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asinh(x), x, inf), inf)",
		comment="",
		duration=0.000374,
		simplifyStack={"Init", "Limit:Prune:apply", "asinh:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(cosh(x), x, a), cosh(a))",
		comment="",
		duration=0.00081299999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cosh(x), x, -inf), inf)",
		comment="",
		duration=0.00041300000000001,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Limit:Prune:apply", "cosh:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cosh(x), x, inf), inf)",
		comment="",
		duration=0.00036899999999999,
		simplifyStack={"Init", "Limit:Prune:apply", "cosh:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(sinh(x), x, a), sinh(a))",
		comment="",
		duration=0.00064999999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sinh(x), x, -inf), -inf)",
		comment="",
		duration=0.000832,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sinh(x), x, inf), inf)",
		comment="",
		duration=0.00026500000000002,
		simplifyStack={"Init", "Limit:Prune:apply", "sinh:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(sin(x), x, a), sin(a))",
		comment="",
		duration=0.00056900000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sin(x), x, -inf), invalid)",
		comment="",
		duration=0.00048199999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sin(x), x, inf), invalid)",
		comment="",
		duration=0.000359,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(cos(x), x, a), cos(a))",
		comment="",
		duration=0.000614,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cos(x), x, -inf), invalid)",
		comment="",
		duration=0.00081200000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cos(x), x, inf), invalid)",
		comment="",
		duration=0.00044999999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(tan(x), x, a), tan(a))",
		comment="",
		duration=0.006665,
		simplifyStack={"Init", "tan:Prune:apply", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, -inf), invalid)",
		comment="",
		duration=0.00081100000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, -3*pi/2), invalid)",
		comment="",
		duration=0.002897,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, -pi), tan(-pi))",
		comment="",
		duration=0.002665,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "sin:Prune:apply", "cos:Prune:apply", "*:Prune:apply", "/:Prune:xOverMinusOne", "tan:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, -pi/2), invalid)",
		comment="",
		duration=0.002203,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, 0), tan(0))",
		comment="",
		duration=0.00093399999999999,
		simplifyStack={"Init", "sin:Prune:apply", "cos:Prune:apply", "/:Prune:xOverOne", "tan:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, pi/2), invalid)",
		comment="",
		duration=0.00095399999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, pi/2, '+'), -inf)",
		comment="",
		duration=0.001633,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, pi/2, '-'), inf)",
		comment="",
		duration=0.000999,
		simplifyStack={"Init", "tan:Prune:apply", "Limit:Prune:apply", "sin:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "cos:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, pi), tan(pi))",
		comment="",
		duration=0.001374,
		simplifyStack={"Init", "sin:Prune:apply", "cos:Prune:apply", "*:Prune:apply", "/:Prune:xOverMinusOne", "tan:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, 3*pi/2), invalid)",
		comment="",
		duration=0.001938,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, inf), invalid)",
		comment="",
		duration=0.001041,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="do local a = set.positiveReal:var'a' simplifyAssertEq(lim(log(x), x, a), log(a)) end",
		comment="if the input is within the domain of the function then we can evaluate it for certain",
		duration=0.00084100000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.negativeReal:var'a' simplifyAssertEq(lim(log(x), x, a), invalid) end",
		comment="if the input is outside the domain of the function then we know the result is invalid. TODO is this the same as indeterminate?  Or should I introduce a new singleton?",
		duration=0.00092199999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.real:var'a' print(lim(log(x), x, a):prune()) assert(lim(log(x), x, a):prune() == lim(log(x), x, a)) end",
		comment="if the input covers both the domain and its complement, and we can't determine the limit evaluation, then don't touch the expression",
		duration=0.001431,
		simplifyStack={"Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(log(x), x, -inf), invalid)",
		comment="",
		duration=0.00093199999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(log(x), x, 0), invalid)",
		comment="",
		duration=0.000476,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(log(x), x, 0, '+'), -inf)",
		comment="",
		duration=0.00079800000000002,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(log(x), x, inf), inf)",
		comment="",
		duration=0.00023799999999999,
		simplifyStack={"Init", "Limit:Prune:apply", "log:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local a = set.RealSubset(-1, 1, false, false):var'a' simplifyAssertEq(lim(acosh(x), x, a), acosh(a)) end",
		comment="",
		duration=0.000856,
		simplifyStack={"Init", "acosh:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.RealSubset(-math.huge, -1, false, false):var'a' simplifyAssertEq(lim(acosh(x), x, a), invalid) end",
		comment="",
		duration=0.00059099999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.real:var'a' print(lim(acosh(x), x, a):prune()) assert(lim(acosh(x), x, a):prune() == lim(acosh(x), x, a)) end",
		comment="",
		duration=0.00054199999999999,
		simplifyStack={"Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(acosh(x), x, -inf), invalid)",
		comment="",
		duration=0.00064700000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acosh(x), x, 1), invalid)",
		comment="",
		duration=0.00049399999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acosh(x), x, 1, '+'), 0)",
		comment="",
		duration=0.00033899999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acosh(x), x, inf), inf)",
		comment="",
		duration=0.000551,
		simplifyStack={"Init", "Limit:Prune:apply", "acosh:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local a = set.RealSubset(-1, 1, false, false):var'a' simplifyAssertEq(lim(atanh(x), x, a), atanh(a)) end",
		comment="",
		duration=0.001144,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.RealSubset(-math.huge, -1, false, false):var'a' simplifyAssertEq(lim(atanh(x), x, a), invalid) end",
		comment="",
		duration=0.00050499999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.real:var'a' print(lim(atanh(x), x, a):prune()) assert(lim(atanh(x), x, a):prune() == lim(atanh(x), x, a)) end",
		comment="",
		duration=0.00059300000000001,
		simplifyStack={"Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, -inf), invalid)",
		comment="",
		duration=0.00043399999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, -1), invalid)",
		comment="",
		duration=0.001008,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, -1, '+'), -inf)",
		comment="",
		duration=0.00074399999999999,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, 0), 0)",
		comment="",
		duration=0.00064700000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, 1), invalid)",
		comment="",
		duration=0.00109,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, 1, '-'), inf)",
		comment="",
		duration=0.00024199999999999,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, inf), invalid)",
		comment="",
		duration=0.00098200000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local a = set.RealSubset(-1, 1, false, false):var'a' simplifyAssertEq(lim(asin(x), x, a), asin(a)) end",
		comment="",
		duration=0.00074299999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.RealSubset(-math.huge, -1, false, false):var'a' simplifyAssertEq(lim(asin(x), x, a), invalid) end",
		comment="",
		duration=0.00037400000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.real:var'a' print(lim(asin(x), x, a):prune()) assert(lim(asin(x), x, a):prune() == lim(asin(x), x, a)) end",
		comment="",
		duration=0.00068600000000002,
		simplifyStack={"Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, -inf), invalid)",
		comment="",
		duration=0.00037299999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, -1), invalid)",
		comment="",
		duration=0.0012,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, -1, '+'), -inf)",
		comment="",
		duration=0.001018,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, 0), 0)",
		comment="",
		duration=0.000305,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, 1), invalid)",
		comment="",
		duration=0.00045099999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, 1, '-'), inf)",
		comment="",
		duration=0.00025700000000001,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, inf), invalid)",
		comment="",
		duration=0.000365,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local a = set.RealSubset(-1, 1, false, false):var'a' simplifyAssertEq(lim(acos(x), x, a), acos(a)) end",
		comment="",
		duration=0.00062299999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.RealSubset(-math.huge, -1, false, false):var'a' simplifyAssertEq(lim(acos(x), x, a), invalid) end",
		comment="",
		duration=0.000642,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.real:var'a' print(lim(acos(x), x, a):prune()) assert(lim(acos(x), x, a):prune() == lim(acos(x), x, a)) end",
		comment="",
		duration=0.00064900000000001,
		simplifyStack={"Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, -inf), invalid)",
		comment="",
		duration=0.001673,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, -1), invalid)",
		comment="",
		duration=0.00048999999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, -1, '+'), inf)",
		comment="",
		duration=0.00021699999999999,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, 0), pi/2)",
		comment="",
		duration=0.001928,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, 1), invalid)",
		comment="",
		duration=0.00042900000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, 1, '-'), -inf)",
		comment="",
		duration=0.001381,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, inf), invalid)",
		comment="",
		duration=0.001302,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, a), Heaviside(a))",
		comment="",
		duration=0.00034600000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, -inf), 0)",
		comment="",
		duration=0.000586,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, -1), 0)",
		comment="",
		duration=0.00031599999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, 0), invalid)",
		comment="",
		duration=0.000336,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, 0, '-'), 0)",
		comment="",
		duration=0.00026100000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, 0, '+'), 1)",
		comment="",
		duration=0.00032599999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, 1), 1)",
		comment="",
		duration=0.00051200000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, inf), 1)",
		comment="",
		duration=0.000332,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="products of functions", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(x * sin(x), x, a), a * sin(a))",
		comment="",
		duration=0.001631,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="TODO polynomial roots", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(1 / (x - 1), x, 1), invalid)",
		comment="",
		duration=0.003649,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1 / (x - 1), x, 1, '+'), inf)",
		comment="",
		duration=0.001642,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "+:Prune:combineConstants", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1 / (x - 1), x, 1, '-'), -inf)",
		comment="",
		duration=0.001939,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim((x + 1) / (x^2 - 1), x, 1), invalid)",
		comment="",
		duration=0.015428,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim((x + 1) / (x^2 - 1), x, 1, '+'), inf)",
		comment="",
		duration=0.011035,
		simplifyStack={"Init", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "Limit:Prune:apply", "Limit:Prune:apply", "+:Prune:combineConstants", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "^:Prune:simplifyConstantPowers", "Limit:Prune:apply", "+:Prune:combineConstants", "Limit:Prune:apply", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "+:Prune:combineConstants", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "^:Prune:simplifyConstantPowers", "Limit:Prune:apply", "+:Prune:combineConstants", "Limit:Prune:apply", "Prune", "+:Factor:apply", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim((x + 1) / (x^2 - 1), x, 1, '-'), -inf)",
		comment="",
		duration=0.009733,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="can we evaluate derivatives as limits?  yes.", duration=1.000000000001e-06},
	{
		code="difftest(x)",
		comment="",
		duration=0.001085,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="difftest(c * x)",
		comment="",
		duration=0.002844,
		simplifyStack={"Init", "Derivative:Prune:self", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy", "Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="difftest(x^2)",
		comment="",
		duration=0.005332,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="difftest(x^3)",
		comment="",
		duration=0.013794,
		simplifyStack={"Init", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="difftest(1/x)",
		comment="",
		duration=0.011139,
		simplifyStack={"Init", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "^:ExpandPolynomial:apply", "+:Prune:combineConstants", "*:Prune:apply", "/:Factor:polydiv", "Factor", "/:Prune:xOverMinusOne", "*:Prune:apply", "*:Prune:flatten", "Prune", "Constant:Tidy:apply", "/:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=9.9999999997324e-07},
	{code="", comment="can't handle these yet.", duration=0},
	{code="", comment="TODO give unit tests a 'reach' section?", duration=1.0000000000288e-06},
	{code="", comment="so console can show that these tests aren't 100% certified.", duration=9.9999999997324e-07},
	{code="", comment="use infinite taylor expansion?", duration=9.9999999997324e-07},
	{code="", comment="or just use L'Hospital's rule -- that solves these too, because, basically, that replaces the limit with the derivative, so it will always be equal.", duration=1.0000000000288e-06},
	{
		code="difftest(sqrt(x))",
		comment="",
		duration=0.182706,
		simplifyStack={"Init", "Prune", "Expand", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "/:Prune:xOverX", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "^:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="difftest(sin(x))",
		comment="",
		duration=0.002923,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="difftest(cos(x))",
		comment="",
		duration=0.0041,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="difftest(exp(x))",
		comment="",
		duration=0.003497,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.0000000000288e-06},
	{code="", comment="some other L'Hospital rule problems:", duration=9.9999999997324e-07},
	{
		code="simplifyAssertEq(lim(sin(x) / x, x, 0), 1)",
		comment="",
		duration=0.00135,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(exp(x) / x^2, x, inf), inf)",
		comment="",
		duration=0.004611,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "^:Prune:handleInfAndNan", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "^:Prune:handleInfAndNan", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim((e^x - 1) / (x^2 + x), x, 0), 1)",
		comment="",
		duration=0.005865,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim((2*sin(x) - sin(2*x)) / (x - sin(x)), x, 0), 6)",
		comment="",
		duration=0.035447,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999991773e-07},
	{code="", comment="TODO this one, repeatedly apply L'Hospital until the power of x on top is <= 0", duration=1.0000000000288e-06},
	{code="", comment="but this seems like it would need a special case of evaluating into a factorial", duration=0},
	{
		code="simplifyAssertEq(lim(x^n * e^x, x, 0), 0)",
		comment="",
		duration=0.0020019999999999,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:108: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:227: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:226>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:108: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(x^n * e^x, x, 0), 0)\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:219: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:218>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:218: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x55b1047562f0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.0000000000288e-06},
	{code="", comment="TODO this requires representing x ln x as (ln x) / (1/x) before applying L'Hospital", duration=1.0000000000288e-06},
	{
		code="simplifyAssertEq(lim(x * log(x), x, 0, '+'), 0)",
		comment="",
		duration=0.00050899999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.0000000000288e-06},
	{code="", comment="mortgage repayment formula -- works", duration=1.0000000000288e-06},
	{
		code="simplifyAssertEq(lim( (a * x * (1 + x)^n) / ((1 + x)^n - 1), x, 0 ), a / n)",
		comment="",
		duration=0.036099,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.0000000000288e-06},
	{code="", comment="the infamous tanh(x) ... works?  hmm ... this is infamous for taking an infinite number of L'Hospital applications.  Why is it working?", duration=1.0000000000288e-06},
	{
		code="print( ((e^x + e^-x) / (e^x - e^-x)):lim(x, inf):prune() )",
		comment="",
		duration=0.01616,
		simplifyStack={"Init", "Derivative:Prune:constants", "Derivative:Prune:constants", "*:Prune:apply", "Derivative:Prune:self", "*:Prune:apply", "+:Prune:combineConstants", "Derivative:Prune:eval", "log:Prune:apply", "*:Prune:apply", "Derivative:Prune:other", "*:Prune:apply", "/:Prune:zeroOverX", "+:Prune:combineConstants", "Derivative:Prune:eval", "+:Prune:combineConstants", "Derivative:Prune:eval", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "*:Tidy:apply", "Tidy", "/:Prune:xOverX", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply"}
	}
}