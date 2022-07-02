{
	{code="", comment="infinite.", duration=1.000000000001e-06},
	{code="", comment="using https://en.wikipedia.org/wiki/Limit_of_a_function", duration=9.9999999999753e-07},
	{code="", comment="TODO should these be valid, or should they always produce 'invalid'", duration=9.9999999999753e-07},
	{code="", comment="and only Limit() produce valid operations on infinity?", duration=9.9999999999753e-07},
	{code="", comment="", duration=9.9999999999753e-07},
	{
		code="simplifyAssertEq(inf, inf)",
		comment="",
		duration=4.7000000000002e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertNe(inf, -inf)",
		comment="",
		duration=0.001034,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertNe(inf, invalid)",
		comment="",
		duration=0.00015,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="q + inf = inf for q != -inf", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(inf + inf, inf)",
		comment="",
		duration=0.000229,
		simplifyStack={"Init", "+:Prune:handleInfAndInvalid", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf + 0, inf)",
		comment="",
		duration=1.0999999999997e-05,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq(inf + 1, inf)",
		comment="",
		duration=0.000127,
		simplifyStack={"Init", "+:Prune:handleInfAndInvalid", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf - 1, inf)",
		comment="",
		duration=0.00028,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "+:Prune:handleInfAndInvalid", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf + x + y, inf)",
		comment="",
		duration=0.000414,
		simplifyStack={"Init", "+:Prune:handleInfAndInvalid", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="q * inf = inf for q > 0 (incl q == inf)", duration=0},
	{code="", comment="q * inf = -inf for q < 0 (incl q == -inf)", duration=9.9999999999753e-07},
	{
		code="simplifyAssertEq((inf * inf), inf)",
		comment="",
		duration=6.3000000000001e-05,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((inf * -inf), -inf)",
		comment="",
		duration=0.001521,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((inf * -1), -inf)",
		comment="",
		duration=0.001565,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((inf * -1 * -2), inf)",
		comment="",
		duration=8.7999999999998e-05,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((inf * 1 * 2), inf)",
		comment="",
		duration=0.000143,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf * x, inf)",
		comment="TODO this should be unknown unless x is defined as a positive or negative real",
		duration=0.000228,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf / 2, inf)",
		comment="",
		duration=5.8999999999997e-05,
		simplifyStack={"Init", "/:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{code="", comment="0 * inf = invalid", duration=0},
	{
		code="simplifyAssertEq(inf * 0, invalid)",
		comment="",
		duration=0.000143,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf / 0, invalid)",
		comment="",
		duration=7.4000000000005e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="q / inf = 0 for q != inf and q != -inf", duration=9.9999999999406e-07},
	{
		code="simplifyAssertEq(-2 / inf, 0)",
		comment="",
		duration=0.000192,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-1 / inf, 0)",
		comment="",
		duration=0.00016,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-.5 / inf, 0)",
		comment="",
		duration=0.000145,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(0 / inf, 0)",
		comment="",
		duration=0.000149,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(.5 / inf, 0)",
		comment="",
		duration=0.000105,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(1 / inf, 0)",
		comment="",
		duration=0.000115,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(2 / inf, 0)",
		comment="",
		duration=0.000108,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="inf^q = 0 for q < 0", duration=1.000000000001e-06},
	{code="", comment="inf^q = inf for q > 0", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(inf ^ -inf, invalid)",
		comment="",
		duration=0.000196,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ -2, 0)",
		comment="",
		duration=9.8000000000001e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ -1, 0)",
		comment="",
		duration=0.000147,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ -.5, 0)",
		comment="",
		duration=0.000151,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ 0, invalid)",
		comment="",
		duration=0.000123,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ .5, inf)",
		comment="",
		duration=5.4999999999999e-05,
		simplifyStack={"Init", "^:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ 1, inf)",
		comment="",
		duration=1.2999999999999e-05,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq(inf ^ 2, inf)",
		comment="",
		duration=3.2999999999998e-05,
		simplifyStack={"Init", "^:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ inf, inf)",
		comment="",
		duration=2.7999999999993e-05,
		simplifyStack={"Init", "^:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="q^inf = 0 for 0 < q < 1", duration=1.000000000001e-06},
	{code="", comment="q^inf = inf for 1 < q", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq((-2) ^ inf, invalid)",
		comment="",
		duration=0.000104,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((-.5) ^ inf, invalid)",
		comment="",
		duration=0.000332,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(0 ^ inf, invalid)",
		comment="",
		duration=8.2000000000006e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(.5 ^ inf, 0)",
		comment="",
		duration=6.2999999999994e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(2 ^ inf, inf)",
		comment="",
		duration=3.8000000000003e-05,
		simplifyStack={"Init", "^:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{code="", comment="q^-inf = inf for 0 < q < 1", duration=1.000000000001e-06},
	{code="", comment="q^-inf = 0 for 1 < q", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq((-2) ^ -inf, invalid)",
		comment="",
		duration=0.000127,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((-.5) ^ -inf, invalid)",
		comment="",
		duration=0.000131,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(0 ^ -inf, invalid)",
		comment="",
		duration=0.000299,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(.5 ^ -inf, inf)",
		comment="",
		duration=0.000129,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "^:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(2 ^ -inf, 0)",
		comment="",
		duration=0.000164,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{code="", comment="indeterminant:", duration=2.3000000000002e-05},
	{
		code="simplifyAssertEq(Constant(0) / 0, invalid)",
		comment="",
		duration=7.7000000000001e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(Constant(0) / (Constant(3) * Constant(0)), invalid)",
		comment="verify short-circuit doesn't interfere",
		duration=0.00013800000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-inf / inf, invalid)",
		comment="",
		duration=0.000132,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf / inf, invalid)",
		comment="",
		duration=6.5999999999997e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf / -inf, invalid)",
		comment="",
		duration=0.000345,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-inf / -inf, invalid)",
		comment="",
		duration=0.000175,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(0 * inf, invalid)",
		comment="",
		duration=0.000205,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(0 * -inf, invalid)",
		comment="",
		duration=0.000253,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf + -inf, invalid)",
		comment="",
		duration=0.000103,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(Constant(0) ^ 0, invalid)",
		comment="",
		duration=7.1000000000002e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ 0, invalid)",
		comment="",
		duration=8.5000000000002e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((-1) ^ inf, invalid)",
		comment="",
		duration=0.000113,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((-1) ^ -inf, invalid)",
		comment="",
		duration=0.000178,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(1 ^ inf, invalid)",
		comment="",
		duration=9.7e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(1 ^ -inf, invalid)",
		comment="",
		duration=0.000125,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}