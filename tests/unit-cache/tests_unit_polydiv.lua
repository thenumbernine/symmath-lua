{
	{
		code="simplifyAssertAllEq({(x - a):polydivr(x - a, x, verbose)}, {1,0})",
		comment="",
		duration=0.011182,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x^2 - a):polydivr(x - sqrt(a), x, verbose)}, {x + sqrt(a),0})",
		comment="",
		duration=0.046183,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x^2 + 2 * x * a + a^2):polydivr(x + a, x, verbose)}, {x + a, 0})",
		comment="",
		duration=0.012851,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x^2 - 2 * x * a + a^2):polydivr(x - a, x, verbose)}, {x - a, 0})",
		comment="",
		duration=0.015967,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertAllEq({(x^2 - a^2):polydivr(x - a, x, verbose)}, {x + a, 0})",
		comment="",
		duration=0.013307,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x^2 - a^2):polydivr(x + a, x, verbose)}, {x - a, 0})",
		comment="",
		duration=0.01225,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}