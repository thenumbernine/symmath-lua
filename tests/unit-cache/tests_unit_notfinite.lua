{
	{code="", comment="infinite.", duration=1.000000000001e-06},
	{code="", comment="using https://en.wikipedia.org/wiki/Limit_of_a_function", duration=1.000000000001e-06},
	{code="", comment="TODO should these be valid, or should they always produce 'invalid'", duration=1.000000000001e-06},
	{code="", comment="and only Limit() produce valid operations on infinity?", duration=0},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(inf, inf)",
		comment="",
		duration=0.000397,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertNe(inf, -inf)",
		comment="",
		duration=0.002403,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertNe(inf, invalid)",
		comment="",
		duration=0.000615,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="q + inf = inf for q != -inf", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(inf + inf, inf)",
		comment="",
		duration=0.000571,
		simplifyStack={"Init", "+:Prune:handleInfAndInvalid", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf + 0, inf)",
		comment="",
		duration=0.00011,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq(inf + 1, inf)",
		comment="",
		duration=0.000244,
		simplifyStack={"Init", "+:Prune:handleInfAndInvalid", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf - 1, inf)",
		comment="",
		duration=0.000324,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "+:Prune:handleInfAndInvalid", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf + x + y, inf)",
		comment="",
		duration=0.000641,
		simplifyStack={"Init", "+:Prune:handleInfAndInvalid", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="q * inf = inf for q > 0 (incl q == inf)", duration=0},
	{code="", comment="q * inf = -inf for q < 0 (incl q == -inf)", duration=0},
	{
		code="simplifyAssertEq((inf * inf), inf)",
		comment="",
		duration=0.000351,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((inf * -inf), -inf)",
		comment="",
		duration=0.003739,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((inf * -1), -inf)",
		comment="",
		duration=0.001891,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "Prune", "Expand", "*:Prune:handleInfAndNan", "Prune", "Factor", "*:Prune:handleInfAndNan", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((inf * -1 * -2), inf)",
		comment="",
		duration=0.000531,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((inf * 1 * 2), inf)",
		comment="",
		duration=0.00046599999999999,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf * x, inf)",
		comment="TODO this should be unknown unless x is defined as a positive or negative real",
		duration=0.000633,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf / 2, inf)",
		comment="",
		duration=0.00041,
		simplifyStack={"Init", "/:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="0 * inf = invalid", duration=0},
	{
		code="simplifyAssertEq(inf * 0, invalid)",
		comment="",
		duration=0.000573,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf / 0, invalid)",
		comment="",
		duration=0.00036,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="q / inf = 0 for q != inf and q != -inf", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(-2 / inf, 0)",
		comment="",
		duration=0.00044,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-1 / inf, 0)",
		comment="",
		duration=0.000289,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-.5 / inf, 0)",
		comment="",
		duration=0.000244,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(0 / inf, 0)",
		comment="",
		duration=0.000228,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(.5 / inf, 0)",
		comment="",
		duration=0.000296,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(1 / inf, 0)",
		comment="",
		duration=0.00079700000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(2 / inf, 0)",
		comment="",
		duration=0.00076,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="inf^q = 0 for q < 0", duration=1.000000000001e-06},
	{code="", comment="inf^q = inf for q > 0", duration=0},
	{
		code="simplifyAssertEq(inf ^ -inf, invalid)",
		comment="",
		duration=0.00112,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ -2, 0)",
		comment="",
		duration=0.000439,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ -1, 0)",
		comment="",
		duration=0.000389,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ -.5, 0)",
		comment="",
		duration=0.000318,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ 0, invalid)",
		comment="",
		duration=0.000515,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ .5, inf)",
		comment="",
		duration=0.000136,
		simplifyStack={"Init", "^:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ 1, inf)",
		comment="",
		duration=0.000173,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq(inf ^ 2, inf)",
		comment="",
		duration=0.000288,
		simplifyStack={"Init", "^:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ inf, inf)",
		comment="",
		duration=0.000116,
		simplifyStack={"Init", "^:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="q^inf = 0 for 0 < q < 1", duration=0},
	{code="", comment="q^inf = inf for 1 < q", duration=9.9999999998712e-07},
	{
		code="simplifyAssertEq((-2) ^ inf, invalid)",
		comment="",
		duration=0.000307,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((-.5) ^ inf, invalid)",
		comment="",
		duration=0.000483,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(0 ^ inf, invalid)",
		comment="",
		duration=0.000211,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(.5 ^ inf, 0)",
		comment="",
		duration=0.000222,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(2 ^ inf, inf)",
		comment="",
		duration=0.00018,
		simplifyStack={"Init", "^:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="q^-inf = inf for 0 < q < 1", duration=0},
	{code="", comment="q^-inf = 0 for 1 < q", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq((-2) ^ -inf, invalid)",
		comment="",
		duration=0.000358,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((-.5) ^ -inf, invalid)",
		comment="",
		duration=0.00038100000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(0 ^ -inf, invalid)",
		comment="",
		duration=0.00064,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(.5 ^ -inf, inf)",
		comment="",
		duration=0.00041999999999999,
		simplifyStack={"Init", "*:Prune:handleInfAndNan", "unm:Prune:doubleNegative", "^:Prune:handleInfAndNan", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(2 ^ -inf, 0)",
		comment="",
		duration=0.00045899999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="indeterminant:", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(Constant(0) / 0, invalid)",
		comment="",
		duration=0.00016899999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(Constant(0) / (Constant(3) * Constant(0)), invalid)",
		comment="verify short-circuit doesn't interfere",
		duration=0.00038199999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-inf / inf, invalid)",
		comment="",
		duration=0.000417,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf / inf, invalid)",
		comment="",
		duration=0.000231,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf / -inf, invalid)",
		comment="",
		duration=0.00020100000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-inf / -inf, invalid)",
		comment="",
		duration=0.000401,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(0 * inf, invalid)",
		comment="",
		duration=0.000246,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(0 * -inf, invalid)",
		comment="",
		duration=0.000302,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf + -inf, invalid)",
		comment="",
		duration=0.000293,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(Constant(0) ^ 0, invalid)",
		comment="",
		duration=0.000122,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(inf ^ 0, invalid)",
		comment="",
		duration=0.000253,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((-1) ^ inf, invalid)",
		comment="",
		duration=0.000295,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((-1) ^ -inf, invalid)",
		comment="",
		duration=0.00044999999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(1 ^ inf, invalid)",
		comment="",
		duration=0.00018499999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(1 ^ -inf, invalid)",
		comment="",
		duration=0.000266,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}