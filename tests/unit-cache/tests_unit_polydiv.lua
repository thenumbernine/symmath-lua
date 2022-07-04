{
	{
		code="simplifyAssertAllEq({(x - a):polydivr(x - a, x, verbose)}, {1,0})",
		comment="",
		duration=0.009255,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x^2 - a):polydivr(x - sqrt(a), x, verbose)}, {x + sqrt(a),0})",
		comment="",
		duration=0.029868,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x^2 + 2 * x * a + a^2):polydivr(x + a, x, verbose)}, {x + a, 0})",
		comment="",
		duration=0.012524,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x^2 - 2 * x * a + a^2):polydivr(x - a, x, verbose)}, {x - a, 0})",
		comment="",
		duration=0.012019,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x^2 - a^2):polydivr(x - a, x, verbose)}, {x + a, 0})",
		comment="",
		duration=0.009734,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x^2 - a^2):polydivr(x + a, x, verbose)}, {x - a, 0})",
		comment="",
		duration=0.01186,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	}
}