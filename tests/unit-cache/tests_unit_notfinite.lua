{
	{code="", comment="infinite.", duration=1.000000000001e-06},
	{code="", comment="using https://en.wikipedia.org/wiki/Limit_of_a_function", duration=1.000000000001e-06},
	{code="", comment="TODO should these be valid, or should they always produce 'invalid'", duration=1.000000000001e-06},
	{code="", comment="and only Limit() produce valid operations on infinity?", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(inf, inf)",
		comment="",
		duration=0.000215,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertNe(inf, -inf)",
		comment="",
		duration=0.000834,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertNe(inf, invalid)",
		comment="",
		duration=0.000122,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="q + inf = inf for q != -inf", duration=0},
	{
		code="simplifyAssertEq(inf + inf, inf)",
		comment="",
		duration=0.00024100000000001,
		simplifyStack={"Init", "+:Prune:handleInfAndInvalid", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf + 0, inf)",
		comment="",
		duration=2.2000000000001e-05,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq(inf + 1, inf)",
		comment="",
		duration=0.000103,
		simplifyStack={"Init", "+:Prune:handleInfAndInvalid", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf - 1, inf)",
		comment="",
		duration=0.000265,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "+:Prune:handleInfAndInvalid", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf + x + y, inf)",
		comment="",
		duration=0.000245,
		simplifyStack={"Init", "+:Prune:handleInfAndInvalid", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{code="", comment="q * inf = inf for q > 0 (incl q == inf)", duration=1.000000000001e-06},
	{code="", comment="q * inf = -inf for q < 0 (incl q == -inf)", duration=9.9999999999406e-07},
	{
		code="simplifyAssertEq((inf * inf), inf)",
		comment="",
		duration=7.4999999999999e-05,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((inf * -inf), -inf)",
		comment="",
		duration=0.001135,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((inf * -1), -inf)",
		comment="",
		duration=0.000802,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((inf * -1 * -2), inf)",
		comment="",
		duration=0.00015399999999999,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((inf * 1 * 2), inf)",
		comment="",
		duration=0.000157,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf * x, inf)",
		comment="TODO this should be unknown unless x is defined as a positive or negative real",
		duration=8.6999999999997e-05,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf / 2, inf)",
		comment="",
		duration=0.000161,
		simplifyStack={"Init", "/:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="0 * inf = invalid", duration=9.9999999999406e-07},
	{
		code="simplifyAssertEq(inf * 0, invalid)",
		comment="",
		duration=0.000335,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf / 0, invalid)",
		comment="",
		duration=5.9999999999998e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="q / inf = 0 for q != inf and q != -inf", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(-2 / inf, 0)",
		comment="",
		duration=0.000299,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-1 / inf, 0)",
		comment="",
		duration=0.00014,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-.5 / inf, 0)",
		comment="",
		duration=0.000134,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(0 / inf, 0)",
		comment="",
		duration=0.000214,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(.5 / inf, 0)",
		comment="",
		duration=0.00019599999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(1 / inf, 0)",
		comment="",
		duration=0.000256,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(2 / inf, 0)",
		comment="",
		duration=0.000208,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{code="", comment="inf^q = 0 for q < 0", duration=1.000000000001e-06},
	{code="", comment="inf^q = inf for q > 0", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(inf ^ -inf, invalid)",
		comment="",
		duration=0.000171,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ -2, 0)",
		comment="",
		duration=0.000117,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ -1, 0)",
		comment="",
		duration=0.000112,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ -.5, 0)",
		comment="",
		duration=0.000118,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ 0, invalid)",
		comment="",
		duration=0.000112,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ .5, inf)",
		comment="",
		duration=4.6999999999998e-05,
		simplifyStack={"Init", "^:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ 1, inf)",
		comment="",
		duration=3.9999999999998e-05,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq(inf ^ 2, inf)",
		comment="",
		duration=6.6999999999998e-05,
		simplifyStack={"Init", "^:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ inf, inf)",
		comment="",
		duration=9.4999999999998e-05,
		simplifyStack={"Init", "^:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="q^inf = 0 for 0 < q < 1", duration=1.000000000001e-06},
	{code="", comment="q^inf = inf for 1 < q", duration=0},
	{
		code="simplifyAssertEq((-2) ^ inf, invalid)",
		comment="",
		duration=0.000113,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((-.5) ^ inf, invalid)",
		comment="",
		duration=0.000152,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(0 ^ inf, invalid)",
		comment="",
		duration=0.00012,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(.5 ^ inf, 0)",
		comment="",
		duration=0.000221,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(2 ^ inf, inf)",
		comment="",
		duration=0.00013800000000001,
		simplifyStack={"Init", "^:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{code="", comment="q^-inf = inf for 0 < q < 1", duration=0},
	{code="", comment="q^-inf = 0 for 1 < q", duration=0},
	{
		code="simplifyAssertEq((-2) ^ -inf, invalid)",
		comment="",
		duration=0.000156,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((-.5) ^ -inf, invalid)",
		comment="",
		duration=9.3999999999997e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(0 ^ -inf, invalid)",
		comment="",
		duration=0.000122,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(.5 ^ -inf, inf)",
		comment="",
		duration=0.000174,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "^:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(2 ^ -inf, 0)",
		comment="",
		duration=0.00013299999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="indeterminant:", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(Constant(0) / 0, invalid)",
		comment="",
		duration=5.1999999999996e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(Constant(0) / (Constant(3) * Constant(0)), invalid)",
		comment="verify short-circuit doesn't interfere",
		duration=0.00037,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-inf / inf, invalid)",
		comment="",
		duration=0.000456,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf / inf, invalid)",
		comment="",
		duration=0.000176,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf / -inf, invalid)",
		comment="",
		duration=0.000215,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-inf / -inf, invalid)",
		comment="",
		duration=0.000277,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(0 * inf, invalid)",
		comment="",
		duration=0.000243,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(0 * -inf, invalid)",
		comment="",
		duration=0.000116,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf + -inf, invalid)",
		comment="",
		duration=0.000113,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(Constant(0) ^ 0, invalid)",
		comment="",
		duration=4.4999999999996e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ 0, invalid)",
		comment="",
		duration=9.5999999999999e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((-1) ^ inf, invalid)",
		comment="",
		duration=5.9999999999998e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((-1) ^ -inf, invalid)",
		comment="",
		duration=0.000171,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(1 ^ inf, invalid)",
		comment="",
		duration=5.9999999999998e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(1 ^ -inf, invalid)",
		comment="",
		duration=0.000126,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}