{
	{
		code="simplifyAssertEq(#{x:eq(0):solve(x)}, 1)",
		comment="",
		duration=0.000525,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(x:eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.000831,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(#{x:eq(1):solve(x)}, 1)",
		comment="",
		duration=0.000267,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(x:eq(1):solve(x), x:eq(1))",
		comment="",
		duration=0.000529,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(#{(x+1):eq(0):solve(x)}, 1)",
		comment="",
		duration=0.000488,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x+1):eq(0):solve(x), x:eq(-1))",
		comment="",
		duration=0.000751,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{
		code="simplifyAssertEq(#{(x^2):eq(1):solve(x)}, 2)",
		comment="",
		duration=0.002306,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x^2):eq(1):solve(x), x:eq(1))",
		comment="",
		duration=0.001449,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x^2):eq(1):solve(x)), x:eq(-1))",
		comment="",
		duration=0.00176,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq(#{(x^2):eq(-1):solve(x)}, 2)",
		comment="",
		duration=0.001036,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x^2):eq(-1):solve(x), x:eq(i))",
		comment="",
		duration=0.001377,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x^2):eq(-1):solve(x)), x:eq(-i))",
		comment="",
		duration=0.001447,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="print((x^2):eq(0):solve(x))",
		comment="",
		duration=0.001314,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "^:Prune:zeroToTheX", "*:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x^2):eq(0):solve(x)}, 2)",
		comment="",
		duration=0.00093500000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x^2):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.001237,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x^2):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.00103,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="same with 3 ...", duration=9.9999999999406e-07},
	{
		code="print((x^3):eq(0):solve(x))",
		comment="",
		duration=0.017523,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:zeroToTheX", "*:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x^3):eq(0):solve(x)}, 3)",
		comment="",
		duration=0.012172,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x^3):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.010333,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x^3):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.012653,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x^3):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.008495,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="same with 4 ...", duration=1.000000000001e-06},
	{
		code="print((x^4):eq(0):solve(x))",
		comment="",
		duration=0.001967,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "^:Prune:zeroToTheX", "*:Prune:apply", "*:Prune:flatten", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x^4):eq(0):solve(x)}, 4)",
		comment="",
		duration=0.002264,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x^4):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.002796,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x^4):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.004597,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x^4):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.001791,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(4, (x^4):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.001769,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="Deterministic order of roots?", duration=1.000000000001e-06},
	{code="", comment="For quadratics it is plus sqrt(discr) first then minus", duration=1.000000000001e-06},
	{code="", comment="For x^n times P(x) it is the zeroes first (TODO how about instead of enumerating all roots, we provide multiplicity, so (x^n):eq(0):solve(x) can return (for n != 0, x=0 n-times)", duration=0},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="distinguish between x*(x^2 + 2x + 1) and (x^3 + 2x^2 + x) , because the solver handles one but not the other", duration=0},
	{
		code="printbr( (x * (x^2 + 2*x + 1)):eq(0):solve(x)  )",
		comment="",
		duration=0.001053,
		simplifyStack={"Init", "*:Prune:apply", "unm:Prune:doubleNegative", "^:Prune:simplifyConstantPowers", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:zeroToTheX", "sqrt:Prune:apply", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x * (x^2 + 2*x + 1)):eq(0):solve(x)}, 3)",
		comment="",
		duration=0.001722,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x * (x^2 + 2*x + 1)):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.001964,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x * (x^2 + 2*x + 1)):eq(0):solve(x)), x:eq(-1))",
		comment="",
		duration=0.001658,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x * (x^2 + 2*x + 1)):eq(0):solve(x)), x:eq(-1))",
		comment="",
		duration=0.001477,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="printbr( (x^3 + 2*x^2 + x):eq(0):solve(x) )",
		comment="",
		duration=0.00093700000000002,
		simplifyStack={"Init", "*:Prune:apply", "unm:Prune:doubleNegative", "^:Prune:simplifyConstantPowers", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:zeroToTheX", "sqrt:Prune:apply", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x^3 + 2*x^2 + x):eq(0):solve(x)}, 3)",
		comment="",
		duration=0.001046,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x * (x^2 + 2*x + 1)):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.001107,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x * (x^2 + 2*x + 1)):eq(0):solve(x)), x:eq(-1))",
		comment="",
		duration=0.000944,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x * (x^2 + 2*x + 1)):eq(0):solve(x)), x:eq(-1))",
		comment="",
		duration=0.001361,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="same with x^3 + x^2 - x", duration=0},
	{
		code="printbr( (x * (x^2 + x - 1)):eq(0):solve(x)  )",
		comment="",
		duration=0.003544,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "^:Prune:simplifyConstantPowers", "*:Prune:apply", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x * (x^2 + x - 1)):eq(0):solve(x)}, 3)",
		comment="",
		duration=0.004194,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x * (x^2 + x - 1)):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.005732,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x * (x^2 + x - 1)):eq(0):solve(x)), x:eq( -(1 + sqrt(5))/2 ))",
		comment="",
		duration=0.006616,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x * (x^2 + x - 1)):eq(0):solve(x)), x:eq( -(1 - sqrt(5))/2 ))",
		comment="",
		duration=0.005475,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "^:Prune:sqrtFix4", "^:Tidy:replacePowerOfFractionWithRoots", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:apply", "*:Prune:flatten", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="printbr( (x^3 + x^2 - x):eq(0):solve(x) )",
		comment="",
		duration=0.00302,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "^:Prune:simplifyConstantPowers", "*:Prune:apply", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x^3 + x^2 - x):eq(0):solve(x)}, 3)",
		comment="",
		duration=0.003468,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x * (x^2 + x - 1)):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.005272,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x * (x^2 + x - 1)):eq(0):solve(x)), x:eq( -(1 + sqrt(5))/2 ))",
		comment="",
		duration=0.005849,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x * (x^2 + x - 1)):eq(0):solve(x)), x:eq( -(1 - sqrt(5))/2 ))",
		comment="",
		duration=0.004902,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "^:Prune:sqrtFix4", "^:Tidy:replacePowerOfFractionWithRoots", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:apply", "*:Prune:flatten", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}