{
	{code="", comment="infinite.", duration=7.000000000007e-06},
	{code="", comment="using https://en.wikipedia.org/wiki/Limit_of_a_function", duration=4.000000000004e-06},
	{code="", comment="TODO should these be valid, or should they always produce 'invalid'", duration=5.000000000005e-06},
	{code="", comment="and only Limit() produce valid operations on infinity?", duration=4.000000000004e-06},
	{code="", comment="", duration=5.000000000005e-06},
	{
		code="simplifyAssertEq(inf, inf)",
		comment="",
		duration=0.00075399999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertNe(inf, -inf)",
		comment="",
		duration=0.006314,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertNe(inf, invalid)",
		comment="",
		duration=0.001355,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=6.000000000006e-06},
	{code="", comment="q + inf = inf for q != -inf", duration=5.000000000005e-06},
	{
		code="simplifyAssertEq(inf + inf, inf)",
		comment="",
		duration=0.00094,
		simplifyStack={"Init", "+:Prune:handleInfAndInvalid", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf + 0, inf)",
		comment="",
		duration=0.00029399999999999,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq(inf + 1, inf)",
		comment="",
		duration=0.001126,
		simplifyStack={"Init", "+:Prune:handleInfAndInvalid", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf - 1, inf)",
		comment="",
		duration=0.00092900000000001,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "+:Prune:handleInfAndInvalid", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf + x + y, inf)",
		comment="",
		duration=0.001761,
		simplifyStack={"Init", "+:Prune:handleInfAndInvalid", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.9999999999782e-06},
	{code="", comment="q * inf = inf for q > 0 (incl q == inf)", duration=6.000000000006e-06},
	{code="", comment="q * inf = -inf for q < 0 (incl q == -inf)", duration=6.000000000006e-06},
	{
		code="simplifyAssertEq((inf * inf), inf)",
		comment="",
		duration=0.001027,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((inf * -inf), -inf)",
		comment="",
		duration=0.008287,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((inf * -1), -inf)",
		comment="",
		duration=0.005104,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((inf * -1 * -2), inf)",
		comment="",
		duration=0.001528,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((inf * 1 * 2), inf)",
		comment="",
		duration=0.000886,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf * x, inf)",
		comment="TODO this should be unknown unless x is defined as a positive or negative real",
		duration=0.001156,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf / 2, inf)",
		comment="",
		duration=0.001785,
		simplifyStack={"Init", "/:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=6.000000000006e-06},
	{code="", comment="0 * inf = invalid", duration=6.000000000006e-06},
	{
		code="simplifyAssertEq(inf * 0, invalid)",
		comment="",
		duration=0.002888,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf / 0, invalid)",
		comment="",
		duration=0.00092,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=6.9999999999792e-06},
	{code="", comment="q / inf = 0 for q != inf and q != -inf", duration=5.000000000005e-06},
	{
		code="simplifyAssertEq(-2 / inf, 0)",
		comment="",
		duration=0.001114,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-1 / inf, 0)",
		comment="",
		duration=0.00045999999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-.5 / inf, 0)",
		comment="",
		duration=0.00050800000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(0 / inf, 0)",
		comment="",
		duration=0.00070500000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(.5 / inf, 0)",
		comment="",
		duration=0.00087800000000002,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(1 / inf, 0)",
		comment="",
		duration=0.001033,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(2 / inf, 0)",
		comment="",
		duration=0.001175,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.9999999999782e-06},
	{code="", comment="inf^q = 0 for q < 0", duration=3.9999999999762e-06},
	{code="", comment="inf^q = inf for q > 0", duration=4.000000000004e-06},
	{
		code="simplifyAssertEq(inf ^ -inf, invalid)",
		comment="",
		duration=0.00059599999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ -2, 0)",
		comment="",
		duration=0.000662,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ -1, 0)",
		comment="",
		duration=0.000497,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ -.5, 0)",
		comment="",
		duration=0.000497,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ 0, invalid)",
		comment="",
		duration=0.00065400000000002,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ .5, inf)",
		comment="",
		duration=0.00029499999999999,
		simplifyStack={"Init", "^:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ 1, inf)",
		comment="",
		duration=0.00023799999999999,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq(inf ^ 2, inf)",
		comment="",
		duration=0.000528,
		simplifyStack={"Init", "^:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ inf, inf)",
		comment="",
		duration=0.00076700000000002,
		simplifyStack={"Init", "^:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=6.000000000006e-06},
	{code="", comment="q^inf = 0 for 0 < q < 1", duration=6.000000000006e-06},
	{code="", comment="q^inf = inf for 1 < q", duration=6.000000000006e-06},
	{
		code="simplifyAssertEq((-2) ^ inf, invalid)",
		comment="",
		duration=0.001054,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((-.5) ^ inf, invalid)",
		comment="",
		duration=0.00070400000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(0 ^ inf, invalid)",
		comment="",
		duration=0.001738,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(.5 ^ inf, 0)",
		comment="",
		duration=0.00073099999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(2 ^ inf, inf)",
		comment="",
		duration=0.00034599999999999,
		simplifyStack={"Init", "^:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="q^-inf = inf for 0 < q < 1", duration=7.000000000007e-06},
	{code="", comment="q^-inf = 0 for 1 < q", duration=7.000000000007e-06},
	{
		code="simplifyAssertEq((-2) ^ -inf, invalid)",
		comment="",
		duration=0.00064700000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((-.5) ^ -inf, invalid)",
		comment="",
		duration=0.00057600000000002,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(0 ^ -inf, invalid)",
		comment="",
		duration=0.001068,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(.5 ^ -inf, inf)",
		comment="",
		duration=0.001167,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "^:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(2 ^ -inf, 0)",
		comment="",
		duration=0.001312,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=6.000000000006e-06},
	{code="", comment="indeterminant:", duration=5.000000000005e-06},
	{
		code="simplifyAssertEq(Constant(0) / 0, invalid)",
		comment="",
		duration=0.00054900000000002,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(Constant(0) / (Constant(3) * Constant(0)), invalid)",
		comment="verify short-circuit doesn't interfere",
		duration=0.002206,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-inf / inf, invalid)",
		comment="",
		duration=0.001277,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf / inf, invalid)",
		comment="",
		duration=0.00095999999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf / -inf, invalid)",
		comment="",
		duration=0.000911,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-inf / -inf, invalid)",
		comment="",
		duration=0.001685,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(0 * inf, invalid)",
		comment="",
		duration=0.001429,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(0 * -inf, invalid)",
		comment="",
		duration=0.00093400000000002,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf + -inf, invalid)",
		comment="",
		duration=0.00058800000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(Constant(0) ^ 0, invalid)",
		comment="",
		duration=0.00049300000000002,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ 0, invalid)",
		comment="",
		duration=0.00057299999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((-1) ^ inf, invalid)",
		comment="",
		duration=0.00051299999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((-1) ^ -inf, invalid)",
		comment="",
		duration=0.000725,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(1 ^ inf, invalid)",
		comment="",
		duration=0.00051799999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(1 ^ -inf, invalid)",
		comment="",
		duration=0.00074099999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}