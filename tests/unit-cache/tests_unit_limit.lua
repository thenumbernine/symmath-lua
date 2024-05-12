{
	{
		code="simplifyAssertEq(lim(x, x, a), a)",
		comment="",
		duration=0.000424,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x, x, a, '+'), a)",
		comment="",
		duration=0.000282,
		simplifyStack={"Init", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x, x, a, '-'), a)",
		comment="",
		duration=0.000192,
		simplifyStack={"Init", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{code="", comment="constants", duration=0},
	{
		code="simplifyAssertEq(lim(0, x, a), 0)",
		comment="",
		duration=0.000549,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1, x, a), 1)",
		comment="",
		duration=0.000399,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{code="", comment="ops", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(x + 2, x, a), a + 2)",
		comment="",
		duration=0.002858,
		simplifyStack={"Init", "+:Prune:combineConstants", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x + x, x, a), 2 * a)",
		comment="",
		duration=0.001298,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x + a, x, a), 2 * a)",
		comment="",
		duration=0.001338,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(a + a, x, a), 2 * a)",
		comment="",
		duration=0.000884,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x * 2, x, a), 2 * a)",
		comment="",
		duration=0.001422,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x / 2, x, a), a / 2)",
		comment="",
		duration=0.003371,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="involving infinity", duration=0},
	{
		code="simplifyAssertEq(lim(x, x, inf), inf)",
		comment="",
		duration=0.00014,
		simplifyStack={"Init", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x, x, -inf), -inf)",
		comment="",
		duration=0.000438,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x, x, inf), inf)",
		comment="",
		duration=0.000165,
		simplifyStack={"Init", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1/x, x, inf), 0)",
		comment="",
		duration=0.000407,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1/x, x, -inf), 0)",
		comment="",
		duration=0.000524,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1/x, x, 0), invalid)",
		comment="",
		duration=0.000979,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq(lim(1/x, x, 0, '+'), inf)",
		comment="",
		duration=0.000343,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1/x, x, 0, '-'), -inf)",
		comment="",
		duration=0.000763,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(1/x^2, x, 0, '+'), inf)",
		comment="",
		duration=0.001671,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1/x^2, x, 0, '-'), inf)",
		comment="",
		duration=0.001975,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="sqrts", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(sqrt(x), x, 0), invalid)",
		comment="",
		duration=0.000836,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sqrt(x), x, 0, '-'), invalid)",
		comment="",
		duration=0.000305,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sqrt(x), x, 0, '+'), 0)",
		comment="",
		duration=0.00047699999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="in each form ...", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(x^frac(1,2), x, 0), invalid)",
		comment="",
		duration=0.00053400000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x^frac(1,2), x, 0, '-'), invalid)",
		comment="",
		duration=0.000385,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x^frac(1,2), x, 0, '+'), 0)",
		comment="",
		duration=0.00046500000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="and one more power up ...", duration=0},
	{
		code="simplifyAssertEq(lim(x^frac(1,4), x, 0), invalid)",
		comment="",
		duration=0.00068799999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x^frac(1,4), x, 0, '-'), invalid)",
		comment="",
		duration=0.00064,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x^frac(1,4), x, 0, '+'), 0)",
		comment="",
		duration=0.00035300000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="functions", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="TODO all of these are only good for 'a' in Real, not necessarily extended-Real, because I don't distinguish them", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="another thing to consider ... most these are set up so that the limit is the same as the evaluation without a limit", duration=1.000000000001e-06},
	{code="", comment="technically this is not true.  technically atan(inf) is not pi/2 but is instead undefined outside of the limit.", duration=1.000000000001e-06},
	{code="", comment="should I enforce this?", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(sin(x), x, a), sin(a))",
		comment="",
		duration=0.000219,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sin(x), x, inf), invalid)",
		comment="",
		duration=0.000166,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sin(x), x, -inf), invalid)",
		comment="",
		duration=0.00021299999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(cos(x), x, a), cos(a))",
		comment="",
		duration=0.00044999999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cos(x), x, inf), invalid)",
		comment="",
		duration=0.00010400000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cos(x), x, -inf), invalid)",
		comment="",
		duration=0.000209,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(abs(x), x, a), abs(a))",
		comment="",
		duration=0.00022699999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(abs(x), x, -inf), inf)",
		comment="",
		duration=0.00011899999999999,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Limit:Prune:apply", "*:Prune:handleInfAndNan", "abs:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(abs(x), x, inf), inf)",
		comment="",
		duration=5.9000000000003e-05,
		simplifyStack={"Init", "Limit:Prune:apply", "abs:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(exp(x), x, a), exp(a))",
		comment="",
		duration=0.000435,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(exp(x), x, -inf), 0)",
		comment="",
		duration=0.000371,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(exp(x), x, inf), inf)",
		comment="",
		duration=0.000165,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "^:Prune:handleInfAndNan", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(atan(x), x, a), atan(a))",
		comment="",
		duration=0.000265,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atan(x), x, -inf), -pi/2)",
		comment="",
		duration=0.002438,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "*:Prune:flatten", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "/:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atan(x), x, inf), pi/2)",
		comment="",
		duration=0.000957,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(tanh(x), x, a), tanh(a))",
		comment="",
		duration=0.000135,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tanh(x), x, -inf), -1)",
		comment="",
		duration=0.00040499999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tanh(x), x, inf), 1)",
		comment="",
		duration=0.000142,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq(lim(asinh(x), x, a), asinh(a))",
		comment="",
		duration=0.000267,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asinh(x), x, -inf), -inf)",
		comment="",
		duration=0.000413,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asinh(x), x, inf), inf)",
		comment="",
		duration=0.00016000000000001,
		simplifyStack={"Init", "Limit:Prune:apply", "asinh:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq(lim(cosh(x), x, a), cosh(a))",
		comment="",
		duration=0.000151,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cosh(x), x, -inf), inf)",
		comment="",
		duration=0.000123,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Limit:Prune:apply", "cosh:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cosh(x), x, inf), inf)",
		comment="",
		duration=9.0999999999994e-05,
		simplifyStack={"Init", "Limit:Prune:apply", "cosh:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq(lim(sinh(x), x, a), sinh(a))",
		comment="",
		duration=0.000207,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sinh(x), x, -inf), -inf)",
		comment="",
		duration=0.000532,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sinh(x), x, inf), inf)",
		comment="",
		duration=6.5999999999997e-05,
		simplifyStack={"Init", "Limit:Prune:apply", "sinh:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(sin(x), x, a), sin(a))",
		comment="",
		duration=0.000114,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sin(x), x, -inf), invalid)",
		comment="",
		duration=0.00020000000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sin(x), x, inf), invalid)",
		comment="",
		duration=7.5000000000006e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq(lim(cos(x), x, a), cos(a))",
		comment="",
		duration=0.00011700000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cos(x), x, -inf), invalid)",
		comment="",
		duration=0.000109,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cos(x), x, inf), invalid)",
		comment="",
		duration=7.6999999999994e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(tan(x), x, a), tan(a))",
		comment="",
		duration=0.001694,
		simplifyStack={"Init", "tan:Prune:apply", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, -inf), invalid)",
		comment="",
		duration=0.000404,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, -3*pi/2), invalid)",
		comment="",
		duration=0.001329,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, -pi), tan(-pi))",
		comment="",
		duration=0.000905,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "sin:Prune:apply", "cos:Prune:apply", "*:Prune:apply", "/:Prune:xOverMinusOne", "tan:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, -pi/2), invalid)",
		comment="",
		duration=0.000845,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, 0), tan(0))",
		comment="",
		duration=0.000416,
		simplifyStack={"Init", "sin:Prune:apply", "cos:Prune:apply", "/:Prune:xOverOne", "tan:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, pi/2), invalid)",
		comment="",
		duration=0.00037,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, pi/2, '+'), -inf)",
		comment="",
		duration=0.00074100000000001,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, pi/2, '-'), inf)",
		comment="",
		duration=0.000331,
		simplifyStack={"Init", "tan:Prune:apply", "Limit:Prune:apply", "sin:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "cos:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, pi), tan(pi))",
		comment="",
		duration=0.00040699999999999,
		simplifyStack={"Init", "sin:Prune:apply", "cos:Prune:apply", "*:Prune:apply", "/:Prune:xOverMinusOne", "tan:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, 3*pi/2), invalid)",
		comment="",
		duration=0.001047,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, inf), invalid)",
		comment="",
		duration=0.000261,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="do local a = set.positiveReal:var'a' simplifyAssertEq(lim(log(x), x, a), log(a)) end",
		comment="if the input is within the domain of the function then we can evaluate it for certain",
		duration=0.000273,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.negativeReal:var'a' simplifyAssertEq(lim(log(x), x, a), invalid) end",
		comment="if the input is outside the domain of the function then we know the result is invalid. TODO is this the same as indeterminate?  Or should I introduce a new singleton?",
		duration=0.000344,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.real:var'a' print(lim(log(x), x, a):prune()) assert(lim(log(x), x, a):prune() == lim(log(x), x, a)) end",
		comment="if the input covers both the domain and its complement, and we can't determine the limit evaluation, then don't touch the expression",
		duration=0.00039500000000001,
		simplifyStack={"Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(log(x), x, -inf), invalid)",
		comment="",
		duration=0.000249,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(log(x), x, 0), invalid)",
		comment="",
		duration=0.00014,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(log(x), x, 0, '+'), -inf)",
		comment="",
		duration=0.00026900000000001,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(log(x), x, inf), inf)",
		comment="",
		duration=8.5000000000002e-05,
		simplifyStack={"Init", "Limit:Prune:apply", "log:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="do local a = set.RealSubset(-1, 1, false, false):var'a' simplifyAssertEq(lim(acosh(x), x, a), acosh(a)) end",
		comment="",
		duration=0.00033,
		simplifyStack={"Init", "acosh:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.RealSubset(-math.huge, -1, false, false):var'a' simplifyAssertEq(lim(acosh(x), x, a), invalid) end",
		comment="",
		duration=0.000139,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.real:var'a' print(lim(acosh(x), x, a):prune()) assert(lim(acosh(x), x, a):prune() == lim(acosh(x), x, a)) end",
		comment="",
		duration=0.00054,
		simplifyStack={"Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(acosh(x), x, -inf), invalid)",
		comment="",
		duration=0.000306,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acosh(x), x, 1), invalid)",
		comment="",
		duration=0.00011900000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acosh(x), x, 1, '+'), 0)",
		comment="",
		duration=0.000167,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acosh(x), x, inf), inf)",
		comment="",
		duration=8.3999999999987e-05,
		simplifyStack={"Init", "Limit:Prune:apply", "acosh:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local a = set.RealSubset(-1, 1, false, false):var'a' simplifyAssertEq(lim(atanh(x), x, a), atanh(a)) end",
		comment="",
		duration=0.000309,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.RealSubset(-math.huge, -1, false, false):var'a' simplifyAssertEq(lim(atanh(x), x, a), invalid) end",
		comment="",
		duration=0.00022,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.real:var'a' print(lim(atanh(x), x, a):prune()) assert(lim(atanh(x), x, a):prune() == lim(atanh(x), x, a)) end",
		comment="",
		duration=0.00035399999999999,
		simplifyStack={"Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, -inf), invalid)",
		comment="",
		duration=0.000183,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, -1), invalid)",
		comment="",
		duration=0.000196,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, -1, '+'), -inf)",
		comment="",
		duration=0.00036800000000001,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, 0), 0)",
		comment="",
		duration=0.000141,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, 1), invalid)",
		comment="",
		duration=0.000321,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, 1, '-'), inf)",
		comment="",
		duration=0.00010600000000001,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, inf), invalid)",
		comment="",
		duration=0.000137,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="do local a = set.RealSubset(-1, 1, false, false):var'a' simplifyAssertEq(lim(asin(x), x, a), asin(a)) end",
		comment="",
		duration=0.00031299999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.RealSubset(-math.huge, -1, false, false):var'a' simplifyAssertEq(lim(asin(x), x, a), invalid) end",
		comment="",
		duration=0.000236,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.real:var'a' print(lim(asin(x), x, a):prune()) assert(lim(asin(x), x, a):prune() == lim(asin(x), x, a)) end",
		comment="",
		duration=0.00042299999999999,
		simplifyStack={"Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, -inf), invalid)",
		comment="",
		duration=0.000193,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, -1), invalid)",
		comment="",
		duration=0.000378,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, -1, '+'), -inf)",
		comment="",
		duration=0.000393,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, 0), 0)",
		comment="",
		duration=0.00021500000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, 1), invalid)",
		comment="",
		duration=0.000252,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, 1, '-'), inf)",
		comment="",
		duration=0.00016200000000001,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, inf), invalid)",
		comment="",
		duration=0.00028099999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local a = set.RealSubset(-1, 1, false, false):var'a' simplifyAssertEq(lim(acos(x), x, a), acos(a)) end",
		comment="",
		duration=0.00067299999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.RealSubset(-math.huge, -1, false, false):var'a' simplifyAssertEq(lim(acos(x), x, a), invalid) end",
		comment="",
		duration=0.000625,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.real:var'a' print(lim(acos(x), x, a):prune()) assert(lim(acos(x), x, a):prune() == lim(acos(x), x, a)) end",
		comment="",
		duration=0.000517,
		simplifyStack={"Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, -inf), invalid)",
		comment="",
		duration=0.000475,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, -1), invalid)",
		comment="",
		duration=0.00022000000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, -1, '+'), inf)",
		comment="",
		duration=0.000142,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, 0), pi/2)",
		comment="",
		duration=0.000986,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, 1), invalid)",
		comment="",
		duration=0.000138,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, 1, '-'), -inf)",
		comment="",
		duration=0.000419,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, inf), invalid)",
		comment="",
		duration=9.7e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, a), Heaviside(a))",
		comment="",
		duration=0.00016799999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, -inf), 0)",
		comment="",
		duration=0.00018899999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, -1), 0)",
		comment="",
		duration=0.000191,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, 0), invalid)",
		comment="",
		duration=0.00010400000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, 0, '-'), 0)",
		comment="",
		duration=7.4000000000005e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, 0, '+'), 1)",
		comment="",
		duration=0.00020300000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, 1), 1)",
		comment="",
		duration=0.000185,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, inf), 1)",
		comment="",
		duration=7.3000000000004e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="products of functions", duration=0},
	{
		code="simplifyAssertEq(lim(x * sin(x), x, a), a * sin(a))",
		comment="",
		duration=0.000449,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=0},
	{code="", comment="TODO polynomial roots", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(1 / (x - 1), x, 1), invalid)",
		comment="",
		duration=0.001315,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1 / (x - 1), x, 1, '+'), inf)",
		comment="",
		duration=0.00085199999999999,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "+:Prune:combineConstants", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1 / (x - 1), x, 1, '-'), -inf)",
		comment="",
		duration=0.00085700000000001,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim((x + 1) / (x^2 - 1), x, 1), invalid)",
		comment="",
		duration=0.005253,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim((x + 1) / (x^2 - 1), x, 1, '+'), inf)",
		comment="",
		duration=0.004255,
		simplifyStack={"Init", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "Limit:Prune:apply", "Limit:Prune:apply", "+:Prune:combineConstants", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "^:Prune:simplifyConstantPowers", "Limit:Prune:apply", "+:Prune:combineConstants", "Limit:Prune:apply", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "Limit:Prune:apply", "Limit:Prune:apply", "+:Prune:combineConstants", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "^:Prune:simplifyConstantPowers", "Limit:Prune:apply", "+:Prune:combineConstants", "Limit:Prune:apply", "Prune", "+:Factor:apply", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim((x + 1) / (x^2 - 1), x, 1, '-'), -inf)",
		comment="",
		duration=0.004222,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="can we evaluate derivatives as limits?  yes.", duration=9.9999999998712e-07},
	{
		code="difftest(x)",
		comment="",
		duration=0.00051900000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="difftest(c * x)",
		comment="",
		duration=0.00109,
		simplifyStack={"Init", "Derivative:Prune:self", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy", "Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="difftest(x^2)",
		comment="",
		duration=0.001725,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="difftest(x^3)",
		comment="",
		duration=0.005476,
		simplifyStack={"Init", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="difftest(1/x)",
		comment="",
		duration=0.005892,
		simplifyStack={"Init", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "^:ExpandPolynomial:apply", "+:Prune:combineConstants", "*:Prune:combinePows", "/:Factor:polydiv", "Factor", "/:Prune:xOverMinusOne", "*:Prune:apply", "*:Prune:flatten", "Prune", "Constant:Tidy:apply", "/:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="can't handle these yet.", duration=0},
	{code="", comment="TODO give unit tests a 'reach' section?", duration=1.000000000001e-06},
	{code="", comment="so console can show that these tests aren't 100% certified.", duration=0},
	{code="", comment="use infinite taylor expansion?", duration=0},
	{code="", comment="or just use L'Hospital's rule -- that solves these too, because, basically, that replaces the limit with the derivative, so it will always be equal.", duration=1.000000000001e-06},
	{
		code="difftest(sqrt(x))",
		comment="",
		duration=0.091085,
		simplifyStack={"Init", "Prune", "Expand", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:combinePows", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:combinePows", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "/:Prune:xOverX", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:combinePows", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "^:Tidy:replacePowerOfFractionWithRoots", "*:Tidy:apply", "Tidy"}
	},
	{
		code="difftest(sin(x))",
		comment="",
		duration=0.001172,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="difftest(cos(x))",
		comment="",
		duration=0.001744,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="difftest(exp(x))",
		comment="",
		duration=0.002417,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="some other L'Hospital rule problems:", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(lim(sin(x) / x, x, 0), 1)",
		comment="",
		duration=0.00038100000000002,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(exp(x) / x^2, x, inf), inf)",
		comment="",
		duration=0.001155,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "^:Prune:handleInfAndNan", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "^:Prune:handleInfAndNan", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim((e^x - 1) / (x^2 + x), x, 0), 1)",
		comment="",
		duration=0.001834,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim((2*sin(x) - sin(2*x)) / (x - sin(x)), x, 0), 6)",
		comment="",
		duration=0.013792,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="TODO this one, repeatedly apply L'Hospital until the power of x on top is <= 0", duration=0},
	{code="", comment="but this seems like it would need a special case of evaluating into a factorial", duration=0},
	{
		code="simplifyAssertEq(lim(x^n * e^x, x, 0), 0)",
		comment="",
		duration=0.002995,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:125: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:246: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:245>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:125: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(x^n * e^x, x, 0), 0)\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:238: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:237>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:237: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:58: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x5fe041b37380",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.0000000000288e-06},
	{code="", comment="TODO this requires representing x ln x as (ln x) / (1/x) before applying L'Hospital", duration=1.0000000000288e-06},
	{
		code="simplifyAssertEq(lim(x * log(x), x, 0, '+'), 0)",
		comment="",
		duration=0.00096799999999997,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{code="", comment="mortgage repayment formula -- works", duration=0},
	{
		code="simplifyAssertEq(lim( (a * x * (1 + x)^n) / ((1 + x)^n - 1), x, 0 ), a / n)",
		comment="",
		duration=0.015009,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.0000000000288e-06},
	{code="", comment="the infamous tanh(x) ... works?  hmm ... this is infamous for taking an infinite number of L'Hospital applications.  Why is it working?", duration=0},
	{
		code="print( ((e^x + e^-x) / (e^x - e^-x)):lim(x, inf):prune() )",
		comment="",
		duration=0.006295,
		simplifyStack={"Init", "Derivative:Prune:constants", "Derivative:Prune:constants", "*:Prune:apply", "Derivative:Prune:self", "*:Prune:apply", "+:Prune:combineConstants", "Derivative:Prune:eval", "log:Prune:apply", "*:Prune:apply", "Derivative:Prune:other", "*:Prune:apply", "/:Prune:zeroOverX", "+:Prune:combineConstants", "Derivative:Prune:eval", "+:Prune:combineConstants", "Derivative:Prune:eval", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "*:Tidy:apply", "Tidy", "/:Prune:xOverX", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply"}
	}
}