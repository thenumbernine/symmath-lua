{
	{
		code="simplifyAssertEq(lim(x, x, a), a)",
		comment="",
		duration=0.000512,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x, x, a, '+'), a)",
		comment="",
		duration=0.000245,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x, x, a, '-'), a)",
		comment="",
		duration=0.000125,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{code="", comment="constants", duration=9.9999999999406e-07},
	{
		code="simplifyAssertEq(lim(0, x, a), 0)",
		comment="",
		duration=0.00075099999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1, x, a), 1)",
		comment="",
		duration=0.000442,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="ops", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(x + 2, x, a), a + 2)",
		comment="",
		duration=0.005438,
		simplifyStack={"Init", "+:Prune:combineConstants", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x + x, x, a), 2 * a)",
		comment="",
		duration=0.002724,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x + a, x, a), 2 * a)",
		comment="",
		duration=0.002139,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(a + a, x, a), 2 * a)",
		comment="",
		duration=0.001503,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x * 2, x, a), 2 * a)",
		comment="",
		duration=0.001389,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x / 2, x, a), a / 2)",
		comment="",
		duration=0.003574,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="involving infinity", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(x, x, inf), inf)",
		comment="",
		duration=0.00015200000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x, x, -inf), -inf)",
		comment="",
		duration=0.000437,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x, x, inf), inf)",
		comment="",
		duration=8.8999999999999e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1/x, x, inf), 0)",
		comment="",
		duration=0.000492,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1/x, x, -inf), 0)",
		comment="",
		duration=0.000826,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1/x, x, 0), invalid)",
		comment="",
		duration=0.000971,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(1/x, x, 0, '+'), inf)",
		comment="",
		duration=0.000394,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1/x, x, 0, '-'), -inf)",
		comment="",
		duration=0.000945,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{
		code="simplifyAssertEq(lim(1/x^2, x, 0, '+'), inf)",
		comment="",
		duration=0.002773,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1/x^2, x, 0, '-'), inf)",
		comment="",
		duration=0.00373,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="sqrts", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(sqrt(x), x, 0), invalid)",
		comment="",
		duration=0.002017,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sqrt(x), x, 0, '-'), invalid)",
		comment="",
		duration=0.000537,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sqrt(x), x, 0, '+'), 0)",
		comment="",
		duration=0.00091000000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="in each form ...", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(x^frac(1,2), x, 0), invalid)",
		comment="",
		duration=0.001059,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x^frac(1,2), x, 0, '-'), invalid)",
		comment="",
		duration=0.000972,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x^frac(1,2), x, 0, '+'), 0)",
		comment="",
		duration=0.001666,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="and one more power up ...", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(x^frac(1,4), x, 0), invalid)",
		comment="",
		duration=0.001282,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x^frac(1,4), x, 0, '-'), invalid)",
		comment="",
		duration=0.000608,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x^frac(1,4), x, 0, '+'), 0)",
		comment="",
		duration=0.000402,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="functions", duration=9.9999999998712e-07},
	{code="", comment="", duration=0},
	{code="", comment="TODO all of these are only good for 'a' in Real, not necessarily extended-Real, because I don't distinguish them", duration=0},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="another thing to consider ... most these are set up so that the limit is the same as the evaluation without a limit", duration=1.000000000001e-06},
	{code="", comment="technically this is not true.  technically atan(inf) is not pi/2 but is instead undefined outside of the limit.", duration=1.000000000001e-06},
	{code="", comment="should I enforce this?", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(sin(x), x, a), sin(a))",
		comment="",
		duration=0.000455,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sin(x), x, inf), invalid)",
		comment="",
		duration=0.000127,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sin(x), x, -inf), invalid)",
		comment="",
		duration=0.000386,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(cos(x), x, a), cos(a))",
		comment="",
		duration=0.000539,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cos(x), x, inf), invalid)",
		comment="",
		duration=0.000125,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cos(x), x, -inf), invalid)",
		comment="",
		duration=0.000691,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(abs(x), x, a), abs(a))",
		comment="",
		duration=0.00036900000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(abs(x), x, -inf), inf)",
		comment="",
		duration=0.00032199999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(abs(x), x, inf), inf)",
		comment="",
		duration=0.00010599999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(exp(x), x, a), exp(a))",
		comment="",
		duration=0.00065,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(exp(x), x, -inf), 0)",
		comment="",
		duration=0.000322,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(exp(x), x, inf), inf)",
		comment="",
		duration=0.00026,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(atan(x), x, a), atan(a))",
		comment="",
		duration=0.000346,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atan(x), x, -inf), -pi/2)",
		comment="",
		duration=0.004499,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "*:Prune:flatten", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "/:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atan(x), x, inf), pi/2)",
		comment="",
		duration=0.002433,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(tanh(x), x, a), tanh(a))",
		comment="",
		duration=0.000292,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tanh(x), x, -inf), -1)",
		comment="",
		duration=0.000248,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tanh(x), x, inf), 1)",
		comment="",
		duration=0.000393,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(asinh(x), x, a), asinh(a))",
		comment="",
		duration=0.000365,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asinh(x), x, -inf), -inf)",
		comment="",
		duration=0.000865,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asinh(x), x, inf), inf)",
		comment="",
		duration=0.00010600000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(cosh(x), x, a), cosh(a))",
		comment="",
		duration=0.000335,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cosh(x), x, -inf), inf)",
		comment="",
		duration=0.000609,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cosh(x), x, inf), inf)",
		comment="",
		duration=0.00011499999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(sinh(x), x, a), sinh(a))",
		comment="",
		duration=0.000259,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sinh(x), x, -inf), -inf)",
		comment="",
		duration=0.000845,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sinh(x), x, inf), inf)",
		comment="",
		duration=0.00010399999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(sin(x), x, a), sin(a))",
		comment="",
		duration=0.000276,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sin(x), x, -inf), invalid)",
		comment="",
		duration=0.00067500000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sin(x), x, inf), invalid)",
		comment="",
		duration=0.000116,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(cos(x), x, a), cos(a))",
		comment="",
		duration=0.000253,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cos(x), x, -inf), invalid)",
		comment="",
		duration=0.00035199999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cos(x), x, inf), invalid)",
		comment="",
		duration=0.000108,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(tan(x), x, a), tan(a))",
		comment="",
		duration=0.00376,
		simplifyStack={"Init", "tan:Prune:apply", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, -inf), invalid)",
		comment="",
		duration=0.00083800000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, -3*pi/2), invalid)",
		comment="",
		duration=0.007485,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, -pi), tan(-pi))",
		comment="",
		duration=0.002309,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "sin:Prune:apply", "cos:Prune:apply", "*:Prune:apply", "/:Prune:xOverMinusOne", "tan:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, -pi/2), invalid)",
		comment="",
		duration=0.004899,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, 0), tan(0))",
		comment="",
		duration=0.001047,
		simplifyStack={"Init", "sin:Prune:apply", "cos:Prune:apply", "/:Prune:xOverOne", "tan:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, pi/2), invalid)",
		comment="",
		duration=0.00519,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, pi/2, '+'), -inf)",
		comment="",
		duration=0.001016,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, pi/2, '-'), inf)",
		comment="",
		duration=0.000723,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, pi), tan(pi))",
		comment="",
		duration=0.000848,
		simplifyStack={"Init", "sin:Prune:apply", "cos:Prune:apply", "*:Prune:apply", "/:Prune:xOverMinusOne", "tan:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, 3*pi/2), invalid)",
		comment="",
		duration=0.002545,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, inf), invalid)",
		comment="",
		duration=0.000496,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local a = set.positiveReal:var'a' simplifyAssertEq(lim(log(x), x, a), log(a)) end",
		comment="if the input is within the domain of the function then we can evaluate it for certain",
		duration=0.000689,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.negativeReal:var'a' simplifyAssertEq(lim(log(x), x, a), invalid) end",
		comment="if the input is outside the domain of the function then we know the result is invalid. TODO is this the same as indeterminate?  Or should I introduce a new singleton?",
		duration=0.00086900000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.real:var'a' print(lim(log(x), x, a):prune()) assert(lim(log(x), x, a):prune() == lim(log(x), x, a)) end",
		comment="if the input covers both the domain and its complement, and we can't determine the limit evaluation, then don't touch the expression",
		duration=0.000918,
		simplifyStack={"Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(log(x), x, -inf), invalid)",
		comment="",
		duration=0.00031400000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(log(x), x, 0), invalid)",
		comment="",
		duration=0.000224,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(log(x), x, 0, '+'), -inf)",
		comment="",
		duration=0.00041200000000002,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(log(x), x, inf), inf)",
		comment="",
		duration=0.00017499999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local a = set.RealSubset(-1, 1, false, false):var'a' simplifyAssertEq(lim(acosh(x), x, a), acosh(a)) end",
		comment="",
		duration=0.00031299999999998,
		simplifyStack={"Init", "acosh:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.RealSubset(-math.huge, -1, false, false):var'a' simplifyAssertEq(lim(acosh(x), x, a), invalid) end",
		comment="",
		duration=0.000337,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.real:var'a' print(lim(acosh(x), x, a):prune()) assert(lim(acosh(x), x, a):prune() == lim(acosh(x), x, a)) end",
		comment="",
		duration=0.00064399999999998,
		simplifyStack={"Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(acosh(x), x, -inf), invalid)",
		comment="",
		duration=0.000218,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acosh(x), x, 1), invalid)",
		comment="",
		duration=0.00018899999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acosh(x), x, 1, '+'), 0)",
		comment="",
		duration=0.00012700000000002,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acosh(x), x, inf), inf)",
		comment="",
		duration=0.000109,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local a = set.RealSubset(-1, 1, false, false):var'a' simplifyAssertEq(lim(atanh(x), x, a), atanh(a)) end",
		comment="",
		duration=0.00157,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.RealSubset(-math.huge, -1, false, false):var'a' simplifyAssertEq(lim(atanh(x), x, a), invalid) end",
		comment="",
		duration=0.00045999999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.real:var'a' print(lim(atanh(x), x, a):prune()) assert(lim(atanh(x), x, a):prune() == lim(atanh(x), x, a)) end",
		comment="",
		duration=0.001524,
		simplifyStack={"Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, -inf), invalid)",
		comment="",
		duration=0.00026300000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, -1), invalid)",
		comment="",
		duration=0.00051400000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, -1, '+'), -inf)",
		comment="",
		duration=0.000449,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, 0), 0)",
		comment="",
		duration=0.00036,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, 1), invalid)",
		comment="",
		duration=0.000448,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, 1, '-'), inf)",
		comment="",
		duration=0.00011499999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, inf), invalid)",
		comment="",
		duration=0.00013199999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local a = set.RealSubset(-1, 1, false, false):var'a' simplifyAssertEq(lim(asin(x), x, a), asin(a)) end",
		comment="",
		duration=0.00124,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.RealSubset(-math.huge, -1, false, false):var'a' simplifyAssertEq(lim(asin(x), x, a), invalid) end",
		comment="",
		duration=0.000412,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.real:var'a' print(lim(asin(x), x, a):prune()) assert(lim(asin(x), x, a):prune() == lim(asin(x), x, a)) end",
		comment="",
		duration=0.00063300000000002,
		simplifyStack={"Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, -inf), invalid)",
		comment="",
		duration=0.000224,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, -1), invalid)",
		comment="",
		duration=0.00043700000000002,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, -1, '+'), -inf)",
		comment="",
		duration=0.000329,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, 0), 0)",
		comment="",
		duration=0.00023199999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, 1), invalid)",
		comment="",
		duration=0.000218,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, 1, '-'), inf)",
		comment="",
		duration=0.00010200000000002,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, inf), invalid)",
		comment="",
		duration=0.00012700000000002,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local a = set.RealSubset(-1, 1, false, false):var'a' simplifyAssertEq(lim(acos(x), x, a), acos(a)) end",
		comment="",
		duration=0.001045,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.RealSubset(-math.huge, -1, false, false):var'a' simplifyAssertEq(lim(acos(x), x, a), invalid) end",
		comment="",
		duration=0.00036700000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.real:var'a' print(lim(acos(x), x, a):prune()) assert(lim(acos(x), x, a):prune() == lim(acos(x), x, a)) end",
		comment="",
		duration=0.001048,
		simplifyStack={"Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, -inf), invalid)",
		comment="",
		duration=0.000223,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, -1), invalid)",
		comment="",
		duration=0.00024100000000002,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, -1, '+'), inf)",
		comment="",
		duration=0.000112,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, 0), pi/2)",
		comment="",
		duration=0.001596,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, 1), invalid)",
		comment="",
		duration=0.000282,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, 1, '-'), -inf)",
		comment="",
		duration=0.000387,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, inf), invalid)",
		comment="",
		duration=0.00026599999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, a), Heaviside(a))",
		comment="",
		duration=0.00035199999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, -inf), 0)",
		comment="",
		duration=0.00021000000000002,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, -1), 0)",
		comment="",
		duration=0.000191,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, 0), invalid)",
		comment="",
		duration=0.000166,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, 0, '-'), 0)",
		comment="",
		duration=0.00011700000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, 0, '+'), 1)",
		comment="",
		duration=0.000111,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, 1), 1)",
		comment="",
		duration=0.000251,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, inf), 1)",
		comment="",
		duration=0.00014399999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="products of functions", duration=1.9999999999742e-06},
	{
		code="simplifyAssertEq(lim(x * sin(x), x, a), a * sin(a))",
		comment="",
		duration=0.002943,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="TODO polynomial roots", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(1 / (x - 1), x, 1), invalid)",
		comment="",
		duration=0.00348,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1 / (x - 1), x, 1, '+'), inf)",
		comment="",
		duration=0.00133,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1 / (x - 1), x, 1, '-'), -inf)",
		comment="",
		duration=0.001734,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim((x + 1) / (x^2 - 1), x, 1), invalid)",
		comment="",
		duration=0.017282,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim((x + 1) / (x^2 - 1), x, 1, '+'), inf)",
		comment="",
		duration=0.00958,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim((x + 1) / (x^2 - 1), x, 1, '-'), -inf)",
		comment="",
		duration=0.0097,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=2.000000000002e-06},
	{code="", comment="can we evaluate derivatives as limits?  yes.", duration=1.000000000001e-06},
	{
		code="difftest(x)",
		comment="",
		duration=0.001638,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="difftest(c * x)",
		comment="",
		duration=0.004729,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="difftest(x^2)",
		comment="",
		duration=0.006058,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="difftest(x^3)",
		comment="",
		duration=0.011499,
		simplifyStack={"Init", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="difftest(1/x)",
		comment="",
		duration=0.013851,
		simplifyStack={"Init", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "^:ExpandPolynomial:apply", "+:Prune:combineConstants", "*:Prune:apply", "/:Factor:polydiv", "Factor", "/:Prune:xOverMinusOne", "*:Prune:apply", "*:Prune:flatten", "Prune", "Constant:Tidy:apply", "/:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="can't handle these yet.", duration=1.000000000001e-06},
	{code="", comment="TODO give unit tests a 'reach' section?", duration=1.000000000001e-06},
	{code="", comment="so console can show that these tests aren't 100% certified.", duration=1.000000000001e-06},
	{code="", comment="use infinite taylor expansion?", duration=1.000000000001e-06},
	{code="", comment="or just use L'Hospital's rule -- that solves these too, because, basically, that replaces the limit with the derivative, so it will always be equal.", duration=1.000000000001e-06},
	{
		code="difftest(sqrt(x))",
		comment="",
		duration=0.058138,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "Expand", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "/:Prune:xOverX", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "^:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="difftest(sin(x))",
		comment="",
		duration=0.006815,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="difftest(cos(x))",
		comment="",
		duration=0.00508,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="difftest(exp(x))",
		comment="",
		duration=0.005102,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.0000000000288e-06},
	{code="", comment="some other L'Hospital rule problems:", duration=1.0000000000288e-06},
	{
		code="simplifyAssertEq(lim(sin(x) / x, x, 0), 1)",
		comment="",
		duration=0.001205,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(exp(x) / x^2, x, inf), inf)",
		comment="",
		duration=0.00238,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim((e^x - 1) / (x^2 + x), x, 0), 1)",
		comment="",
		duration=0.006138,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim((2*sin(x) - sin(2*x)) / (x - sin(x)), x, 0), 6)",
		comment="",
		duration=0.040087,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999997324e-07},
	{code="", comment="TODO this one, repeatedly apply L'Hospital until the power of x on top is <= 0", duration=1.0000000000288e-06},
	{code="", comment="but this seems like it would need a special case of evaluating into a factorial", duration=2.000000000002e-06},
	{
		code="simplifyAssertEq(lim(x^n * e^x, x, 0), 0)",
		comment="",
		duration=0.00205,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:107: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:216: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:215>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:107: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(x^n * e^x, x, 0), 0)\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:208: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:207>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:207: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x5651318eb3e0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.0000000000288e-06},
	{code="", comment="TODO this requires representing x ln x as (ln x) / (1/x) before applying L'Hospital", duration=9.9999999997324e-07},
	{
		code="simplifyAssertEq(lim(x * log(x), x, 0, '+'), 0)",
		comment="",
		duration=0.000338,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=9.9999999997324e-07},
	{code="", comment="mortgage repayment formula -- works", duration=9.9999999997324e-07},
	{
		code="simplifyAssertEq(lim( (a * x * (1 + x)^n) / ((1 + x)^n - 1), x, 0 ), a / n)",
		comment="",
		duration=0.0434,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999997324e-07},
	{code="", comment="the infamous tanh(x) ... works?  hmm ... this is infamous for taking an infinite number of L'Hospital applications.  Why is it working?", duration=9.9999999997324e-07},
	{
		code="print( ((e^x + e^-x) / (e^x - e^-x)):lim(x, inf):prune() )",
		comment="",
		duration=0.018412,
		simplifyStack={"Init", "Derivative:Prune:constants", "Derivative:Prune:constants", "*:Prune:apply", "Derivative:Prune:self", "*:Prune:apply", "+:Prune:combineConstants", "Derivative:Prune:eval", "log:Prune:apply", "*:Prune:apply", "Derivative:Prune:other", "*:Prune:apply", "/:Prune:zeroOverX", "+:Prune:combineConstants", "Derivative:Prune:eval", "+:Prune:combineConstants", "Derivative:Prune:eval", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "*:Tidy:apply", "Tidy", "/:Prune:xOverX", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply"}
	}
}