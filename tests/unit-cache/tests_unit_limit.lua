{
	{
		code="simplifyAssertEq(lim(x, x, a), a)",
		comment="",
		duration=0.001442,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x, x, a, '+'), a)",
		comment="",
		duration=0.000483,
		simplifyStack={"Init", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x, x, a, '-'), a)",
		comment="",
		duration=0.000989,
		simplifyStack={"Init", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{code="", comment="constants", duration=3.9999999999901e-06},
	{
		code="simplifyAssertEq(lim(0, x, a), 0)",
		comment="",
		duration=0.002003,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1, x, a), 1)",
		comment="",
		duration=0.002013,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{code="", comment="ops", duration=3.9999999999901e-06},
	{
		code="simplifyAssertEq(lim(x + 2, x, a), a + 2)",
		comment="",
		duration=0.010662,
		simplifyStack={"Init", "+:Prune:combineConstants", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x + x, x, a), 2 * a)",
		comment="",
		duration=0.007091,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x + a, x, a), 2 * a)",
		comment="",
		duration=0.007187,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(a + a, x, a), 2 * a)",
		comment="",
		duration=0.009154,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x * 2, x, a), 2 * a)",
		comment="",
		duration=0.009676,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x / 2, x, a), a / 2)",
		comment="",
		duration=0.007851,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="involving infinity", duration=4.000000000004e-06},
	{
		code="simplifyAssertEq(lim(x, x, inf), inf)",
		comment="",
		duration=0.00079800000000002,
		simplifyStack={"Init", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x, x, -inf), -inf)",
		comment="",
		duration=0.001921,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x, x, inf), inf)",
		comment="",
		duration=0.00049099999999999,
		simplifyStack={"Init", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1/x, x, inf), 0)",
		comment="",
		duration=0.001986,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1/x, x, -inf), 0)",
		comment="",
		duration=0.002005,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1/x, x, 0), invalid)",
		comment="",
		duration=0.003201,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{
		code="simplifyAssertEq(lim(1/x, x, 0, '+'), inf)",
		comment="",
		duration=0.000947,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1/x, x, 0, '-'), -inf)",
		comment="",
		duration=0.003131,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{
		code="simplifyAssertEq(lim(1/x^2, x, 0, '+'), inf)",
		comment="",
		duration=0.009632,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1/x^2, x, 0, '-'), inf)",
		comment="",
		duration=0.009357,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=3.9999999999762e-06},
	{code="", comment="sqrts", duration=4.000000000004e-06},
	{
		code="simplifyAssertEq(lim(sqrt(x), x, 0), invalid)",
		comment="",
		duration=0.002396,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sqrt(x), x, 0, '-'), invalid)",
		comment="",
		duration=0.002242,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sqrt(x), x, 0, '+'), 0)",
		comment="",
		duration=0.001694,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="in each form ...", duration=5.000000000005e-06},
	{
		code="simplifyAssertEq(lim(x^frac(1,2), x, 0), invalid)",
		comment="",
		duration=0.002245,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x^frac(1,2), x, 0, '-'), invalid)",
		comment="",
		duration=0.001598,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x^frac(1,2), x, 0, '+'), 0)",
		comment="",
		duration=0.001714,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="and one more power up ...", duration=5.000000000005e-06},
	{
		code="simplifyAssertEq(lim(x^frac(1,4), x, 0), invalid)",
		comment="",
		duration=0.001204,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x^frac(1,4), x, 0, '-'), invalid)",
		comment="",
		duration=0.001033,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(x^frac(1,4), x, 0, '+'), 0)",
		comment="",
		duration=0.001871,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.9999999999782e-06},
	{code="", comment="", duration=6.000000000006e-06},
	{code="", comment="functions", duration=5.000000000005e-06},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="TODO all of these are only good for 'a' in Real, not necessarily extended-Real, because I don't distinguish them", duration=4.9999999999772e-06},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="another thing to consider ... most these are set up so that the limit is the same as the evaluation without a limit", duration=5.000000000005e-06},
	{code="", comment="technically this is not true.  technically atan(inf) is not pi/2 but is instead undefined outside of the limit.", duration=5.000000000005e-06},
	{code="", comment="should I enforce this?", duration=6.000000000006e-06},
	{
		code="simplifyAssertEq(lim(sin(x), x, a), sin(a))",
		comment="",
		duration=0.002475,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sin(x), x, inf), invalid)",
		comment="",
		duration=0.001305,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sin(x), x, -inf), invalid)",
		comment="",
		duration=0.002296,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{
		code="simplifyAssertEq(lim(cos(x), x, a), cos(a))",
		comment="",
		duration=0.00084300000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cos(x), x, inf), invalid)",
		comment="",
		duration=0.00084599999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cos(x), x, -inf), invalid)",
		comment="",
		duration=0.00095000000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=3.9999999999762e-06},
	{
		code="simplifyAssertEq(lim(abs(x), x, a), abs(a))",
		comment="",
		duration=0.001619,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(abs(x), x, -inf), inf)",
		comment="",
		duration=0.000944,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Limit:Prune:apply", "*:Prune:handleInfAndNan", "abs:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(abs(x), x, inf), inf)",
		comment="",
		duration=0.00090599999999999,
		simplifyStack={"Init", "Limit:Prune:apply", "abs:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{
		code="simplifyAssertEq(lim(exp(x), x, a), exp(a))",
		comment="",
		duration=0.001245,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(exp(x), x, -inf), 0)",
		comment="",
		duration=0.001074,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(exp(x), x, inf), inf)",
		comment="",
		duration=0.000863,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "^:Prune:handleInfAndNan", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=6.000000000006e-06},
	{
		code="simplifyAssertEq(lim(atan(x), x, a), atan(a))",
		comment="",
		duration=0.001881,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atan(x), x, -inf), -pi/2)",
		comment="",
		duration=0.010867,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "*:Prune:flatten", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "/:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atan(x), x, inf), pi/2)",
		comment="",
		duration=0.007116,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.9999999999772e-06},
	{
		code="simplifyAssertEq(lim(tanh(x), x, a), tanh(a))",
		comment="",
		duration=0.001061,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tanh(x), x, -inf), -1)",
		comment="",
		duration=0.001833,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tanh(x), x, inf), 1)",
		comment="",
		duration=0.00107,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.0000000000328e-06},
	{
		code="simplifyAssertEq(lim(asinh(x), x, a), asinh(a))",
		comment="",
		duration=0.001393,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asinh(x), x, -inf), -inf)",
		comment="",
		duration=0.004458,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asinh(x), x, inf), inf)",
		comment="",
		duration=0.001457,
		simplifyStack={"Init", "Limit:Prune:apply", "asinh:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=7.0000000000348e-06},
	{
		code="simplifyAssertEq(lim(cosh(x), x, a), cosh(a))",
		comment="",
		duration=0.003084,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cosh(x), x, -inf), inf)",
		comment="",
		duration=0.001156,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Limit:Prune:apply", "cosh:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cosh(x), x, inf), inf)",
		comment="",
		duration=0.00092799999999998,
		simplifyStack={"Init", "Limit:Prune:apply", "cosh:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.9999999999772e-06},
	{
		code="simplifyAssertEq(lim(sinh(x), x, a), sinh(a))",
		comment="",
		duration=0.00069400000000003,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sinh(x), x, -inf), -inf)",
		comment="",
		duration=0.001981,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sinh(x), x, inf), inf)",
		comment="",
		duration=0.000473,
		simplifyStack={"Init", "Limit:Prune:apply", "sinh:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.9999999999772e-06},
	{
		code="simplifyAssertEq(lim(sin(x), x, a), sin(a))",
		comment="",
		duration=0.001622,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sin(x), x, -inf), invalid)",
		comment="",
		duration=0.001315,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(sin(x), x, inf), invalid)",
		comment="",
		duration=0.00051400000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=6.000000000006e-06},
	{
		code="simplifyAssertEq(lim(cos(x), x, a), cos(a))",
		comment="",
		duration=0.00081999999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cos(x), x, -inf), invalid)",
		comment="",
		duration=0.001349,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(cos(x), x, inf), invalid)",
		comment="",
		duration=0.00041200000000002,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.0000000000328e-06},
	{
		code="simplifyAssertEq(lim(tan(x), x, a), tan(a))",
		comment="",
		duration=0.01556,
		simplifyStack={"Init", "tan:Prune:apply", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, -inf), invalid)",
		comment="",
		duration=0.002819,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, -3*pi/2), invalid)",
		comment="",
		duration=0.008126,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, -pi), tan(-pi))",
		comment="",
		duration=0.0033,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "sin:Prune:apply", "cos:Prune:apply", "*:Prune:apply", "/:Prune:xOverMinusOne", "tan:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, -pi/2), invalid)",
		comment="",
		duration=0.004584,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, 0), tan(0))",
		comment="",
		duration=0.002524,
		simplifyStack={"Init", "sin:Prune:apply", "cos:Prune:apply", "/:Prune:xOverOne", "tan:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, pi/2), invalid)",
		comment="",
		duration=0.002306,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, pi/2, '+'), -inf)",
		comment="",
		duration=0.002366,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, pi/2, '-'), inf)",
		comment="",
		duration=0.00096200000000002,
		simplifyStack={"Init", "tan:Prune:apply", "Limit:Prune:apply", "sin:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "cos:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, pi), tan(pi))",
		comment="",
		duration=0.002312,
		simplifyStack={"Init", "sin:Prune:apply", "cos:Prune:apply", "*:Prune:apply", "/:Prune:xOverMinusOne", "tan:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, 3*pi/2), invalid)",
		comment="",
		duration=0.003017,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(tan(x), x, inf), invalid)",
		comment="",
		duration=0.001481,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.9999999999772e-06},
	{
		code="do local a = set.positiveReal:var'a' simplifyAssertEq(lim(log(x), x, a), log(a)) end",
		comment="if the input is within the domain of the function then we can evaluate it for certain",
		duration=0.001798,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.negativeReal:var'a' simplifyAssertEq(lim(log(x), x, a), invalid) end",
		comment="if the input is outside the domain of the function then we know the result is invalid. TODO is this the same as indeterminate?  Or should I introduce a new singleton?",
		duration=0.003447,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.real:var'a' print(lim(log(x), x, a):prune()) assert(lim(log(x), x, a):prune() == lim(log(x), x, a)) end",
		comment="if the input covers both the domain and its complement, and we can't determine the limit evaluation, then don't touch the expression",
		duration=0.001091,
		simplifyStack={"Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(log(x), x, -inf), invalid)",
		comment="",
		duration=0.00074299999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(log(x), x, 0), invalid)",
		comment="",
		duration=0.00085800000000003,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(log(x), x, 0, '+'), -inf)",
		comment="",
		duration=0.002069,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(log(x), x, inf), inf)",
		comment="",
		duration=0.000363,
		simplifyStack={"Init", "Limit:Prune:apply", "log:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.8999999999991e-05},
	{
		code="do local a = set.RealSubset(-1, 1, false, false):var'a' simplifyAssertEq(lim(acosh(x), x, a), acosh(a)) end",
		comment="",
		duration=0.001689,
		simplifyStack={"Init", "acosh:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.RealSubset(-math.huge, -1, false, false):var'a' simplifyAssertEq(lim(acosh(x), x, a), invalid) end",
		comment="",
		duration=0.00095100000000004,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.real:var'a' print(lim(acosh(x), x, a):prune()) assert(lim(acosh(x), x, a):prune() == lim(acosh(x), x, a)) end",
		comment="",
		duration=0.002266,
		simplifyStack={"Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(acosh(x), x, -inf), invalid)",
		comment="",
		duration=0.00088199999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acosh(x), x, 1), invalid)",
		comment="",
		duration=0.00089900000000004,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acosh(x), x, 1, '+'), 0)",
		comment="",
		duration=0.001074,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acosh(x), x, inf), inf)",
		comment="",
		duration=0.00075700000000001,
		simplifyStack={"Init", "Limit:Prune:apply", "acosh:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=6.000000000006e-06},
	{
		code="do local a = set.RealSubset(-1, 1, false, false):var'a' simplifyAssertEq(lim(atanh(x), x, a), atanh(a)) end",
		comment="",
		duration=0.002439,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.RealSubset(-math.huge, -1, false, false):var'a' simplifyAssertEq(lim(atanh(x), x, a), invalid) end",
		comment="",
		duration=0.00089800000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.real:var'a' print(lim(atanh(x), x, a):prune()) assert(lim(atanh(x), x, a):prune() == lim(atanh(x), x, a)) end",
		comment="",
		duration=0.002266,
		simplifyStack={"Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, -inf), invalid)",
		comment="",
		duration=0.001723,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, -1), invalid)",
		comment="",
		duration=0.001069,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, -1, '+'), -inf)",
		comment="",
		duration=0.001284,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, 0), 0)",
		comment="",
		duration=0.001399,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, 1), invalid)",
		comment="",
		duration=0.003045,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, 1, '-'), inf)",
		comment="",
		duration=0.001276,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(atanh(x), x, inf), invalid)",
		comment="",
		duration=0.00069900000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.9999999999772e-06},
	{
		code="do local a = set.RealSubset(-1, 1, false, false):var'a' simplifyAssertEq(lim(asin(x), x, a), asin(a)) end",
		comment="",
		duration=0.00273,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.RealSubset(-math.huge, -1, false, false):var'a' simplifyAssertEq(lim(asin(x), x, a), invalid) end",
		comment="",
		duration=0.00072800000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.real:var'a' print(lim(asin(x), x, a):prune()) assert(lim(asin(x), x, a):prune() == lim(asin(x), x, a)) end",
		comment="",
		duration=0.002823,
		simplifyStack={"Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, -inf), invalid)",
		comment="",
		duration=0.00075800000000004,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, -1), invalid)",
		comment="",
		duration=0.001144,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, -1, '+'), -inf)",
		comment="",
		duration=0.001616,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, 0), 0)",
		comment="",
		duration=0.00075500000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, 1), invalid)",
		comment="",
		duration=0.00078600000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, 1, '-'), inf)",
		comment="",
		duration=0.000583,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(asin(x), x, inf), invalid)",
		comment="",
		duration=0.00065900000000002,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.0000000000328e-06},
	{
		code="do local a = set.RealSubset(-1, 1, false, false):var'a' simplifyAssertEq(lim(acos(x), x, a), acos(a)) end",
		comment="",
		duration=0.001484,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.RealSubset(-math.huge, -1, false, false):var'a' simplifyAssertEq(lim(acos(x), x, a), invalid) end",
		comment="",
		duration=0.001358,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local a = set.real:var'a' print(lim(acos(x), x, a):prune()) assert(lim(acos(x), x, a):prune() == lim(acos(x), x, a)) end",
		comment="",
		duration=0.00107,
		simplifyStack={"Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, -inf), invalid)",
		comment="",
		duration=0.001079,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, -1), invalid)",
		comment="",
		duration=0.00085200000000002,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, -1, '+'), inf)",
		comment="",
		duration=0.00042999999999999,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, 0), pi/2)",
		comment="",
		duration=0.006231,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, 1), invalid)",
		comment="",
		duration=0.001101,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, 1, '-'), -inf)",
		comment="",
		duration=0.003774,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(acos(x), x, inf), invalid)",
		comment="",
		duration=0.00060500000000002,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.0000000000328e-06},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, a), Heaviside(a))",
		comment="",
		duration=0.002044,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, -inf), 0)",
		comment="",
		duration=0.000776,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, -1), 0)",
		comment="",
		duration=0.00081499999999995,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, 0), invalid)",
		comment="",
		duration=0.00059100000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, 0, '-'), 0)",
		comment="",
		duration=0.00059399999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, 0, '+'), 1)",
		comment="",
		duration=0.00053200000000003,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, 1), 1)",
		comment="",
		duration=0.001027,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(Heaviside(x), x, inf), 1)",
		comment="",
		duration=0.000749,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{code="", comment="products of functions", duration=4.000000000004e-06},
	{
		code="simplifyAssertEq(lim(x * sin(x), x, a), a * sin(a))",
		comment="",
		duration=0.004267,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=4.9999999999772e-06},
	{code="", comment="TODO polynomial roots", duration=4.9999999999772e-06},
	{
		code="simplifyAssertEq(lim(1 / (x - 1), x, 1), invalid)",
		comment="",
		duration=0.008987,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1 / (x - 1), x, 1, '+'), inf)",
		comment="",
		duration=0.006104,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "+:Prune:combineConstants", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(1 / (x - 1), x, 1, '-'), -inf)",
		comment="",
		duration=0.006155,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim((x + 1) / (x^2 - 1), x, 1), invalid)",
		comment="",
		duration=0.027147,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim((x + 1) / (x^2 - 1), x, 1, '+'), inf)",
		comment="",
		duration=0.023205,
		simplifyStack={"Init", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "Limit:Prune:apply", "Limit:Prune:apply", "+:Prune:combineConstants", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "^:Prune:simplifyConstantPowers", "Limit:Prune:apply", "+:Prune:combineConstants", "Limit:Prune:apply", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "Limit:Prune:apply", "Limit:Prune:apply", "+:Prune:combineConstants", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "^:Prune:simplifyConstantPowers", "Limit:Prune:apply", "+:Prune:combineConstants", "Limit:Prune:apply", "Prune", "+:Factor:apply", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim((x + 1) / (x^2 - 1), x, 1, '-'), -inf)",
		comment="",
		duration=0.022268,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=5.0000000000328e-06},
	{code="", comment="can we evaluate derivatives as limits?  yes.", duration=5.0000000000328e-06},
	{
		code="difftest(x)",
		comment="",
		duration=0.001939,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="difftest(c * x)",
		comment="",
		duration=0.009221,
		simplifyStack={"Init", "Derivative:Prune:self", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy", "Limit:Prune:apply", "Limit:Prune:apply"}
	},
	{
		code="difftest(x^2)",
		comment="",
		duration=0.012395,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="difftest(x^3)",
		comment="",
		duration=0.02531,
		simplifyStack={"Init", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="difftest(1/x)",
		comment="",
		duration=0.027683,
		simplifyStack={"Init", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "^:ExpandPolynomial:apply", "+:Prune:combineConstants", "*:Prune:combinePows", "/:Factor:polydiv", "Factor", "/:Prune:xOverMinusOne", "*:Prune:apply", "*:Prune:flatten", "Prune", "Constant:Tidy:apply", "/:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=5.0000000000328e-06},
	{code="", comment="can't handle these yet.", duration=4.000000000004e-06},
	{code="", comment="TODO give unit tests a 'reach' section?", duration=4.000000000004e-06},
	{code="", comment="so console can show that these tests aren't 100% certified.", duration=3.999999999893e-06},
	{code="", comment="use infinite taylor expansion?", duration=4.000000000004e-06},
	{code="", comment="or just use L'Hospital's rule -- that solves these too, because, basically, that replaces the limit with the derivative, so it will always be equal.", duration=4.000000000004e-06},
	{
		code="difftest(sqrt(x))",
		comment="",
		duration=0.319008,
		simplifyStack={"Init", "Prune", "Expand", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:combinePows", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:combinePows", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "/:Prune:xOverX", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:combinePows", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "^:Tidy:replacePowerOfFractionWithRoots", "*:Tidy:apply", "Tidy"}
	},
	{
		code="difftest(sin(x))",
		comment="",
		duration=0.006198,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="difftest(cos(x))",
		comment="",
		duration=0.010699,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="difftest(exp(x))",
		comment="",
		duration=0.007367,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{code="", comment="some other L'Hospital rule problems:", duration=2.9999999999752e-06},
	{
		code="simplifyAssertEq(lim(sin(x) / x, x, 0), 1)",
		comment="",
		duration=0.001885,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim(exp(x) / x^2, x, inf), inf)",
		comment="",
		duration=0.009087,
		simplifyStack={"Init", "Limit:Prune:apply", "Limit:Prune:apply", "^:Prune:handleInfAndNan", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply", "^:Prune:handleInfAndNan", "Limit:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim((e^x - 1) / (x^2 + x), x, 0), 1)",
		comment="",
		duration=0.017624,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(lim((2*sin(x) - sin(2*x)) / (x - sin(x)), x, 0), 6)",
		comment="",
		duration=0.072046,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=3.999999999893e-06},
	{code="", comment="TODO this one, repeatedly apply L'Hospital until the power of x on top is <= 0", duration=3.999999999893e-06},
	{code="", comment="but this seems like it would need a special case of evaluating into a factorial", duration=4.000000000115e-06},
	{
		code="simplifyAssertEq(lim(x^n * e^x, x, 0), 0)",
		comment="",
		duration=0.0053979999999998,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:125: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:246: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:245>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:125: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq(lim(x^n * e^x, x, 0), 0)\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:238: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:237>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:237: in function 'exec'\n\9limit.lua:249: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:54: in function 'timer'\n\9limit.lua:6: in main chunk\n\9[C]: at 0x55ac611723e0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=3.999999999893e-06},
	{code="", comment="TODO this requires representing x ln x as (ln x) / (1/x) before applying L'Hospital", duration=3.999999999893e-06},
	{
		code="simplifyAssertEq(lim(x * log(x), x, 0, '+'), 0)",
		comment="",
		duration=0.00063600000000008,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.000000000115e-06},
	{code="", comment="mortgage repayment formula -- works", duration=3.999999999893e-06},
	{
		code="simplifyAssertEq(lim( (a * x * (1 + x)^n) / ((1 + x)^n - 1), x, 0 ), a / n)",
		comment="",
		duration=0.062104,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.0000000000328e-06},
	{code="", comment="the infamous tanh(x) ... works?  hmm ... this is infamous for taking an infinite number of L'Hospital applications.  Why is it working?", duration=5.0000000000328e-06},
	{
		code="print( ((e^x + e^-x) / (e^x - e^-x)):lim(x, inf):prune() )",
		comment="",
		duration=0.032127,
		simplifyStack={"Init", "Derivative:Prune:constants", "Derivative:Prune:constants", "*:Prune:apply", "Derivative:Prune:self", "*:Prune:apply", "+:Prune:combineConstants", "Derivative:Prune:eval", "log:Prune:apply", "*:Prune:apply", "Derivative:Prune:other", "*:Prune:apply", "/:Prune:zeroOverX", "+:Prune:combineConstants", "Derivative:Prune:eval", "+:Prune:combineConstants", "Derivative:Prune:eval", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "*:Tidy:apply", "Tidy", "/:Prune:xOverX", "Limit:Prune:apply", "Limit:Prune:apply", "Limit:Prune:apply"}
	}
}