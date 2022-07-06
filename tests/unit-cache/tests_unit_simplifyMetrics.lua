{
	{
		code="simplifyAssertEq(a'^i':simplifyMetrics(), a'^i')",
		comment="",
		duration=0.002324,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'^min' * delta'_i^j'):simplifyMetrics(), a'^mjn')",
		comment="",
		duration=0.004604,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{code="", comment="g shouldn't apply to delta, but delta should apply to g", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq((g'^ij' * delta'_j^k'):simplifyMetrics(), g'^ik')",
		comment="",
		duration=0.003427,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((delta'_j^k' * g'^ij'):simplifyMetrics(), g'^ik')",
		comment="",
		duration=0.004774,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="delta works on mixed tensors", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq((a'^i' * delta'_i^j'):simplifyMetrics(), a'^j')",
		comment="",
		duration=0.002791,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'^i' * delta'^j_i'):simplifyMetrics(), a'^j')",
		comment="",
		duration=0.002355,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((delta'_i^j' * a'^i'):simplifyMetrics(), a'^j')",
		comment="",
		duration=0.002709,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((delta'^j_i' * a'^i'):simplifyMetrics(), a'^j')",
		comment="",
		duration=0.001949,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999998712e-07},
	{code="", comment="does delta work when not mixed?  it shouldn't (unless the metric is equal to identity)", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq((a'^i' * delta'_ij'):simplifyMetrics(), a'^i' * delta'_ij')",
		comment="",
		duration=0.003174,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="g raises and lowers", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq((a'^i' * g'_ij'):simplifyMetrics(), a'_j')",
		comment="",
		duration=0.002364,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((g'_ij' * a'^i'):simplifyMetrics(), a'_j')",
		comment="",
		duration=0.002299,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'_i' * g'^ij'):simplifyMetrics(), a'^j')",
		comment="",
		duration=0.001776,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((g'^ij' * a'_i'):simplifyMetrics(), a'^j')",
		comment="",
		duration=0.001785,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="does g work when mixed?  technically $g^i_j == \\delta^i_j$", duration=0},
	{
		code="simplifyAssertEq((a'^i' * g'_i^j'):simplifyMetrics(), a'^j')",
		comment="",
		duration=0.002726,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="how about simplifying solely metrics without any non-metric tensors?", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq((g'^ik' * delta'_k^l'):simplifyMetrics(), g'^il')",
		comment="",
		duration=0.002399,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((g'^ik' * delta'_k^l' * delta'_l^m'):simplifyMetrics(), g'^im')",
		comment="",
		duration=0.004766,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="how about simplifying from metrics to deltas?", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq((g'^ik' * g'_kj'):simplifyMetrics(), delta'^i_j')",
		comment="",
		duration=0.002379,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((g'^ik' * delta'_k^l' * g'_lm'):simplifyMetrics(), delta'^i_m')",
		comment="",
		duration=0.003456,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((g'^ik' * delta'_k^l' * delta'_l^m' * g'_mn'):simplifyMetrics(), delta'^i_n')",
		comment="",
		duration=0.006444,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999998712e-07},
	{code="", comment="how about derivatives?  delta should work but g should not.", duration=1.000000000001e-06},
	{code="", comment="TODO technically g should work on the last ... technically ...  but raised partials are awkward to deal with.", duration=1.000000000001e-06},
	{code="", comment="and on that note, I might as well lower with the metric", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq((a'_,i' * g'^ij'):simplifyMetrics(), a'_,i' * g'^ij')",
		comment="",
		duration=0.00324,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'^,i' * g'_ij'):simplifyMetrics(), a'^,i' * g'_ij')",
		comment="",
		duration=0.003352,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'_,im' * g'^ij'):simplifyMetrics(), a'_,im' * g'^ij')",
		comment="",
		duration=0.003478,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'^,im' * g'_ij'):simplifyMetrics(), a'^,im' * g'_ij')",
		comment="",
		duration=0.003357,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'_i,m' * g'^ij'):simplifyMetrics(), a'_i,m' * g'^ij')",
		comment="",
		duration=0.00307,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'^i,m' * g'_ij'):simplifyMetrics(), a'^i,m' * g'_ij')",
		comment="",
		duration=0.002686,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="but delta should simplify with commas", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq((a'_,i' * delta'^i_j'):simplifyMetrics(), a'_,j')",
		comment="",
		duration=0.001607,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'^,i' * delta'_i^j'):simplifyMetrics(), a'^,j')",
		comment="",
		duration=0.001607,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'_,im' * delta'^i_j'):simplifyMetrics(), a'_,jm')",
		comment="",
		duration=0.002331,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'^,im' * delta'_i^j'):simplifyMetrics(), a'^,jm')",
		comment="",
		duration=0.001816,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'_i,m' * delta'^i_j'):simplifyMetrics(), a'_j_,m')",
		comment="",
		duration=0.001778,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'^i,m' * delta'_i^j'):simplifyMetrics(), a'^j^,m')",
		comment="",
		duration=0.001902,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{code="", comment="TODO someday:", duration=0},
	{code="", comment="allow g_ij to raise/lower the last partial derivative", duration=1.000000000001e-06},
	{code="", comment="allow g_ij to raise/lower any covariant derivatives not enclosed in partial derivatives.", duration=1.000000000001e-06}
}