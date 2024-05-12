{
	{
		code="simplifyAssertAllEq({(x - a):polydivr(x - a, x, verbose)}, {1,0})",
		comment="",
		duration=0.005125,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x^2 - a):polydivr(x - sqrt(a), x, verbose)}, {x + sqrt(a),0})",
		comment="",
		duration=0.018344,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x^2 + 2 * x * a + a^2):polydivr(x + a, x, verbose)}, {x + a, 0})",
		comment="",
		duration=0.005648,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x^2 - 2 * x * a + a^2):polydivr(x - a, x, verbose)}, {x - a, 0})",
		comment="",
		duration=0.005726,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x^2 - a^2):polydivr(x - a, x, verbose)}, {x + a, 0})",
		comment="",
		duration=0.003687,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x^2 - a^2):polydivr(x + a, x, verbose)}, {x - a, 0})",
		comment="",
		duration=0.00404,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}