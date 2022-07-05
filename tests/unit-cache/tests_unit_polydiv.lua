{
	{
		code="simplifyAssertAllEq({(x - a):polydivr(x - a, x, verbose)}, {1,0})",
		comment="",
		duration=0.014586,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x^2 - a):polydivr(x - sqrt(a), x, verbose)}, {x + sqrt(a),0})",
		comment="",
		duration=0.045426,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999998712e-07},
	{
		code="simplifyAssertAllEq({(x^2 + 2 * x * a + a^2):polydivr(x + a, x, verbose)}, {x + a, 0})",
		comment="",
		duration=0.011806,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x^2 - 2 * x * a + a^2):polydivr(x - a, x, verbose)}, {x - a, 0})",
		comment="",
		duration=0.019168,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertAllEq({(x^2 - a^2):polydivr(x - a, x, verbose)}, {x + a, 0})",
		comment="",
		duration=0.011381,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x^2 - a^2):polydivr(x + a, x, verbose)}, {x - a, 0})",
		comment="",
		duration=0.012833,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}