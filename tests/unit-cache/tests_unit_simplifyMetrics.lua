{
	{
		code="simplifyAssertEq(a'^i':simplifyMetrics(), a'^i')",
		comment="",
		duration=0.002337,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'^min' * delta'_i^j'):simplifyMetrics(), a'^mjn')",
		comment="",
		duration=0.00651,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="g shouldn't apply to delta, but delta should apply to g", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq((g'^ij' * delta'_j^k'):simplifyMetrics(), g'^ik')",
		comment="",
		duration=0.003249,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((delta'_j^k' * g'^ij'):simplifyMetrics(), g'^ik')",
		comment="",
		duration=0.004135,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="delta works on mixed tensors", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq((a'^i' * delta'_i^j'):simplifyMetrics(), a'^j')",
		comment="",
		duration=0.002438,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'^i' * delta'^j_i'):simplifyMetrics(), a'^j')",
		comment="",
		duration=0.002573,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((delta'_i^j' * a'^i'):simplifyMetrics(), a'^j')",
		comment="",
		duration=0.00208,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((delta'^j_i' * a'^i'):simplifyMetrics(), a'^j')",
		comment="",
		duration=0.003505,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="does delta work when not mixed?  it shouldn't (unless the metric is equal to identity)", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq((a'^i' * delta'_ij'):simplifyMetrics(), a'^i' * delta'_ij')",
		comment="",
		duration=0.004614,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="g raises and lowers", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq((a'^i' * g'_ij'):simplifyMetrics(), a'_j')",
		comment="",
		duration=0.001879,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((g'_ij' * a'^i'):simplifyMetrics(), a'_j')",
		comment="",
		duration=0.002603,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'_i' * g'^ij'):simplifyMetrics(), a'^j')",
		comment="",
		duration=0.001986,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((g'^ij' * a'_i'):simplifyMetrics(), a'^j')",
		comment="",
		duration=0.002075,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=2.000000000002e-06},
	{code="", comment="does g work when mixed?  technically $g^i_j == \\delta^i_j$", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq((a'^i' * g'_i^j'):simplifyMetrics(), a'^j')",
		comment="",
		duration=0.001641,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="how about simplifying solely metrics without any non-metric tensors?", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq((g'^ik' * delta'_k^l'):simplifyMetrics(), g'^il')",
		comment="",
		duration=0.00218,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((g'^ik' * delta'_k^l' * delta'_l^m'):simplifyMetrics(), g'^im')",
		comment="",
		duration=0.003272,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="how about simplifying from metrics to deltas?", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq((g'^ik' * g'_kj'):simplifyMetrics(), delta'^i_j')",
		comment="",
		duration=0.002222,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((g'^ik' * delta'_k^l' * g'_lm'):simplifyMetrics(), delta'^i_m')",
		comment="",
		duration=0.003041,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((g'^ik' * delta'_k^l' * delta'_l^m' * g'_mn'):simplifyMetrics(), delta'^i_n')",
		comment="",
		duration=0.003948,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="how about derivatives?  delta should work but g should not.", duration=1.000000000001e-06},
	{code="", comment="TODO technically g should work on the last ... technically ...  but raised partials are awkward to deal with.", duration=1.000000000001e-06},
	{code="", comment="and on that note, I might as well lower with the metric", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq((a'_,i' * g'^ij'):simplifyMetrics(), a'_,i' * g'^ij')",
		comment="",
		duration=0.006032,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'^,i' * g'_ij'):simplifyMetrics(), a'^,i' * g'_ij')",
		comment="",
		duration=0.004356,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'_,im' * g'^ij'):simplifyMetrics(), a'_,im' * g'^ij')",
		comment="",
		duration=0.003882,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'^,im' * g'_ij'):simplifyMetrics(), a'^,im' * g'_ij')",
		comment="",
		duration=0.003362,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'_i,m' * g'^ij'):simplifyMetrics(), a'_i,m' * g'^ij')",
		comment="",
		duration=0.003327,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'^i,m' * g'_ij'):simplifyMetrics(), a'^i,m' * g'_ij')",
		comment="",
		duration=0.002985,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="but delta should simplify with commas", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq((a'_,i' * delta'^i_j'):simplifyMetrics(), a'_,j')",
		comment="",
		duration=0.002129,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'^,i' * delta'_i^j'):simplifyMetrics(), a'^,j')",
		comment="",
		duration=0.001842,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'_,im' * delta'^i_j'):simplifyMetrics(), a'_,jm')",
		comment="",
		duration=0.002319,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'^,im' * delta'_i^j'):simplifyMetrics(), a'^,jm')",
		comment="",
		duration=0.002645,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'_i,m' * delta'^i_j'):simplifyMetrics(), a'_j_,m')",
		comment="",
		duration=0.002025,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'^i,m' * delta'_i^j'):simplifyMetrics(), a'^j^,m')",
		comment="",
		duration=0.002187,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="TODO someday:", duration=1.000000000001e-06},
	{code="", comment="allow g_ij to raise/lower the last partial derivative", duration=1.000000000001e-06},
	{code="", comment="allow g_ij to raise/lower any covariant derivatives not enclosed in partial derivatives.", duration=2.000000000002e-06}
}