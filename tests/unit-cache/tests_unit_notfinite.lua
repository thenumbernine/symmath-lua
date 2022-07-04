{
	{code="", comment="infinite.", duration=1.000000000001e-06},
	{code="", comment="using https://en.wikipedia.org/wiki/Limit_of_a_function", duration=9.9999999999406e-07},
	{code="", comment="TODO should these be valid, or should they always produce 'invalid'", duration=0},
	{code="", comment="and only Limit() produce valid operations on infinity?", duration=0},
	{code="", comment="", duration=9.9999999999406e-07},
	{
		code="simplifyAssertEq(inf, inf)",
		comment="",
		duration=0.000721,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertNe(inf, -inf)",
		comment="",
		duration=0.001077,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertNe(inf, invalid)",
		comment="",
		duration=0.000235,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="q + inf = inf for q != -inf", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(inf + inf, inf)",
		comment="",
		duration=0.000217,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf + 0, inf)",
		comment="",
		duration=4.8000000000006e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf + 1, inf)",
		comment="",
		duration=0.000155,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf - 1, inf)",
		comment="",
		duration=0.000136,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf + x + y, inf)",
		comment="",
		duration=0.000162,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="q * inf = inf for q > 0 (incl q == inf)", duration=1.000000000001e-06},
	{code="", comment="q * inf = -inf for q < 0 (incl q == -inf)", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq((inf * inf), inf)",
		comment="",
		duration=7.2000000000003e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((inf * -inf), -inf)",
		comment="",
		duration=0.001299,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((inf * -1), -inf)",
		comment="",
		duration=0.000867,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((inf * -1 * -2), inf)",
		comment="",
		duration=0.000392,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((inf * 1 * 2), inf)",
		comment="",
		duration=7.0000000000001e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf * x, inf)",
		comment="TODO this should be unknown unless x is defined as a positive or negative real",
		duration=0.000125,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf / 2, inf)",
		comment="",
		duration=6.5000000000003e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="0 * inf = invalid", duration=0},
	{
		code="simplifyAssertEq(inf * 0, invalid)",
		comment="",
		duration=0.000218,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf / 0, invalid)",
		comment="",
		duration=5.3999999999998e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="q / inf = 0 for q != inf and q != -inf", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(-2 / inf, 0)",
		comment="",
		duration=0.00019,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(-1 / inf, 0)",
		comment="",
		duration=8.9000000000006e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(-.5 / inf, 0)",
		comment="",
		duration=0.00022299999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(0 / inf, 0)",
		comment="",
		duration=0.000302,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(.5 / inf, 0)",
		comment="",
		duration=0.000207,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(1 / inf, 0)",
		comment="",
		duration=0.000141,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(2 / inf, 0)",
		comment="",
		duration=0.000185,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{code="", comment="inf^q = 0 for q < 0", duration=1.000000000001e-06},
	{code="", comment="inf^q = inf for q > 0", duration=9.9999999999406e-07},
	{
		code="simplifyAssertEq(inf ^ -inf, invalid)",
		comment="",
		duration=0.00020199999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ -2, 0)",
		comment="",
		duration=8.7000000000004e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ -1, 0)",
		comment="",
		duration=8.4000000000001e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ -.5, 0)",
		comment="",
		duration=0.000198,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ 0, invalid)",
		comment="",
		duration=0.000139,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ .5, inf)",
		comment="",
		duration=6.5000000000003e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ 1, inf)",
		comment="",
		duration=4.2e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ 2, inf)",
		comment="",
		duration=6.0999999999999e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ inf, inf)",
		comment="",
		duration=5.8000000000002e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="q^inf = 0 for 0 < q < 1", duration=1.000000000001e-06},
	{code="", comment="q^inf = inf for 1 < q", duration=0},
	{
		code="simplifyAssertEq((-2) ^ inf, invalid)",
		comment="",
		duration=7.7000000000001e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((-.5) ^ inf, invalid)",
		comment="",
		duration=7.9000000000003e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(0 ^ inf, invalid)",
		comment="",
		duration=8.8000000000005e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(.5 ^ inf, 0)",
		comment="",
		duration=0.000176,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(2 ^ inf, inf)",
		comment="",
		duration=6.4000000000002e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{code="", comment="q^-inf = inf for 0 < q < 1", duration=9.9999999999406e-07},
	{code="", comment="q^-inf = 0 for 1 < q", duration=9.9999999999406e-07},
	{
		code="simplifyAssertEq((-2) ^ -inf, invalid)",
		comment="",
		duration=0.00062,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((-.5) ^ -inf, invalid)",
		comment="",
		duration=0.000197,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(0 ^ -inf, invalid)",
		comment="",
		duration=0.00012599999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(.5 ^ -inf, inf)",
		comment="",
		duration=0.000114,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(2 ^ -inf, 0)",
		comment="",
		duration=0.000155,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="indeterminant:", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(Constant(0) / 0, invalid)",
		comment="",
		duration=5.4999999999999e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(Constant(0) / (Constant(3) * Constant(0)), invalid)",
		comment="verify short-circuit doesn't interfere",
		duration=9.4999999999998e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-inf / inf, invalid)",
		comment="",
		duration=0.000114,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf / inf, invalid)",
		comment="",
		duration=6.4999999999996e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf / -inf, invalid)",
		comment="",
		duration=0.000241,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-inf / -inf, invalid)",
		comment="",
		duration=0.0002,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(0 * inf, invalid)",
		comment="",
		duration=7.8000000000002e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(0 * -inf, invalid)",
		comment="",
		duration=0.000123,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf + -inf, invalid)",
		comment="",
		duration=9.8000000000001e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(Constant(0) ^ 0, invalid)",
		comment="",
		duration=6.2e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ 0, invalid)",
		comment="",
		duration=9.7e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((-1) ^ inf, invalid)",
		comment="",
		duration=7.3999999999998e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((-1) ^ -inf, invalid)",
		comment="",
		duration=0.000104,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(1 ^ inf, invalid)",
		comment="",
		duration=7.2000000000003e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(1 ^ -inf, invalid)",
		comment="",
		duration=0.000139,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}